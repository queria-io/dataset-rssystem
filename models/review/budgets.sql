{# 2-1 予算・執行_サマリ。予算年度ごとに合計の行と会計・勘定ごとの内訳の行がある。ここでは合計の行を取る。
   合計の行は内訳の列 (当初予算・歳出予算現額) が空。会計区分は内訳の行でも空のことがあるので使わない。
   金額は円 #}

select
    cast(事業年度 as integer) as review_year,
    予算事業ID as project_id,
    cast(予算年度 as integer) as budget_year,
    cast("当初予算（合計）" as bigint) as initial_budget,
    cast("補正予算（合計）" as bigint) as supplementary_budget,
    cast("前年度からの繰越し（合計）" as bigint) as carried_over_from_previous,
    cast("予備費等（合計）" as bigint) as reserve_funds,
    cast("計（歳出予算現額合計）" as bigint) as current_appropriation,
    cast("執行額（合計）" as bigint) as execution_amount,
    cast(執行率 as double) as execution_rate,
    cast("翌年度への繰越し(合計）" as bigint) as carried_over_to_next,
    cast("翌年度要求額（合計）" as bigint) as next_year_request,
    主な増減理由 as change_reason,
    その他特記事項 as remarks
from read_csv('data/*/2-1.csv', all_varchar = true)
where 当初予算 is null and 歳出予算現額 is null
