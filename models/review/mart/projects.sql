{# 1 事業 1 行にまとめ、主要経費をリストにする #}

with projects as (
    select
        review_year,
        project_id,
        project_name,
        sheet_url,
        policy_ministry,
        ministry,
        bureau,
        department,
        division,
        office,
        purpose,
        issues,
        overview,
        overview_url,
        project_category,
        start_year,
        start_year_unknown,
        end_year,
        no_end_year,
        list(distinct major_expense_item order by major_expense_item)
            filter (where major_expense_item is not null) as major_expense_items,
        method_direct,
        method_subsidy,
        method_burden,
        method_grant,
        method_contribution,
        method_other,
        former_project_number,
        notes,
        source_path
    from {{ ref('stg_project_overviews') }}
    group by all
)

select p.* exclude (source_path), f.sha256 as source_sha256
from projects as p
left join {{ ref('stg_source_file') }} as f on list_contains(f.paths, p.source_path)
