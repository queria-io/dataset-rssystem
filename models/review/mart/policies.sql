{# 1-3 のうち政策・施策の一覧。番号のある行だけを取り出す #}

select s.review_year, s.project_id, s.policy_number, s.policy_ministry, s.policy, s.measure, s.policy_url, f.sha256 as source_sha256
from {{ ref('stg_policies_and_laws') }} as s
left join {{ ref('stg_source_file') }} as f on list_contains(f.paths, s.source_path)
where s.policy_number is not null
