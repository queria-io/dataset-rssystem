-- 支出先の事業は事業概要にある
select e.review_year, e.project_id
from {{ ref('expenditures') }} as e
anti join {{ ref('projects') }} as p using (review_year, project_id)
