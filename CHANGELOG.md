# Changelog

## [0.2.0](https://github.com/shigechika/github-insights/compare/v0.1.0...v0.2.0) (2026-07-08)


### Features

* **actions:** auto-refresh README screenshot via Playwright ([#15](https://github.com/shigechika/github-insights/issues/15)) ([ee13408](https://github.com/shigechika/github-insights/commit/ee1340831863cbd2adfcad25193a038fc10b5b5f))
* add Daily Ranking chart ([#24](https://github.com/shigechika/github-insights/issues/24)) ([bb03e7b](https://github.com/shigechika/github-insights/commit/bb03e7b5e36645395697ff81711b1e045acdf6bf))
* add daily traffic collection workflow ([0acd74e](https://github.com/shigechika/github-insights/commit/0acd74eb1007c1c25c22b7acf73f0a277ce7a9cc))
* add mermaid chart generation and fix Node.js 20 warning ([64d1c4e](https://github.com/shigechika/github-insights/commit/64d1c4eea676b2e0a19d504926b70d6ed4a5100e))
* add release-please, CLAUDE.md, and copilot-instructions.md ([#25](https://github.com/shigechika/github-insights/issues/25)) ([515c8e3](https://github.com/shigechika/github-insights/commit/515c8e363c8e9e085719b106fb349723b37609e1))
* add repository links and Insights heading to charts ([486c322](https://github.com/shigechika/github-insights/commit/486c322007c8399376f2eb4ea8b4455f4006cfbd))
* **charts:** publish Insights to GitHub Actions step summary ([#13](https://github.com/shigechika/github-insights/issues/13)) ([7d0a0fd](https://github.com/shigechika/github-insights/commit/7d0a0fd085a014fbac583c76c00aa1f5719f62b4)), closes [#5](https://github.com/shigechika/github-insights/issues/5)
* make owner configurable for fork-friendliness ([a6b1f4e](https://github.com/shigechika/github-insights/commit/a6b1f4e44943f26b527c25cf4c513a325f6387f6))
* move Insights to top, add rename detection and repo descriptions ([91be808](https://github.com/shigechika/github-insights/commit/91be808ec1463f9e983015f7b2289086f381f347))
* **phase2:** add GitHub Pages dashboard with Chart.js ([8cd87ef](https://github.com/shigechika/github-insights/commit/8cd87efa2e95483642879c66b5b1f125307b4b26))
* render Repositories list as a markdown table ([403569b](https://github.com/shigechika/github-insights/commit/403569bfb6af6b9590788f1108eb4079c8380497))
* show actual data range in chart titles ([30b05c0](https://github.com/shigechika/github-insights/commit/30b05c001f3cc68d9a9e449867156329665f45cd))
* sort Repositories table by combined traffic instead of alphabetically ([#18](https://github.com/shigechika/github-insights/issues/18)) ([4fd2fd1](https://github.com/shigechika/github-insights/commit/4fd2fd13cc02eb3c09aaad1911a1fb46801e4f4b))


### Bug Fixes

* keep Daily Views chart readable with a 30-day window and adaptive height ([#20](https://github.com/shigechika/github-insights/issues/20)) ([47e1076](https://github.com/shigechika/github-insights/commit/47e107671e5c5ea1ad3b137b2a6ec62a69c81dea))
* pass GH_TOKEN to Generate charts step and fail loudly on API error ([4e494f4](https://github.com/shigechika/github-insights/commit/4e494f4a763a682b632cf3691b41884ba0cafb6a))
* reduce chart labels and fix daily views duplication ([b10d995](https://github.com/shigechika/github-insights/commit/b10d99563004b902b68fc6846b6b7d3361ceb13f))
* **screenshot:** crop to charts only (drop the long table tail) ([#16](https://github.com/shigechika/github-insights/issues/16)) ([e83137b](https://github.com/shigechika/github-insights/commit/e83137bc03f5043a4e27ddd8127160b2218a93c7))
* upgrade actions/checkout v4 to v6 for Node.js 24 ([05b42aa](https://github.com/shigechika/github-insights/commit/05b42aabab35c797e46fafbaf7ef9adc4ebeeaad))
* use horizontal bar chart for Daily Views too ([e8d0d0a](https://github.com/shigechika/github-insights/commit/e8d0d0a80bd7d91eb3df26e6b2aa2822c84c885b))
* use horizontal bar charts for repository rankings ([389a5f4](https://github.com/shigechika/github-insights/commit/389a5f4bf92386bb37645d2fae1246780376dcaf))


### Refactoring

* **collect:** restrict rename loop to public repos ([#12](https://github.com/shigechika/github-insights/issues/12)) ([42f70da](https://github.com/shigechika/github-insights/commit/42f70da54b7b644a36084d0ae5557f8b74e04c22)), closes [#9](https://github.com/shigechika/github-insights/issues/9)
* dashboard fetches data/traffic.json directly from raw.gh ([c3d9224](https://github.com/shigechika/github-insights/commit/c3d92241d59ffc5a63db5e68c76e58c4abf8fca7))
