# CLAUDE.md

## Overview

GitHub Traffic insights dashboard for a user's public repositories. A
scheduled GitHub Actions workflow collects views/clones via the GitHub API
(beyond GitHub's 14-day retention window), and two consumers render it:
a static Mermaid snapshot embedded in `README.md`, and a live interactive
Chart.js dashboard at `docs/index.html` (published via GitHub Pages). No
backend, no build step, no package manifest — pure shell scripts +
`jq` + a static HTML/JS page.

## Commands

```bash
shellcheck scripts/*.sh   # lint (mirrors .github/workflows/lint.yml)

# Manual local run (needs `gh` authenticated and GH_TOKEN with
# Administration: Read-only on the target repos):
bash scripts/collect.sh          # updates data/traffic.json
bash scripts/generate-charts.sh  # regenerates the README Mermaid block from traffic.json
```

There is no test suite — `shellcheck` is the only CI gate besides the
scheduled `collect.yml` workflow succeeding in production.

## Architecture

- `scripts/collect.sh` — single source of truth for "which repos are in
  scope": `gh api users/<owner>/repos?type=public&per_page=100` (the
  `IMPORTANT` comment block right above that line is the whole public-only
  invariant this repo depends on — see SECURITY.md's "Public-only
  invariant" section before touching it). Also reconciles repo renames
  (GitHub's 301-redirect on a
  renamed repo) by merging the old name's history into the new one in
  `data/traffic.json`, but only when the resolved new name is itself still
  in the public list.
- `data/traffic.json` — the single persisted state file: `{updated_at,
  owner, views: {repo: {timestamp: {count, uniques}}}, clones: {...}}`.
  Merged (not overwritten) on every collection run via `jq`'s `*` (object
  merge) operator, which is how history survives beyond GitHub's 14-day
  traffic API window.
- `scripts/generate-charts.sh` — reads `data/traffic.json`, emits four
  Mermaid `xychart-beta` blocks (views-by-repo, daily views, daily ranking,
  clones-by-repo) plus a repositories table, and splices them into
  `README.md` between the `<!-- CHARTS:START -->`/`<!-- CHARTS:END -->`
  markers (via `awk`). Falls back to inserting before `## Roadmap`, or
  appending, if the markers aren't present yet.
- `docs/index.html` — the live GitHub Pages dashboard. Fetches
  `data/traffic.json` client-side and renders it with Chart.js 4.4.1 (CDN,
  SRI-pinned — see SECURITY.md's "Frontend supply chain" section before
  changing the CDN URL or version). This is a **separate** rendering path
  from the README's Mermaid charts — the two can drift in what they show
  and that's expected, not a bug.
- `scripts/screenshot.js` — Playwright captures `docs/index.html` (the live
  Pages URL, not a local file) to `docs/screenshot.png` for the README's
  preview image. Runs *before* the commit-and-push step, loading the live
  Pages URL that still serves the previous run's data (GitHub Pages
  redeploys asynchronously after each push), so it inherently lags one cron
  tick behind (documented in the script's own comment).
- `.github/workflows/collect.yml` — orchestrates collect → generate-charts
  → screenshot → commit-and-push, on a twice-daily cron plus
  `workflow_dispatch`. Uses two distinct credentials (see SECURITY.md's
  "Workflow trust boundaries"): `GH_INSIGHTS_PAT` (read-only Administration,
  for the `gh api` traffic calls) and the implicit `GITHUB_TOKEN` (for the
  final `git push`, which bypasses the `Protect main` ruleset for this bot).

## Conventions

- All third-party Actions are pinned to a full commit SHA with a trailing
  version comment (Dependabot keeps the pin current via PRs) — this is a
  stricter convention than some sibling repos in this author's other
  projects, which pin to a tag; don't relax this repo's pin back to a tag.
- Shell scripts: `set -euo pipefail`, `shellcheck`-clean.
- `SECURITY.md` is the authoritative trust-model document for this repo
  (who can write what, the public-only invariant, workflow credential
  boundaries, frontend supply chain, branch protection state and its
  known gap) — read it before making a security-relevant change, not just
  this file.
