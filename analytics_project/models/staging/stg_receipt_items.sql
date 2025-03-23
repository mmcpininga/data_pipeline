SELECT 
    MD5(CONCAT(r._id.oid, SAFE_CAST(item.partnerItemId AS INT64))) AS receipt_item_id
    , r._id.oid AS receipt_id
    , r.userId AS user_id
    , item.metabriteCampaignId AS campaingn_id
    , SAFE_CAST(item.priceAfterCoupon AS FLOAT64) AS price_after_coupon
    , SAFE_CAST(item.deleted AS BOOLEAN) AS deleted
    , SAFE_CAST(item.originalFinalPrice AS FLOAT64) AS original_final_price
    , SAFE_CAST(item.competitiveProduct AS BOOLEAN) AS competitive_product
    , SAFE_CAST(item.pointsEarned AS FLOAT64) AS points_earned
    , SAFE_CAST(item.originalMetaBriteQuantityPurchased AS INT64) AS original_quantity_purchased
    , item.competitorRewardsGroup AS competitor_rewards_group
    , SAFE_CAST(item.itemNumber AS INT64) AS item_number
    , SAFE_CAST(item.originalMetaBriteBarcode AS INT64) AS original_barcode
    , UPPER(item.brandCode) AS brand_code
    , item.rewardsProductPartnerId AS rewards_product_partner_id
    , SAFE_CAST(item.discountedItemPrice AS FLOAT64) AS discounted_item_price
    , item.originalMetaBriteDescription AS original_description
    , item.userFlaggedDescription AS user_flagged_description
    , item.rewardsGroup AS rewards_group
    , item.needsFetchReviewReason AS needs_fetch_review_reason
    , SAFE_CAST(item.userFlaggedQuantity AS INT64) AS user_flagged_quantity
    , item.pointsPayerId AS points_payer_id
    , SAFE_CAST(item.targetPrice AS INT64) AS target_price
    , item.pointsNotAwardedReason AS points_not_awarded_reason
    , SAFE_CAST(item.userFlaggedPrice AS FLOAT64) AS user_flagged_price
    , SAFE_CAST(item.finalPrice AS FLOAT64) AS final_price
    , SAFE_CAST(item.originalMetaBriteItemPrice AS FLOAT64) AS original_item_price
    , SAFE_CAST(item.userFlaggedNewItem AS BOOLEAN) AS user_flagged_new_item
    , SAFE_CAST(item.quantityPurchased AS INT64) AS quantity_purshased
    , SAFE_CAST(item.userFlaggedBarcode AS INT64) AS user_flagged_barcode
    , SAFE_CAST(item.preventTargetGapPoints AS BOOLEAN) AS prevent_target_gap_points
    , SAFE_CAST(item.partnerItemId AS INT64) AS partner_item_id
    , item.barcode AS barcode
    , SAFE_CAST(item.needsFetchReview AS BOOLEAN) AS needs_fetch_review
    , SAFE_CAST(item.itemPrice AS FLOAT64) AS item_price
    , item.originalReceiptItemText AS original_receipt_item_text
    , UPPER(item.description) AS description
    , COALESCE(UPPER(TRIM(item.brandCode)), TRIM(SAFE_CAST(item.barcode AS STRING))) AS brand_code_adj
FROM {{ source('source_external', 'receipts') }} r,
UNNEST(rewardsReceiptItemList) AS item
