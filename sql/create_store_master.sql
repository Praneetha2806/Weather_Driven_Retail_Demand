-- =============================================
-- Store Master Data Creation
-- Weather-Driven Retail Demand Intelligence
-- =============================================

USE CATALOG retail_demo;
USE SCHEMA retail_gold;

-- Drop table if exists (for clean recreation)
DROP TABLE IF EXISTS store_master;

-- Create Store Master Table
CREATE TABLE store_master (
    store_id STRING COMMENT 'Unique store identifier',
    city STRING COMMENT 'City where store is located',
    region STRING COMMENT 'US region (West, South, Midwest, Northeast)',
    latitude DOUBLE COMMENT 'Store latitude coordinate',
    longitude DOUBLE COMMENT 'Store longitude coordinate',
    category_focus STRING COMMENT 'Primary product category for this store',
    store_size_sqft INT COMMENT 'Store size in square feet',
    opened_date DATE COMMENT 'Store opening date'
)
USING DELTA
COMMENT 'Master store dimension table with location and business attributes';

-- Insert Store Master Data
INSERT INTO store_master VALUES
    ('ST001', 'San Jose', 'West', 37.3382, -121.8863, 'Electronics', 12000, '2019-03-15'),
    ('ST002', 'Los Angeles', 'West', 34.0522, -118.2437, 'Apparel', 15000, '2018-06-20'),
    ('ST003', 'Seattle', 'West', 47.6062, -122.3321, 'Home & Garden', 18000, '2017-09-10'),
    ('ST004', 'Denver', 'Mountain', 39.7392, -104.9903, 'Sports & Outdoors', 14000, '2020-01-25'),
    ('ST005', 'Phoenix', 'Mountain', 33.4484, -112.0740, 'Seasonal', 16000, '2018-11-12'),
    ('ST006', 'Chicago', 'Midwest', 41.8781, -87.6298, 'General Merchandise', 20000, '2016-05-08'),
    ('ST007', 'Minneapolis', 'Midwest', 44.9778, -93.2650, 'Winter Gear', 13000, '2019-08-30'),
    ('ST008', 'Dallas', 'South', 32.7767, -96.7970, 'Home Improvement', 17000, '2017-04-18'),
    ('ST009', 'Houston', 'South', 29.7604, -95.3698, 'Electronics', 19000, '2018-02-14'),
    ('ST010', 'Miami', 'South', 25.7617, -80.1918, 'Beachwear', 11000, '2019-12-05'),
    ('ST011', 'Atlanta', 'South', 33.7490, -84.3880, 'Apparel', 14500, '2020-07-22'),
    ('ST012', 'New York', 'Northeast', 40.7128, -74.0060, 'Fashion', 22000, '2015-10-01'),
    ('ST013', 'Boston', 'Northeast', 42.3601, -71.0589, 'General Merchandise', 16500, '2017-01-15');

-- Verify data insertion
SELECT 
    region,
    COUNT(*) as store_count,
    AVG(store_size_sqft) as avg_store_size
FROM store_master
GROUP BY region
ORDER BY region;

-- Display all stores
SELECT * FROM store_master ORDER BY region, city;