{# 5-1 支出先_支出情報。取得したままの形 #}

select * from read_csv('data/*/5-1.csv', all_varchar = true)
