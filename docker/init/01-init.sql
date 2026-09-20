CREATE TABLE orders (
    row_id INTEGER,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT,
    sales NUMERIC(12,2),
    quantity INTEGER,
    discount NUMERIC(5,2),
    profit NUMERIC(12,2)
);

CREATE TABLE people (
    person VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE returns (
    returned VARCHAR(10),
    order_id VARCHAR(50)
);

COPY orders
FROM '/data/orders.csv'
DELIMITER ','
CSV HEADER;

COPY people
FROM '/data/people.csv'
DELIMITER ','
CSV HEADER;

COPY returns
FROM '/data/returns.csv'
DELIMITER ','
CSV HEADER;