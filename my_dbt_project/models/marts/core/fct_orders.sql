{{ config(materialezd= 'table')}}
SELECT * 
FROM {{ ref('int_orders_enriched')}}