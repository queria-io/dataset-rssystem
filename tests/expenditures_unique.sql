-- CSV の行ごとに 1 行
select review_year, line_number
from {{ ref('expenditures') }}
group by all
having count(*) > 1
