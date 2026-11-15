{# 1-2 基本情報_事業概要等。取得したままの形 #}

select * from read_csv('data/*/1-2.csv', all_varchar = true, filename = true)
