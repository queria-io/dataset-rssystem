-- 政策・施策は事業ごとの番号で一意
select review_year, project_id, policy_number
from {{ ref('policies') }}
group by all
having count(*) > 1
