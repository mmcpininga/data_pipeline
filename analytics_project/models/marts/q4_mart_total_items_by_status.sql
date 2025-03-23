/*
**Question 4:**
When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?


Considerations:
- Since the status 'Accepted' is not explicitly defined, it was assumed that 'Finished' represents accepted receipts.
- Therefore, the analysis compares receipts with 'Finished' vs. 'Rejected'.

Final Response:
- Receipts with 'Finished' status have a higher total count of purchased items (8184) compared to 'Rejected' receipts (173).

+------------------------+----------------------+
| rewards_receipt_status | total_purchased_item |
+------------------------+----------------------+
| FINISHED               | 8184                 |
| REJECTED               | 173                  |
+------------------------+----------------------+

*/

-- Calculate the total number of items purchased for 'Finished' and 'Rejected'
SELECT
    rewards_receipt_status
    , COALESCE(SUM(purchased_item_count), 0) AS total_purchased_item
FROM {{ ref('fct_receipts') }}
WHERE rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY rewards_receipt_status
ORDER BY total_purchased_item DESC
