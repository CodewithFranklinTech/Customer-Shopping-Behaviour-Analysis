# Load libraries 
library(tidyverse)
library(dplyr)
library(ggplot2)

# Load the dataset 
online_retail <- read_csv("online_retail.csv", show_col_types = FALSE)
online_retail

# Inspect the dataset. 
str(online_retail)
summary(online_retail)
glimpse(online_retail)

# Check for missing values
anyNA(online_retail)
colSums(is.na(online_retail))

# Remove rows with missing CustomerID and Description.
online_retail_clean <- online_retail %>%
  filter(!is.na(CustomerID), !is.na(Description))
online_retail_clean

# Confirm no missing values
colSums(is.na(online_retail_clean[, c("CustomerID", "Description")]))

# Add a purchase_amount column: Quantity * UnitPrice.
online_retail_clean <- online_retail_clean %>%
  mutate(
    purchase_amount = Quantity * UnitPrice
  )
online_retail_clean

# Create a product_category column using keywords in Description
online_retail_clean <- online_retail_clean %>%
  mutate(
    product_category = case_when(
      grepl("IPOD|USB|RADIO|HEADPHONE|PHONE", Description, ignore.case = TRUE) ~ "Electronics",
      grepl("T-SHIRT|JUMPER|DRESS|BAG|SCARF", Description, ignore.case = TRUE) ~ "Clothing",
      grepl("CANDLE|MUG|PLATE|TEA", Description, ignore.case = TRUE) ~ "Home & Kitchen",
      grepl("PEN|NOTEBOOK|PAPER", Description, ignore.case = TRUE) ~ "Office Supplies",
      grepl("CANDY|COFFEE|TEA|FOOD", Description, ignore.case = TRUE) ~ "Groceries",
      grepl("PUZZLE|TOY|BOARD GAME", Description, ignore.case = TRUE) ~ "Toys & Games",
      TRUE ~ "Miscellaneous"
    )
  )
online_retail_clean

# Assign gender using CustomerID to make it reproducible and realistic: 
# Example: odd CustomerID → Male, even CustomerID → Female
online_retail_clean <- online_retail_clean %>%
  mutate(
    gender = if_else(CustomerID %% 2 == 0, "Female", "Male")
  )
online_retail_clean

# Convert these to factors: product_category, gender, Country
online_retail_clean <- online_retail_clean %>%
  mutate(
    Country = factor(Country),
    product_category = factor(product_category),
    gender = factor(gender)
  )
online_retail_clean

# Which product category generates the highest total revenue?
product_cate <- online_retail_clean %>%
  group_by(product_category) %>%
  summarise(total_revenue = sum(purchase_amount)) %>%
  arrange(desc(total_revenue))
product_cate

# Which country has the highest total purchase amount?
country_highest_purchase <- online_retail_clean %>%
  group_by(Country) %>%
  summarise(total_purchase_amount = sum(purchase_amount)) %>%
  arrange(desc(total_purchase_amount))
country_highest_purchase

# Which gender spends more on average?
gender_average <- online_retail_clean %>%
  group_by(gender) %>%
  summarise(avg_gender_spend = mean(purchase_amount)) %>%
  arrange(desc(avg_gender_spend))
gender_average

# Find the top 10 customers by total purchase_amount.
top_ten_customers <- online_retail_clean %>%
  group_by(CustomerID) %>%
  summarise(total_purchase = sum(purchase_amount)) %>%
  slice_max(total_purchase, n = 10)
top_ten_customers

# Find orders where purchase_amount > 1000.
high_value_orders <- online_retail_clean %>%
  filter(purchase_amount > 1000)
high_value_orders

# Analyze average purchase_amount per product_category.
product_cate_average <- online_retail_clean %>%
  group_by(product_category) %>%
  summarise(avg_product_category = mean(purchase_amount)) %>%
  arrange(desc(avg_product_category))
product_cate_average

# Filter dataset to UK only to make it more realistic.
uk_country <- online_retail_clean %>%
  filter(Country == "United Kingdom")
uk_country

# Remove negative quantities (returns) if needed.
online_retail_clean <- online_retail_clean %>%
  filter(Quantity > 0)
online_retail_clean

# Create a new column price_range: Low, Medium, High purchase_amount.
online_retail_clean <- online_retail_clean %>%
  mutate(
    price_range = case_when(
      purchase_amount < 4.2 ~ "Low",
      purchase_amount >= 4.2 & purchase_amount <= 19.5 ~ "Medium",
      purchase_amount > 19.5 ~ "High"
    )
  )
online_retail_clean

# Calculate average purchase per customer to find loyal high-value customers.
high_value_customers <- online_retail_clean %>%
  group_by(CustomerID) %>%
  summarise(avg_purchase_customer = mean(purchase_amount)) %>%
  arrange(desc(avg_purchase_customer))
high_value_customers

# Create a bar chart of Product Category vs Total Revenue
online_retail_clean %>%
  group_by(product_category) %>%
  summarise(total_revenue = sum(purchase_amount)) %>%
  arrange(product_category) %>%
  ggplot(aes(x = product_category, y = total_revenue, fill = product_category)) +
  geom_col() +
  labs(
    title = "Product Category vs Total Revenue",
    x = "Product Category",
    y = "Total Revenue"
  ) +
  coord_flip()

# Create a bar chart Country vs Total Revenue
online_retail_clean %>%
  group_by(Country) %>%
  summarise(total_revenue = sum(purchase_amount)) %>%
  arrange(Country) %>%
  ggplot(aes(x = Country, y = total_revenue, fill = Country)) +
  geom_col() +
  labs(
    title = "Country vs Total Revenue",
    x = "Country",
    y = "Total Revenue"
  ) +
  coord_flip()

# Create a bar chart Gender vs Average Purchase
online_retail_clean %>%
  group_by(gender) %>%
  summarise(avg_purchase = mean(purchase_amount)) %>%
  arrange(gender) %>%
  ggplot(aes(x = gender, y = avg_purchase, fill = gender)) +
  geom_col() +
  labs(
    title = "Gender vs Average Purchase",
    x = "Gender",
    y = "Average Purchase"
  )

# Create a bar chart showing the Top 10 Products by Revenue
online_retail_clean %>%
  group_by(Description) %>%
  summarise(total_revenue = sum(purchase_amount)) %>%
  slice_max(total_revenue, n = 10) %>%
  ggplot(aes(x = reorder(Description, total_revenue), 
             y = total_revenue, fill = Description)) +
  geom_col() +
  labs(
    title = "Top 10 Products by Revenue",
    x = "Product",
    y = "Total Revenue"
  ) +
  coord_flip()

# Create a histogram Distribution of purchase_amount
ggplot(online_retail_clean, aes(x = purchase_amount)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "black") +
  labs(
    title = "Distribution of Customer Purchase Amount",
    x = "Purchase Amount",
    y = "Number of Purchases"
  ) +
  theme_minimal()













