# github-insights

GitHub Traffic insights dashboard for [shigechika](https://github.com/shigechika) repositories.

**Live dashboard**: https://shigechika.github.io/github-insights/

<!-- CHARTS:START -->
## Insights

> Last updated: 2026-04-17T20:10:55Z

### Views by Repository

```mermaid
xychart-beta horizontal
    title "Views by Repository (32 days)"
    x-axis ["mcp-stdio", "github-insights", "aruba-central-mcp", "keycloak-mcp", "gws-mcp", "junos-mcp", "junos-ops", "homebrew-tap"]
    y-axis "Views"
    bar [330, 171, 117, 115, 114, 113, 104, 98]
```

### Daily Views

```mermaid
xychart-beta horizontal
    title "Daily Views (All Repositories)"
    x-axis ["03-28", "03-29", "03-30", "03-31", "04-01", "04-02", "04-03", "04-04", "04-05", "04-06", "04-07", "04-08", "04-09", "04-10", "04-11", "04-12", "04-13", "04-14", "04-15", "04-16", "04-17"]
    y-axis "Views"
    bar [19, 7, 6, 45, 43, 39, 10, 170, 136, 53, 17, 55, 89, 70, 40, 139, 144, 99, 40, 43, 0]
```

### Clones by Repository

```mermaid
xychart-beta horizontal
    title "Clones by Repository (32 days)"
    x-axis ["mcp-stdio", "homebrew-tap", "junos-ops", "junos-mcp", "github-insights", "aruba-central-mcp", "keycloak-mcp", "gws-mcp"]
    y-axis "Clones"
    bar [1094, 788, 594, 530, 514, 429, 317, 311]
```

### Repositories

| Repository | Description |
| --- | --- |
| [aruba-central-mcp](https://github.com/shigechika/aruba-central-mcp) | MCP server for Aruba Central: expose AP, switch, and client status to AI assistants |
| [github-insights](https://github.com/shigechika/github-insights) | GitHub Traffic insights dashboard — aggregates views/clones across a user's public repositories |
| [gws-mcp](https://github.com/shigechika/gws-mcp) | MCP fork of Google Workspace CLI — exposes Drive, Gmail, Calendar, Sheets, Docs, Chat, Admin, and more to AI assistants. Dynamically built from Google Discovery Service. Includes AI agent skills. |
| [homebrew-tap](https://github.com/shigechika/homebrew-tap) | Homebrew tap for junos-ops, mcp-stdio and speedtest-z |
| [junos-mcp](https://github.com/shigechika/junos-mcp) | MCP server for Juniper/JUNOS — show, upgrade with rollback, config push (commit confirmed) with safe dry-run defaults, RSI/SCF collection |
| [junos-ops](https://github.com/shigechika/junos-ops) | Python CLI to automate Juniper/JUNOS operations over NETCONF: model-aware upgrade, rollback, reboot, config push, and RSI/SCF collection |
| [keycloak-mcp](https://github.com/shigechika/keycloak-mcp) | MCP server for the Keycloak Admin REST API — a strong ally for auth troubleshooting: inspect users, sessions, clients, and realm config through AI assistants. |
| [mcp-stdio](https://github.com/shigechika/mcp-stdio) | Stdio-to-HTTP gateway — connects MCP clients to remote HTTP MCP servers |
<!-- CHARTS:END -->

## Overview

GitHub only retains traffic data (views & clones) for **14 days**. This project collects and preserves that data daily via GitHub Actions, building long-term traffic history.

## Features

- **Interactive dashboard**: Stacked area charts (views & clones) on GitHub Pages with 30d / 90d / 1y / All range toggles
- **Cross-repository aggregation**: Unified stats across all public repositories of the owner
- **Rename-aware**: Detects repository renames via GitHub API's 301 redirect and merges history under the new name automatically
- **Long-term retention**: Preserves traffic data beyond GitHub's 14-day window

## How it works

1. **Daily collection**: GitHub Actions runs `scripts/collect.sh` at 00:00 UTC (09:00 JST)
2. **Data storage**: Traffic snapshots are merged into `data/traffic.json`, deduplicating by timestamp
3. **Visualization**: (Phase 2) Stacked area charts via GitHub Pages + Chart.js

## Manual trigger

```bash
gh workflow run collect.yml
```

## Setup

Requires a Fine-grained PAT with **Administration: Read-only** permission, stored as `GH_INSIGHTS_PAT` in repository secrets.

## Roadmap

- [ ] [Phase 3: Make this a template repository](https://github.com/shigechika/github-insights/issues/1)

## License

[MIT](LICENSE) — Originally created by [shigechika/github-insights](https://github.com/shigechika/github-insights)
