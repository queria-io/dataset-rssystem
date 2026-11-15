{# 1-3 政策・施策、法令等。1 つの CSV に政策・施策、根拠法令、関係する計画・通知等の
   3 つの一覧が横に並んでいる #}

select
    cast(事業年度 as integer) as review_year,
    予算事業ID as project_id,
    cast("番号（政策・施策）" as integer) as policy_number,
    政策所管府省庁_P as policy_ministry,
    政策 as policy,
    施策 as measure,
    "政策・施策URL" as policy_url,
    cast("番号（根拠法令）" as integer) as legal_basis_number,
    法令名 as law_title,
    法令番号 as law_num,
    nullif(法令ID, 'IDなし') as law_id,
    条 as article,
    項 as paragraph,
    "号・号の細分" as item,
    cast("番号（関係する計画・通知等）" as integer) as plan_number,
    計画通知名 as plan_title,
    計画通知等URL as plan_url,
    filename as source_path
from {{ ref('raw_policies_and_laws') }}
