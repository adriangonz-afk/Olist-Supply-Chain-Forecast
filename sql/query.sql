/*
Supply Chain Analytics - Core Transformation Script
Description: This query transforms raw Olist order data into a consolidated table
for Power BI analysis. It calculates critical KPIs including Lead Time and Delivery Status
to monitor logistics efficiency.
*/

SELECT
    -- Primary Identifiers for the Star Schema
    o.order_id,
    o.customer_id,
    o.product_id,

    -- Time Dimensions
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- KPI Calculation 1: Actual Lead Time (Days)
    -- Measures the efficiency of the logistics chain from purchase to final handoff.
    TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS lead_time_days,

    -- KPI Calculation 2: Delivery Delay (Days)
    -- Positive values indicate days late; negative values indicate early delivery.
    TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY) AS delay_days,

    -- Business Logic: Delivery Status Classification
    -- Used to calculate the "Late Delivery Rate" KPI in Power BI.
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On Time'
        ELSE 'In Transit'
    END AS delivery_status,

    -- Financial Metrics
    o.price,
    o.freight_value,
    (o.price + o.freight_value) AS total_order_value

FROM
    `brazilian-ecommerce.olist.orders` AS o
    -- Join logic to bring item details (adjust table names based on your BigQuery schema)
    LEFT JOIN `brazilian-ecommerce.olist.order_items` AS i
        ON o.order_id = i.order_id

WHERE
    -- Data Quality Filter:
    -- We only analyze 'delivered' orders to ensure Lead Time accuracy.
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_purchase_timestamp IS NOT NULL;


/* TABLA AGREGADA PARA FORECAST
Objetivo: Contar cuántos pedidos hubo por semana para modelar la demanda.
*/
SELECT
    -- Truncar la fecha al inicio de la semana (Lunes)
    DATE_TRUNC(DATE(order_purchase_timestamp), WEEK) AS semana,
    COUNT(DISTINCT order_id) AS total_pedidos
FROM `Supply_Chain_Analytics.orders`
WHERE 
    order_status = 'delivered'
GROUP BY 1
ORDER BY 1 ASC;

