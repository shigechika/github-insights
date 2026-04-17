#!/bin/bash
set -euo pipefail

# Collect GitHub Traffic data (views & clones) for all public repositories
# and merge into data/traffic.json, preserving historical data beyond
# GitHub's 14-day retention window.

OWNER="${GITHUB_REPOSITORY_OWNER:-shigechika}"
DATA_FILE="data/traffic.json"

# Initialize data file if missing
if [[ ! -f "$DATA_FILE" ]]; then
  echo '{"updated_at":"","views":{},"clones":{}}' > "$DATA_FILE"
fi

# Reconcile repository renames.
# GitHub API 301-redirects old names to new ones; the returned .name is the
# canonical current name. Merge any renamed repo's history into the new key.
existing_repos=$(jq -r '[(.views // {} | keys[]), (.clones // {} | keys[])] | unique[]' "$DATA_FILE")
for old_name in $existing_repos; do
  new_name=$(gh api "repos/${OWNER}/${old_name}" --jq '.name' 2>/dev/null || echo "")
  if [[ -n "$new_name" && "$new_name" != "$old_name" ]]; then
    echo "Detected rename: ${old_name} -> ${new_name}"
    jq --arg old "$old_name" --arg new "$new_name" '
        .views[$new]  = ((.views[$new]  // {}) * (.views[$old]  // {}))
      | .clones[$new] = ((.clones[$new] // {}) * (.clones[$old] // {}))
      | del(.views[$old], .clones[$old])
    ' "$DATA_FILE" > tmp.json && mv tmp.json "$DATA_FILE"
  fi
done

# List all public repositories
repos=$(gh api "users/${OWNER}/repos?type=public&per_page=100" --jq '.[].name' | sort)

for repo in $repos; do
  echo "Collecting traffic for ${OWNER}/${repo}..."

  # Fetch views (14-day window from GitHub API)
  views=$(gh api "repos/${OWNER}/${repo}/traffic/views" 2>/dev/null || echo '{"views":[]}')

  # Fetch clones (14-day window from GitHub API)
  clones=$(gh api "repos/${OWNER}/${repo}/traffic/clones" 2>/dev/null || echo '{"clones":[]}')

  # Merge views into existing data (timestamp as key for dedup)
  existing=$(cat "$DATA_FILE")
  existing=$(echo "$existing" | jq --arg repo "$repo" --argjson new_views "$views" '
    .views[$repo] = (
      (.views[$repo] // {}) *
      ($new_views.views // [] | map({(.timestamp): {count, uniques}}) | add // {})
    )
  ')

  # Merge clones into existing data
  existing=$(echo "$existing" | jq --arg repo "$repo" --argjson new_clones "$clones" '
    .clones[$repo] = (
      (.clones[$repo] // {}) *
      ($new_clones.clones // [] | map({(.timestamp): {count, uniques}}) | add // {})
    )
  ')

  echo "$existing" > "$DATA_FILE"
done

# Update timestamp and owner
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg owner "$OWNER" \
  '.updated_at = $ts | .owner = $owner' "$DATA_FILE" > tmp.json \
  && mv tmp.json "$DATA_FILE"

echo "Done. Data saved to ${DATA_FILE}"
