-- Задание 4. Выполнять по одной команде сверху вниз.
-- Историю и каждую порцию вставлять один раз.
-- Для повторного опыта выполнить весь файл с подготовительного сброса.

-- drop_mv.
DROP VIEW IF EXISTS takt.hw_country_hourly_mv;

-- drop_target.
DROP TABLE IF EXISTS takt.hw_country_hourly;

-- drop_source.
DROP TABLE IF EXISTS takt.hw_mv_events;

-- create_source.
CREATE TABLE takt.hw_mv_events
(
    ended_at DateTime('UTC'),
    country String,
    played_seconds UInt32
)
ENGINE = MergeTree
ORDER BY ended_at;

-- load_source.
INSERT INTO takt.hw_mv_events
SELECT ended_at, country, played_seconds
FROM takt.listening_events
WHERE ended_at >= toDateTime('2026-10-13 00:00:00', 'UTC')
  AND ended_at < toDateTime('2026-10-27 00:00:00', 'UTC');

-- create_target.
CREATE TABLE takt.hw_country_hourly
(
    hour DateTime('UTC'),
    country String,
    events UInt64,
    events_under_20 UInt64,
    total_seconds UInt64
)
ENGINE = SummingMergeTree((events, events_under_20, total_seconds))
ORDER BY (hour, country);

-- source_before.
SELECT count() AS source_events FROM takt.hw_mv_events;

-- create_mv.
CREATE MATERIALIZED VIEW takt.hw_country_hourly_mv
TO takt.hw_country_hourly
AS
SELECT
    toStartOfHour(ended_at) AS hour,
    country,
    count() AS events,
    countIf(played_seconds < 20) AS events_under_20,
    sum(played_seconds) AS total_seconds
FROM takt.hw_mv_events
GROUP BY hour, country;

-- empty_target.
SELECT count() AS stored_rows FROM takt.hw_country_hourly;

-- backfill.
INSERT INTO takt.hw_country_hourly
SELECT
    toStartOfHour(ended_at) AS hour,
    country,
    count() AS events,
    countIf(played_seconds < 20) AS events_under_20,
    sum(played_seconds) AS total_seconds
FROM takt.hw_mv_events
GROUP BY hour, country;

-- control_history.
SELECT
    hour,
    country,
    sum(events_delta) AS events_diff,
    sum(short_delta) AS short_diff,
    sum(seconds_delta) AS seconds_diff
FROM
(
    SELECT
        toStartOfHour(ended_at) AS hour,
        country,
        toInt64(count()) AS events_delta,
        toInt64(countIf(played_seconds < 20)) AS short_delta,
        toInt64(sum(played_seconds)) AS seconds_delta
    FROM takt.hw_mv_events
    GROUP BY hour, country
    UNION ALL
    SELECT
        hour,
        country,
        -toInt64(events),
        -toInt64(events_under_20),
        -toInt64(total_seconds)
    FROM takt.hw_country_hourly
)
GROUP BY hour, country
HAVING events_diff != 0
    OR short_diff != 0
    OR seconds_diff != 0
ORDER BY hour, country;

-- insert_a.
INSERT INTO takt.hw_mv_events
(ended_at, country, played_seconds)
VALUES
('2026-10-27 19:01:00', 'RU', 5),
('2026-10-27 19:02:00', 'RU', 19),
('2026-10-27 19:03:00', 'RU', 20),
('2026-10-27 19:04:00', 'RU', 40),
('2026-10-27 19:05:00', 'KZ', 25);

-- report_a.
SELECT
    hour,
    country,
    sum(events) AS events_count,
    sum(events_under_20) AS short_count,
    sum(total_seconds) AS seconds_sum,
    round(100.0 * short_count / events_count, 2) AS under_20_percent,
    round(seconds_sum / events_count, 2) AS average_seconds
FROM takt.hw_country_hourly
WHERE hour >= toDateTime('2026-10-27 19:00:00', 'UTC')
  AND hour < toDateTime('2026-10-27 21:00:00', 'UTC')
GROUP BY hour, country
ORDER BY hour, country;

-- control_a.
SELECT
    hour,
    country,
    sum(events_delta) AS events_diff,
    sum(short_delta) AS short_diff,
    sum(seconds_delta) AS seconds_diff
FROM
(
    SELECT
        toStartOfHour(ended_at) AS hour,
        country,
        toInt64(count()) AS events_delta,
        toInt64(countIf(played_seconds < 20)) AS short_delta,
        toInt64(sum(played_seconds)) AS seconds_delta
    FROM takt.hw_mv_events
    GROUP BY hour, country
    UNION ALL
    SELECT
        hour,
        country,
        -toInt64(events),
        -toInt64(events_under_20),
        -toInt64(total_seconds)
    FROM takt.hw_country_hourly
)
GROUP BY hour, country
HAVING events_diff != 0
    OR short_diff != 0
    OR seconds_diff != 0
ORDER BY hour, country;

-- historical_before_b.
SELECT
    hour,
    country,
    sum(events) AS events_count,
    sum(events_under_20) AS short_count,
    sum(total_seconds) AS seconds_sum,
    round(100.0 * short_count / events_count, 2) AS under_20_percent,
    round(seconds_sum / events_count, 2) AS average_seconds
FROM takt.hw_country_hourly
WHERE hour >= toDateTime('2026-10-24 12:00:00', 'UTC')
  AND hour < toDateTime('2026-10-24 13:00:00', 'UTC')
  AND country = 'RU'
GROUP BY hour, country
ORDER BY hour, country;

-- insert_b.
INSERT INTO takt.hw_mv_events
(ended_at, country, played_seconds)
VALUES
('2026-10-27 19:00:00', 'RU', 1),
('2026-10-27 20:00:00', 'RU', 10),
('2026-10-24 12:34:00', 'RU', 7);

-- report_b.
SELECT
    hour,
    country,
    sum(events) AS events_count,
    sum(events_under_20) AS short_count,
    sum(total_seconds) AS seconds_sum,
    round(100.0 * short_count / events_count, 2) AS under_20_percent,
    round(seconds_sum / events_count, 2) AS average_seconds
FROM takt.hw_country_hourly
WHERE hour >= toDateTime('2026-10-27 19:00:00', 'UTC')
  AND hour < toDateTime('2026-10-27 21:00:00', 'UTC')
GROUP BY hour, country
ORDER BY hour, country;

-- historical_after_b.
SELECT
    hour,
    country,
    sum(events) AS events_count,
    sum(events_under_20) AS short_count,
    sum(total_seconds) AS seconds_sum,
    round(100.0 * short_count / events_count, 2) AS under_20_percent,
    round(seconds_sum / events_count, 2) AS average_seconds
FROM takt.hw_country_hourly
WHERE hour >= toDateTime('2026-10-24 12:00:00', 'UTC')
  AND hour < toDateTime('2026-10-24 13:00:00', 'UTC')
  AND country = 'RU'
GROUP BY hour, country
ORDER BY hour, country;

-- control_b.
SELECT
    hour,
    country,
    sum(events_delta) AS events_diff,
    sum(short_delta) AS short_diff,
    sum(seconds_delta) AS seconds_diff
FROM
(
    SELECT
        toStartOfHour(ended_at) AS hour,
        country,
        toInt64(count()) AS events_delta,
        toInt64(countIf(played_seconds < 20)) AS short_delta,
        toInt64(sum(played_seconds)) AS seconds_delta
    FROM takt.hw_mv_events
    GROUP BY hour, country
    UNION ALL
    SELECT
        hour,
        country,
        -toInt64(events),
        -toInt64(events_under_20),
        -toInt64(total_seconds)
    FROM takt.hw_country_hourly
)
GROUP BY hour, country
HAVING events_diff != 0
    OR short_diff != 0
    OR seconds_diff != 0
ORDER BY hour, country;

-- source_after.
SELECT count() AS source_events FROM takt.hw_mv_events;
