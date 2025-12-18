


-- 1) ایجاد INDEX
-- برای افزایش سرعت جستجو روی ستون email
CREATE INDEX idx_users_email
ON users(email);


-- 2) ایجاد جدول موقت (TEMP TABLE)
-- برای نگهداری موقت کاربران فعال در طول سشن
CREATE TEMP TABLE temp_active_users AS
SELECT id, name
FROM users
WHERE active = 1;


-- 3) UPSERT (درج یا بروزرسانی همزمان)
-- اگر رکورد وجود داشت آپدیت می‌شود، اگر نبود درج می‌شود
INSERT INTO products (id, name, price)
VALUES (1, 'Laptop', 50000)
ON CONFLICT (id)
DO UPDATE SET price = EXCLUDED.price;


-- 4) CROSS JOIN
-- ساخت تمام حالت‌های ممکن بین رنگ‌ها و سایزها
SELECT c.color, s.size
FROM colors c
CROSS JOIN sizes s;


-- 5) TRIGGER
-- ثبت لاگ بعد از هر بروزرسانی اطلاعات کاربر
CREATE TRIGGER after_user_update
AFTER UPDATE ON users
FOR EACH ROW
INSERT INTO user_logs(user_id, old_name, new_name)
VALUES (OLD.id, OLD.name, NEW.name);


-- 6) EXPLAIN
-- بررسی نحوه اجرای کوئری برای بهینه‌سازی سرعت
EXPLAIN
SELECT * FROM orders
WHERE total_price > 100000;


-- 7) CHECK Constraint
-- جلوگیری از ثبت حقوق کمتر از مقدار مشخص
ALTER TABLE employees
ADD CONSTRAINT chk_salary
CHECK (salary >= 10000);


-- 8) LATERAL JOIN
-- گرفتن آخرین سفارش هر کاربر
SELECT u.name, o.last_order
FROM users u
JOIN LATERAL (
    SELECT order_date AS last_order
    FROM orders
    WHERE orders.user_id = u.id
    ORDER BY order_date DESC
    LIMIT 1
) o ON true;


-- 9) حذف داده‌های تکراری
-- نگه داشتن اولین رکورد و حذف بقیه بر اساس ایمیل
DELETE FROM users
WHERE id IN (
    SELECT id FROM (
        SELECT id,
               ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) rn
        FROM users
    ) t
    WHERE rn > 1
);


-- 10) MERGE
-- همگام‌سازی موجودی انبار با داده‌های جدید
MERGE INTO inventory i
USING new_inventory n
ON i.product_id = n.product_id
WHEN MATCHED THEN
    UPDATE SET i.quantity = n.quantity
WHEN NOT MATCHED THEN
    INSERT (product_id, quantity)
    VALUES (n.product_id, n.quantity);


