Overview

The Gold Layer represents the business-level data model of the data warehouse. It is designed to provide clean, standardized, and business-ready data for analytical queries, reporting, and business intelligence. The layer consists of dimension tables that provide descriptive context and a fact table that stores measurable business events.

---

## 1. gold.dim_customers

**Purpose:** Stores customer information enriched with demographic and geographic attributes.

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | INT | Surrogate key uniquely identifying each customer record in the dimension. |
| `customer_id` | INT | Unique identifier of the customer from the source system. |
| `customer_number` | NVARCHAR(50) | Business identifier used to identify and track the customer. |
| `first_name` | NVARCHAR(50) | Customer's first name. |
| `last_name` | NVARCHAR(50) | Customer's last name. |
| `country` | NVARCHAR(50) | Country associated with the customer. |
| `marital_status` | NVARCHAR(50) | Customer's marital status. |
| `gender` | NVARCHAR(50) | Customer's gender. |
| `birthdate` | DATE | Customer's date of birth. |
| `create_date` | DATE | Date when the customer record was created. |

---

## 2. gold.dim_products

**Purpose**: Stores product information enriched with category, subcategory, and product-line attributes.

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | INT | Surrogate key uniquely identifying each product record in the dimension. |
| `product_id` | INT | Unique identifier of the product from the source system. |
| `product_number` | NVARCHAR(50) | Business identifier used to identify and track the product. |
| `product_name` | NVARCHAR(50) | Name of the product. |
| `category_id` | NVARCHAR(50) | Identifier of the product category. |
| `category` | NVARCHAR(50) | High-level category to which the product belongs. |
| `subcategory` | NVARCHAR(50) | Subcategory providing a more detailed classification of the product. |
| `maintenance` | NVARCHAR(50) | Indicates whether maintenance is required or applicable for the product. |
| `cost` | INT | Standard cost associated with the product. |
| `product_line` | NVARCHAR(50) | Product line classification of the product. |

---

## 3. gold.fact_sales

**Purpose**: Stores sales transactions at the order-line level, including transactional measures and references to related dimensions.

| Column Name | Data Type | Description |
|---|---|---|
| `order_number` | NVARCHAR(50) | Identifier of the sales order. |
| `product_key` | INT | Foreign key referencing the product dimension. |
| `customer_key` | INT | Foreign key referencing the customer dimension. |
| `order_date` | DATE | Date when the sales order was placed. |
| `shipping_date` | DATE | Date when the sales order was shipped. |
| `due_date` | DATE | Expected delivery or due date of the sales order. |
| `sales` | INT | Total sales amount for the order line. |
| `quantity` | INT | Number of units sold. |
| `price` | INT | Selling price per unit. |

