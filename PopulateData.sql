USE SSP3G5;

DELETE FROM OrderDetails;
DELETE FROM Payment;
DELETE FROM Shipment;
DELETE FROM Invoice;
DELETE FROM Orders;
DELETE FROM Restricted;
DELETE FROM ProductType;
DELETE FROM Product;
DELETE FROM Shop;
DELETE FROM CreditCard;
DELETE FROM Customer;

INSERT INTO Customer
VALUES
    ('username1', 'email1.com', 'fullname1', 'blk1231', 'pw1', '123456781'),
    ('username2', 'email2.com', 'fullname2', 'blk1232', 'pw2', '123456782'),
    ('username3', 'email3.com', 'fullname3', 'blk1233', 'pw3', '123456783'),
    ('username4', 'email4.com', 'fullname4', 'blk1234', 'pw4', '123456784'),
    ('username5', 'email5.com', 'fullname5', 'blk1235', 'pw5', '123456785'),
    ('username6', 'email6.com', 'fullname6', 'blk1236', 'pw6', '123456786');


INSERT INTO CreditCard
VALUES
    ('213093712012', 1),
    ('231098102374', 2),
    ('320947209813', 3),
    ('409580472313', 4),
    ('085987434923', 5),
    ('098479832124', 6);


INSERT INTO Shop
VALUES
    ('shop1'),
    ('shop2'),
    ('shop3'),
    ('shop4');


INSERT INTO ProductType
VALUES
    ('Foodstuff', NULL),
    ('Toys', NULL),
    ('Cutlery', NULL),
    ('Electronics', NULL),
    ('Furniture', NULL),
    ('Smartphones', 4),
    ('Fruits', 1);

INSERT INTO Restricted
VALUES
    (1, 1),
    (1, 7),
    (2, 4),
    (2, 6);


/*
Product has to be inserted individually because of trigger limitations
*/
INSERT INTO Product
VALUES('Apple', 'Red', 'It is an apple', 0.70, 'M', 1, 1);

INSERT INTO Product
VALUES('iPhone 13', 'Purple', 'The latest iPhone', 1200, 'M', 6, 2);

INSERT INTO Product
VALUES('Mahogany Table', 'Brown', 'Only the finest handcrafted table', 2500, 'L', 5, 3);


INSERT INTO Orders
VALUES
    ('2021-10-20', 'processing', 1),
    ('2021-10-20', 'processing', 1),
    ('2021-10-20', 'processing', 2),
    ('2021-10-20', 'processing', 3);


INSERT INTO Invoice
VALUES
    ('2021-10-20', 'issued', 0, 1.4, 0, 1),
    ('2021-10-20', 'issued', 0, 1200, 0, 2),
    ('2021-10-20', 'issued', 0, 3700, 0, 3),
    ('2021-10-20', 'issued', 0, 1200, 0, 4);


INSERT INTO OrderDetails
VALUES
    (1, 1, 1, 'processing', 2, 1.4),
    (2, 2, 1, 'processing', 1, 1200),
    (3, 2, 1, 'processing', 1, 1200),
    (3, 3, 2, 'processing', 1, 2500),
    (4, 2, 1, 'processing', 1, 120);


/*
Shipment has to be inserted individually because of trigger limitations
*/
INSERT INTO Shipment
VALUES(1, '2021-10-20', 84952, 1);

INSERT INTO Shipment
VALUES(2, '2021-10-20', 74192, 2);

INSERT INTO Shipment
VALUES(2, '2021-10-20', 84924, 3);


INSERT INTO Shipment
VALUES(3, '2021-10-20', 84925, 3);


/*
Same as payment, trigger limitations
*/
INSERT INTO Payment
VALUES('2021-10-20', 0.70, 1, 1);

INSERT INTO Payment
VALUES('2021-10-20', 1200, 1, 2);

INSERT INTO Payment
VALUES('2021-10-21', 2400, 2, 3);

INSERT INTO Payment
VALUES('2021-10-21', 1200, 2, 3);

INSERT INTO Payment
VALUES('2021-10-21', 100, 2, 3);

INSERT INTO Payment
VALUES('2021-10-22', 1200, 3, 4);


/*
Test the changing of ordered to cancelled
*/
UPDATE Orders
SET order_status = 'cancelled'
WHERE order_id = 1;