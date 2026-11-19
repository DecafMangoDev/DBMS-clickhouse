-- 2.1. Подготовка таблиц. Команды выполнять по одной.
DROP TABLE IF EXISTS takt.hw_events_country;
DROP TABLE IF EXISTS takt.hw_events_time;

CREATE TABLE takt.hw_events_time
AS takt.listening_events
ENGINE = MergeTree
ORDER BY (ended_at)
SETTINGS
    index_granularity = 8192,
    index_granularity_bytes = 0;

CREATE TABLE takt.hw_events_country
AS takt.hw_events_time
ENGINE = MergeTree
ORDER BY (country, ended_at)
SETTINGS
    index_granularity = 8192,
    index_granularity_bytes = 0;

INSERT INTO takt.hw_events_time
SELECT *
FROM takt.listening_events
WHERE ended_at >= toDateTime('2026-10-13 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-27 00:00:00', 'UTC');

INSERT INTO takt.hw_events_country
SELECT * FROM takt.hw_events_time;

OPTIMIZE TABLE takt.hw_events_time FINAL;
OPTIMIZE TABLE takt.hw_events_country FINAL;

-- 2.1. Контроль частей и количества событий.
SELECT
    table,
    count() AS active_parts,
    sum(rows) AS events
FROM system.parts
WHERE database = 'takt'
  AND active
  AND table IN ('hw_events_time', 'hw_events_country')
GROUP BY table
ORDER BY table;

-- 2.1. Определения таблиц и ключи сортировки.
SHOW CREATE TABLE takt.hw_events_time;
SHOW CREATE TABLE takt.hw_events_country;

-- 2.2.de_time. Германия, ключ ended_at.
SELECT
    country,
    count() AS events_total,
    countIf(played_seconds < 20) AS events_under_20,
    round(100.0 * events_under_20 / events_total, 2) AS under_20_percent
FROM takt.hw_events_time
WHERE ended_at >= toDateTime('2026-10-24 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-25 00:00:00', 'UTC')
  AND country = 'DE'
GROUP BY country
ORDER BY country
SETTINGS
    max_threads = 4,
    use_query_cache = 0,
    use_query_condition_cache = 0,
    optimize_move_to_prewhere = 0;

-- 2.2.de_country. Германия, ключ (country, ended_at).
SELECT
    country,
    count() AS events_total,
    countIf(played_seconds < 20) AS events_under_20,
    round(100.0 * events_under_20 / events_total, 2) AS under_20_percent
FROM takt.hw_events_country
WHERE ended_at >= toDateTime('2026-10-24 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-25 00:00:00', 'UTC')
  AND country = 'DE'
GROUP BY country
ORDER BY country
SETTINGS
    max_threads = 4,
    use_query_cache = 0,
    use_query_condition_cache = 0,
    optimize_move_to_prewhere = 0;

-- 2.2.all_time. Все страны, ключ ended_at.
SELECT
    country,
    count() AS events_total,
    countIf(played_seconds < 20) AS events_under_20,
    round(100.0 * events_under_20 / events_total, 2) AS under_20_percent
FROM takt.hw_events_time
WHERE ended_at >= toDateTime('2026-10-24 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-25 00:00:00', 'UTC')
GROUP BY country
ORDER BY country
SETTINGS
    max_threads = 4,
    use_query_cache = 0,
    use_query_condition_cache = 0,
    optimize_move_to_prewhere = 0;

-- 2.2.all_country. Все страны, ключ (country, ended_at).
SELECT
    country,
    count() AS events_total,
    countIf(played_seconds < 20) AS events_under_20,
    round(100.0 * events_under_20 / events_total, 2) AS under_20_percent
FROM takt.hw_events_country
WHERE ended_at >= toDateTime('2026-10-24 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-25 00:00:00', 'UTC')
GROUP BY country
ORDER BY country
SETTINGS
    max_threads = 4,
    use_query_cache = 0,
    use_query_condition_cache = 0,
    optimize_move_to_prewhere = 0;

-- 2.2.explain_de_time. План запроса 2.2.de_time.
EXPLAIN indexes = 1
SELECT
    country,
    count() AS events_total,
    countIf(played_seconds < 20) AS events_under_20,
    round(100.0 * events_under_20 / events_total, 2) AS under_20_percent
FROM takt.hw_events_time
WHERE ended_at >= toDateTime('2026-10-24 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-25 00:00:00', 'UTC')
  AND country = 'DE'
GROUP BY country
ORDER BY country
SETTINGS
    max_threads = 4,
    use_query_cache = 0,
    use_query_condition_cache = 0,
    optimize_move_to_prewhere = 0;

-- 2.2.explain_de_country. План запроса 2.2.de_country.
EXPLAIN indexes = 1
SELECT
    country,
    count() AS events_total,
    countIf(played_seconds < 20) AS events_under_20,
    round(100.0 * events_under_20 / events_total, 2) AS under_20_percent
FROM takt.hw_events_country
WHERE ended_at >= toDateTime('2026-10-24 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-25 00:00:00', 'UTC')
  AND country = 'DE'
GROUP BY country
ORDER BY country
SETTINGS
    max_threads = 4,
    use_query_cache = 0,
    use_query_condition_cache = 0,
    optimize_move_to_prewhere = 0;

-- 2.2.explain_all_time. План запроса 2.2.all_time.
EXPLAIN indexes = 1
SELECT
    country,
    count() AS events_total,
    countIf(played_seconds < 20) AS events_under_20,
    round(100.0 * events_under_20 / events_total, 2) AS under_20_percent
FROM takt.hw_events_time
WHERE ended_at >= toDateTime('2026-10-24 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-25 00:00:00', 'UTC')
GROUP BY country
ORDER BY country
SETTINGS
    max_threads = 4,
    use_query_cache = 0,
    use_query_condition_cache = 0,
    optimize_move_to_prewhere = 0;

-- 2.2.explain_all_country. План запроса 2.2.all_country.
EXPLAIN indexes = 1
SELECT
    country,
    count() AS events_total,
    countIf(played_seconds < 20) AS events_under_20,
    round(100.0 * events_under_20 / events_total, 2) AS under_20_percent
FROM takt.hw_events_country
WHERE ended_at >= toDateTime('2026-10-24 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-25 00:00:00', 'UTC')
GROUP BY country
ORDER BY country
SETTINGS
    max_threads = 4,
    use_query_cache = 0,
    use_query_condition_cache = 0,
    optimize_move_to_prewhere = 0;
