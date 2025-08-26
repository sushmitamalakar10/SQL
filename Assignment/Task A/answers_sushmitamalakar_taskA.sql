--Task A: Window Function

--1. **Monthly Customer Rank by Spend**
--For each month (based on `order_date`), rank customers by **total order value** in that month using `RANK()`.
--Output: month (YYYY-MM), customer_id, total_monthly_spend, rank_in_month.

SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,
    c.customer_id,
    SUM(oi.quantity * oi.unit_price) AS total_monthly_spend,
    RANK() OVER (PARTITION BY TO_CHAR(o.order_date, 'YYYY-MM') ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS rank_in_month
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM'), c.customer_id
ORDER BY month, rank_in_month;


-- 2. Share of Basket per Item
--For each order, compute each item's **revenue share** in that order:
--`item_revenue / order_total` using `SUM() OVER (PARTITION BY order_id)`.

SELECT 
    oi.order_id,
    oi.product_id,
    p.product_name,
    (oi.quantity * oi.unit_price) AS item_revenue,
    (oi.quantity * oi.unit_price) / SUM(oi.quantity * oi.unit_price) OVER (PARTITION BY oi.order_id) AS revenue_share
FROM training_ecom.order_items oi
JOIN training_ecom.products p ON oi.product_id = p.product_id
JOIN training_ecom.orders o ON oi.order_id = o.order_id
WHERE o.status != 'cancelled'
ORDER BY oi.order_id, oi.product_id;


-- 3. Time Between Orders (per Customer)
-- Show days since the **previous order** for each customer using `LAG(order_date)` and `AGE()`.

SELECT 
    c.customer_id,
    c.full_name,
    o.order_id,
    o.order_date,
    LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS previous_order_date,
    AGE(o.order_date, LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date)) AS days_since_previous
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
WHERE o.status != 'cancelled'
ORDER BY c.customer_id, o.order_date;

-- 4. Product Revenue Quartiles
-- Compute total revenue per product and assign **quartiles** using `NTILE(4)` over total revenue.

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    NTILE(4) OVER (ORDER BY SUM(oi.quantity * oi.unit_price)) AS revenue_quartile
FROM training_ecom.products p
LEFT JOIN training_ecom.order_items oi ON p.product_id = oi.product_id
LEFT JOIN training_ecom.orders o ON oi.order_id = o.order_id AND o.status != 'cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- 5. First and Last Purchase Category per Customer
 --For each customer, show the **first** and **most recent** product category they've bought using `FIRST_VALUE` and `LAST_VALUE` over `order_date`.

SELECT DISTINCT
    c.customer_id,
    c.full_name,
    FIRST_VALUE(p.category) OVER (PARTITION BY c.customer_id ORDER BY o.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_category,
    LAST_VALUE(p.category) OVER (PARTITION BY c.customer_id ORDER BY o.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_category
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE o.status != 'cancelled'
ORDER BY c.customer_id;
