{# 1-3 政策・施策、法令等のうち政策・施策の列。1 つの CSV に政策・施策、根拠法令、関係する計画・通知等の
   3 つの一覧が横に並んでいるので、番号のある行だけを取り出す #}

select
    cast(事業年度 as integer) as review_year,
    予算事業ID as project_id,
    cast("番号（政策・施策）" as integer) as policy_number,
    政策所管府省庁_P as policy_ministry,
    政策 as policy,
    施策 as measure,
    "政策・施策URL" as policy_url
from read_csv('data/*/1-3.csv', all_varchar = true)
where "番号（政策・施策）" is not null
