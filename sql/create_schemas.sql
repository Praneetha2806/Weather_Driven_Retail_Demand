-- =============================================
-- Unity Catalog Schema Setup
-- Weather-Driven Retail Demand Intelligence
-- =============================================

-- Create Catalog
CREATE CATALOG IF NOT EXISTS retail_demo
COMMENT 'Retail analytics catalog for weather-driven demand intelligence';

-- Switch to the catalog
USE CATALOG retail_demo;

-- =============================================
-- BRONZE LAYER: Raw Data Storage
-- =============================================
CREATE SCHEMA IF NOT EXISTS retail_bronze
COMMENT 'Raw ingestion layer - stores unprocessed weather API responses';

-- =============================================
-- SILVER LAYER: Cleansed Data
-- =============================================
CREATE SCHEMA IF NOT EXISTS retail_silver
COMMENT 'Cleansed and validated layer - deduplicated weather observations';

-- =============================================
-- GOLD LAYER: Business-Ready Aggregations
-- =============================================
CREATE SCHEMA IF NOT EXISTS retail_gold
COMMENT 'Business layer - demand signals and operational metrics';

-- =============================================
-- Verify Schema Creation
-- =============================================
SHOW SCHEMAS IN retail_demo;