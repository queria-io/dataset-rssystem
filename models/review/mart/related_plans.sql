{# 1-3 のうち関係する計画・通知等の一覧。番号のある行だけを取り出す #}

select review_year, project_id, plan_number, plan_title, plan_url
from {{ ref('stg_policies_and_laws') }}
where plan_number is not null
