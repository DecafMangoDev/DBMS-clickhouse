# План 2.2.all_time

Запрос: блок `2.2.explain_all_time` в [02_order_by.sql](../sql/02_order_by.sql).

```text
Expression ((Project names + (Before ORDER BY + Projection) [lifted up part]))
  Sorting (Sorting for ORDER BY)
    Expression ((Before ORDER BY + Projection))
      Aggregating
        Expression (Before GROUP BY)
          Filter ((WHERE + Change column names to column identifiers))
            ReadFromMergeTree (takt.hw_events_time)
            Indexes:
              PrimaryKey
                Keys:
                  ended_at
                Condition: and((ended_at in (-Inf, 1792886399]), (ended_at in [1792800000, +Inf)))
                Parts: 1/1
                Granules: 102/1221
                Search Algorithm: binary search
                Ranges: 1
```
