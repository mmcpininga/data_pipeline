# DATA QUALITY ISSUES

This document summarizes key data quality checks performed across the users, brands, receipts, and receipt items datasets
It highlights issues found, decisions made, and adjustments applied in the intermediate (dim/fact) layers to ensure consistency in downstream analysis.

## **1. USERS DATABASE**

### **Data Quality Check: User ID uniqueness and integrity**

- There are 495 total records in the user dataset but only 212 unique `user_id` values, indicating a 57% duplication rate.
- The `user_id` field contain no nulls, meaning all records have a valid identifier.
- These duplicates could suggest that users are allowed to create multiple accounts, or they may reflect redundant system entries.
- In the intermediate layer (`dim_users`), duplicates were removed to maintain consistency in user-level reporting. 

| total_records | unique_records | total_null_id | duplicate_entries |
|:-------------:|:--------------:|:-------------:|:-----------------:|
|      495      |       212      |       0       |       283         |

```
SELECT 
    COUNT(*) AS total_records
    , COUNT(DISTINCT user_id) AS unique_records
    , SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS total_null_id
    , COUNT(*) - COUNT(DISTINCT user_id) AS duplicate_entries
FROM `fetch-453421.data_warehouse.stg_users`
```

### **Data Quality Check: User Roles Distribution**

- Most users (83%) are labeled as `Consumer`, with 82 users (15%) marked as `Fetch-Staff`.
- Only `Consumer` users were considered in the `dim_users` table to reflect end-user behavior in analysis.

|    role     |    count    | 
|:-----------:|:-----------:|
|  CONSUMER   |     413     |
| FETCH-STAFF |     82      |

```
SELECT
    role
    , COUNT(*) AS count
FROM `fetch-453421.data_warehouse.stg_users`
GROUP BY role
```

## **2. BRANDS DATABASE**

### **Data Quality Check: Brand ID uniqueness and integrity**

- No null or duplicate values were found in `brand_id`.
- The dataset is consistent: all 1167 rows are uniquely identified.
- Even though no duplicates were detected at the staging layer, potential duplicate brands were 
proactively removed in the intermediate layer (`dim_brands`) to ensure consistency.

| total_records | unique_records | total_null_id | duplicate_entries |
|:-------------:|:--------------:|:-------------:|:-----------------:|
|     1167      |      1167      |       0       |        0          |

```
SELECT 
    COUNT(*) AS total_records
    , COUNT(DISTINCT brand_id) AS unique_records
    , SUM(CASE WHEN brand_id IS NULL THEN 1 ELSE 0 END) AS total_null_id
    , COUNT(*) - COUNT(DISTINCT brand_id) AS duplicate_entries
FROM `fetch-453421.data_warehouse.stg_brands`
```

### **Data Quality Check: Brand code uniqueness and integrity**

- Among the 1167 records, only 897 brand codes are unique, indicating 270 duplicated values (23%). These duplicates 
were not removed because they have different `brand_id` values making it unclear whether they represent different brands
or redundant entries.
- 234 rows have NULL in `brand_code`, though they include other identifying fields (e.g., brand name, barcode).
- These NULL values were excluded in the intermediate layer (`dim_brands`) to avoid ambiguity in brand attribution.

| total_records | unique_records | total_null_id | duplicate_entries |
|:-------------:|:--------------:|:-------------:|:-----------------:|
|     1167      |       897      |      234      |        270        |

```
SELECT 
    COUNT(*) AS total_records
    , COUNT(DISTINCT brand_code) AS unique_records
    , SUM(CASE WHEN brand_code IS NULL THEN 1 ELSE 0 END) AS total_null_id
    , COUNT(*) - COUNT(DISTINCT brand_code) AS duplicate_entries
FROM `fetch-453421.data_warehouse.stg_brands`
```

### **Data Quality Check: Missing Brand Codes**

- These 234 records do not have a `brand_code` but still contain a brand ID, barcode, and brand name.
- These cases were excluded in the intermediate layer (`dim_brands`).

|          brand_id          |   barcode    | brand_code | brand_category |     brand_name     |
|:--------------------------:|:------------:|:----------:|:--------------:|:------------------:|
|  5332fa7ae4b03c9a25efd229  | 511111402961 |    null    |      null      |       FANTA        |
|  5332f765e4b03c9a25efd120  | 511111003687 |    null    |      null      | GLACEAU FRUITWATER |
|  5332fa75e4b03c9a25efd221  | 511111303015 |    null    |      null      |       DASANI       |

```
SELECT 
    brand_id
    , barcode
    , brand_code
    , brand_category
    , brand_name
FROM `fetch-453421.data_warehouse.stg_brands`
WHERE brand_code IS NULL AND brand_name IS NOT NULL
```

### **Data Quality Check: Fallback usage of barcode as brand code**

- 54 rows use the `barcode` as a fallback for `brand_code`, indicating possible inconsistencies in how brand codes are assigned.
- To ensure consistent joins, a new column `brand_code_adj` was created to use `barcode` when `brand_code` is NULL.

|          brand_id        |    barcode     |   brand_code   |   brand_category  |     brand_name     |
|:------------------------:|:--------------:|:--------------:|:-----------------:|-------------------:|
| 5da608dfa60b87376833e354 |  511111805786  |  511111805786  | HEALTH & WELLNESS |  ONE A DAY® ENERGY |

```
SELECT 
    brand_id
    , barcode
    , brand_code
    , brand_category
    , brand_name
FROM `fetch-453421.data_warehouse.dim_brands`
WHERE brand_code = CAST(barcode AS STRING)
```

## **3. RECEIPTS DATABASE**

### **Data Quality Check: Receipt ID uniqueness and integrity**

- The `receipt_id` field is clean, no nulls or duplicates detected.
- The total records (1119) matches the number of unique receipt IDs, confirming data consistency.
- Still, duplicates were proactively removed in the intermediate layer (`fct_receipts`) to guarantee user-level consistency.

| total_records | unique_records | total_null_id | duplicate_entries |
|:-------------:|:--------------:|:-------------:|:-----------------:|
|     1119      |      1119      |       0       |        0          |

```
SELECT 
    COUNT(*) AS total_records
    , COUNT(DISTINCT receipt_id) AS unique_records
    , SUM(CASE WHEN receipt_id IS NULL THEN 1 ELSE 0 END) AS total_null_id
    , COUNT(*) - COUNT(DISTINCT receipt_id) AS duplicate_entries
FROM `fetch-453421.data_warehouse.stg_receipts`
```

### **Data Quality Check: Receipt Status Distribution**

- Most receipts are in `Finished` status (518 records), meaning they were likely processed and validated.
- Only `Finished` receipts were included in the intermediate table `fct_receipts_finished` for analytical purposes.

| rewards_receipt_status |  count  | 
|:----------------------:|:-------:|
| FINISHED               |   518   |
| SUBMITTED              |   434   |
| REJECTED               |    71   |
| PENDING                |    50   |
| FLAGGED                |    46   |

```
SELECT
    rewards_receipt_status
    , COUNT(*) AS count
FROM `fetch-453421.data_warehouse.stg_receipts`
GROUP BY rewards_receipt_status
```

### **Data Quality Check: Receipts with zero purchased items or zero total spend**

- Some `Finished` receipts have zero purchased items or $0 total spend but still received reward points, suggesting potential inconsistencies in reward calculations or unexpected system behavior.
- These records were retained, as they may require further investigation before deciding on exclusion.

|       receipt_id         |  purchased_item_count | points_earned | total_spent |
|:------------------------:|:---------------------:|:-------------:|:-----------:|
| 6009eb000a7214ada2000003 |          0            |     250       |      0      |

```
SELECT
    receipt_id
    , purchased_item_count
    , points_earned
    , total_spent
FROM `fetch-453421.data_warehouse.fct_receipts_finished`
WHERE purchased_item_count <= 0 OR total_spent <= 0
```

### **Data Quality Check: Receipts without a valid user in the database**

- 148 receipts (13%) are associated with users not found in the `stg_users` table.
- The highest count comes from `Finished` receipts (108 transactions), meaning these receipts were processed 
and validated but have no corresponding user.
- These were excluded in the `fct_receipts_finished` layer to ensure user-link integrity.

| rewards_receipt_status |  total_receipts  | 
|:----------------------:|:----------------:|
| FINISHED               |       108        |
| FLAGGED                |       22         |
| REJECTED               |       14         |
| SUBMITTED              |        3         |
| PENDING                |        1         |

```
SELECT
  rewards_receipt_status
  , COUNT(*) AS total_receipts
FROM `fetch-453421.data_warehouse.stg_receipts`
WHERE user_id NOT IN (
    SELECT DISTINCT user_id FROM `fetch-453421.data_warehouse.stg_users`
    )
GROUP BY rewards_receipt_status
```

## **4. RECEIPTS ITEMS DATABASE**

### **Data Quality Check: Receipt Item ID uniqueness and integrity**

- The `receipt_item_id`  column is clean, with no nulls or duplicates detected.
- All 6941 items records are uniquely identified, with no duplicates detected at the staging layer.
- Even though no duplicates were found initially, potential duplicate receipt items were proactively removed in the 
intermediate layer (`fct_receipt_items`) to ensure consistency across joins and aggregations.

| total_records | unique_records | total_null_id | duplicate_entries |
|:-------------:|:--------------:|:-------------:|:-----------------:|
|     6941      |      6941      |       0       |        0          |

```
SELECT 
    COUNT(*) AS total_records
    , COUNT(DISTINCT receipt_item_id) AS unique_records
    , SUM(CASE WHEN receipt_item_id IS NULL THEN 1 ELSE 0 END) AS total_null_id
    , COUNT(*) - COUNT(DISTINCT receipt_item_id) AS duplicate_entries
FROM `fetch-453421.data_warehouse.stg_receipt_items`
```
