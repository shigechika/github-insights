# Repository overview

`github-insights` is a GitHub Traffic insights dashboard: a scheduled
GitHub Actions workflow (`.github/workflows/collect.yml`) collects
views/clones for a user's public repositories via `gh api`, persists them
in `data/traffic.json` (beyond GitHub's 14-day retention window), and two
consumers render it — a static Mermaid snapshot spliced into `README.md`,
and a live Chart.js dashboard at `docs/index.html` published via GitHub
Pages. No backend, no build step, no distributed package (hence no
`release.yml` publish pipeline in this repo, unlike some sibling repos in
this author's other projects — there is nothing to build or publish beyond
the GitHub Release itself).

See `CLAUDE.md` for the architecture map and **`SECURITY.md` for the
authoritative trust model** — read `SECURITY.md` before reviewing any
change to `scripts/collect.sh`, workflow permissions, or the frontend CDN
dependency; it documents exactly why each boundary exists, not just that
it does.

# Build & validate

```bash
shellcheck scripts/*.sh
```

This mirrors `.github/workflows/lint.yml`, the only CI gate in this repo
(besides the scheduled `collect.yml` workflow succeeding in production —
there is no test suite).

# What to focus review on in this repo

## 1. The public-only filter in `collect.sh` is the entire security boundary — treat any change to it as high-risk

`scripts/collect.sh`'s `gh api users/<owner>/repos?type=public&per_page=100`
call (with its `IMPORTANT` comment block) is the **only** thing preventing
this tool from fetching, storing, or publishing traffic data for private
repositories — the PAT itself (`GH_INSIGHTS_PAT`) may have broader repo
access than this filter grants. Flag any diff that:
- Removes or weakens `?type=public` on that call, or adds a second
  repo-discovery path that doesn't apply the same filter.
- Changes the rename-reconciliation loop's two safety conditions: it must
  skip the rename probe entirely when the old name is still in the current
  public list, and must only apply a detected rename when the resolved new
  name is *also* in the public list. Loosening either condition risks
  reorganizing historical data toward a repo that is no longer public (or
  never was).
- Adds any code path that persists, logs, or returns traffic data for a
  repo not sourced from the `public_repos` variable.

## 2. `data/traffic.json` is merged, never overwritten — a regression here silently deletes history

The entire reason this project exists is preserving traffic data past
GitHub's 14-day API retention. Both `collect.sh`'s views/clones merge steps
use `jq`'s `*` (recursive object merge) against the existing file content —
e.g. `.views[$repo] = ((.views[$repo] // {}) * $new_views...)` — not a
plain assignment. A new or modified merge step that assigns instead of
merges (or that merges at the wrong nesting level, e.g. replacing the whole
per-repo object instead of merging into it) would silently drop historical
timestamps on the next run. Flag any such change and ask for a test/manual
verification against a non-trivial existing `data/traffic.json` sample,
not just an empty-file case.

## 3. Two credentials with different scopes — don't blur the boundary

Per `SECURITY.md`'s "Workflow trust boundaries": `GH_INSIGHTS_PAT`
(read-only Administration, used only for `gh api` traffic/repo-list calls)
and the implicit `GITHUB_TOKEN` (`contents: write`, used only for the final
`git push`) are deliberately separate, least-privilege credentials. Flag
any change that uses `GH_INSIGHTS_PAT` for something other than read-only
`gh api` calls (e.g. a push or a write-scoped API call), or that widens
`collect.yml`'s `permissions:` block beyond what a specific new step
actually needs.

## 4. Frontend CDN dependency is SRI-pinned — a version bump needs a matching integrity hash

`docs/index.html` loads `chart.js` and `chartjs-adapter-date-fns` from
`cdn.jsdelivr.net` with `integrity="sha384-..."` + `crossorigin="anonymous"`.
A diff that bumps either CDN URL's version without recomputing and updating
the matching `integrity` hash breaks Subresource Integrity (the browser
will refuse to load the mismatched file) — this is a correctness bug for
the live dashboard, not just a supply-chain nit. See `SECURITY.md`'s
"Frontend supply chain" section for the exact regeneration command.

## 5. Shell script conventions

- Every script starts `set -euo pipefail`, is `shellcheck`-clean, and
  quotes variable expansions. A new script that doesn't follow this (e.g.
  missing `set -euo pipefail`, unquoted `$var` in a context where word
  splitting/globbing matters) is inconsistent with the existing suite and
  a real robustness gap for a scheduled unattended job.
- All third-party Actions are pinned to a full commit SHA with a trailing
  `# vX.Y.Z` comment (Dependabot keeps the pin current). Flag a new
  workflow step that references an Action by tag/branch instead of a SHA.
- The `concurrency: group: collect-traffic` block in `collect.yml` prevents
  overlapping cron/manual runs from racing on `data/traffic.json`. Flag any
  new workflow that writes to `data/traffic.json` without joining (or
  respecting) that same concurrency group.

# Out of scope for review comments

- There is no test suite in this repo (only `shellcheck` + the workflow
  running successfully in production) — don't ask for unit tests unless
  the PR itself is adding meaningful new logic that would benefit from one.
- The Mermaid charts embedded in `README.md` (via `generate-charts.sh`) and
  the live Chart.js dashboard (`docs/index.html`) are two independently
  maintained rendering paths by design — don't flag them for showing
  slightly different data or update timing as an inconsistency bug.
- `release-please.yml`'s use of `secrets.RELEASE_PLEASE_TOKEN` instead of
  `GITHUB_TOKEN` is intentional — this repo's own `SECURITY.md` documents
  that adding `github-actions[bot]` to the branch-protection bypass list
  failed via the API (issue #7), and a `GITHUB_TOKEN`-authored PR/Release
  also wouldn't trigger downstream workflow runs. Falls back to
  `GITHUB_TOKEN` when the secret is unset so PR CI still passes on forks —
  don't suggest reverting it.
