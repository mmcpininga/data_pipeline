SELECT 
    brand_id --PK
    , barcode
    , brand_code
    , brand_category
    , brand_category_code
    , cpg_id
    , cpg_ref
    , top_brand
    , COALESCE(brand_name) AS brand_name
FROM {{ ref('stg_brands') }}
WHERE brand_code IS NOT NULL
QUALIFY ROW_NUMBER() OVER(PARTITION BY brand_id) = 1
