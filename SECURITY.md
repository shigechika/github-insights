# Security

This document describes the security posture of `github-insights` for both the upstream repository (`shigechika/github-insights`) and forks created via "Use this template".

## Reporting a vulnerability

If you believe you have found a security issue, please report it privately through GitHub's [private vulnerability reporting](https://github.com/shigechika/github-insights/security/advisories/new) instead of opening a public issue. Public reports are also accepted, but private reports are preferred for anything with non-trivial blast radius.

For forks, replace `shigechika/github-insights` with your own repository in the URL above.

## Trust model

### Who can write what

| Actor | Scope |
|---|---|
| Repository owner / collaborators | Push to any branch, modify workflows, settings, secrets |
| `github-actions[bot]` (GITHUB_TOKEN) | Push to `main` (used by the daily cron to update `data/traffic.json` and `README.md`); bypasses the `Protect main` ruleset |
| `GH_INSIGHTS_PAT` (Fine-grained PAT) | Read-only Administration on the owner's repos. Used to call `gh api` for `users/<owner>/repos` and `repos/<owner>/<repo>/traffic/{views,clones}`. Cannot push or modify any repository. |

### Who can read what

| Asset | Visibility |
|---|---|
| Source code, workflows, `data/traffic.json` | Public (this is a public repo) |
| Live dashboard at `https://<owner>.github.io/<repo>/` | Public |
| `GH_INSIGHTS_PAT` | Stored as a repository secret; never echoed by scripts; redacted from Actions logs by GitHub |
| Aggregated traffic counts (views, clones, uniques) | Public via `data/traffic.json` once the workflow commits — fundamentally what this project publishes |

## Public-only invariant

This tool is designed to **never fetch, store, or publish traffic data for private repositories**, even when the PAT happens to have broader access.

The invariant is enforced in `scripts/collect.sh`:

- The list of repos in scope is built once via `gh api users/<owner>/repos?type=public` (`collect.sh:25`). This is the *only* gate; the `IMPORTANT` comment block above that line warns future contributors not to weaken it.
- The data-collection loop iterates over that list (`collect.sh:54`), so traffic API calls only target public repos.
- The rename reconciliation loop (`collect.sh:37–50`) skips probing any repo name that is still in the public list (no rename could have happened), and only honors a detected rename when the resolved new name is also in the public list — so historical data is never reorganized toward a private repo's name even if a private name ever sneaks into `traffic.json`.

The only residual touch on potentially-private repos is the rename probe `gh api repos/<owner>/<old_name>` for names that have left the public list (renamed-away, deleted, or made private). The PAT is read-only Administration, so this is defence-in-depth only — see #9 for the full discussion.

## Workflow trust boundaries

`.github/workflows/collect.yml`:

- Declares `permissions: contents: write` — the minimum needed for the bot's commit-and-push at the end. No other token-scoped permissions.
- Uses two distinct credentials in separate steps:
  - `GH_INSIGHTS_PAT` (env: `GH_TOKEN`) — passed to `bash scripts/collect.sh` and `bash scripts/generate-charts.sh` for `gh api` calls. Read-only Administration.
  - `GITHUB_TOKEN` (implicit via `actions/checkout`) — used by the final `git push`. Scoped to `contents: write` for this run only.
- All third-party Actions are pinned to a full commit SHA (currently `actions/checkout@de0fac2e... # v6.0.2` in both `collect.yml` and `lint.yml`). Dependabot watches for updates.
- A `concurrency: collect-traffic` group prevents overlapping cron and manual runs from racing on `data/traffic.json`.

## Frontend supply chain

`docs/index.html` loads two scripts from `cdn.jsdelivr.net`:

- `chart.js@4.4.1`
- `chartjs-adapter-date-fns@3.0.0`

Both `<script>` tags carry `integrity="sha384-..."` and `crossorigin="anonymous"` attributes. A jsdelivr or NPM compromise that swapped the file at the same URL would be rejected by the browser's Subresource Integrity check.

When upgrading either dependency, regenerate the hash:

```bash
curl -sL https://cdn.jsdelivr.net/npm/chart.js@<new-version>/dist/chart.umd.min.js \
  | openssl dgst -sha384 -binary | openssl base64 -A
```

and update both `src` and `integrity` together.

## Branch protection

`main` is protected by a Repository Ruleset (`Protect main`, id 15561427) with:

- `deletion` blocked — `main` cannot be deleted
- `non_fast_forward` blocked — history rewrite (force push) blocked

Pull-request requirement was deferred because adding `github-actions[bot]` to the bypass list via the API on a personal repo failed validation. It can be added later via the Web UI; see issue #7 for the trail.

## Fork (template) users

When you create a fork via "Use this template", read these notes before going live:

1. **PAT scope**. The setup guide in `README.md` walks through creating a Fine-grained PAT with `Administration: Read-only`. Use **All repositories** or **Only select repositories** — the *Public repositories* preset cannot grant the Administration permission and the workflow will fail. The PAT cannot push or modify anything; it only reads metadata.
2. **Private-repo safety**. Even if your PAT is scoped to "All repositories", `scripts/collect.sh` filters with `?type=public` and never collects traffic from your private repos. Verify by reading the `IMPORTANT` block in `collect.sh:20–24`.
3. **Pages visibility**. Once enabled, `data/traffic.json` is public via `raw.githubusercontent.com`. The data is aggregate counts (views, clones, uniques) for your *own* public repos — this is fundamentally what the project publishes.
4. **Secret name**. The workflow expects the secret to be named `GH_INSIGHTS_PAT`. If you rename it, update `.github/workflows/collect.yml` accordingly.
5. **Branch protection**. The `Protect main` ruleset is per-repository and does not carry across forks. If you want the same protection, recreate it on your fork (UI: Settings → Rules → Rulesets, or via the API as documented in #7).
6. **Rename detection**. If you rename a public repo, history is automatically merged into the new name on the next cron run via the GitHub API's 301 redirect (`scripts/collect.sh:27–50`). No manual intervention needed.

## What's intentionally not in scope

- **Authentication, sessions, user data** — none. The dashboard is read-only and ships no auth code.
- **Server-side state** — none. All persistence lives in `data/traffic.json` in the repo itself; no backend.
- **Third-party tracking, cookies, analytics on the dashboard** — none.
