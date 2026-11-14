{# 5-1 支出先_支出情報。CSV は支出先ブロックの行、支出先の行 (支出先の合計支出額)、契約の行が並ぶ。
   1 行を 1 契約にし、直前のブロックの行と支出先の行の値を持たせる。
   同じ事業に同じブロック番号・支出先名の行が 2 回出ることがあるので、キーではなく行番号で直前の行を取る (asof join)。
   金額は円 #}

with source as (
    select * replace (cast(行番号 as integer) as 行番号)
    from read_csv('data/*/5-1.csv', all_varchar = true)
),

blocks as (
    select 事業年度, 予算事業ID, 支出先ブロック番号, 行番号,
        支出先ブロック名, 支出先の数, 事業を行う上での役割, ブロックの合計支出額
    from source
    where 支出先ブロック名 is not null
),

suppliers as (
    select 事業年度, 予算事業ID, 支出先ブロック番号, 支出先名, 行番号, 支出先の合計支出額
    from source
    where 支出先の合計支出額 is not null
),

contracts as (
    select * from source
    where 契約概要 is not null or 金額 is not null
)

select
    cast(c.事業年度 as integer) as review_year,
    c.予算事業ID as project_id,
    c.行番号 as line_number,
    c.支出先ブロック番号 as block_number,
    b.支出先ブロック名 as block_name,
    cast(trim(b.支出先の数) as integer) as block_supplier_count,
    b.事業を行う上での役割 as block_role,
    cast(trim(b.ブロックの合計支出額) as bigint) as block_amount,
    c.支出先名 as supplier_name,
    nullif(trim(c.法人番号), '') as corporate_number,
    c.所在地 as address,
    c.法人種別 as corporate_kind,
    cast(c.その他支出先 as boolean) as other_suppliers,
    cast(trim(s.支出先の合計支出額) as bigint) as supplier_amount,
    c.契約概要 as contract_summary,
    cast(trim(c.金額) as bigint) as amount,
    c.契約方式等 as contract_method,
    c.具体的な契約方式等 as contract_method_detail,
    cast(trim(c.入札者数) as integer) as bidder_count,
    cast(trim(c.落札率) as double) as winning_bid_rate,
    c."一者応札・一者応募又は競争性のない随意契約となった理由及び改善策（支出額10億円以上）" as single_bid_reason,
    cast(c.その他の契約 as boolean) as other_contracts
from contracts as c
asof left join blocks as b
    on b.事業年度 = c.事業年度 and b.予算事業ID = c.予算事業ID
    and b.支出先ブロック番号 = c.支出先ブロック番号 and b.行番号 < c.行番号
asof left join suppliers as s
    on s.事業年度 = c.事業年度 and s.予算事業ID = c.予算事業ID
    and s.支出先ブロック番号 = c.支出先ブロック番号 and s.支出先名 = c.支出先名
    and s.行番号 < c.行番号
