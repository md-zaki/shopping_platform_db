/*
Query 1, Get product ids not yet shipped by customer email
We use product name since we don't have product id
*/
DECLARE @cust_email varchar(255)
SET @cust_email = 'email3.com'

/*
Get product names that customer has ordered
*/
SELECT product_id 
FROM OrderDetails OD
WHERE OD.order_id IN (   
    SELECT order_id
    FROM Orders
    WHERE cust_id = (
        SELECT cust_id
        FROM Customer
        WHERE email = @cust_email
    )
) 
/*
Get product names that aren't shipped for all invoices related to user
and have been paid either partially or fully
*/
AND product_id NOT IN (
    SELECT product_id
    FROM Shipment
    WHERE invoice_num IN (
        SELECT invoice_num
        FROM Invoice
        WHERE order_id = OD.order_id
        AND amount_paid > 0
    )
);

SELECT * FROM OrderDetails, Customer;


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
Query 5, get 3 random customers' emails
*/
SELECT TOP 3 email
FROM Customer
ORDER BY NEWID()