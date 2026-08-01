-- =============================================================================
-- 02_campaign_queries.sql — Marketing Performance Analytics Queries
-- =============================================================================
-- Contains analytical SQL queries for campaign performance, user conversion 
-- funnels, cohort analysis, and multi-touch attribution calculations.
-- Written for MySQL 8.0+.
-- =============================================================================

USE marketing_analytics;

-- -----------------------------------------------------------------------------
-- Query 1: Channel Performance Summary
-- Answers: What is the ROI, ROAS, CPC, CPA, and CTR for each marketing channel?
-- -----------------------------------------------------------------------------
WITH channel_summary AS (
    SELECT 
        channel,
        SUM(budget) AS total_spend,
        SUM(impressions) AS total_impressions,
        SUM(clicks) AS total_clicks,
        SUM(conversions) AS total_conversions,
        SUM(revenue) AS total_revenue
    FROM campaigns
    GROUP BY channel
)
SELECT 
    channel,
    total_spend,
    total_revenue,
    -- Click-Through Rate
    ROUND((total_clicks / total_impressions) * 100, 2) AS ctr_percent,
    -- Cost Per Click
    ROUND(total_spend / total_clicks, 2) AS cpc_gbp,
    -- Cost Per Acquisition
    ROUND(total_spend / total_conversions, 2) AS cpa_gbp,
    -- Return on Ad Spend
    ROUND(total_revenue / total_spend, 2) AS roas,
    -- Return on Investment (%)
    ROUND(((total_revenue - total_spend) / total_spend) * 100, 2) AS roi_percent
FROM channel_summary
ORDER BY roas DESC;


-- -----------------------------------------------------------------------------
-- Query 2: Campaign Performance ROI Ranking
-- Answers: Which individual campaigns generated the highest return on budget?
-- -----------------------------------------------------------------------------
SELECT 
    campaign_id,
    campaign_name,
    channel,
    budget AS spend,
    revenue,
    conversions,
    ROUND((clicks / impressions) * 100, 2) AS ctr_percent,
    ROUND(budget / conversions, 2) AS cpa_gbp,
    ROUND(revenue / budget, 2) AS roas,
    ROUND(((revenue - budget) / budget) * 100, 2) AS roi_percent,
    -- Rank campaigns by ROI descending
    DENSE_RANK() OVER (ORDER BY (revenue - budget) / budget DESC) AS roi_rank
FROM campaigns
ORDER BY roi_percent DESC;


-- -----------------------------------------------------------------------------
-- Query 3: Conversion Funnel Stage Analysis
-- Answers: What is the conversion drop-off rate at each stage of the funnel?
-- -----------------------------------------------------------------------------
WITH funnel_counts AS (
    SELECT 
        COUNT(*) AS total_sessions,
        SUM(CASE WHEN product_related > 0 THEN 1 ELSE 0 END) AS visited_product_page,
        SUM(CASE WHEN administrative > 0 THEN 1 ELSE 0 END) AS visited_admin_page,
        SUM(CASE WHEN informational > 0 THEN 1 ELSE 0 END) AS visited_info_page,
        SUM(CASE WHEN revenue = 1 THEN 1 ELSE 0 END) AS completed_purchase
    FROM sessions
)
SELECT 
    total_sessions AS sessions_all,
    visited_product_page AS step_1_product_page,
    visited_admin_page AS step_2_admin_page,
    visited_info_page AS step_3_info_page,
    completed_purchase AS step_4_purchase,
    -- Conversion rates relative to all sessions
    ROUND((visited_product_page / total_sessions) * 100, 2) AS step_1_conversion_percent,
    ROUND((visited_admin_page / total_sessions) * 100, 2) AS step_2_conversion_percent,
    ROUND((completed_purchase / total_sessions) * 100, 2) AS overall_conversion_rate
FROM funnel_counts;


-- -----------------------------------------------------------------------------
-- Query 4: A/B Test Segment Analysis (New vs Returning)
-- Answers: Do New Visitors convert at a higher rate, and is it significant?
-- -----------------------------------------------------------------------------
WITH ab_test_summary AS (
    SELECT 
        visitor_segment,
        COUNT(*) AS total_sessions,
        SUM(converted) AS total_conversions
    FROM sessions
    WHERE visitor_segment IN ('New', 'Returning')
    GROUP BY visitor_segment
),
calculated_rates AS (
    SELECT 
        visitor_segment,
        total_sessions,
        total_conversions,
        total_conversions / total_sessions AS conversion_rate
    FROM ab_test_summary
)
SELECT 
    a.visitor_segment AS segment,
    a.total_sessions AS sessions,
    a.total_conversions AS conversions,
    ROUND(a.conversion_rate * 100, 2) AS conv_rate_percent,
    -- Compare conversion rate of New vs Returning
    ROUND(((b.conversion_rate - a.conversion_rate) / a.conversion_rate) * 100, 2) AS lift_new_vs_returning_percent
FROM calculated_rates a
JOIN calculated_rates b ON b.visitor_segment = 'New' AND a.visitor_segment = 'Returning';


-- -----------------------------------------------------------------------------
-- Query 5: Month-over-Month Revenue & Conversion Trends
-- Answers: What is the monthly seasonal volume and conversion rate?
-- -----------------------------------------------------------------------------
SELECT 
    month,
    COUNT(*) AS total_sessions,
    SUM(converted) AS total_conversions,
    ROUND((SUM(converted) / COUNT(*)) * 100, 2) AS conversion_rate_percent,
    -- Average PageValues as proxy for session value trend
    ROUND(AVG(page_values), 2) AS avg_session_page_value
FROM sessions
GROUP BY month
ORDER BY 
    CASE month
        WHEN 'Feb' THEN 1
        WHEN 'Mar' THEN 2
        WHEN 'May' THEN 3
        WHEN 'Jun' THEN 4
        WHEN 'Jul' THEN 5
        WHEN 'Aug' THEN 6
        WHEN 'Sep' THEN 7
        WHEN 'Oct' THEN 8
        WHEN 'Nov' THEN 9
        WHEN 'Dec' THEN 10
        ELSE 99
    END;


-- -----------------------------------------------------------------------------
-- Query 6: Regional Conversion Rate Benchmarks
-- Answers: Which geographical regions exhibit the highest conversion rates?
-- -----------------------------------------------------------------------------
SELECT 
    region,
    COUNT(*) AS sessions,
    SUM(converted) AS conversions,
    ROUND((SUM(converted) / COUNT(*)) * 100, 2) AS conversion_rate_percent,
    -- Rank regions by conversion rate
    ROW_NUMBER() OVER (ORDER BY SUM(converted) / COUNT(*) DESC) AS region_rank
FROM sessions
GROUP BY region
ORDER BY conversion_rate_percent DESC;


-- -----------------------------------------------------------------------------
-- Query 7: Touchpoint Path Length Distribution (Attribution)
-- Answers: How many interactions (touchpoints) do users make before converting?
-- -----------------------------------------------------------------------------
SELECT 
    total_touchpoints,
    COUNT(DISTINCT user_id) AS converting_users,
    ROUND(AVG(revenue), 2) AS average_conversion_value
FROM touchpoints
WHERE converted = 1
GROUP BY total_touchpoints
ORDER BY total_touchpoints ASC;


-- -----------------------------------------------------------------------------
-- Query 8: First-Touch vs Last-Touch Attributed Revenue
-- Answers: How does First-Touch revenue compare to Last-Touch revenue?
-- -----------------------------------------------------------------------------
WITH first_touch AS (
    SELECT 
        channel,
        SUM(revenue) AS first_touch_revenue
    FROM touchpoints
    WHERE touchpoint_order = 1 AND converted = 1
    GROUP BY channel
),
last_touch AS (
    SELECT 
        channel,
        SUM(revenue) AS last_touch_revenue
    FROM touchpoints
    WHERE touchpoint_order = total_touchpoints AND converted = 1
    GROUP BY channel
)
SELECT 
    f.channel,
    f.first_touch_revenue,
    l.last_touch_revenue,
    ROUND(l.last_touch_revenue - f.first_touch_revenue, 2) AS variance_last_minus_first
FROM first_touch f
JOIN last_touch l ON f.channel = l.channel
ORDER BY variance_last_minus_first DESC;
