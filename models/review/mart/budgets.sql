{# 予算年度ごとの合計の行 #}

select s.* exclude (is_total, source_path), f.sha256 as source_sha256
from {{ ref('stg_budget_summaries') }} as s
left join {{ ref('stg_source_file') }} as f on list_contains(f.paths, s.source_path)
where s.is_total
