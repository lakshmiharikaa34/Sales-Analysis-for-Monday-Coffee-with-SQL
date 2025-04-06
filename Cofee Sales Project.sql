CREATE DATABASE Coffee_Sales;

use Coffee_Sales;

CREATE TABLE city (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(50) NOT NULL,    
    population BIGINT NOT NULL,
    estimated_rent DECIMAL(10,2) NOT NULL,
    city_rank INT NOT NULL CHECK (city_rank > 0)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50) NOT NULL,    
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,    
    customer_name VARCHAR(50) NOT NULL,    
    city_id INT NOT NULL,
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id) ON DELETE CASCADE
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    sale_date DATE NOT NULL,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);


select * from city;
select * from products;
select * from customers;
select * from sales;

## ANANLYSIS

#1. How many people are estiamted to consume cofee ,given that 25% of the population does?

SELECT 
    city_name, 
    ROUND((population * 0.25) / 1000000, 2) AS coffee_consumers_in_millions, 
    city_rank  
FROM 
    city
ORDER BY 
    (population * 0.25) DESC
LIMIT 5;

# INSIGHT
## From this, we can say that Delhi and Mumbai have the highest number of coffee consumers in millions.
## The first five cities in the list are the top targets for the company because they have the highest number of coffee consumers.


#2. What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
    
SELECT 
    SUM(total) AS total_revenue 
FROM 
    sales 
WHERE 
    sale_date BETWEEN "2023-10-01" AND "2023-12-31";

## INSIGHT
# The total revenue generated from coffee sales across all cities in the last quarter of 2023 is **1,963,300.00**. This indicates strong customer demand during October to December, possibly due to increased consumption in colder months and holiday season.

#3. How many units of each coffee product have been sold?

SELECT 
    p.product_name, 
    COUNT(s.product_id) AS total_units_sold
FROM 
    sales s
JOIN 
    products p ON s.product_id = p.product_id
GROUP BY 
    p.product_name;

# INSIGHT
## Cold Brew Coffee Pack(6 Bottles) has the highest number of units sold with **1,326 sales**, followed closely by Ground Espresso Coffee(250g) and Instant Coffee Powder(100g). 
## These three products are the most popular and should be prioritized for marketing, inventory restocking, and promotions.

#4. What is the average sales amount per customer in each city?

SELECT 
    c.city_name,
    ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sales_per_customer
FROM 
    sales s
JOIN 
    customers cu ON s.customer_id = cu.customer_id
JOIN 
    city c ON cu.city_id = c.city_id
GROUP BY 
    c.city_name
ORDER BY
	avg_sales_per_customer DESC;
    
# INSIGHT
## Pune, Chennai, and Bangalore have the **highest average sales per customer**, with Pune leading at ₹24,197.88. This indicates strong individual customer spending in these cities.
## Cities like Jaipur and Delhi also show high averages above ₹11,000, highligh

#5. Compare the estimated coffee consumers (25% of city population) with the actual unique customers in each city.

SELECT 
    ci.city_name,
    ROUND((ci.population * 0.25) / 1000000, 2) AS coffee_consumer_in_millions,
    COUNT(DISTINCT cu.customer_id) AS unique_customers
FROM 
    city ci
JOIN 
    customers cu ON ci.city_id = cu.city_id
JOIN 
    sales s ON s.customer_id = cu.customer_id
GROUP BY 
    ci.city_name, ci.population
ORDER BY 
	unique_customers DESC;
    
# INSIGHT
## Delhi and Jaipur record the greatest number of single customers (68 and 69), although estimated consumers of coffee in cities like Mumbai and Kolkata are greater.
## This indicates that some of the smaller cities are doing better at reaching their coffee-consuming audience, while larger cities might still have untapped potential.


#6. What are the top 3 selling products in each city based on sales volume?

SELECT * 
FROM (
    SELECT 
        ci.city_name,
        p.product_name,
        COUNT(s.sale_id) AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC
        ) AS rank_in_city
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY ci.city_name, p.product_name
) AS ranked
WHERE rank_in_city <= 3
ORDER BY city_name, rank_in_city;

# INSIGHT
## In every city, the **Cold Brew Coffee Pack (6 Bottles)** is the most sold product, consistently ranked #1 in Ahmedabad, Bangalore, and Chennai.
## Other popular products include **Ground Espresso Coffee (250g)** and **Instant Coffee Powder (100g)**, which frequently appear in the top 3. 
## This indicates that multi-pack and instant coffee options are the most preferred choices across cities and should be prioritized for stock and promotion.

#7. How many unique customers are there in each city who have purchased coffee products?

SELECT 
    ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_customers
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY unique_customers DESC;

# INSIGHT
## Delhi and Jaipur have the most unique coffee customers with 69 and 68 respectively. Both of these cities reflect good customer engagement.
## Other cities like Pune and Chennai also score well, whereas Mumbai and Kolkata have fewer unique customers even though they are big cities, suggesting that there is growth potential.

#8. Find each city and their average sale per customer and avg rent per customer

SELECT 
    ci.city_name,
    ROUND(SUM(s.total) / COUNT(DISTINCT c.customer_id), 2) AS avg_sale_per_customer,
    ROUND(ci.estimated_rent / COUNT(DISTINCT c.customer_id), 2) AS avg_rent_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name, ci.estimated_rent
ORDER BY avg_sale_per_customer DESC;

# INSIGHT
## Pune, Chennai, and Bangalore show the highest **average sales per customer**, with Pune leading at ₹24,197.88. These cities reflect strong customer spending behavior.
## However, Mumbai and Hyderabad have the **highest average rent per customer** (₹1,166.67 and ₹1,071.43 respectively), suggesting a higher cost of living but lower coffee spending per customer.

#9.Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(s.sale_date, '%Y-%m') AS month,
        SUM(s.total) AS total_sales
    FROM sales s
    GROUP BY month
),
growth_rate AS (
    SELECT 
        m1.month,
        m1.total_sales,
        LAG(m1.total_sales) OVER (ORDER BY m1.month) AS prev_month_sales
    FROM monthly_sales m1
)

SELECT 
    month,
    total_sales,
    prev_month_sales,
    ROUND(((total_sales - prev_month_sales) / prev_month_sales) * 100, 2) AS sales_growth_percentage
FROM growth_rate;

# 10. Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

SELECT 
    ci.city_name,
    ROUND(SUM(s.total), 2) AS total_sales,
    ci.estimated_rent AS total_rent,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND((ci.population * 0.25)) AS estimated_coffee_consumers
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name, ci.estimated_rent, ci.population
ORDER BY total_sales DESC
LIMIT 3;

# INSIGHT
## The top 3 cities based on total sales are **Pune**, **Chennai**, and **Bangalore**.
## **Pune** leads with ₹1,252,890 in sales from 52 customers, despite having the lowest estimated coffee consumers among the three.
## **Chennai** has the second-highest sales and the second-highest estimated coffee consumers.
## **Bangalore**, while having the highest estimated coffee consumer base (3.07 million), ranks third in total sales, indicating untapped potential.
