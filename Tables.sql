CREATE TABLE customers(
    customer_id VARCHAR(50) PRIMARY KEY,
    gender VARCHAR(10),
    age INTEGER not null
);

SELECT * FROM customers;

CREATE TABLE products_nw(
    product_id VARCHAR(50) PRIMARY KEY,
    product_category VARCHAR(100) NOT NULL,
    price  DECIMAL(10,2),
    payment_method VARCHAR(50),
    date DATE not NULL
);

SELECT * FROM products_nw;

CREATE TABLE retail_new(
    date DATE NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INTEGER not null,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products_nw(product_id)
);



SELECT * FROM retail_new;