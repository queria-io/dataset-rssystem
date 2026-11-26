{# 5-1 支出先_支出情報。取得したままの形。年度によって列名が違うので、列名で縦に並べる #}

select * from read_csv('data/*/5-1.csv', all_varchar = true, filename = true, union_by_name = true)
