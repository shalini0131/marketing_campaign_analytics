# Power BI Model Specification — Marketing Analytics

This document defines the schema relationships, connection settings, and custom DAX measures used to construct the marketing performance dashboard in Power BI.

---

## 1. Data Model & Relationships

The model utilizes a star schema configuration centering on the `sessions` and `touchpoints` tables.

```
                  +-------------------+
                  |   dim_calendar    |
                  +-------------------+
                            | (1:*)
                            |
                            v
                  +-------------------+
                  |     sessions      |
                  +-------------------+
                            ^
                            | (1:*)
                            |
                  +-------------------+
                  |     campaigns     |
                  +-------------------+
                            |
                            | (1:*)
                            v
                  +-------------------+
                  |    touchpoints    |
                  +-------------------+
```

### Table Relationships
* `campaigns` (1) $\rightarrow$ `touchpoints` (*) on `channel` (Active)
* `dim_calendar` (1) $\rightarrow$ `sessions` (*) on `month` (Active)

---

## 2. Power Query M Connections

### Connection to MySQL Server
```powerquery
let
    Source = MySQL.Database("localhost", "marketing_analytics", [ReturnSingleDatabase=true]),
    sessions_table = Source{[Schema="marketing_analytics", Item="sessions"]}[Data]
in
    sessions_table
```

---

## 3. Custom DAX Measures

Paste these formulas one by one into your measures table.

### Core Metrics

```dax
Total Spend = SUM(campaigns[budget])
```

```dax
Total Revenue = SUM(campaigns[revenue])
```

```dax
Overall ROAS = DIVIDE([Total Revenue], [Total Spend], 0)
```

```dax
Total Sessions = COUNT(sessions[session_id])
```

```dax
Total Conversions = SUM(sessions[converted])
```

```dax
Conversion Rate % = DIVIDE([Total Conversions], [Total Sessions], 0) * 100
```

```dax
Average Cost Per Acquisition (CPA) = DIVIDE([Total Spend], [Total Conversions], 0)
```

```dax
Click-Through Rate (CTR) % = DIVIDE(SUM(campaigns[clicks]), SUM(campaigns[impressions]), 0) * 100
```

### A/B Testing & Segment Measures

```dax
New Visitor Conversion Rate % = 
CALCULATE(
    [Conversion Rate %],
    sessions[visitor_segment] = "New"
)
```

```dax
Returning Visitor Conversion Rate % = 
CALCULATE(
    [Conversion Rate %],
    sessions[visitor_segment] = "Returning"
)
```

```dax
A/B Test Lift % = 
DIVIDE(
    [New Visitor Conversion Rate %] - [Returning Visitor Conversion Rate %],
    [Returning Visitor Conversion Rate %],
    0
) * 100
```

### Attribution Measures

```dax
First-Touch Attributed Revenue = 
CALCULATE(
    SUM(touchpoints[revenue]),
    touchpoints[touchpoint_order] = 1,
    touchpoints[converted] = 1
)
```

```dax
Last-Touch Attributed Revenue = 
CALCULATE(
    SUM(touchpoints[revenue]),
    touchpoints[touchpoint_order] = touchpoints[total_touchpoints],
    touchpoints[converted] = 1
)
```

```dax
Attribution Variance % = 
DIVIDE(
    [Last-Touch Attributed Revenue] - [First-Touch Attributed Revenue],
    [First-Touch Attributed Revenue],
    0
) * 100
```

---

## 4. Dashboard Page Layouts

### Page 1: Campaign ROI Overview (Executive View)
* **Goal:** Present top-line ROI and budget efficiency.
* **Visuals:**
  - **KPI Cards:** `Total Spend`, `Total Revenue`, `Overall ROAS`, `Conversion Rate %`.
  - **Grouped Bar Chart:** ROAS by Channel (with a target line at 1.0x).
  - **Scatter Plot:** CPA vs. ROAS by Campaign (bubble size representing budget, colored by channel).
  - **Slicers:** `Month`, `Channel`.

### Page 2: A/B Testing & Visitor Behavior
* **Goal:** Showcase conversion difference by customer type.
* **Visuals:**
  - **Card Visuals:** `New Visitor Conversion Rate %`, `Returning Visitor Conversion Rate %`, `A/B Test Lift %`.
  - **Side-by-Side Bar Chart:** Conversion Rate: New Visitors (24.91%) vs. Returning Visitors (13.93%).
  - **Funnel Visual:** E-commerce Session Funnel (All Sessions $\rightarrow$ Product Visitors $\rightarrow$ Admin Visitors $\rightarrow$ Conversions).
  - **Pie Chart:** Conversion Rate by Day Type (Weekend: 17.40% vs. Weekday: 14.89%).

### Page 3: Multi-Touch Attribution Insights
* **Goal:** Guide budget allocation using attribution models.
* **Visuals:**
  - **Clustered Column Chart:** Attributed Revenue: First-Touch vs. Last-Touch by Channel.
  - **Matrix Table:** Attributed Revenue, Spend, and calculated ROAS across all 4 attribution models (First-Touch, Last-Touch, Linear, Time-Decay).
  - **Recommendation Card:** Text box outlining the 34% ROAS optimization opportunity by reallocating budget from Paid Search to Email based on Time-Decay modeling.
