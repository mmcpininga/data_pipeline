/*
**Question 1:**
What are the top 5 brands by receipts scanned for most recent month?


Considerations:
- Only receipts with a 'Finished' status were included in the analysis.
- Only users with role = 'CONSUMER' were considered.
- All users must exist in the 'dim_users' table to be included.
- Initially, the most recent month identified was February 2021. However, 
this period had too few receipts (only 16) and no matching brand names. Due to insufficient data,
the analysis was conducted using the previous month (January 2021) instead.

Final Response:
- The top 5 brands based on receipts scanned in January 2021 are: 
+---------------+---------------------------+----------------+
| scanned_month | brand_name                |  rank_position |
+---------------+---------------------------+----------------+
| 2021-01-01    | KLEENEX                   |  1             |
| 2021-01-01    | KNORR                     |  2             |
| 2021-01-01    | PEPSI                     |  2             |
| 2021-01-01    | KRAFT                     |  3             |
| 2021-01-01    | RICE A RONI               |  4             |
| 2021-01-01    | DORITOS                   |  4             |
| 2021-01-01    | SWANSON                   |  5             |
| 2021-01-01    | YUBAN COFFEE              |  5             |
| 2021-01-01    | TOSTITOS                  |  5             |
| 2021-01-01    | DOLE CHILLED FRUIT JUICES |  5             |
+---------------+---------------------------+----------------+

Conclusion:
- Since there was insufficient data in February 2021, the analysis was based on January 2021, 
where more meaningful insights could be extracted.

*/

WITH

-- Get the most recent month in the scanned receipts data
max_month AS (
    SELECT DATE_TRUNC(MAX(DATE(scanned_date)), MONTH) AS latest_month
    FROM {{ ref('fct_receipts_finished') }}
)

-- Get all receipts from the most recent month
, last_receipts_tbl AS (
    SELECT 
        receipt_id,
        DATE_TRUNC(DATE(scanned_date), MONTH) AS scanned_month
    FROM {{ ref('fct_receipts_finished') }}
    -- Commented due to explanation in the above considerations
    -- WHERE DATE_TRUNC(DATE(scanned_date), MONTH) = (
    --     SELECT latest_month FROM max_month
    -- )
)

-- Count unique receipts per brand and rank them within each month
, brand_count AS (
    SELECT
        r.scanned_month
        , b.brand_name
        , DENSE_RANK() OVER (
            PARTITION BY r.scanned_month ORDER BY COUNT(DISTINCT r.receipt_id) DESC) AS rank_position
    FROM {{ ref('fct_receipt_items') }} i 
    INNER JOIN last_receipts_tbl r
    ON i.receipt_id = r.receipt_id
    INNER JOIN {{ ref('dim_brands') }} b
    ON i.brand_code_adj = b.brand_code 
    GROUP BY r.scanned_month, brand_name
)

-- Get the top 5 brands based on receipt count, ordered by rank
SELECT 
* 
FROM brand_count
WHERE rank_position <= 5
ORDER BY rank_position ASC
