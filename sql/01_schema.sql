-- =============================================================================
-- 01_schema.sql — Database Schema Definition
-- =============================================================================
-- Relational Schema for the marketing_analytics database.
-- Built for MySQL 8.0+.
--
-- This schema models user sessions, geo-regions, channel traffic, and
-- conversion events to support marketing performance and attribution analysis.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS marketing_analytics;
USE marketing_analytics;

-- -----------------------------------------------------------------------------
-- 1. Table: sessions
-- -----------------------------------------------------------------------------
-- Stores session-level user behavior, browser configurations, page visit metrics,
-- and conversion flags derived from the Online Shoppers dataset.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sessions (
    session_id INT PRIMARY KEY,
    administrative INT NOT NULL DEFAULT 0,
    administrative_duration DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    informational INT NOT NULL DEFAULT 0,
    informational_duration DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    product_related INT NOT NULL DEFAULT 0,
    product_related_duration DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    bounce_rate DECIMAL(5,4) NOT NULL DEFAULT 0.0000,
    exit_rate DECIMAL(5,4) NOT NULL DEFAULT 0.0000,
    page_values DECIMAL(10,4) NOT NULL DEFAULT 0.0000,
    special_day DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    month VARCHAR(20) NOT NULL,
    operating_system INT NOT NULL,
    browser INT NOT NULL,
    region INT NOT NULL,
    traffic_type INT NOT NULL,
    visitor_type VARCHAR(50) NOT NULL,
    weekend BOOLEAN NOT NULL,
    revenue BOOLEAN NOT NULL,
    channel VARCHAR(50) NOT NULL,
    engagement_score DECIMAL(6,2) NOT NULL,
    visitor_segment VARCHAR(50) NOT NULL,
    day_type VARCHAR(20) NOT NULL,
    converted TINYINT NOT NULL DEFAULT 0,
    
    -- Indexes for query optimization
    INDEX idx_channel (channel),
    INDEX idx_month (month),
    INDEX idx_visitor_segment (visitor_segment),
    INDEX idx_region (region),
    INDEX idx_converted (converted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------------------------------
-- 2. Table: campaigns
-- -----------------------------------------------------------------------------
-- Tracks individual marketing campaigns, budget allocations, impressions,
-- clicks, and total channel revenue.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campaigns (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(100) NOT NULL,
    channel VARCHAR(50) NOT NULL,
    budget DECIMAL(12,2) NOT NULL,
    impressions INT NOT NULL,
    clicks INT NOT NULL,
    conversions INT NOT NULL,
    revenue DECIMAL(14,2) NOT NULL,
    
    INDEX idx_campaign_channel (channel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------------------------------
-- 3. Table: touchpoints
-- -----------------------------------------------------------------------------
-- Simulated clickstream touchpoint log mapping user interaction pathways
-- prior to purchasing events. Used to run multi-touch attribution queries.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS touchpoints (
    touchpoint_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(50) NOT NULL,
    channel VARCHAR(50) NOT NULL,
    touchpoint_order INT NOT NULL,
    total_touchpoints INT NOT NULL,
    days_before_conversion DECIMAL(5,2),
    revenue DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    converted TINYINT NOT NULL DEFAULT 0,
    
    INDEX idx_tp_user (user_id),
    INDEX idx_tp_channel (channel),
    INDEX idx_tp_converted (converted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------------------------------
-- Commit changes and verify
-- -----------------------------------------------------------------------------
SHOW TABLES;
