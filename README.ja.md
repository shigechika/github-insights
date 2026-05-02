# github-insights

[shigechika](https://github.com/shigechika) リポジトリの GitHub トラフィックインサイト

[English](README.md)

**ライブダッシュボード**: https://shigechika.github.io/github-insights/

[![ダッシュボードのスクリーンショット](docs/screenshot.png)](https://shigechika.github.io/github-insights/)

> 最新チャートと統計は [英語版 README](README.md) をご覧ください（毎日自動更新）。

## 概要

GitHub のトラフィックデータ（閲覧数・クローン数）は **14日間** しか残りません。そこでこの github-insights は GitHub Actions をはじめとする GitHub エコシステムを活用し、毎日データを収集・長期保管して、トラフィックインサイトを自動更新します。

## 機能

- **インタラクティブなダッシュボード**: GitHub Pages 上に閲覧数・クローン数のスタック面グラフを表示。30日・90日・1年・全期間の範囲切り替えに対応
- **複数リポジトリの集約**: あなたのすべてのパブリックリポジトリの統計を一元管理
- **リネーム対応**: GitHub API の 301 リダイレクトでリポジトリのリネームを検出し、履歴を新名称に自動統合
- **長期保存**: GitHub の 14日間を超える統計情報を長期保存
- **テンプレート対応**: 「Use this template」ワンクリックで起動。ダッシュボードは `window.location` からオーナー・リポジトリ名を導出するため、フォークすればコード変更なしで自動設定

## 仕組み

1. **毎日の収集**: GitHub Actions が cron スケジュールで `scripts/collect.sh` を実行
2. **データ保存**: トラフィックのスナップショットをタイムスタンプで重複排除しながら `data/traffic.json` にマージ
3. **可視化**: `docs/index.html` のダッシュボードが `raw.githubusercontent.com` から `data/traffic.json` を取得し、Chart.js でスタック面グラフを描画

## テンプレートとして使う

このリポジトリ上部の **Use this template → Create a new repository** をクリックして、あなたのダッシュボードを作成してください。コピー後の手順：

1. **空データ** をあなたのリポジトリに作成します。
   ```bash
   echo '{"updated_at":"","views":{},"clones":{}}' > data/traffic.json
   git commit -am "chore: reset traffic data"
   git push
   ```
2. **Fine-grained PAT** を作成します（<https://github.com/settings/personal-access-tokens/new>）：
   - **Token name**: 任意の名前（例: `github-insights`）
   - **Repository access**: **All repositories** または **Only select repositories**（Traffic API に必要な Administration 権限は *Public repositories* プリセットでは付与できません）
   - **Permissions → Repository → Administration**: **Read-only**

   > **注意**: 「All repositories」を選択するとプライベートリポジトリにもアクセスできますので **パブリックリポジトリのみ** を取得対象にするため `scripts/collect.sh` で `gh api users/<owner>/repos?type=public` と public リポジトリに限定しリスト取得しています。PAT は Administration 権限ですが **読み取り専用** に限定し必要最小限の権限で Traffic 収集するよう配慮しています。

3. **シークレットトークン** を追加します（名前: `GH_INSIGHTS_PAT`）：Settings → Secrets and variables → Actions → New repository secret
4. **GitHub Pages** を有効化します（Settings → Pages）：
   - Source: **Deploy from a branch**
   - Branch: `main` / Folder: `/docs`
5. **ワークフロー** を手動実行してデータを初期投入します：
   ```bash
   gh workflow run collect.yml
   ```
   数分待ってから `https://<your-username>.github.io/<your-repo>/` を確認してください。

以降は GitHub Actions の cron が自動実行します。1日1回で十分です。スケジュールは `.github/workflows/collect.yml` で調整できます。毎時0分（特に `00:00 UTC`）の実行は遅延したり失敗することがあるので避けてください（[参考: GitHub Docs](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule)）。

## ライセンス

[MIT](LICENSE) — Originally created by [shigechika/github-insights](https://github.com/shigechika/github-insights)
