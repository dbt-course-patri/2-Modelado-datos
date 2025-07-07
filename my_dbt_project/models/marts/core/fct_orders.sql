{{ config(materialezd= 'incremental',
    unique_key='order_id'
)}}
SELECT order_id,
    customer_id,
    order_date,
    amount
FROM {{ ref('int_orders_enriched')}}

{% if is_incremental()%}
where order_date > (SELECT MAX(order_date)FROM {{this}})
{% endif %}