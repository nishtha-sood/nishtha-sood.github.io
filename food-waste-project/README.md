# NYC Food Wastage (2015–2025)

## Project Overview

New York City generates over **3 million tons of food waste** annually. Despite composting programs and redistribution efforts, borough-level waste trends remain inconsistent.

This project analyzes food waste patterns across NYC boroughs, models their relationship with income, population, and restaurant density, and recommends borough-specific interventions.

---

## Research Questions

1. How much food is wasted annually, and how has this changed over time?
2. Which boroughs generate the most food waste?
3. What factors (income, population, restaurant density) drive this waste?
4. How effective are composting efforts across the city?

---

## Tools & Data Sources

| Tool | Use |
|------|-----|
| **R** | Data wrangling, regression modeling, clustering |
| **Tableau** | Borough-level dashboards and visuals |
| **Excel** | Initial cleaning, pivoting, and verification |

**Data Sources:**
- NYC DSNY Monthly Tonnage Data (2015–2025)
- NYC Organics Collection Tonnage
- NYC Restaurant Inspection Records
- U.S. Census ACS: Median Income
- NYC Population by Borough (2020)

---

## Methodology

- **EDA**: Borough-level trends (waste volume, composting rate)
- **Linear Regression**: To predict food waste by borough
- **Poisson Regression**: Confirmed count-based model reliability
- **K-Means Clustering**: Grouped boroughs by waste behavior
- **Correlation Analysis**: Tested relationships with socioeconomic variables

---

## Key Insights

| Finding | Insight |
|--------|---------|
| 📈 R² = 0.93 | Linear regression accurately predicted food waste volume |
| 🍽️ Restaurant density = strongest predictor | More restaurants → more food waste (corr = 0.45) |
| 💸 Income has a negative relationship | Lower-income boroughs generate more waste |
| 🏙️ Population density has a weak effect | Not a major standalone driver |
| ♻️ Composting inconsistent | Spikes in 2023, dip in 2024 — unstable participation |

---

## Visual Samples

### Annual Food Waste Forecast (2015–2027)
> Modeled using linear regression  
> RMSE ≈ 79,000 tons

<img src="../assets/img/food-waste-trend.png" alt="NYC Food Waste Forecast Chart" width="600" />

---

### Clustering of Borough Waste Behavior (K-Means)
> Boroughs grouped by patterns in waste, restaurant density, and income

<img src="../assets/img/borough-comparison.png" alt="NYC Food Waste Forecast Chart" width="600" />

---

## Project Structure

```bash
NYC-Food-Waste-Forecasting/
├── README.md
├── code/
│   └── food_waste_analysis.R
├── data/
│   └── cleaned_data.csv
├── visuals/
│   ├── trend_plot.png
│   └── cluster_map.png
├── presentation/
│   └── food-waste-presentation.pdf

