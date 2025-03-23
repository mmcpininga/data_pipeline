
SELECT
    r.receipt_id
    , r.user_id
    , r.bonus_points_earned
    , r.bonus_points_earned_reason
    , r.created_date
    , r.scanned_date
    , r.finished_date
    , r.modify_date
    , r.purchase_date
    , r.points_awarded_date
    , r.points_earned 
    , r.purchased_item_count
    , r.rewards_receipt_status
    , r.total_spent
FROM {{ ref('fct_receipts') }} r
INNER JOIN {{ ref('dim_users') }} u
ON r.user_id = u.user_id
WHERE r.rewards_receipt_status IN ('FINISHED')
