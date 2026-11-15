{# 予算年度ごとの合計の行 #}

select * exclude (is_total)
from {{ ref('stg_budget_summaries') }}
where is_total
