-- 根拠法令は事業ごとの番号で一意
select review_year, project_id, legal_basis_number
from {{ ref('legal_bases') }}
group by all
having count(*) > 1
