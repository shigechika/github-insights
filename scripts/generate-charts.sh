#!/bin/bash
set -euo pipefail

# Generate mermaid charts from traffic.json and update README.md

OWNER="${GITHUB_REPOSITORY_OWNER:-shigechika}"
DATA_FILE="data/traffic.json"
README="README.md"

if [[ ! -f "$DATA_FILE" ]]; then
  echo "No data file found. Skipping chart generation."
  exit 0
fi

updated_at=$(jq -r '.updated_at' "$DATA_FILE")

# Calculate data range in days
views_days=$(jq -r '
  [.views | to_entries[].value | keys[]] | unique | sort | if length > 1 then
    ((.[length-1] | split("T")[0] | strptime("%Y-%m-%d") | mktime) -
     (.[0]        | split("T")[0] | strptime("%Y-%m-%d") | mktime)) / 86400 | ceil
  else 0 end
' "$DATA_FILE")

# --- Chart 1: Top repositories by views (bar chart, top 8) ---
views_bar=$(jq -r --arg days "${views_days} days" '
  [.views | to_entries[] | {repo: .key, total: ([.value | to_entries[].value.count] | add)}]
  | sort_by(-.total)
  | [.[] | select(.total > 0)]
  | .[0:8]
  | "xychart-beta horizontal\n    title \"Views by Repository (\($days))\"\n    x-axis ["
    + ([.[].repo] | map("\"" + . + "\"") | join(", "))
    + "]\n    y-axis \"Views\"\n    bar ["
    + ([.[].total | tostring] | join(", "))
    + "]"
' "$DATA_FILE")

# --- Chart 2: Daily views aggregate (bar chart, trim leading zeros) ---
daily_views=$(jq -r '
  [.views | to_entries[].value | to_entries[] | {date: .key, count: .value.count}]
  | group_by(.date)
  | sort_by(.[0].date)
  | map({date: .[0].date, total: ([.[].count] | add)})
  | . as $all
  | (first(range(length) | select($all[.].total > 0)) // 0) as $start
  | .[$start:]
  | "xychart-beta horizontal\n    title \"Daily Views (All Repositories)\"\n    x-axis ["
    + ([.[].date | split("T")[0] | .[5:]] | map("\"" + . + "\"") | join(", "))
    + "]\n    y-axis \"Views\"\n    bar ["
    + ([.[].total | tostring] | join(", "))
    + "]"
' "$DATA_FILE")

# --- Chart 3: Top repositories by clones (bar chart, top 8) ---
clones_bar=$(jq -r --arg days "${views_days} days" '
  [.clones | to_entries[] | {repo: .key, total: ([.value | to_entries[].value.count] | add)}]
  | sort_by(-.total)
  | [.[] | select(.total > 0)]
  | .[0:8]
  | if length == 0 then "NONE" else
    "xychart-beta horizontal\n    title \"Clones by Repository (\($days))\"\n    x-axis ["
    + ([.[].repo] | map("\"" + . + "\"") | join(", "))
    + "]\n    y-axis \"Clones\"\n    bar ["
    + ([.[].total | tostring] | join(", "))
    + "]"
  end
' "$DATA_FILE")

# --- Build charts markdown ---
{
  echo "<!-- CHARTS:START -->"
  echo "## Insights"
  echo ""
  echo "> Last updated: ${updated_at}"
  echo ""
  echo "### Views by Repository"
  echo ""
  echo '```mermaid'
  echo -e "$views_bar"
  echo '```'
  echo ""
  echo "### Daily Views"
  echo ""
  echo '```mermaid'
  echo -e "$daily_views"
  echo '```'
  if [[ "$clones_bar" != "NONE" ]]; then
    echo ""
    echo "### Clones by Repository"
    echo ""
    echo '```mermaid'
    echo -e "$clones_bar"
    echo '```'
  fi
  echo ""
  echo "### Repositories"
  echo ""
  # Collect repos from views/clones top 8 each, deduplicate, sort by combined traffic desc
  jq -r '
    ([.views | to_entries[] | {key: .key, value: ([.value | to_entries[].value.count] | add // 0)}] | from_entries) as $vt |
    ([.clones | to_entries[] | {key: .key, value: ([.value | to_entries[].value.count] | add // 0)}] | from_entries) as $ct |
    [
      ([.views | to_entries[] | {repo: .key, total: ([.value | to_entries[].value.count] | add)}]
        | sort_by(-.total) | [.[] | select(.total > 0)] | .[0:8][].repo),
      ([.clones | to_entries[] | {repo: .key, total: ([.value | to_entries[].value.count] | add)}]
        | sort_by(-.total) | [.[] | select(.total > 0)] | .[0:8][].repo)
    ] | unique
    | map({repo: ., total: (($vt[.] // 0) + ($ct[.] // 0))})
    | sort_by(-.total)
    | .[].repo
  ' "$DATA_FILE" | {
    echo "| Repository | Description |"
    echo "| --- | --- |"
    while read -r repo; do
      if ! description=$(gh api "repos/${OWNER}/${repo}" --jq '.description // ""'); then
        echo "ERROR: failed to fetch description for ${OWNER}/${repo}" >&2
        exit 1
      fi
      echo "| [${repo}](https://github.com/${OWNER}/${repo}) | ${description} |"
    done
  }
  echo "<!-- CHARTS:END -->"
} > charts.md

# --- Update README ---
if grep -q "<!-- CHARTS:START -->" "$README"; then
  # Replace between markers using awk
  awk '
    /<!-- CHARTS:START -->/ { skip=1; system("cat charts.md"); next }
    /<!-- CHARTS:END -->/ { skip=0; next }
    !skip { print }
  ' "$README" > tmp_readme.md
  mv tmp_readme.md "$README"
else
  # Insert before ## Roadmap, or append
  if grep -q "## Roadmap" "$README"; then
    awk '
      /^## Roadmap/ { system("cat charts.md"); print ""; }
      { print }
    ' "$README" > tmp_readme.md
    mv tmp_readme.md "$README"
  else
    cat charts.md >> "$README"
  fi
fi

# When running under GitHub Actions, also publish the same Insights block
# to the run's step summary so each cron tick is glanceable from the
# Actions tab without opening README or the dashboard.
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  cat charts.md >> "$GITHUB_STEP_SUMMARY"
fi

rm -f charts.md
echo "Charts updated in ${README}"
