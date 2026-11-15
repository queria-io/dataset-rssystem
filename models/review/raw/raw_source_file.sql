{# 取得したファイルの記録 (data/source_file.parquet、pipelines/source_file.py が書く)。取得したままの形 #}

select * from read_parquet('data/source_file.parquet')
