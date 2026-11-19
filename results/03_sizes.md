# 3.3. Размеры колонок

Запрос: блок `3.3` в [03_codecs.sql](../sql/03_codecs.sql). Размеры указаны в байтах; `compression_ratio` — отношение несжатого размера к сжатому.

| table | column | uncompressed_bytes | compressed_bytes | compression_ratio |
|---|---:|---:|---:|---:|
| hw_codec_mixed | t_delta | 2000000 | 1586160 | 1.26 |
| hw_codec_mixed | t_double_delta | 2000000 | 1962850 | 1.02 |
| hw_codec_mixed | t_zstd | 2000000 | 1543831 | 1.30 |
| hw_codec_ordered | t_delta | 2000000 | 2234 | 895.26 |
| hw_codec_ordered | t_double_delta | 2000000 | 2325 | 860.22 |
| hw_codec_ordered | t_zstd | 2000000 | 1332284 | 1.50 |
