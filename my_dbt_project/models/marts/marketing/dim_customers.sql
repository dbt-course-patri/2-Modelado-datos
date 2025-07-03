{{ config(materialized='table') }}

SELECT DISTINCT
  customer_id,
  name,
  email
FROM {{ ref('stg_customers') }}
