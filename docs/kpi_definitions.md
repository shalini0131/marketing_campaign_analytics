# KPI Definitions — Marketing Performance Analytics

This document defines the mathematical equations and logic used to evaluate marketing performance, attribution models, and conversion rates.

---

## 1. Core Performance KPIs

### Click-Through Rate (CTR)
Measures the percentage of impressions that resulted in an ad click.
$$\text{CTR \%} = \frac{\text{clicks}}{\text{impressions}} \times 100$$

### Cost Per Click (CPC)
Measures the average cost of driving a single visitor click.
$$\text{CPC} = \frac{\text{totalSpend}}{\text{clicks}}$$

### Cost Per Acquisition (CPA)
Measures the average advertising spend required to acquire a single paying customer.
$$\text{CPA} = \frac{\text{totalSpend}}{\text{conversions}}$$

### Return on Ad Spend (ROAS)
Measures the gross revenue generated for every dollar spent on advertising.
$$\text{ROAS} = \frac{\text{attributedRevenue}}{\text{totalSpend}}$$

### Return on Investment (ROI)
Measures the net profitability of marketing campaigns relative to their cost.
$$\text{ROI \%} = \frac{\text{attributedRevenue} - \text{totalSpend}}{\text{totalSpend}} \times 100$$

### Session Conversion Rate
Measures the percentage of website sessions that resulted in a purchase.
$$\text{Conversion Rate \%} = \frac{\text{conversions}}{\text{sessions}} \times 100$$

---

## 2. A/B Testing & Statistical Metrics

### Conversion Lift %
Measures the relative change in conversion rate between a treatment variant (personalized design) and a baseline control.
$$\text{Lift \%} = \frac{\text{conversionRateTreatment} - \text{conversionRateControl}}{\text{conversionRateControl}} \times 100$$

### Chi-Square Test for Independence
Tests if there is a statistically significant difference in conversion rates between two independent user segments (e.g. New vs Returning Visitors).
$$\chi^2 = \sum \frac{(O - E)^2}{E}$$
*Where:*
- \(O\) = Observed conversion counts (e.g. actual conversions and non-conversions)
- \(E\) = Expected counts under the null hypothesis (no difference between groups)
- Significance threshold: \(\text{p-value} < 0.05\) (meaning 95% confidence that the lift is real)

---

## 3. Multi-Touch Attribution Models

### First-Touch Attribution
100% of conversion credit is assigned to the first channel interaction.
$$\text{Credit}_{\text{First}} = \text{revenue}$$

### Last-Touch Attribution
100% of conversion credit is assigned to the final channel interaction prior to purchase.
$$\text{Credit}_{\text{Last}} = \text{revenue}$$

### Linear Attribution
Credit is divided equally among all touchpoints in the user path.
$$\text{Credit}_{\text{Linear}} = \frac{\text{revenue}}{\text{totalTouchpoints}}$$

### Time-Decay Attribution
Attributes more credit to touchpoints closer to the purchase event, calculated with an exponential decay function.
$$\text{Weight}_i = 2^{-\frac{\text{daysBeforeConversion}_i}{\lambda}}$$
$$\text{Credit}_i = \text{revenue} \times \frac{\text{Weight}_i}{\sum_{j=1}^{N} \text{Weight}_j}$$
*Where:*
- \(\lambda\) = Decay half-life parameter (set to 7.0 days)
- \(N\) = Total touchpoints in the journey
- \(\text{daysBeforeConversion}_i\) = Days elapsed between touchpoint \(i\) and purchase
