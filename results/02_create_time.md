# 2.1. Определение hw_events_time

Запрос: [02_order_by.sql](../sql/02_order_by.sql), блок `2.1`.

```sql
CREATE TABLE takt.hw_events_time
(
    `ended_at` DateTime('UTC') CODEC(Delta(4), ZSTD(1)),
    `user_id` UInt64,
    `track_id` UInt64,
    `country` String,
    `platform` String,
    `app_version` String,
    `played_seconds` UInt32,
    `track_seconds` UInt32
)
ENGINE = MergeTree
ORDER BY ended_at
SETTINGS index_granularity = 8192, index_granularity_bytes = 0
```
