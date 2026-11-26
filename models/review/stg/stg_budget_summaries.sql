{# 2-1 予算・執行_サマリ。金額は円。会計区分は内訳の行でも空のことがあるので使わない。
   2025 年度までのシートは、予算年度ごとに合計の行と会計・勘定ごとの内訳の行がある。合計の行は内訳の列 (当初予算・歳出予算現額) が空。
   2026 年度のシートは合計の行が無く、内訳の行それぞれに合計の値が入る。予算年度の無い行は予算の記載が無い事業。
   2026 年度のシートから合計の列名が「（合計）」から「（一般会計・特別会計合計）」に変わり、「翌年度への繰越し」の列が無くなった。
   執行率は 2025 年度までが比率、2026 年度からが百分率なので、比率に統一する #}

select
    cast(事業年度 as integer) as review_year,
    予算事業ID as project_id,
    cast(予算年度 as integer) as budget_year,
    cast(coalesce("当初予算（合計）", "当初予算（一般会計・特別会計合計）") as bigint) as initial_budget,
    cast(coalesce("補正予算（合計）", "補正予算（一般会計・特別会計合計）") as bigint) as supplementary_budget,
    cast(coalesce("前年度からの繰越し（合計）", "前年度から繰越し（一般会計・特別会計合計）") as bigint) as carried_over_from_previous,
    cast(coalesce("予備費等（合計）", "予備費等（一般会計・特別会計合計）") as bigint) as reserve_funds,
    cast(coalesce("計（歳出予算現額合計）", "計（一般会計・特別会計歳出予算現額合計）") as bigint) as current_appropriation,
    cast(coalesce("執行額（合計）", "執行額（一般会計・特別会計合計）") as bigint) as execution_amount,
    cast(執行率 as double) / if(cast(事業年度 as integer) >= 2026, 100, 1) as execution_rate,
    cast("翌年度への繰越し(合計）" as bigint) as carried_over_to_next,
    cast(coalesce("翌年度要求額（合計）", "翌年度要求額（一般会計・特別会計合計）") as bigint) as next_year_request,
    主な増減理由 as change_reason,
    その他特記事項 as remarks,
    if(cast(事業年度 as integer) >= 2026, 予算年度 is not null, 当初予算 is null and 歳出予算現額 is null) as is_total,
    filename as source_path
from {{ ref('raw_budget_summaries') }}
