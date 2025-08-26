-- Task E: Joins, Grouping, Operators (Reinforcement)

-- 1. Average Order Value by City (Delivered Only)
-- Output: city, avg_order_value, delivered_orders_count. Order by `avg_order_value` desc. Use `HAVING` to keep cities with at least 2 delivered orders.

SELECT 
    c.city,
    AVG(p.amount) AS avg_order_value,
    COUNT(DISTINCT o.order_id) AS delivered_orders_count
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.payments p ON o.order_id = p.order_id
WHERE o.status = 'delivered'
GROUP BY c.city
HAVING COUNT(DISTINCT o.order_id) >= 2
ORDER BY avg_order_value DESC;

-- 2. Category Mix per Customer
-- For each customer, list categories purchased and the **count of distinct orders** per category. Order by customer and count desc.

SELECT 
    c.customer_id,
    c.full_name,
    p.category,
    COUNT(DISTINCT o.order_id) AS order_count
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE o.status != 'cancelled'
GROUP BY c.customer_id, c.full_name, p.category
ORDER BY c.customer_id, order_count DESC;


-- 3. Set Ops: Overlapping Customers
-- Split customers into two sets: those who bought `Electronics` and those who bought `Fitness`. Show:
-- `UNION` of both sets,
-- `INTERSECT` (bought both),
-- `EXCEPT` (bought Electronics but not Fitness).

-- UNION: Customers who bought Electronics or Fitness
SELECT 
    c.customer_id,
    c.full_name
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Electronics' AND o.status != 'cancelled'
UNION
SELECT 
    c.customer_id,
    c.full_name
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Fitness' AND o.status != 'cancelled'
ORDER BY customer_id;

-- INTERSECT: Customers who bought both Electronics and Fitness
SELECT 
    c.customer_id,
    c.full_name
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = o.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Electronics' AND o.status != 'cancelled'
INTERSECT
SELECT 
    c.customer_id,
    c.full_name
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = o.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Fitness' AND o.status != 'cancelled'
ORDER BY customer_id;

-- EXCEPT: Customers who bought Electronics but not Fitness
SELECT 
    c.customer_id,
    c.full_name
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = o.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Electronics' AND o.status != 'cancelled'
EXCEPT
SELECT 
    c.customer_id,
    c.full_name
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = o.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Fitness' AND o.status != 'cancelled'
ORDER BY customer_id;


