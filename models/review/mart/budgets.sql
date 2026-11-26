{# 予算年度ごとの合計の行。2026 年度のシートは内訳の行ごとに同じ合計の値が入るので、1 行に絞る #}

select s.* exclude (is_total, source_path), f.sha256 as source_sha256
from {{ ref('stg_budget_summaries') }} as s
left join {{ ref('stg_source_file') }} as f on list_contains(f.paths, s.source_path)
where s.is_total
qualify row_number() over (partition by s.review_year, s.project_id, s.budget_year) = 1
