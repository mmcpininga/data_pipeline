/*
**Question 3:**
When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?


Considerations:
- Since the status 'Accepted' is not explicitly defined, it was assumed that 'Finished' represents accepted receipts.
- Therefore, the analysis compares receipts with 'Finished' vs. 'Rejected'.

Final Response:
- Receipts with 'Finished' status have a higher average spend (80.85) compared to 'Rejected' receipts (23.33).

+------------------------+-----------------+
| rewards_receipt_status | avg_total_spend |
+------------------------+-----------------+
| FINISHED               | 80.85           |
| REJECTED               | 23.33           |
+------------------------+-----------------+

*/

-- Calculate the average spend for receipts with 'Finished' and 'Rejected' 
SELECT
    rewards_receipt_status
    , ROUND(COALESCE(AVG(total_spent), 0), 2) AS avg_total_spend
FROM {{ ref('fct_receipts') }}
WHERE rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY rewards_receipt_status
ORDER BY avg_total_spend DESC
