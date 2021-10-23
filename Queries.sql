/*
Query 1, Get product ids not yet shipped by customer email
We use product name since we don't have product id
*/
DECLARE @cust_email varchar(255)
SET @cust_email = 'email3.com'

SELECT product_id
FROM OrderDetails
WHERE order_id =(SELECT order_id
		FROM Orders
		WHERE cust_id =(SELECT cust_id
				FROM Customer
				WHERE email = @cust_email))
AND EXISTS(
	SELECT invoice_num
	FROM Invoice
	WHERE amount_paid > 0
	AND order_id =(SELECT order_id
		FROM Orders
		WHERE cust_id =(SELECT cust_id
				FROM Customer
				WHERE email = @cust_email)));


/*
Query 2, get top 3 best selling product type ids
*/

/*
Order by total qty ordered and only get top 3
*/
SELECT TOP 3 p_type_id, qty_ordered FROM (
    /*
    2 column table with p_type_id and total qty ordered for that id
    */
    SELECT p_type_id, SUM(qty) AS qty_ordered
    FROM Product P
    LEFT JOIN OrderDetails OD ON OD.product_id = P.product_id
    GROUP BY p_type_id
) subquery
ORDER BY qty_ordered DESC

SELECT * FROM Product P JOIN OrderDetails OD ON OD.product_id = P.product_id;

/*
Query 3, get description of 2nd level product types
*/

/*
Check if != 0 because <> NULL doesn't work
*/
SELECT p_type_description 
FROM ProductType 
WHERE parent_id IN (
	SELECT p_type_id 
	FROM ProductType 
	WHERE parent_id IS NULL
);

SELECT * FROM ProductType;


/*
Query 4, find 2 product names that are ordered the most
*/


/*
Create a view that groups product id in pairs if and only if they exist in the same order id.
Total_times_ordered_tgt stores the number of times these pairs appear in orders
*/
CREATE VIEW
num_times
AS
SELECT O1.product_id AS first_prod, O2.product_id AS second_prod, COUNT(*) AS total_times_ordered_tgt
FROM OrderDetails AS O1, OrderDetails AS O2
WHERE O1.order_id=O2.order_id
AND O1.product_id < O2.product_id
GROUP BY O1.product_id, O2.product_id;

GO

/*
Select the pair of products = to the max_times of total_times_ordered_tgt
*/
SELECT first_prod, second_prod
FROM num_times
WHERE total_times_ordered_tgt =(
SELECT max(total_times_ordered_tgt) as max_times
FROM num_times);

DROP VIEW num_times

/*
Query 5, get 3 random customers' emails
*/
SELECT TOP 3 email
FROM Customer
ORDER BY NEWID()

/*
Query 6, Find the average number of days each item takes to ship
*/

SELECT * FROM Invoice;
SELECT * FROM Shipment;


SELECT product_id, AVG(DATEDIFF(day, invoice_date, ship_date)) AS "AvgDaysToShip"
FROM Invoice, Shipment
WHERE Invoice.invoice_num = Shipment.invoice_num
GROUP BY product_id;

/*
Query 7, Find the total amount saved for each customer
*/

SELECT o.order_id, o.cust_id, od.product_id, od.qty, od.unit_price,p.price
FROM orders as o, OrderDetails as od, Product as p
WHERE o.order_id=od.order_id
AND od.product_id=p.product_id

SELECT o.cust_id, SUM(p.price-od.unit_price) as total_savings
FROM orders as o, OrderDetails as od, Product as p
WHERE o.order_id=od.order_id
AND od.product_id=p.product_id
GROUP BY o.cust_id