-- 1. CUSTOMER DEMOGRAPHICS ANALYSIS
-- Analyze customer distribution by gender and age groups
SELECT 
    gender,
    CASE 
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 35 THEN '25-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percentage
FROM customers
GROUP BY gender, age_group
ORDER BY gender, age_group;

-- 2. PRODUCT PERFORMANCE BY CATEGORY
-- Analyze sales performance across product categories
SELECT 
    p.product_category,
    COUNT(*) AS total_transactions,
    SUM(r.quantity) AS total_quantity_sold,
    ROUND(SUM(p.price * r.quantity)::numeric, 2) AS total_revenue,
    ROUND(AVG(p.price)::numeric, 2) AS avg_price,
    ROUND(SUM(p.price * r.quantity) * 100.0 / NULLIF((
        SELECT SUM(p2.price * r2.quantity) 
        FROM products_nw p2 
        JOIN retail_new r2 ON p2.product_id = r2.product_id
    ), 0)::numeric, 2) AS revenue_percentage
FROM products_nw p
JOIN retail_new r ON p.product_id = r.product_id
GROUP BY p.product_category
ORDER BY total_revenue DESC;

-- 3. PAYMENT METHOD ANALYSIS
-- Analyze customer payment preferences and spending patterns
SELECT 
    p.payment_method,
    COUNT(*) AS transaction_count,
    ROUND(SUM(p.price * r.quantity)::numeric, 2) AS total_revenue,
    ROUND(AVG(p.price * r.quantity)::numeric, 2) AS avg_transaction_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM retail_new)::numeric, 2) AS transaction_percentage
FROM products_nw p
JOIN retail_new r ON p.product_id = r.product_id
GROUP BY p.payment_method
ORDER BY total_revenue DESC;

-- 4. TOP PERFORMING CUSTOMERS
-- Identify high-value customers
SELECT 
    c.customer_id,
    c.gender,
    c.age,
    COUNT(*) AS total_purchases,
    SUM(r.quantity) AS total_items_purchased,
    ROUND(SUM(p.price * r.quantity)::numeric, 2) AS total_spent,
    ROUND(AVG(p.price * r.quantity)::numeric, 2) AS avg_purchase_value
FROM customers c
JOIN retail_new r ON c.customer_id = r.customer_id
JOIN products_nw p ON r.product_id = p.product_id
GROUP BY c.customer_id, c.gender, c.age
ORDER BY total_spent DESC
LIMIT 20;

-- 5. MONTHLY SALES TREND ANALYSIS
-- Analyze sales patterns over time
SELECT 
    EXTRACT(YEAR FROM r.date) AS year,
    EXTRACT(MONTH FROM r.date) AS month,
    COUNT(*) AS transaction_count,
    SUM(r.quantity) AS total_quantity,
    ROUND(SUM(p.price * r.quantity)::numeric, 2) AS monthly_revenue,
    ROUND(AVG(p.price * r.quantity)::numeric, 2) AS avg_transaction_value
FROM retail_new r
JOIN products_nw p ON r.product_id = p.product_id
GROUP BY EXTRACT(YEAR FROM r.date), EXTRACT(MONTH FROM r.date)
ORDER BY year, month;

-- 6. CUSTOMER BEHAVIOR BY AGE AND GENDER
-- Detailed analysis of purchasing patterns across demographics
SELECT 
    c.gender,
    CASE 
        WHEN c.age < 30 THEN 'Young Adults (18-29)'
        WHEN c.age BETWEEN 30 AND 45 THEN 'Adults (30-45)'
        WHEN c.age BETWEEN 46 AND 60 THEN 'Middle-aged (46-60)'
        ELSE 'Seniors (60+)'
    END AS age_segment,
    COUNT(DISTINCT c.customer_id) AS unique_customers,
    COUNT(*) AS total_transactions,
    ROUND(AVG(p.price * r.quantity)::numeric, 2) AS avg_transaction_value,
    ROUND(SUM(p.price * r.quantity)::numeric / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customers c
JOIN retail_new r ON c.customer_id = r.customer_id
JOIN products_nw p ON r.product_id = p.product_id
GROUP BY c.gender, age_segment
ORDER BY c.gender, age_segment;

-- 7. PRODUCT CATEGORY PERFORMANCE BY PAYMENT METHOD
-- Cross-analysis of product categories and payment methods
SELECT 
    p.product_category,
    p.payment_method,
    COUNT(*) AS transaction_count,
    SUM(r.quantity) AS total_quantity,
    ROUND(SUM(p.price * r.quantity)::numeric, 2) AS total_revenue,
    ROUND(AVG(p.price * r.quantity)::numeric, 2) AS avg_transaction_value
FROM products_nw p
JOIN retail_new r ON p.product_id = r.product_id
GROUP BY p.product_category, p.payment_method
ORDER BY p.product_category, total_revenue DESC;

-- 8. CUSTOMER PURCHASE FREQUENCY ANALYSIS
-- Analyze how often customers make purchases
WITH customer_purchase_stats AS (
    SELECT 
        c.customer_id,
        c.gender,
        c.age,
        COUNT(*) AS purchase_count,
        COUNT(DISTINCT r.date) AS unique_purchase_days,
        MIN(r.date) AS first_purchase_date,
        MAX(r.date) AS last_purchase_date
    FROM customers c
    JOIN retail_new r ON c.customer_id = r.customer_id
    GROUP BY c.customer_id, c.gender, c.age
)
SELECT 
    gender,
    CASE 
        WHEN purchase_count = 1 THEN 'One-time'
        WHEN purchase_count BETWEEN 2 AND 5 THEN 'Occasional (2-5)'
        WHEN purchase_count BETWEEN 6 AND 10 THEN 'Regular (6-10)'
        ELSE 'Frequent (10+)'
    END AS purchase_frequency,
    COUNT(*) AS customer_count,
    ROUND(AVG(age)::numeric, 1) AS avg_age,
    ROUND(AVG(purchase_count)::numeric, 1) AS avg_purchases
FROM customer_purchase_stats
GROUP BY gender, purchase_frequency
ORDER BY gender, purchase_frequency;

-- 9. DAILY SALES PERFORMANCE
-- Analyze sales patterns by day of week
SELECT 
    EXTRACT(DOW FROM r.date) AS day_of_week,
    CASE EXTRACT(DOW FROM r.date)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS transaction_count,
    SUM(r.quantity) AS total_quantity,
    ROUND(SUM(p.price * r.quantity)::numeric, 2) AS daily_revenue,
    ROUND(AVG(p.price * r.quantity)::numeric, 2) AS avg_transaction_value
FROM retail_new r
JOIN products_nw p ON r.product_id = p.product_id
GROUP BY EXTRACT(DOW FROM r.date), day_name
ORDER BY day_of_week;

-- 10. SEASONAL ANALYSIS - QUARTERLY PERFORMANCE
-- Analyze performance by quarters
SELECT 
    EXTRACT(YEAR FROM r.date) AS year,
    EXTRACT(QUARTER FROM r.date) AS quarter,
    COUNT(*) AS transaction_count,
    SUM(r.quantity) AS total_quantity,
    ROUND(SUM(p.price * r.quantity)::numeric, 2) AS quarterly_revenue,
    ROUND(AVG(p.price * r.quantity)::numeric, 2) AS avg_transaction_value,
    COUNT(DISTINCT r.customer_id) AS unique_customers
FROM retail_new r
JOIN products_nw p ON r.product_id = p.product_id
GROUP BY EXTRACT(YEAR FROM r.date), EXTRACT(QUARTER FROM r.date)
ORDER BY year, quarter;

-- 11. PRODUCT PRICE RANGE ANALYSIS
-- Analyze how different price points perform
SELECT 
    CASE 
        WHEN price < 20 THEN 'Budget (<$20)'
        WHEN price BETWEEN 20 AND 50 THEN 'Mid-range ($20-$50)'
        WHEN price BETWEEN 50 AND 100 THEN 'Premium ($50-$100)'
        ELSE 'Luxury ($100+)'
    END AS price_segment,
    COUNT(*) AS product_count,
    COUNT(DISTINCT r.product_id) AS products_sold,
    SUM(r.quantity) AS total_quantity_sold,
    ROUND(SUM(p.price * r.quantity)::numeric, 2) AS total_revenue,
    ROUND(AVG(r.quantity)::numeric, 2) AS avg_quantity_per_transaction
FROM products_nw p
JOIN retail_new r ON p.product_id = r.product_id
GROUP BY price_segment
ORDER BY total_revenue DESC;

-- 12. COMPREHENSIVE BUSINESS OVERVIEW DASHBOARD
-- Key metrics for executive dashboard
WITH business_metrics AS (
    SELECT 
        COUNT(DISTINCT c.customer_id) AS total_customers,
        COUNT(DISTINCT p.product_id) AS total_products,
        COUNT(*) AS total_transactions,
        SUM(r.quantity) AS total_items_sold,
        ROUND(SUM(p.price * r.quantity)::numeric, 2) AS total_revenue,
        MIN(r.date) AS first_sale_date,
        MAX(r.date) AS last_sale_date
    FROM customers c
    JOIN retail_new r ON c.customer_id = r.customer_id
    JOIN products_nw p ON r.product_id = p.product_id
)
SELECT 
    total_customers,
    total_products,
    total_transactions,
    total_items_sold,
    total_revenue,
    ROUND(total_revenue / total_customers, 2) AS avg_revenue_per_customer,
    ROUND(total_revenue / total_transactions, 2) AS avg_transaction_value,
    ROUND(total_items_sold * 1.0 / total_transactions, 2) AS avg_items_per_transaction,
    first_sale_date,
    last_sale_date,
    last_sale_date - first_sale_date AS business_duration
FROM business_metrics;

-- 13. CUSTOMER RETENTION ANALYSIS
-- Identify repeat customers vs one-time buyers
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT date) AS order_count,
        MIN(date) AS first_order,
        MAX(date) AS last_order
    FROM retail_new
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        WHEN order_count = 2 THEN 'Returning (2)'
        WHEN order_count BETWEEN 3 AND 5 THEN 'Regular (3-5)'
        ELSE 'Loyal (6+)'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_orders)::numeric, 2) AS percentage,
    ROUND(AVG(order_count)::numeric, 2) AS avg_orders
FROM customer_orders
GROUP BY customer_type
ORDER BY customer_count DESC;
