# ☕ Sales Analysis for Monday Coffee with SQL
![ChatGPT Image Apr 6, 2025, 01_14_22 PM](https://github.com/user-attachments/assets/26041f8f-c1b5-4edf-9eed-a38c0e3f5af0)



##  Objective
The goal of this project is to analyze the sales data of **Monday Coffee**, a company that has been selling its coffee products online since **January 2023**.  
The main objective is to recommend the **top three cities in India** where the company can open new physical coffee shop locations based on:
- Consumer demand
- Sales performance
- Cost-efficiency

## Dataset Overview

The project uses four main tables:

| Table Name | Description |
|------------|-------------|
| `city` | Contains city-level data including population, estimated rent, and ranking |
| `products` | List of coffee products and their pricing |
| `customers` | Customer profiles including city |
| `sales` | Sales transactions including date, product, customer, amount, and rating |


## Key Analysis Performed

1. **Estimated Coffee Consumers**  
   Identify top cities based on 25% of the population being potential coffee drinkers.

2. **Total Revenue in Q4 2023**  
   Calculate sales from October to December 2023.

3. **Top-Selling Products**  
   Find which products are most popular by volume sold.

4. **Average Sales per Customer per City**  
   Discover which cities have the highest customer spending.

5. **Compare Estimated vs Actual Buyers**  
   Compare estimated coffee consumers vs actual unique buyers by city.

6. **Top 3 Products in Each City**  
   What are the top 3 selling products in each city based on sales volume?

7. **Unique Customers by City**  
   Total number of different customers per city.

8. **Average Rent vs Sales per Customer**  
   Analyze profitability by comparing rent to revenue per customer.

9. **Sales Growth Rate (Monthly)**  
   Monthly percentage growth/decline in total sales.

10. **Top 3 Cities for New Stores**  
   Final decision based on revenue, cost, customer engagement, and market size.


## Final Recommendations

Based on the SQL analysis, the recommended cities for new store openings are:

### 📍 1. Pune
- Highest total revenue (₹1.25M)
- Strong average sales per customer (₹24,197.88)
- Very low rent per customer (₹294.23)

### 📍 2. Delhi
- Highest estimated coffee consumers (7.75M)
- High number of unique customers (68)
- Rent per customer still manageable (₹330.88)

### 📍 3. Jaipur
- Highest actual customer count (69)
- Lowest rent per customer (₹156.52)
- Solid average sales per customer (₹11,644.20)

---
