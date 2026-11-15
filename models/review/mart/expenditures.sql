{# 1 行を 1 契約にし、直前のブロックの行と支出先の行の値を持たせる。
   同じ事業に同じブロック番号・支出先名の行が 2 回出ることがあるので、キーではなく行番号で直前の行を取る (asof join)。
   金額は円 #}

with source as (
    select * from {{ ref('stg_expenditures') }}
),

blocks as (
    select review_year, project_id, block_number, line_number,
        block_name, block_supplier_count, block_role, block_amount
    from source
    where is_block
),

suppliers as (
    select review_year, project_id, block_number, supplier_name, line_number, supplier_amount
    from source
    where is_supplier
),

contracts as (
    select * from source
    where is_contract
)

select
    c.review_year,
    c.project_id,
    c.line_number,
    c.block_number,
    b.block_name,
    b.block_supplier_count,
    b.block_role,
    b.block_amount,
    c.supplier_name,
    c.corporate_number,
    c.address,
    c.corporate_kind,
    c.other_suppliers,
    s.supplier_amount,
    c.contract_summary,
    c.amount,
    c.contract_method,
    c.contract_method_detail,
    c.bidder_count,
    c.winning_bid_rate,
    c.single_bid_reason,
    c.other_contracts,
    f.sha256 as source_sha256
from contracts as c
asof left join blocks as b
    on b.review_year = c.review_year and b.project_id = c.project_id
    and b.block_number = c.block_number and b.line_number < c.line_number
asof left join suppliers as s
    on s.review_year = c.review_year and s.project_id = c.project_id
    and s.block_number = c.block_number and s.supplier_name = c.supplier_name
    and s.line_number < c.line_number
left join {{ ref('stg_source_file') }} as f on list_contains(f.paths, c.source_path)
