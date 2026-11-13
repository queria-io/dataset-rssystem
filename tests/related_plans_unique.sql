-- 関係する計画・通知等は事業ごとの番号で一意
select review_year, project_id, plan_number
from {{ ref('related_plans') }}
group by all
having count(*) > 1
