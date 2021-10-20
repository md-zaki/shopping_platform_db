USE SSP3G5;

DROP TABLE IF EXISTS OrderDetails
DROP TABLE IF EXISTS Payment
DROP TABLE IF EXISTS Shipment
DROP TABLE IF EXISTS Invoice
DROP TABLE IF EXISTS Orders
DROP TABLE IF EXISTS Restricted
DROP TABLE IF EXISTS ProductType
DROP TABLE IF EXISTS Product
DROP TABLE IF EXISTS Shop
DROP TABLE IF EXISTS CreditCard
DROP TABLE IF EXISTS Customer


CREATE TABLE Customer
(
	cust_id int NOT NULL IDENTITY(1,1),
	username varchar(255) NOT NULL,
	email varchar(255) NOT NULL,
	full_name varchar(255) NOT NULL,
	cust_address varchar(255) NOT NULL,
	cust_password varchar(255) NOT NULL,
	phone_num varchar(255),
	PRIMARY KEY(cust_id)
);


CREATE TABLE CreditCard
(
	card_num varchar(255) NOT NULL,
	cust_id int NOT NULL,
	PRIMARY KEY (card_num),
	FOREIGN KEY (cust_id) REFERENCES Customer(cust_id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Shop
(
	shop_id int NOT NULL IDENTITY(1,1),
	shop_name varchar(255) NOT NULL,
	PRIMARY KEY (shop_id)
);


CREATE TABLE Product
(
	product_id int NOT NULL IDENTITY(1,1),
	product_name varchar(255) NOT NULL,
	color varchar(255) NOT NULL,
	prod_description varchar(255) NOT NULL,
	price money NOT NULL,
	size varchar(255) NOT NULL,
	p_type_id int NOT NULL,
	shop_id int NOT NULL,
	PRIMARY KEY (product_id),
	FOREIGN KEY (shop_id) REFERENCES Shop(shop_id) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE ProductType
(
	p_type_id int NOT NULL IDENTITY(1,1),
	p_type_description varchar(255) NOT NULL,
	parent_id int,
	PRIMARY KEY (p_type_id)
);


CREATE TABLE Restricted
(
	shop_id int NOT NULL,
	p_type_id int NOT NULL,
	PRIMARY KEY(shop_id, p_type_id),
	FOREIGN KEY (shop_id) REFERENCES Shop(shop_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (p_type_id) REFERENCES ProductType(p_type_id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Orders
(
	order_id int NOT NULL IDENTITY(1,1),
	order_date date NOT NULL,
	order_status varchar(255) NOT NULL CHECK (order_status IN ('processing', 'completed', 'cancelled')),
	cust_id int NOT NULL,
	PRIMARY KEY (order_id),
	FOREIGN KEY (cust_id) REFERENCES Customer(cust_id)
);


CREATE TABLE Invoice
(
	invoice_num int NOT NULL IDENTITY(1,1),
	invoice_date date NOT NULL,
	invoice_status varchar(255) NOT NULL CHECK (invoice_status IN ('issued', 'paid')),
	amount_paid money NOT NULL,
	amount_total money NOT NULL,
	is_fully_paid int NOT NULL CHECK(is_fully_paid=0 OR is_fully_paid=1),
	order_id int NOT NULL UNIQUE,
	PRIMARY KEY (invoice_num),
	FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK (amount_total > 0)
);


CREATE TABLE Shipment
(
	shipment_id int NOT NULL IDENTITY(1,1),
	product_id int NOT NULL,
	ship_date date NOT NULL,
	tracking_num int NOT NULL,
	invoice_num int NOT NULL,
	
	PRIMARY KEY (shipment_id),
	FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (invoice_num) REFERENCES Invoice(invoice_num) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Payment
(
	payment_id int NOT NULL IDENTITY(1,1),
	payment_date date NOT NULL,
	payment_amount money NOT NULL,
	cust_id int NOT NULL,
	invoice_num int NOT NULL,
	PRIMARY KEY (payment_id),
	FOREIGN KEY (cust_id) REFERENCES Customer(cust_id),
	FOREIGN KEY (invoice_num) REFERENCES Invoice(invoice_num)
);

CREATE TABLE OrderDetails
(
	order_id int NOT NULL,
	product_id int NOT NULL,
	seq_num int NOT NULL,
	order_status varchar(255) NOT NULL CHECK (order_status IN ('processing', 'shipped', 'out of stock')),
	qty int NOT NULL,
	unit_price money NOT NULL,
	PRIMARY KEY(order_id, seq_num),
	FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
);