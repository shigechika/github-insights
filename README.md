# github-insights

GitHub Traffic insights dashboard for [shigechika](https://github.com/shigechika) repositories.

English | [日本語](README.ja.md)

**Live dashboard**: https://shigechika.github.io/github-insights/

[![Dashboard screenshot](docs/screenshot.png)](https://shigechika.github.io/github-insights/)

<!-- CHARTS:START -->
## Insights

> Last updated: 2026-06-30T10:44:12Z

### Views by Repository

```mermaid
xychart-beta horizontal
    title "Views by Repository (105 days)"
    x-axis ["jquants-mcp", "mcp-stdio", "junos-ops", "gws-mcp", "github-insights", "junos-mcp", "aruba-central-mcp", "keycloak-mcp"]
    y-axis "Views"
    bar [1538, 780, 563, 495, 420, 198, 186, 175]
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
    x-axis ["05-31", "06-01", "06-02", "06-03", "06-04", "06-05", "06-06", "06-07", "06-08", "06-09", "06-10", "06-11", "06-12", "06-13", "06-14", "06-15", "06-16", "06-17", "06-18", "06-19", "06-20", "06-21", "06-22", "06-23", "06-24", "06-25", "06-26", "06-27", "06-28", "06-29"]
    y-axis "Views"
    bar [32, 29, 45, 14, 7, 26, 26, 30, 11, 7, 9, 10, 5, 9, 14, 6, 78, 18, 44, 2, 4, 4, 12, 5, 21, 14, 34, 20, 27, 25]
```

### Clones by Repository

```mermaid
xychart-beta horizontal
    title "Clones by Repository (105 days)"
    x-axis ["jquants-mcp", "mcp-stdio", "gws-mcp", "github-insights", "junos-ops", "homebrew-tap", "keycloak-mcp", "junos-mcp"]
    y-axis "Clones"
    bar [16617, 12060, 4366, 3854, 3404, 3089, 1861, 1631]
```

### Repositories

| Repository | Description |
| --- | --- |
| [jquants-mcp](https://github.com/shigechika/jquants-mcp) | MCP server for Japanese stock market data via J-Quants API — tools for price history, financials, screeners, and candlestick charts |
| [mcp-stdio](https://github.com/shigechika/mcp-stdio) | Stdio-to-HTTP gateway — connects MCP clients to remote HTTP MCP servers |
| [gws-mcp](https://github.com/shigechika/gws-mcp) | MCP fork of Google Workspace CLI — exposes Drive, Gmail, Calendar, Sheets, Docs, Chat, Admin, and more to AI assistants. Dynamically built from Google Discovery Service. Includes AI agent skills. |
| [github-insights](https://github.com/shigechika/github-insights) | GitHub Traffic insights dashboard — aggregates views/clones across a user's public repositories |
| [junos-ops](https://github.com/shigechika/junos-ops) | Python CLI to automate Juniper/JUNOS operations over NETCONF: model-aware upgrade, rollback, reboot, config push, and RSI/SCF collection |
| [homebrew-tap](https://github.com/shigechika/homebrew-tap) | Homebrew tap for junos-ops, mcp-stdio, speedtest-z and gws-mcp. |
| [keycloak-mcp](https://github.com/shigechika/keycloak-mcp) | MCP server for the Keycloak Admin REST API — a strong ally for auth troubleshooting: inspect users, sessions, clients, and realm config through AI assistants. |
| [junos-mcp](https://github.com/shigechika/junos-mcp) | MCP server for Juniper/JUNOS — show, upgrade with rollback, config push (commit confirmed) with safe dry-run defaults, RSI/SCF collection |
| [aruba-central-mcp](https://github.com/shigechika/aruba-central-mcp) | MCP server for Aruba Central: expose AP, switch, and client status to AI assistants |
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

## License

[MIT](LICENSE) — Originally created by [shigechika/github-insights](https://github.com/shigechika/github-insights)
