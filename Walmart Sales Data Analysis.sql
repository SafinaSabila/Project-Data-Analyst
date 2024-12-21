-- Membuat basis data
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Membuat tabel
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- Membersihkan data
SELECT
	*
FROM sales;

-- Menambahkan kolom time_of_day
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- Menambahkan kolom day_name 
SELECT
	date,
	DAYNAME(date)
FROM sales;
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name = DAYNAME(date);

-- Menambahkan kolom month_name 
SELECT
	date,
	MONTHNAME(date)
FROM sales;
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------
-- ---------------------------- Umum ------------------------------
-- --------------------------------------------------------------------
-- Berapa banyak kota yang dimiliki data?
SELECT 
	DISTINCT city
FROM sales;

-- Sebutkan kategori cabang dari kota diatas?
SELECT 
	DISTINCT city,
    branch
FROM sales;


-- --------------------------------------------------------------------
-- ---------------------------- Produk -------------------------------
-- --------------------------------------------------------------------

-- Berapa banyak produk kain yang dimiliki data ?
SELECT
	DISTINCT product_line
FROM sales;

-- Apa metode pembayaran yang paling umum?
SELECT
	SUM(quantity) as qty,
    payment
FROM sales
GROUP BY payment
ORDER BY qty DESC;

-- Apa saja produk kain yang paling laris ?
SELECT
	SUM(quantity) as qty,
    product_line
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- Berapa pendatan total per bulan?
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name 
ORDER BY total_revenue;

-- Sebutkan nama bulan yang memiliki COGS terbesar?
SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name 
ORDER BY cogs;

-- Sebutkan produk kain yang memiliki pendapatan terbesar?
SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- sebutkan urutan kota dan cabang yang memiliki pendapatan terbesar?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue;

-- Sebutkan produk kain yang memiliki PPN terbesar?
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;


-- Berapa rating rata-rata dari kualitas produk kain?
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

-- Menambahkan kolom berdasarkan kategori kualitas produk kain
SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Sebutkan cabang yang menjual lebih banyak produk daripada rata-rata produk yang terjual?
SELECT 
	branch, 
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- Sebutkan produk kain yang paling umum digunakan berdasarkan jenis kelamin?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- Berapa rata-rata reting dari produk kain?
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- --------------------------------------------------------------------
-- -------------------------- Pelanggan -------------------------------
-- --------------------------------------------------------------------

-- Berapa banyak jenis pelanggan pada data?
SELECT
	DISTINCT customer_type
FROM sales;

-- Berapa banyak metode pembanyaran pada data?
SELECT
	DISTINCT payment
FROM sales;

-- Apa tipe pelanggan yang paling umum?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Sebutkan tipe pelanggan yang melakukan pembelian terbanyak ?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

-- Apa jenis kelamin sebagian besar pelanggan?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Sebutkan banyaknya distribusi jenis kelamin pada cabang C?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Sebutkan rata-rata pemberian rating?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Sebutkan rata-rata pemberian rating terbanyak berdasarkan cabang A?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Sebutkan hari apa saja yang memiliki rata-rata rating terbanyak?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Sebutkan hari apa saja yang memiliki rata-rata rating terbanyak dicabang C?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;

-- --------------------------------------------------------------------
-- ---------------------------- Penjualan ---------------------------------
-- --------------------------------------------------------------------

-- Sebutkan jumlah penjualan per waktu dalam sehari?
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Sebutkan jenis pelanggan yang menghasilkan pendapatan terbanyak ?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Sebutkan kota yang memiliki PPN terbesar?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Sebutkan jenis pelanggan yang paling banyak membayar PPN?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;
