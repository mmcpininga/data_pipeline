/*
**Question 2:**
How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?


Considerations:
- Only receipts with a 'Finished' status were included in the analysis.
- Only users with role = 'CONSUMER' were considered.
- All users must exist in the 'dim_users' table to be included.

Final Response:
- Initially, the most recent month identified was February 2021. However, 
February 2021 had too few receipts (only 16) and no matching brand names. 
- Additionally, there is no available data for December 2020, 
preventing a comparison between January and the prior month.   
- As a result, this query does not return any results due to a lack of two months with scanned receipts from the same brands.
- Ideally, this query should generate a table comparing brand rankings over the last two months, tracking which brands gained or lost popularity.  

Expected Output Example:
+-----------------+------------------+---------------+----------------+----------------+
| recent_month    | previous_month   |  brand_name   |  recent_rank   | previous_rank  |
+-----------------+------------------+---------------+----------------+----------------+
| 2021-01-01      | 2020-12-01       |  KLEENEX      |   1            |   10           |
+-----------------+------------------+---------------+----------------+----------------+

Conclusion:
- If there are valid records for two months, the query will provide a ranking comparison to track brand trends.
- However, in this case, no valid data exists for both months, , making a ranking comparison impossible.  
- Further investigation is needed to determine whether December and February data is missing due to a system issue or reflects actual business trends.  
*/

WITH

-- Get the most recent month in the scanned receipts data
max_month AS (
    SELECT DATE_TRUNC(MAX(DATE(scanned_date)), MONTH) AS latest_month
    FROM {{ ref('fct_receipts_finished') }}
)

-- Get all receipts from the most recent and previous months
, last_receipts_tbl AS (
    SELECT 
        receipt_id,
        DATE_TRUNC(DATE(scanned_date), MONTH) AS scanned_month
    FROM  {{ ref('fct_receipts_finished') }}
    WHERE DATE_TRUNC(DATE(scanned_date), MONTH) IN (
        (SELECT latest_month FROM max_month), 
        (SELECT DATE_SUB(latest_month, INTERVAL 1 MONTH) FROM max_month) 
    )
) 

-- Count unique receipts per brand and rank them within each month
, brand_count AS (
    SELECT
        r.scanned_month
        , b.brand_name
        , COUNT(DISTINCT r.receipt_id) AS receipt_count
        , DENSE_RANK() OVER (
            PARTITION BY r.scanned_month
            ORDER BY COUNT(DISTINCT r.receipt_id) DESC) AS rank_position
    FROM {{ ref('fct_receipt_items') }} i 
    INNER JOIN last_receipts_tbl r
    ON i.receipt_id = r.receipt_id
    INNER JOIN {{ ref('dim_brands') }} b
    ON i.brand_code_adj = b.brand_code 
    GROUP BY r.scanned_month, brand_name
)

-- Compare rankings of the top 5 brands from the recent and previous months
SELECT
   brand_name
   , MAX(scanned_month) AS recent_month
   , MIN(scanned_month) AS previous_month
   , MAX(CASE WHEN scanned_month = (SELECT MAX(scanned_month) FROM last_receipts_tbl) THEN rank_position END) AS recent_rank
   , MAX(CASE WHEN scanned_month = (SELECT MIN(scanned_month) FROM last_receipts_tbl) THEN rank_position END) AS previous_rank
FROM brand_count
GROUP BY brand_name
HAVING recent_rank <= 5
ORDER BY recent_rank ASC
