/*
**Question 6:**
Which brand has the most transactions among users who were created within the past 6 months?


Considerations:
- Only receipts with a 'Finished' status were included in the analysis.
- Only users with role = 'CONSUMER' were considered.
- All users must exist in the 'dim_users' table to be included.
- A six-month period from the latest user creation date in the database (2021-02-12) was considered.

Final Response:
- The brand with the highest number of transactions is KLEENEX,
with 15 transactions among users created in the last six months.

+--------------+---------------+
| brand_name   | receipt_count |
+--------------+---------------+
| KLEENEX      |  15           |
| PEPSI        |  14           |
| KNORR        |  13           |
| KRAFT        |  13           |
| RICE A RONI  |  12           |
| DORITOS      |  12           |
+--------------+---------------+

*/

WITH
-- Get users created within the past 6 months from the latest user creation date
last_users_tbl AS (
    SELECT 
        user_id
    FROM {{ ref('dim_users') }}
    WHERE DATE(created_date) >= (
        SELECT DATE_SUB(DATE_TRUNC(MAX(DATE(created_date)), MONTH), INTERVAL 6 MONTH)
        FROM {{ ref('dim_users') }}
    )
)

-- Calculate the number of transactions per brand among users created in the past 6 months
SELECT
   b.brand_name
   , COUNT(DISTINCT r.receipt_id) AS receipt_count
FROM  {{ ref('fct_receipts_finished') }} r
INNER JOIN last_users_tbl u
ON r.user_id = u.user_id
INNER JOIN {{ ref('fct_receipt_items') }} i
ON r.receipt_id = i.receipt_id
INNER JOIN  {{ ref('dim_brands') }} b
ON i.brand_code_adj = b.brand_code 
GROUP BY b.brand_name
ORDER BY receipt_count DESC
LIMIT 1
