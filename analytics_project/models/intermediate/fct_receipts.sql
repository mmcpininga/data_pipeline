
SELECT 
    r.receipt_id --PK
    , r.user_id --FK
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
FROM {{ ref('stg_receipts') }} r
QUALIFY ROW_NUMBER() OVER(PARTITION BY receipt_id ORDER BY created_date DESC) = 1
