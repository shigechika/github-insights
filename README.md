# github-insights

GitHub Traffic insights dashboard for [shigechika](https://github.com/shigechika) repositories.

## Overview

GitHub only retains traffic data (views & clones) for **14 days**. This project collects and preserves that data daily via GitHub Actions, building long-term traffic history.

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

<!-- CHARTS:START -->
> Last updated: 2026-04-12T05:45:22Z

### Views by Repository

```mermaid
xychart-beta horizontal
    title "Views by Repository (14 days)"
    x-axis ["mcp-stdio", "junos-mcp", "aruba-central-mcp", "keycloak-mcp", "homebrew-tap", "gws-cli", "junos-ops", "macos-ddns6"]
    y-axis "Views"
    bar [202, 90, 86, 85, 82, 73, 64, 30]
```

### Daily Views

```mermaid
xychart-beta horizontal
    title "Daily Views (All Repositories)"
    x-axis ["03-28", "03-29", "03-30", "03-31", "04-01", "04-02", "04-03", "04-04", "04-05", "04-06", "04-07", "04-08", "04-09", "04-10", "04-11", "04-12"]
    y-axis "Views"
    bar [19, 7, 6, 45, 43, 39, 10, 170, 136, 53, 17, 55, 89, 70, 1, 0]
```

### Clones by Repository

```mermaid
xychart-beta horizontal
    title "Clones by Repository (14 days)"
    x-axis ["mcp-stdio", "aruba-central-mcp", "junos-mcp", "homebrew-tap", "keycloak-mcp", "gws-cli", "macos-ddns6", "junos-ops"]
    y-axis "Clones"
    bar [437, 260, 257, 250, 187, 134, 93, 84]
```
<!-- CHARTS:END -->

## Roadmap

- [x] Phase 1: Daily traffic collection via GitHub Actions
- [ ] Phase 2: GitHub Pages + Chart.js stacked area charts
