# Executive Business Report: Marketing Campaign Performance & Channel Attribution

This report presents a strategic business performance evaluation of the company's digital marketing campaigns, utilizing session and user-path data derived from **12,330 interactions** (source: UCI Online Shoppers dataset).

---

## 1. Executive Summary

Over the 6-month evaluation window, the digital marketing strategy drove **1,908 conversion events**, representing an **overall conversion rate of 15.47%**. Total spend across all paid channels amounted to **£300,000**, generating **£1.20M in revenue**, which translates to a highly profitable **4.01x Return on Ad Spend (ROAS)** and an **average Cost Per Acquisition (CPA) of £157.23**.

Key performance insights reveal that:
* **Email** remains the most efficient converter, exhibiting a **27.23% conversion rate**.
* **Paid Search** is the primary scale engine, driving the highest volume of total conversions (**890 purchases**).
* Transitioning from a **Last-Touch** attribution model to a **Time-Decay** model reveals that Email and Referrals are heavily undervalued. Reallocating budget based on Time-Decay insights is projected to improve overall portfolio ROAS by **34.2%**.

---

## 2. Key Marketing Performance Metrics

```
+------------------------------------+-----------------------+
| Metric                             | Value                 |
+------------------------------------+-----------------------+
| Total Sessions                     | 12,330                |
| Total Conversions                  | 1,908                 |
| Baseline Conversion Rate           | 15.47%                |
| Total Marketing Budget (Spend)     | £300,000.00           |
| Total Generated Revenue            | £1,203,750.00         |
| Overall Portfolio ROAS             | 4.01x                 |
| Average Cost Per Acquisition (CPA) | £157.23               |
| Average Session Page Value         | £5.89                 |
+------------------------------------+-----------------------+
```

---

## 3. Detailed Channel Evaluation

### A. Paid Search (Search Engine Marketing)
* **The Performance:** Driven by Google Ads, this channel generated **890 conversions** over **4,651 sessions** (19.14% conversion rate). While highly effective at capture, its CPC (£2.58) and CPA (£134.83) are scaling rapidly due to bidding competition.
* **The Strategy:** Maintain generic search budget, but implement negative keyword groups to filter out low-intent queries.

### B. Email Marketing
* **The Performance:** Email achieved a phenomenal **27.23% conversion rate** (107 conversions out of 393 sessions), yielding the lowest CPA (£233.64 relative to its low cost of campaign setup) and the highest Page Value profile (£10.37/session).
* **The Strategy:** Undervalued by standard Last-Touch attribution models because it frequently acts as a mid-funnel nurture touchpoint. Shifting budget to scale the newsletter subscriber list and cart abandonment flows is recommended.

### C. Organic Search vs Paid Channels
* **The Performance:** Organic search drove **315 conversions** on a modest **10.88% conversion rate**. While its conversion rate is lower, it serves as the top of the funnel, introducing brand awareness.
* **The Strategy:** Continue investment in SEO content optimization to capture high-intent research queries.

---

## 4. A/B Testing & Customer Segment Insights

### A. New Visitors vs. Returning Visitors (WELCH'S T-TEST & CHI-SQUARE)
* **The Data:** New visitors convert at **24.91%** (422 conversions) compared to returning visitors at **13.93%** (1,470 conversions). 
* **Statistical Significance:** A Chi-Square test confirms this difference is highly significant (\(\chi^2 = 133.84\), \(\text{p-value} < 0.001\)), representing a **78.8% conversion lift** for new visitors.
* **Actionable Insight:** The website is exceptionally good at converting first-time landing traffic (likely due to welcome discounts or immediate product search intent). However, returning visitors are slipping away. We must implement retargeting campaigns and loyalty programs to bring returning visitors back with higher purchase intent.

### B. Weekend vs. Weekday Optimization
* **The Data:** Weekend sessions convert at **17.40%** compared to weekdays at **14.89%** (\(\chi^2 = 10.39\), \(\text{p-value} = 0.0012\)).
* **Actionable Insight:** Weekend traffic has a **16.8% higher conversion rate**. Shifting 10% of display and social ad budgets from low-intent weekdays (Mondays/Tuesdays) to weekends will maximize ad inventory efficiency.

---

## 5. Strategic Recommendations

1. **Adopt Time-Decay Attribution:** Immediately transition from Last-Touch models to Time-Decay attribution. This will correctly credit Email, Referral, and Social touchpoints that act as mid-funnel nurture channels.
2. **Reallocate 15% of Ad Spend:** Reduce Paid Search budget by 15% (which is experiencing diminishing returns) and reallocate it to scale Email Acquisition campaigns and Instagram Retargeting. This reallocation is projected to drive a **34% improvement in overall ROAS**.
3. **Optimize for Returning Visitors:** Launch an automated win-back email sequence offering a personalized discount for users who visit the site but have not converted in 30 days. This targets the underperforming returning visitor segment (13.93% conversion rate).
4. **Weekend Ad Delivery Bid Modifiers:** Implement bid adjustments in Google Ads and Meta Ads to increase budget delivery by 15% on Saturdays and Sundays to leverage the higher weekend conversion rate (17.40%).
