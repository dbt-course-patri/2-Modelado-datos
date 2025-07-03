SELECT 
o.order_id,
o.customer_id,
c.name,
o.order_date,
o.amount
FROM {{ref('stg_orders')}} o
LEFT JOIN {{ ref('stg_customers')}} c 
ON o.customer_id = c.customer_id