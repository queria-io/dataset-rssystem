# ビルドと更新

データセットの概要は [README.md](README.md) にあります。ここにはこのリポジトリでデータセットをビルド・更新する手順を書きます。

## ビルド

```bash
uv sync
uv run python main.py           # 取得して手元で dbt build（profiles.yml の環境変数が要る）
scripts/build.sh                # 取得・ビルドして Queria に公開する
```

rssystem.go.jp は GitHub Actions のランナーからの取得に ZIP の代わりに画面の HTML を返します。Apply が「どの年度の ZIP も取得できなかった」で止まったら、手元で `scripts/build.sh` を実行して公開します。
