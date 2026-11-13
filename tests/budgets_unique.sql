-- 予算年度ごとに 1 行
select review_year, project_id, budget_year
from {{ ref('budgets') }}
group by all
having count(*) > 1
