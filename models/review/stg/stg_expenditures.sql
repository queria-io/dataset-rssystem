{# 5-1 支出先_支出情報。CSV は支出先ブロックの行、支出先の行 (支出先の合計支出額)、契約の行が並ぶ。
   行の種類は is_block・is_supplier・is_contract で表す。金額は円 #}

select
    cast(事業年度 as integer) as review_year,
    予算事業ID as project_id,
    cast(行番号 as integer) as line_number,
    支出先ブロック番号 as block_number,
    支出先ブロック名 as block_name,
    cast(trim(支出先の数) as integer) as block_supplier_count,
    事業を行う上での役割 as block_role,
    cast(trim(ブロックの合計支出額) as bigint) as block_amount,
    支出先名 as supplier_name,
    nullif(trim(法人番号), '') as corporate_number,
    所在地 as address,
    法人種別 as corporate_kind,
    cast(その他支出先 as boolean) as other_suppliers,
    cast(trim(支出先の合計支出額) as bigint) as supplier_amount,
    契約概要 as contract_summary,
    cast(trim(金額) as bigint) as amount,
    契約方式等 as contract_method,
    具体的な契約方式等 as contract_method_detail,
    cast(trim(入札者数) as integer) as bidder_count,
    cast(trim(落札率) as double) as winning_bid_rate,
    "一者応札・一者応募又は競争性のない随意契約となった理由及び改善策（支出額10億円以上）" as single_bid_reason,
    cast(その他の契約 as boolean) as other_contracts,
    支出先ブロック名 is not null as is_block,
    支出先の合計支出額 is not null as is_supplier,
    契約概要 is not null or 金額 is not null as is_contract
from {{ ref('raw_expenditures') }}
