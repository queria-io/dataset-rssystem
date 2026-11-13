-- 根拠法令の事業は事業概要にある
select l.review_year, l.project_id
from {{ ref('legal_bases') }} as l
anti join {{ ref('projects') }} as p using (review_year, project_id)
