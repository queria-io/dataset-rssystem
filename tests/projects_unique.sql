-- 1 事業年度に 1 事業 1 行
select review_year, project_id
from {{ ref('projects') }}
group by all
having count(*) > 1
