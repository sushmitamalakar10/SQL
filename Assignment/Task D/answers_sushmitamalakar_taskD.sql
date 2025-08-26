-- Task D: Procedures

-- 1. sp_apply_category_discount
-- Reduce `unit_price` of **active** products in a category by `p_percent` (e.g., 10 = 10%). Prevent negative or zero prices using a `CHECK` at update time.

CREATE OR REPLACE PROCEDURE training_ecom.sp_apply_category_discount(
    p_category TEXT,
    p_percent NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE training_ecom.products
    SET unit_price = unit_price * (1 - p_percent / 100)
    WHERE category = p_category
      AND active = TRUE
      AND unit_price * (1 - p_percent / 100) > 0;

    IF NOT FOUND THEN
        RAISE NOTICE 'No active products found in category % or discount would result in non-positive prices.', p_category;
    END IF;
END;
$$;

ALTER TABLE training_ecom.products
ADD CONSTRAINT chk_positive_unit_price CHECK (unit_price > 0);

CALL training_ecom.sp_apply_category_discount('Electronics', 10);

SELECT product_id, product_name, category, unit_price
FROM training_ecom.products
WHERE category = 'Electronics';


-- 2. sp_cancel_order
-- Set order `status` to `cancelled` **only if** it is not already `delivered`.
-- (Optional) Delete unpaid `payments` if any exist for that order (there shouldn’t be, but handle

CREATE OR REPLACE PROCEDURE training_ecom.sp_cancel_order(p_order_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE training_ecom.orders
    SET status = 'cancelled'
    WHERE order_id = p_order_id
    AND status != 'delivered';
    
    IF NOT FOUND THEN
        RAISE NOTICE 'Order % not found or already delivered.', p_order_id;
    END IF;
    
    -- Delete any unpaid payments (defensive, should not exist)
    DELETE FROM training_ecom.payments
    WHERE order_id = p_order_id
    AND paid_at IS NULL;
END;
$$;

CALL training_ecom.sp_cancel_order(6);

SELECT order_id, customer_id, status
FROM training_ecom.orders
WHERE order_id = 6;


-- 3. sp_reprice_stale_products
-- For products **not ordered** in the last `p_days`, increase `unit_price` by `p_increase` percent.

CREATE OR REPLACE PROCEDURE training_ecom.sp_reprice_stale_products(p_days INT, p_increase NUMERIC)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE training_ecom.products p
    SET unit_price = unit_price * (1 + p_increase / 100)
    WHERE NOT EXISTS (
        SELECT 1
        FROM training_ecom.order_items oi
        JOIN training_ecom.orders o ON oi.order_id = o.order_id
        WHERE oi.product_id = p.product_id
        AND o.order_date >= CURRENT_DATE - INTERVAL '1 day' * p_days
    )
    AND p.active = TRUE;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'No stale products found in the last % days.', p_days;
    END IF;
END;
$$;

CALL training_ecom.sp_reprice_stale_products(30, 10);

SELECT product_id, product_name, unit_price, active
FROM training_ecom.products
ORDER BY product_id;

