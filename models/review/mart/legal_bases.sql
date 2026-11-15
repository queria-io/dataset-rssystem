{# 1-3 のうち根拠法令の一覧。番号のある行だけを取り出す #}

select review_year, project_id, legal_basis_number, law_title, law_num, law_id, article, paragraph, item
from {{ ref('stg_policies_and_laws') }}
where legal_basis_number is not null
