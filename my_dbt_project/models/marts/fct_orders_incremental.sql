{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='sync_all_columns'
    )
}}

SELECT 
    order_id,
    customer_id,
    order_date,
    amount
FROM {{ ref('int_orders_enriched')}}
{% if is_incremental() %}
    WHERE order_date >= (SELECTE MAX(order_date) FROM {{this}})
{% endif %}