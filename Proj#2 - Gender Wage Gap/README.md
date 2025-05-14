# Proj#2 - U.S. Gender Wage Gap Analysis

## Summary of Project

This project explores gender-based wage disparities across the United States using publicly available data from the U.S. Census Bureau and Bureau of Labor Statistics. The focus is on identifying wage gaps between men and women across different education levels, job types, and work arrangements (e.g., remote, full-time).

The project combines data cleaning, exploratory data analysis, and visual storytelling to uncover how gender, education, and work flexibility affect earnings and to quantify the gap with regression techniques.

**Part I – Data Preparation**  
The dataset includes earnings by gender, education level, job type, and work flexibility (full-time/remote). Key steps included:
- Cleaning nulls and fixing formats
- Creating new indicators like `wage_gap_percent`
- Grouping by categories for comparative analysis

**Part II – Analysis & Visualization (`gender_wage_gap_analysis.ipynb`)**  
Explored trends in wage gaps:
- Across education levels (e.g., Bachelor’s vs. High School)
- Across job flexibility (remote vs. on-site)
- Wage gap percent across industries

Used regression to estimate the degree to which gender explains wage differences, controlling for education and work type. Presented interactive and static visualizations using Seaborn and Matplotlib.

## Datasets

| File | Description |
|------|-------------|
| `data/cleaned_gender_data.csv` | Cleaned dataset containing earnings, gender, education level, and work arrangement |
| `data/raw_census_wages.csv` | Raw dataset from U.S. Census or BLS |

> Additional sources: U.S. Census Bureau, BLS ACS PUMS API

## Visuals

| Chart | File |
|-------|------|
| Wage Gap by Education Level | `visuals/education_vs_gap.png` |
| Wage Gap in Remote vs On-Site Jobs | `visuals/flexibility_vs_gap.png` |
| Distribution of Wages by Gender | `visuals/distribution_by_gender.png` |

## Files

### 📊 Notebook
[View Jupyter Notebook](gender_wage_gap_analysis.ipynb)

### 📄 Final Report (Optional)
Coming soon

## Installation
To run the notebook locally:
```bash
pip install pandas matplotlib seaborn
```

## Acknowledgements
Special thanks to the U.S. Census Bureau and BLS for open access to demographic and wage data.

## Author
**Nishtha Sood**  
[LinkedIn](https://linkedin.com/in/nishtha-sood) | [Website](https://nishtha-sood.github.io)
