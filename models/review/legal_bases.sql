{# 1-3 政策・施策、法令等のうち根拠法令の列 #}

select
    cast(事業年度 as integer) as review_year,
    予算事業ID as project_id,
    cast("番号（根拠法令）" as integer) as legal_basis_number,
    法令名 as law_title,
    法令番号 as law_num,
    nullif(法令ID, 'IDなし') as law_id,
    条 as article,
    項 as paragraph,
    "号・号の細分" as item
from read_csv('data/*/1-3.csv', all_varchar = true)
where "番号（根拠法令）" is not null
