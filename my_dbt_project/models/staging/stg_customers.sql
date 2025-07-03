-- models/staging/stg_customers.sql

{{config(materialez='view')}}
select
    id as customer_id,
    name,
    email,
    signup_date
from {{source('raw','customers')}}
