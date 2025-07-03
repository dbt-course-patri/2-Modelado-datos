-- models/staging/stg_orders.sql
select
    id as order_id,
    customer_id,
    order_date,
    amount
from raw.orders
