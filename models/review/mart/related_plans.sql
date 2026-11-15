{# 1-3 のうち関係する計画・通知等の一覧。番号のある行だけを取り出す #}

select s.review_year, s.project_id, s.plan_number, s.plan_title, s.plan_url, f.sha256 as source_sha256
from {{ ref('stg_policies_and_laws') }} as s
left join {{ ref('stg_source_file') }} as f on list_contains(f.paths, s.source_path)
where s.plan_number is not null
