# 行政事業レビュー見える化サイト

内閣官房行政改革推進本部事務局が[行政事業レビュー見える化サイト（RS システム）](https://rssystem.go.jp)で公開する、国の予算事業のレビューシートを SQL で検索できるテーブルにしたデータセットです。全府省庁の予算事業を収録しています。

## 行政事業レビュー（review）

| テーブル | 内容 |
| --- | --- |
| `review.projects` | 1 行が 1 事業年度の 1 予算事業。所管の府省庁・局・課、事業の目的・概要、開始と終了の年度、実施方法 |
| `review.legal_bases` | 1 行が 1 事業の 1 根拠法令。法令名・法令番号・e-Gov の法令 ID・条・項・号 |
| `review.policies` | 1 行が 1 事業の 1 施策。政策評価の政策・施策 |
| `review.related_plans` | 1 行が 1 事業の 1 文書。関係する計画・通知等の名前と URL |
| `review.budgets` | 1 行が 1 事業の 1 予算年度。当初予算・補正予算・歳出予算現額・執行額などの合計（円） |
| `review.expenditures` | 1 行が 1 事業の 1 支出先の 1 契約。支出先ブロック、支出先名・法人番号・所在地、契約概要・金額（円）・契約方式・入札者数・落札率 |

- `review_year`（事業年度）はレビューシートの年度です。今は 2024 年度と 2025 年度のシートがあります
- `project_id`（予算事業 ID）は RS システムが予算事業ごとに付ける ID です。多くの事業は年度をまたいで同じ ID です
- `review.legal_bases.law_id` は e-Gov 法令検索の法令 ID です。`e_gov.laws.laws` と結合できます
- `review.expenditures.corporate_number` は国税庁の法人番号です。ブロックと支出先の合計支出額は契約の行ごとに繰り返し入るので、合計するときは `amount` を足します

## 使い方

国土交通省の予算事業と根拠法令:

```sql
SELECT p.project_name, l.law_title, l.article, b.initial_budget
FROM rssystem.review.projects AS p
JOIN rssystem.review.legal_bases AS l USING (review_year, project_id)
LEFT JOIN rssystem.review.budgets AS b
  ON b.review_year = p.review_year AND b.project_id = p.project_id AND b.budget_year = p.review_year
WHERE p.review_year = 2025 AND p.ministry = '国土交通省'
ORDER BY b.initial_budget DESC NULLS LAST;
```

ある法律を根拠にする事業を府省庁をまたいで検索する:

```sql
SELECT p.ministry, p.project_name, l.article
FROM rssystem.review.legal_bases AS l
JOIN rssystem.review.projects AS p USING (review_year, project_id)
WHERE l.review_year = 2025 AND l.law_id = '332AC0000000177';  -- 水道法
```

一般競争契約で入札者が 1 者だった契約の多い支出先:

```sql
SELECT p.ministry, e.supplier_name, e.corporate_number, count(*) AS contracts, sum(e.amount) AS amount
FROM rssystem.review.expenditures AS e
JOIN rssystem.review.projects AS p USING (review_year, project_id)
WHERE e.review_year = 2025 AND e.contract_method LIKE '一般競争契約%' AND e.bidder_count = 1
GROUP BY ALL
ORDER BY amount DESC;
```

## 出典と利用条件

[CSV データのダウンロード](https://rssystem.go.jp/download-csv)のレビューシートの CSV（1-2 事業概要等、1-3 政策・施策、法令等、2-1 予算・執行_サマリ、5-1 支出先_支出情報）を取得して加工しています。

- 行政事業レビュー見える化サイトのコンテンツは[公共データ利用規約（第1.0版）](https://www.digital.go.jp/resources/open_data/public_data_license_v1.0)に準拠した条件で提供されています（[利用規約](https://rssystem.go.jp/terms)）
- 使うときは「出典：行政事業レビュー見える化サイト（https://rssystem.go.jp）を加工して作成」のように、出典と加工したことを明記してください
- 根拠法令名などは RS システムが e-Gov 法令検索から、法人番号は国税庁法人番号公表サイトから取得した値です。利用規約のとおり、その提供元の利用条件にも従ってください

## 収録範囲の注意

- 基金シートとセグメントシートは含みません
- 予算・執行は予算年度ごとの合計です。会計・勘定ごとの内訳は含みません
- 効果発現経路・点検評価、支出先の費目・使途と国庫債務負担行為等の CSV はまだ取り込んでいません

## ビルド

```bash
uv sync
uv run python main.py           # 取得して手元で dbt build（profiles.yml の環境変数が要る）
scripts/build.sh                # 取得・ビルドして Queria に公開する
```
