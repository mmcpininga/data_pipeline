
SELECT 
    receipt_item_id --PK
    , receipt_id --FK
    , partner_item_id
    , user_id --FK
    , campaingn_id
    , price_after_coupon
    , deleted
    , original_final_price
    , competitive_product
    , points_earned
    , original_quantity_purchased
    , competitor_rewards_group
    , item_number
    , original_barcode
    , brand_code
    , rewards_product_partner_id
    , discounted_item_price
    , original_description
    , user_flagged_description
    , rewards_group
    , needs_fetch_review_reason
    , user_flagged_quantity
    , points_payer_id
    , target_price
    , points_not_awarded_reason
    , user_flagged_price
    , final_price
    , original_item_price
    , user_flagged_new_item
    , quantity_purshased
    , user_flagged_barcode
    , prevent_target_gap_points
    , barcode
    , needs_fetch_review
    , item_price
    , original_receipt_item_text
    , description
    , brand_code_adj
FROM {{ ref('stg_receipt_items') }} 
QUALIFY ROW_NUMBER() OVER(PARTITION BY receipt_item_id) = 1
