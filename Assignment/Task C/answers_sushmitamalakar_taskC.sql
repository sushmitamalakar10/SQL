-- Task C: Functions

-- 1. Scalar Function: fn_customer_lifetime_value
-- Return total **paid** amount for the customer's delivered/shipped/placed (non-cancelled) orders.

CREATE OR REPLACE FUNCTION training_ecom.fn_customer_lifetime_value(p_customer_id INT)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(p.amount), 0)
        FROM training_ecom.payments p
        JOIN training_ecom.orders o ON p.order_id = o.order_id
        WHERE o.customer_id = p_customer_id
        AND o.status IN ('placed', 'shipped', 'delivered')
    );
END;
$$ LANGUAGE plpgsql;

SELECT training_ecom.fn_customer_lifetime_value(1);


-- 2. Table Function: fn_recent_orders
-- Return `order_id, customer_id, order_date, status, order_total` for orders in the last `p_days` days.

CREATE OR REPLACE FUNCTION training_ecom.fn_recent_orders(p_days INT)
RETURNS TABLE (
    order_id INT,
    customer_id INT,
    order_date TIMESTAMP,
    status VARCHAR,
    order_total NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        SUM(oi.quantity * oi.unit_price) AS order_total
    FROM training_ecom.orders o
    JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 day' * p_days
    AND o.status != 'cancelled'
    GROUP BY o.order_id, o.customer_id, o.order_date, o.status;
END;
$$ LANGUAGE plpgsql;

SELECT * 
FROM training_ecom.fn_recent_orders(100);

-- 3. Utility Function: fn_title_case_city
-- Return city name with first letter of each word capitalized (hint: split/upper/lower or use `initcap()` in PostgreSQL).

CREATE OR REPLACE FUNCTION training_ecom.fn_title_case_city(p_city TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN initcap(p_city);
END;
$$ LANGUAGE plpgsql;

SELECT training_ecom.fn_title_case_city('kathmandu');

