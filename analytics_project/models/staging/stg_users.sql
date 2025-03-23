
SELECT 
    _id.oid AS user_id
    , UPPER(state) AS state
    , DATETIME(TIMESTAMP_MILLIS(createdDate.date)) AS created_date
    , DATETIME(TIMESTAMP_MILLIS(lastLogin.date)) AS last_login_date
    , UPPER(role) AS role
    , SAFE_CAST(active AS BOOLEAN) AS active
    , UPPER(signUpSource) AS signup_source
FROM {{ source('source_external', 'users') }}
