{# 1-2 事業概要等。主要経費が複数ある事業は主要経費ごとに行が分かれているので、1 事業 1 行にまとめる #}

with source as (
    select * from read_csv('data/*/1-2.csv', all_varchar = true)
)

select
    cast(事業年度 as integer) as review_year,
    予算事業ID as project_id,
    事業名 as project_name,
    -- シート検索の画面を事業年度と予算事業 ID で絞った URL。検索結果はこの事業のシート 1 件だけになる
    'https://rssystem.go.jp/project?fiscalYear=' || 事業年度
        || '&projectNumbers=' || lpad(予算事業ID, 6, '0') as sheet_url,
    政策所管府省庁 as policy_ministry,
    府省庁 as ministry,
    "局・庁" as bureau,
    部 as department,
    課 as division,
    室 as office,
    事業の目的 as purpose,
    "現状・課題" as issues,
    事業の概要 as overview,
    事業概要URL as overview_url,
    事業区分 as project_category,
    cast(事業開始年度 as integer) as start_year,
    cast(開始年度不明 as boolean) as start_year_unknown,
    cast("事業終了（予定）年度" as integer) as end_year,
    cast(終了予定なし as boolean) as no_end_year,
    list(distinct 主要経費 order by 主要経費) filter (where 主要経費 is not null) as major_expense_items,
    実施方法ー直接実施 is not null as method_direct,
    実施方法ー補助 is not null as method_subsidy,
    実施方法ー負担 is not null as method_burden,
    実施方法ー交付 is not null as method_grant,
    "実施方法ー分担金・拠出金" is not null as method_contribution,
    実施方法ーその他 is not null as method_other,
    旧事業番号 as former_project_number,
    備考 as notes
from source
group by all
