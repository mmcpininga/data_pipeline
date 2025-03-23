SELECT 
    user_id --PK
    , state
    , created_date
    , last_login_date
    , role
    , active
    , signup_source
FROM {{ ref('stg_users') }}
WHERE role = 'CONSUMER'
QUALIFY ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY created_date DESC) = 1
