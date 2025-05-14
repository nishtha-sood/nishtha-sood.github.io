dir.create("~/Desktop/FoodWasteNYC")
setwd("~/Desktop/FoodWasteNYC")
getwd()

install.packages("tidyverse")
install.packages("lubridate")
library(tidyverse)
library(lubridate)

# ---------------------------
# 1. CLEAN FOOD WASTE DATA
# ---------------------------

monthly <- read_csv("/Users/nishthasood/Desktop/DSNY_Monthly_Tonnage_Data_20250513.csv")

monthly_clean <- monthly %>%
  mutate(
    Month_Clean = str_replace_all(MONTH, " / ", "-"),
    Month = ym(Month_Clean),
    Year = year(Month),
    Refuse = as.numeric(REFUSETONSCOLLECTED),
    Paper = as.numeric(PAPERTONSCOLLECTED),
    MGP = as.numeric(MGPTONSCOLLECTED),
    ResOrg = as.numeric(RESORGANICSTONS),
    SchOrg = as.numeric(SCHOOLORGANICTONS),
    Leaves = as.numeric(LEAVESORGANICTONS),
    Xmas = as.numeric(XMASTREETONS),
    Total_Waste = rowSums(across(c(Refuse, Paper, MGP, ResOrg, SchOrg, Leaves, Xmas)), na.rm = TRUE)
  ) %>%
  filter(!is.na(BOROUGH), Year >= 2015, Year <= 2024)

# Total annual food waste
annual_waste <- monthly_clean %>%
  group_by(Year) %>%
  summarise(Total_Tons = sum(Total_Waste, na.rm = TRUE))

write_csv(annual_waste, "annual_waste.csv")

# Borough-wise waste
borough_waste <- monthly_clean %>%
  group_by(Year, BOROUGH) %>%
  summarise(Total_Tons = sum(Total_Waste, na.rm = TRUE)) %>%
  rename(Borough = BOROUGH)

write_csv(borough_waste, "borough_waste.csv")

# ---------------------------
# 2. CLEAN COMPOST DATA
# ---------------------------

organics <- read_csv("/Users/nishthasood/Desktop/DSNY_Other_Organics_Collection_Tonnages_20250513.csv")

organics_clean <- organics %>%
  rename(
    Year = `Fiscal Year`,
    DSNY = `Other Organics Tons Collected - DSNY`,
    Non_DSNY = `Other Organics Tons Collected - Non-DSNY`,
    Total_Organics = `Other Organics Total Tons Collected - DSNY + Non-DSNY`
  ) %>%
  filter(Year >= 2015, Year <= 2024) %>%
  mutate(across(c(DSNY, Non_DSNY, Total_Organics), ~ as.numeric(gsub(",", "", .))))

# ---------------------------
# 3. CLEAN RESTAURANT DATA
# ---------------------------

restaurants <- read_csv("/Users/nishthasood/Desktop/DOHMH_New_York_City_Restaurant_Inspection_Results_20250513.csv")

restaurant_clean <- restaurants %>%
  mutate(
    Year = year(mdy(`INSPECTION DATE`)),
    BORO = str_trim(str_to_upper(BORO))
  ) %>%
  filter(Year >= 2015 & Year <= 2024) %>%
  group_by(BORO) %>%
  summarise(Restaurant_Count = n_distinct(CAMIS)) %>%
  mutate(Borough = case_when(
    BORO == "BRONX" ~ "Bronx",
    BORO == "BROOKLYN" ~ "Brooklyn",
    BORO == "MANHATTAN" ~ "Manhattan",
    BORO == "QUEENS" ~ "Queens",
    BORO == "STATEN ISLAND" ~ "Staten Island"
  )) %>%
  select(Borough, Restaurant_Count)

# ---------------------------
# 4. CLEAN INCOME DATA
# ---------------------------

income <- read_csv("/Users/nishthasood/Desktop/ACSST1Y2023.S1901-Data.csv")

income_clean <- income %>%
  filter(GEO_ID %in% c("0500000US36005", "0500000US36047", "0500000US36061", "0500000US36081", "0500000US36085")) %>%
  mutate(
    Borough = case_when(
      GEO_ID == "0500000US36005" ~ "Bronx",
      GEO_ID == "0500000US36047" ~ "Brooklyn",
      GEO_ID == "0500000US36061" ~ "Manhattan",
      GEO_ID == "0500000US36081" ~ "Queens",
      GEO_ID == "0500000US36085" ~ "Staten Island"
    ),
    Median_Income = as.numeric(S1901_C01_012E)
  ) %>%
  select(Borough, Median_Income)

# ---------------------------
# 5. MANUAL POPULATION TABLE
# ---------------------------

population_clean <- tribble(
  ~Borough,        ~Population, ~Area_sqmi,
  "Bronx",         1472654,     42.1,
  "Brooklyn",      2559903,     69.4,
  "Manhattan",     1628706,     22.8,
  "Queens",        2253858,     108.7,
  "Staten Island", 495747,      57.5
) %>%
  mutate(Population_Density = Population / Area_sqmi)

# ---------------------------
# 6. COMBINE FINAL MODEL DATA
# ---------------------------

borough_totals <- borough_waste %>%
  group_by(Borough) %>%
  summarise(Total_Tons = sum(Total_Tons, na.rm = TRUE))

final_model_data <- borough_totals %>%
  left_join(income_clean, by = "Borough") %>%
  left_join(population_clean, by = "Borough") %>%
  left_join(restaurant_clean, by = "Borough")

write_csv(final_model_data, "final_model_data.csv")

# ---------------------------
# 7. COMPOST % TABLE
# ---------------------------

citywide_totals <- borough_waste %>%
  group_by(Year) %>%
  summarise(Total_Food_Waste = sum(Total_Tons, na.rm = TRUE))

waste_vs_compost <- organics_clean %>%
  left_join(citywide_totals, by = "Year") %>%
  mutate(
    Percent_Composted = round((Total_Organics / Total_Food_Waste) * 100, 2)
  )

write_csv(waste_vs_compost, "waste_vs_compost.csv")
