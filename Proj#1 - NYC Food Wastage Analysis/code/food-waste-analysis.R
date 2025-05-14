# NYC Food Waste Analysis (2015–2024)
# By: Nishtha Sood
# Description: This script analyzes food waste trends across NYC boroughs using DSNY data, census income, restaurant inspections, and more. Includes forecasting, correlation analysis, and clustering.

# Load required libraries
library(tidyverse)
library(lubridate)
library(ggplot2)
library(reshape2)

# 1. Load and Clean Data --------------------------------------------------

## 1.1 DSNY Monthly Food Waste Tonnage
dsny_monthly <- read_csv("/Users/nishthasood/Desktop/DSNY_Monthly_Tonnage_Data_20250513.csv") %>%
  separate(MONTH, into = c("Year", "Month"), sep = " / ", convert = TRUE) %>%
  mutate(across(ends_with("TONSCOLLECTED") | ends_with("ORGANICTONS"), ~replace_na(., 0))) %>%
  mutate(across(c(REFUSETONSCOLLECTED, PAPERTONSCOLLECTED, MGPTONSCOLLECTED,
                  RESORGANICSTONS, SCHOOLORGANICTONS, LEAVESORGANICTONS, XMASTREETONS),
                ~replace_na(., 0)),
         Total_Waste = REFUSETONSCOLLECTED + PAPERTONSCOLLECTED + MGPTONSCOLLECTED +
           RESORGANICSTONS + SCHOOLORGANICTONS + LEAVESORGANICTONS + XMASTREETONS)

## Borough-level annual totals
annual_waste_borough <- dsny_monthly %>%
  group_by(Year, BOROUGH) %>%
  summarise(Annual_Waste = sum(Total_Waste), .groups = "drop")

## Citywide annual totals
annual_waste_city <- annual_waste_borough %>%
  group_by(Year) %>%
  summarise(Total_Waste = sum(Annual_Waste), .groups = "drop")

## 1.2 Organics (Compost) Data
organics <- read_csv("/Users/nishthasood/Desktop/DSNY_Other_Organics_Collection_Tonnages_20250513.csv") %>%
  rename(Year = `Fiscal Year`,
         Organics_DSNY = `Other Organics Tons Collected - DSNY`,
         Organics_NonDSNY = `Other Organics Tons Collected - Non-DSNY`,
         Organics_Total = `Other Organics Total Tons Collected - DSNY + Non-DSNY`) %>%
  filter(Year %in% 2015:2024)

organics$Organics_Total <- as.numeric(gsub(",", "", organics$Organics_Total))

## 1.3 Median Household Income (ACS)
income <- read_csv("/Users/nishthasood/Desktop/ACSST1Y2023.S1901_2025-05-13T204500/ACSST1Y2023.S1901-Data.csv", skip = 1) %>%
  filter(str_detect(`Geographic Area Name`, "County, New York")) %>%
  select(`Geographic Area Name`, `Estimate!!Households!!Median income (dollars)`)

median_income <- c(
  "Bronx" = income %>% filter(str_detect(`Geographic Area Name`, "^Bronx")) %>% pull(2) %>% as.numeric(),
  "Brooklyn" = income %>% filter(str_detect(`Geographic Area Name`, "^Kings")) %>% pull(2) %>% as.numeric(),
  "Manhattan" = income %>% filter(str_detect(`Geographic Area Name`, "^New York")) %>% pull(2) %>% as.numeric(),
  "Queens" = income %>% filter(str_detect(`Geographic Area Name`, "^Queens")) %>% pull(2) %>% as.numeric(),
  "Staten Island" = income %>% filter(str_detect(`Geographic Area Name`, "^Richmond")) %>% pull(2) %>% as.numeric()
)

## 1.4 Restaurant Count by Borough & Year
restaurants <- read_csv("/Users/nishthasood/Desktop/DOHMH_New_York_City_Restaurant_Inspection_Results_20250513.csv",
                        col_types = cols_only(CAMIS=col_character(), BORO=col_character(), `INSPECTION DATE`=col_character())) %>%
  filter(!is.na(`INSPECTION DATE`) & `INSPECTION DATE` != "01/01/1900") %>%
  mutate(Year = year(mdy(`INSPECTION DATE`))) %>%
  filter(Year %in% 2015:2024)

restaurant_counts <- restaurants %>%
  group_by(Year, BORO) %>%
  summarise(Restaurants = n_distinct(CAMIS), .groups = "drop") %>%
  mutate(Borough = case_when(
    BORO == "Bronx" ~ "Bronx",
    BORO == "Brooklyn" ~ "Brooklyn",
    BORO == "Manhattan" ~ "Manhattan",
    BORO == "Queens" ~ "Queens",
    BORO == "Staten Island" ~ "Staten Island",
    TRUE ~ BORO
  )) %>%
  select(Year, Borough, Restaurants)

# Fill missing year-borough combos with 0
restaurant_counts <- expand.grid(Year = 2015:2024, Borough = names(median_income)) %>%
  left_join(restaurant_counts, by = c("Year", "Borough")) %>%
  replace_na(list(Restaurants = 0))

## 1.5 Population & Density by Borough (2020 Census)
borough_data <- tibble(
  Borough = c("Bronx", "Brooklyn", "Manhattan", "Queens", "Staten Island"),
  Population_2020 = c(1472654, 2736074, 1694251, 2405464, 495747),
  Land_Area_sqmi = c(42.2, 69.4, 22.7, 108.7, 57.5)
) %>%
  mutate(Population_Density = Population_2020 / Land_Area_sqmi)

pop_density <- setNames(borough_data$Population_Density, borough_data$Borough)


# 2. Trend Analysis --------------------------------------------------------

## 2.1 Total Waste Over Time + Forecast
model <- lm(Total_Waste ~ Year, data = annual_waste_city)

forecast_data <- tibble(
  Year = 2025:2027,
  Total_Waste = predict(model, newdata = tibble(Year = 2025:2027))
)

# Combine actual & forecasted
plot_data <- bind_rows(
  annual_waste_city %>% mutate(Source = "Actual"),
  forecast_data %>% mutate(Source = "Forecast")
)

ggplot() +
  geom_line(
    data = annual_waste_city,
    aes(x = factor(Year), y = Total_Waste),
    color = "darkgreen", linewidth = 0.9, group = 1
  ) +
  geom_point(
    data = annual_waste_city,
    aes(x = factor(Year), y = Total_Waste),
    color = "black", size = 2
  ) +
  geom_line(
    data = forecast_data,
    aes(x = factor(Year), y = Total_Waste),
    color = "darkorange", linetype = "dashed", linewidth = 0.9, group = 1
  ) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Annual Food Waste Forecast (2015–2027)",
    subtitle = "Dashed line shows predicted values for 2025–2027",
    x = "Year",
    y = "Total Waste (Tons)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    axis.title = element_text(size = 11),
    axis.text = element_text(size = 10)
  )


aes(x = factor(Year), y = Total_Waste)


## 2.2 Borough-Level Comparisons of Food Waste
ggplot(annual_waste_borough, aes(x = factor(Year), y = Annual_Waste, color = BOROUGH)) +
  geom_line(aes(group = BOROUGH), size = 1) +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Food Waste by Borough (2015–2024)",
    x = "Year",
    y = "Food Waste (Tons)",
    color = "Borough"
  ) +
  theme_minimal()

## 2.3 Composting Rate
compost_rate <- annual_waste_city %>%
  left_join(organics %>% select(Year, Organics_Total), by = "Year") %>%
  mutate(Percent_Composted = (Organics_Total / Total_Waste) * 100)

ggplot(compost_rate, aes(x = factor(Year), y = Percent_Composted)) +
  geom_col(fill = "seagreen") +
  labs(title = "Composting Rate in NYC (2015–2024)", y = "% Composted", x = "Year") +
  theme_minimal()

# 3. Correlation Analysis --------------------------------------------------

# Prepare a borough-level dataset for correlation (using 2024 values for example).
corr_data <- annual_waste_borough %>%
  filter(Year == 2024) %>%
  select(Borough = BOROUGH, Total_Waste = Annual_Waste) %>%
  left_join(restaurant_counts %>% filter(Year == 2024) %>%
              select(Borough, Restaurants), by="Borough") %>%
  mutate(MedianIncome = median_income[Borough],
         Population_Density = pop_density[Borough])

# Compute correlation matrix for Total_Waste and the predictors.
corr_matrix <- cor(corr_data %>% select(Total_Waste, MedianIncome, Restaurants, Population_Density))
print(round(corr_matrix, 3))


### Scatter: Food Waste vs Median Income
ggplot(corr_data, aes(x = MedianIncome, y = Total_Waste, label = Borough)) +
  geom_point(color = "blue", size = 3) +
  geom_text(vjust = -0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "gray50", linetype = "dotted") +
  scale_x_continuous(labels = scales::dollar) +      # Formats Median Income as $XX,XXX
  scale_y_continuous(labels = scales::comma) +       # Formats Food Waste as 120,000 etc.
  labs(
    title = "Food Waste vs Median Household Income (by Borough)",
    x = "Median Household Income (USD)",
    y = "Annual Food Waste (Tons)"
  ) +
  theme_minimal()


### Scatter: Food Waste vs Number of Restaurants
ggplot(corr_data, aes(x = Restaurants, y = Total_Waste, label = Borough)) +
  geom_point(color = "blue", size = 3) +
  geom_text(vjust = -0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "gray50", linetype = "dotted") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Food Waste vs Number of Restaurants (by Borough)",
    x = "Number of Restaurants (2024)",
    y = "Annual Food Waste (Tons)"
  ) +
  theme_minimal()


### Scatter: Food Waste vs Population Density
ggplot(corr_data, aes(x = Population_Density, y = Total_Waste, label = Borough)) +
  geom_point(color = "blue", size = 3) +
  geom_text(vjust = -0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "gray50", linetype = "dotted") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Food Waste vs Population Density (by Borough)",
    x = "Population Density (persons per sq. mile)",
    y = "Annual Food Waste (Tons)"
  ) +
  theme_minimal()


# Correlation heatmap for waste and predictors.
corr_df <- as.data.frame(corr_matrix)
corr_df$Var1 <- rownames(corr_df)
corr_df_melt <- melt(corr_df, id.vars = "Var1", variable.name = "Var2", value.name = "Correlation")

ggplot(corr_df_melt, aes(x = Var1, y = Var2, fill = Correlation)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(
    midpoint = 0,
    low = "steelblue",
    high = "firebrick",
    mid = "white",
    limits = c(-1, 1)
  ) +
  geom_text(aes(label = round(Correlation, 2)), color = "black", size = 3) +
  labs(title = "Correlation Heatmap: Waste & Socioeconomic Factors", x = "", y = "") +
  theme_minimal()


# 4. Linear Regression Model ----------------------------------------------

reg_data <- corr_data
linear_model <- lm(Total_Waste ~ MedianIncome + Restaurants + Population_Density, data=reg_data)
summary(linear_model)

# Calculate R-squared and RMSE for the linear model
rsq <- summary(linear_model)$r.squared
rmse <- sqrt(mean(residuals(linear_model)^2))
cat(sprintf("Linear Model R-squared: %.3f\n", rsq))
cat(sprintf("Linear Model RMSE: %.0f tons\n", rmse))

# 5. Residual Diagnostics for Linear Model
# Plot residuals vs fitted values to check for homoscedasticity and patterns.
if (require(broom, quietly = TRUE)) {
  residual_plot_data <- augment(linear_model) %>%
    select(.fitted, .resid) %>%
    rename(Fitted = .fitted, Residuals = .resid)
} else {
  residual_plot_data <- data.frame(
    Fitted = fitted(linear_model),
    Residuals = resid(linear_model)
  )
}

ggplot(residual_plot_data, aes(x = Fitted, y = Residuals)) +
  geom_point(color = "darkorange", size = 3) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_x_continuous(labels = scales::comma) +  # 👈 Clean, readable X-axis
  labs(
    title = "Residuals vs Fitted Values",
    x = "Fitted Values",
    y = "Residuals"
  ) +
  theme_minimal()



# 6. Poisson Regression (Alternative Approach) ----------------------------

poisson_model <- glm(Total_Waste ~ MedianIncome + Restaurants + Population_Density,
                     data=reg_data, family=poisson)
summary(poisson_model)

# 7. Clustering: Borough Profiles ----------------------------------------

cluster_input <- corr_data %>% select(MedianIncome, Restaurants, Population_Density, Total_Waste)
cluster_scaled <- scale(cluster_input)

set.seed(42)
k3 <- kmeans(cluster_scaled, centers = 3, nstart = 10)
print(data.frame(Borough = corr_data$Borough, Cluster = k3$cluster))

# Get original values for each cluster
centroids <- sweep(sweep(k3$centers, 2, attr(cluster_scaled, "scaled:scale"), "*"),
                   2, attr(cluster_scaled, "scaled:center"), "+")
print(centroids)

# End
