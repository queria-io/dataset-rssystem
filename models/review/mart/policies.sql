{# 1-3 のうち政策・施策の一覧。番号のある行だけを取り出す #}

select review_year, project_id, policy_number, policy_ministry, policy, measure, policy_url
from {{ ref('stg_policies_and_laws') }}
where policy_number is not null
