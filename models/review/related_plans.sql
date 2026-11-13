{# 1-3 政策・施策、法令等のうち関係する計画・通知等の列 #}

select
    cast(事業年度 as integer) as review_year,
    予算事業ID as project_id,
    cast("番号（関係する計画・通知等）" as integer) as plan_number,
    計画通知名 as plan_title,
    計画通知等URL as plan_url
from read_csv('data/*/1-3.csv', all_varchar = true)
where "番号（関係する計画・通知等）" is not null
