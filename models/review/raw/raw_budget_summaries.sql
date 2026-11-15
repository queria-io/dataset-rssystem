{# 2-1 予算・執行_サマリ。取得したままの形 #}

select * from read_csv('data/*/2-1.csv', all_varchar = true, filename = true)
