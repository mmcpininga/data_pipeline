SELECT
    _id.oid AS brand_id
    , barcode AS barcode
    , UPPER(TRIM(brandCode)) AS brand_code
    , UPPER(TRIM(category)) AS brand_category
    , UPPER(TRIM(categoryCode)) AS brand_category_code
    , cpg.id.oid AS cpg_id
    , cpg.ref AS cpg_ref
    , SAFE_CAST(topBrand AS BOOLEAN) AS top_brand 
    , UPPER(TRIM(name)) AS brand_name
FROM {{ source('source_external', 'brands') }}
