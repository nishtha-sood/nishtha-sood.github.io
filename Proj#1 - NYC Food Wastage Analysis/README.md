# NYC Food Wastage (2015–2025)

## Project Overview

New York City generates over **3 million tons of food waste** annually. Despite composting programs and redistribution efforts, borough-level waste trends remain inconsistent.

This project analyzes food waste patterns across NYC boroughs, models their relationship with income, population, and restaurant density, and recommends borough-specific interventions.

---

## 📁 Project Parts

### 📦 Part I – Data Collection & Compilation

- **Sources:**
  - NYC Open Data – DSNY Monthly Tonnage Reports
  - NYC Organics Collection Tonnage
  - U.S. Census ACS – Median Household Income
  - NYC Borough Population Density
  - Restaurant Density (manually aggregated from inspection data)

- **Data Preparation:**
  - Combined monthly waste data by borough to create annual totals
  - Calculated percent of waste composted from organics vs total
  - Created unified borough-level dataset with demographic overlays
 
### 📊 Part III – Analysis & Modeling (`food-waste-analysis.R`)

- **Regression Modeling:**
  - Linear regression with R² = 0.93 to forecast citywide waste
  - Poisson regression to validate count-based model reliability
- **EDA & Correlation:**
  - Univariate and bivariate trends by borough
  - Key correlations:
    - Positive: restaurant density
    - Negative: income
    - Weak: population density
- **Clustering:**
  - K-Means to segment boroughs based on similar waste behavior

---

## 📚 Datasets

| File | Description |
|------|-------------|
| `data/tonnage_raw.csv` | Monthly DSNY waste tonnage data |
| `data/income.csv` | Borough-wise median household income |
| `data/population.csv` | Borough-wise population and density |
| `data/organics.csv` | Composting data (DSNY & Non-DSNY sources) |
| `data/cleaned_total.csv` | Final merged dataset for analysis (2015–2025) |

> Note: The restaurant inspection dataset from ACS was too large to upload but was used during aggregation.


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

## 📊 Visual Samples

### Annual Food Waste Forecast (2015–2027)
> Modeled using linear regression  
> RMSE ≈ 79,000 tons

<img src="visuals/food-waste-trend.png" width="600" />

---

### Borough Comparison of Waste (2015–2025)
<img src="visuals/borough-comparison.png" width="600" />

---

### Restaurant Density vs Food Waste
<img src="visuals/restaurant-vs-waste.png" width="600" />

---

## 📄 Files

### 📊 Final Project Deck  
📥 [Download PDF](https://github.com/nishtha-sood/nishtha-sood.github.io/raw/main/Proj%231%20-%20NYC%20Food%20Wastage%20Analysis/presentation/food-waste-presentation.pdf) 
🔗 [Open in new tab ↗](presentation/food-waste-presentation.pdf)

---

### 📜 R Script: Regression, Clustering, and Diagnostics  
📥 [Download food-waste-analysis.R](code/food-waste-analysis.R)

