/* TABLA MAESTRA DE LOGÍSTICA
Objetivo: Unir pedidos con productos y calcular Lead Times (tiempos de demora).
*/
SELECT 
    o.order_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    p.product_category_name AS categoria,
    
    -- FECHAS CLAVE
    o.order_purchase_timestamp AS fecha_compra,
    o.order_approved_at AS fecha_aprobacion,
    o.order_delivered_carrier_date AS fecha_despacho,
    o.order_delivered_customer_date AS fecha_entrega_real,
    o.order_estimated_delivery_date AS fecha_entrega_estimada,
    -- CÁLCULO DE TIEMPOS (En días) - BigQuery usa TIMESTAMP_DIFF
    TIMESTAMP_DIFF(o.order_approved_at, o.order_purchase_timestamp, HOUR)/24.0 AS dias_aprobacion,
    TIMESTAMP_DIFF(o.order_delivered_carrier_date, o.order_approved_at, DAY) AS dias_preparacion_bodega,
    TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date, DAY) AS dias_transporte,
    TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS dias_tiempo_total,
    -- STATUS DE ENTREGA (KPI CLAVE)
    TIMESTAMP_DIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date, DAY) AS dias_delta_promesa,
    CASE 
        WHEN TIMESTAMP_DIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date, DAY) >= 0 THEN 'A tiempo'
        ELSE 'Con Retraso'
    END AS status_entrega
FROM `Supply_Chain_Analytics.orders` o
JOIN `Supply_Chain_Analytics.orders_items` oi 
    ON o.order_id = oi.order_id
LEFT JOIN `Supply_Chain_Analytics.product` p 
    ON oi.product_id = p.product_id
WHERE 
    o.order_status = 'delivered' -- Solo nos sirven los entregados para medir tiempos
    AND o.order_delivered_customer_date IS NOT NULL;

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

