# План 2.2.de_country

Запрос: блок `2.2.explain_de_country` в [02_order_by.sql](../sql/02_order_by.sql).

```text
Expression ((Project names + (Before ORDER BY + Projection) [lifted up part]))
  Sorting (Sorting for ORDER BY)
    Expression ((Before ORDER BY + Projection))
      Aggregating
        Expression (Before GROUP BY)
          Filter ((WHERE + Change column names to column identifiers))
            ReadFromMergeTree (takt.hw_events_country)
            Indexes:
              PrimaryKey
                Keys:
                  country
                  ended_at
                Condition: and((country in ['DE', 'DE']), and((ended_at in (-Inf, 1792886399]), (ended_at in [1792800000, +Inf))))
                Parts: 1/1
                Granules: 8/1221
                Search Algorithm: binary search
                Ranges: 1
```
