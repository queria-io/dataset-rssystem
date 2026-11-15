{# 1-3 のうち根拠法令の一覧。番号のある行だけを取り出す #}

select s.review_year, s.project_id, s.legal_basis_number, s.law_title, s.law_num, s.law_id, s.article, s.paragraph, s.item, f.sha256 as source_sha256
from {{ ref('stg_policies_and_laws') }} as s
left join {{ ref('stg_source_file') }} as f on list_contains(f.paths, s.source_path)
where s.legal_basis_number is not null
