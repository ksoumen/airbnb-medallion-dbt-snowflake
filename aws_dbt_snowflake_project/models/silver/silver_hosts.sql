{{ config(materialized = 'incremental', unique_key = 'HOST_ID') }}

SELECT
    HOST_ID,
    REPLACE(HOST_NAME, ' ', '_') AS HOST_NAME,
    HOST_SINCE                 AS HOST_SINCE,
    IS_SUPERHOST                 AS IS_SUPERHOST,
    RESPONSE_RATE                AS RESPONSE_RATE,
    CASE
        WHEN RESPONSE_RATE > 95 THEN 'Very Good'
        WHEN RESPONSE_RATE > 80 THEN 'Good'
        WHEN RESPONSE_RATE > 60 THEN 'Fair'
        ELSE 'Poor'
    END AS RESPONSE_RATE_QUALITY,
    CREATED_AT                   AS CREATED_AT
FROM 
    {{ ref('bronze_hosts') }}