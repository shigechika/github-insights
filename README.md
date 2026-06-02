# github-insights

GitHub Traffic insights dashboard for [shigechika](https://github.com/shigechika) repositories.

English | [日本語](README.ja.md)

**Live dashboard**: https://shigechika.github.io/github-insights/

[![Dashboard screenshot](docs/screenshot.png)](https://shigechika.github.io/github-insights/)

<!-- CHARTS:START -->
## Insights

> Last updated: 2026-06-02T22:09:37Z

### Views by Repository

```mermaid
xychart-beta horizontal
    title "Views by Repository (78 days)"
    x-axis ["jquants-mcp", "mcp-stdio", "gws-mcp", "junos-ops", "github-insights", "junos-mcp", "keycloak-mcp", "aruba-central-mcp"]
    y-axis "Views"
    bar [1456, 651, 482, 437, 400, 173, 170, 168]
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
    x-axis ["05-04", "05-05", "05-06", "05-07", "05-08", "05-09", "05-10", "05-11", "05-12", "05-13", "05-14", "05-15", "05-16", "05-17", "05-18", "05-19", "05-20", "05-21", "05-22", "05-23", "05-24", "05-25", "05-26", "05-27", "05-28", "05-29", "05-30", "05-31", "06-01", "06-02"]
    y-axis "Views"
    bar [28, 85, 91, 191, 355, 163, 129, 14, 23, 4, 10, 22, 33, 146, 91, 32, 39, 26, 29, 115, 41, 64, 115, 62, 65, 11, 8, 32, 29, 0]
```

### Clones by Repository

```mermaid
xychart-beta horizontal
    title "Clones by Repository (78 days)"
    x-axis ["jquants-mcp", "mcp-stdio", "gws-mcp", "github-insights", "junos-ops", "homebrew-tap", "keycloak-mcp", "aruba-central-mcp"]
    y-axis "Clones"
    bar [14199, 10006, 3520, 2805, 2732, 2530, 1356, 1163]
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
| [aruba-central-mcp](https://github.com/shigechika/aruba-central-mcp) | MCP server for Aruba Central: expose AP, switch, and client status to AI assistants |
| [junos-mcp](https://github.com/shigechika/junos-mcp) | MCP server for Juniper/JUNOS — show, upgrade with rollback, config push (commit confirmed) with safe dry-run defaults, RSI/SCF collection |
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
