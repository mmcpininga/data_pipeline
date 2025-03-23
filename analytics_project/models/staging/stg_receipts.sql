SELECT 
    _id.oid AS receipt_id
    , userId AS user_id
    , SAFE_CAST(bonusPointsEarned AS INT64) AS bonus_points_earned
    , bonusPointsEarnedReason AS bonus_points_earned_reason
    , DATETIME(TIMESTAMP_MILLIS(createDate.date)) AS created_date
    , DATETIME(TIMESTAMP_MILLIS(dateScanned.date)) AS scanned_date
    , DATETIME(TIMESTAMP_MILLIS(finishedDate.date)) AS finished_date
    , DATETIME(TIMESTAMP_MILLIS(modifyDate.date)) AS modify_date
    , DATETIME(TIMESTAMP_MILLIS(purchaseDate.date)) AS purchase_date
    , DATETIME(TIMESTAMP_MILLIS(pointsAwardedDate.date)) AS points_awarded_date
    , SAFE_CAST(pointsEarned AS FLOAT64) AS points_earned 
    , SAFE_CAST(purchasedItemCount AS INT64) AS purchased_item_count
    , UPPER(TRIM(rewardsReceiptStatus)) AS rewards_receipt_status
    , SAFE_CAST(totalSpent AS FLOAT64) AS total_spent
FROM {{ source('source_external', 'receipts') }}
