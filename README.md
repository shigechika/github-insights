# github-insights

GitHub Traffic insights dashboard for [shigechika](https://github.com/shigechika) repositories.

English | [日本語](README.ja.md)

**Live dashboard**: https://shigechika.github.io/github-insights/

[![Dashboard screenshot](docs/screenshot.png)](https://shigechika.github.io/github-insights/)

<!-- CHARTS:START -->
## Insights

> Last updated: 2026-08-11T20:21:19Z

### Views by Repository

```mermaid
xychart-beta horizontal
    title "Views by Repository (147 days)"
    x-axis ["jquants-mcp", "mcp-stdio", "junos-ops", "gws-mcp", "github-insights", "keycloak-mcp", "junos-mcp", "eos-mcp"]
    y-axis "Views"
    bar [1940, 1454, 706, 588, 537, 307, 287, 281]
```

### Daily Views

```mermaid
---
config:
  xyChart:
    height: 760
---
xychart-beta horizontal
    title "Daily Views (Last 30 days)"
    x-axis ["07-12", "07-13", "07-14", "07-15", "07-16", "07-17", "07-18", "07-19", "07-20", "07-21", "07-22", "07-23", "07-24", "07-25", "07-26", "07-27", "07-28", "07-29", "07-30", "07-31", "08-01", "08-02", "08-03", "08-04", "08-05", "08-06", "08-07", "08-08", "08-09", "08-10"]
    y-axis "Views"
    bar [249, 30, 31, 14, 25, 74, 66, 25, 24, 18, 45, 54, 261, 43, 33, 13, 12, 57, 19, 78, 55, 57, 17, 10, 10, 125, 69, 119, 102, 123]
```

### Daily Ranking

```mermaid
---
config:
  xyChart:
    height: 300
---
xychart-beta horizontal
    title "Daily Ranking (Top 10 days by views)"
    x-axis ["2026-05-08", "2026-07-24", "2026-07-12", "2026-05-07", "2026-04-04", "2026-05-03", "2026-05-09", "2026-07-08", "2026-04-29", "2026-05-17"]
    y-axis "Views"
    bar [355, 261, 249, 191, 170, 168, 163, 148, 146, 146]
```

### Clones by Repository

```mermaid
xychart-beta horizontal
    title "Clones by Repository (147 days)"
    x-axis ["jquants-mcp", "mcp-stdio", "gws-mcp", "github-insights", "junos-ops", "keycloak-mcp", "homebrew-tap", "junos-mcp"]
    y-axis "Clones"
    bar [21692, 18749, 5067, 4613, 4260, 4188, 3844, 3359]
```

### Repositories

| Repository | Description |
| --- | --- |
| [jquants-mcp](https://github.com/shigechika/jquants-mcp) | MCP server for Japanese stock market data via J-Quants API — tools for price history, financials, screeners, and candlestick charts |
| [mcp-stdio](https://github.com/shigechika/mcp-stdio) | Bidirectional stdio ↔ HTTP gateway for MCP servers — connect clients to remote servers or publish local servers |
| [gws-mcp](https://github.com/shigechika/gws-mcp) | MCP fork of Google Workspace CLI — exposes Drive, Gmail, Calendar, Sheets, Docs, Chat, Admin, and more to AI assistants. Dynamically built from Google Discovery Service. Includes AI agent skills. |
| [github-insights](https://github.com/shigechika/github-insights) | GitHub Traffic insights dashboard — aggregates views/clones across a user's public repositories |
| [junos-ops](https://github.com/shigechika/junos-ops) | Python CLI to automate Juniper/JUNOS operations over NETCONF: model-aware upgrade, rollback, reboot, config push, and RSI/SCF collection |
| [keycloak-mcp](https://github.com/shigechika/keycloak-mcp) | MCP server for the Keycloak Admin REST API — a strong ally for auth troubleshooting: inspect users, sessions, clients, and realm config through AI assistants. |
| [homebrew-tap](https://github.com/shigechika/homebrew-tap) | Homebrew tap for junos-ops, mcp-stdio, speedtest-z and gws-mcp. |
| [junos-mcp](https://github.com/shigechika/junos-mcp) | MCP server for Juniper/JUNOS — show, upgrade with rollback, config push (commit confirmed) with safe dry-run defaults, RSI/SCF collection |
| [eos-mcp](https://github.com/shigechika/eos-mcp) | MCP server for Arista EOS device operations via eAPI |
<!-- CHARTS:END -->

## Overview

GitHub only retains traffic data (views & clones) for **14 days**. github-insights leverages GitHub Actions and the GitHub ecosystem to collect data daily, preserve it long-term, and keep traffic insights automatically up to date.

## Features

- **Interactive dashboard**: Stacked area charts (views & clones) on GitHub Pages with 30d / 90d / 1y / All range toggles
- **Cross-repository aggregation**: Unified stats across all your public repositories
- **Rename-aware**: Detects repository renames via GitHub API's 301 redirect and merges history under the new name automatically
- **Long-term retention**: Preserves traffic data beyond GitHub's 14-day window
- **Template-ready**: One-click "Use this template" — the dashboard derives owner/repo from `window.location`, so a fork self-configures with no code edits

## How it works

1. **Daily collection**: GitHub Actions runs `scripts/collect.sh` on a cron schedule
2. **Data storage**: Traffic snapshots are merged into `data/traffic.json`, deduplicating by timestamp
3. **Visualization**: The dashboard at `docs/index.html` fetches `data/traffic.json` from `raw.githubusercontent.com` and renders stacked area charts with Chart.js

## Use this as a template

Click **Use this template → Create a new repository** at the top of this repo to spin up your own dashboard. After creating your copy:

1. **Reset the data** so the dashboard starts fresh for your account:
   ```bash
   echo '{"updated_at":"","views":{},"clones":{}}' > data/traffic.json
   git commit -am "chore: reset traffic data"
   git push
   ```
2. **Create a Fine-grained PAT** at <https://github.com/settings/personal-access-tokens/new>:
   - **Token name**: anything descriptive, e.g. `github-insights`
   - **Repository access**: **All repositories** or **Only select repositories** (the *Public repositories* preset cannot grant the Administration permission required by the Traffic API)
   - **Permissions → Repository → Administration**: **Read-only**

   > **Note**: Although "All repositories" grants access to your private repos as well, this tool targets **public repositories only** — `scripts/collect.sh` lists them with `gh api users/<owner>/repos?type=public`. The PAT is scoped to **read-only** via the Administration permission, keeping the required access to the minimum necessary.

   After creating the token, check its permissions page against this [example screenshot](docs/pat-permissions-example.png).
3. **Add the token as a secret** named `GH_INSIGHTS_PAT` (Settings → Secrets and variables → Actions → New repository secret).
4. **Enable GitHub Pages** at Settings → Pages:
   - Source: **Deploy from a branch**
   - Branch: `main` / Folder: `/docs`
5. **Run the workflow** once to seed data:
   ```bash
   gh workflow run collect.yml
   ```
   Wait a few minutes, then visit `https://<your-username>.github.io/<your-repo>/`.

After that, the cron runs automatically. Two or three times a day is a good baseline — scheduled runs can occasionally be delayed or fail to trigger entirely, so multiple runs per day ensures data is reliably captured. Adjust the schedule in `.github/workflows/collect.yml` to suit your needs. Avoid scheduling at the top of the hour (especially `00:00 UTC`) as runs can be delayed or fail to fire ([GitHub Docs](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule)).

> **Troubleshooting**: If the workflow fails with `gh: To use GitHub CLI in a GitHub Actions workflow, set the GH_TOKEN environment variable`, the `GH_INSIGHTS_PAT` secret from step 3 above (using the PAT created in step 2) hasn't been added to this repo — or was added under a different name. Check Settings → Secrets and variables → Actions → Repository secrets.

## License

[MIT](LICENSE) — Originally created by [shigechika/github-insights](https://github.com/shigechika/github-insights)
