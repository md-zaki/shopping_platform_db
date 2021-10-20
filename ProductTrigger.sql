/*
ProductTrigger will intercept any incoming products added to the Product table
*/
CREATE TRIGGER ProductTrigger ON Product
INSTEAD OF INSERT
AS
	/*
	Local variables for trigger
	*/
	DECLARE @rows int, @shop_r int, @shop_id int, @p_type_id int

	/*
	Get values from inserted row for our subquery
	*/
	SELECT @shop_id = shop_id, @p_type_id = p_type_id
	FROM INSERTED

	/*
	@rows = 1 when a shop is restricted to sell that item type
	*/
	SELECT @rows = COUNT(*)
	FROM Restricted R
	WHERE R.shop_id = @shop_id AND R.p_type_id = @p_type_id

	/*
	@shop_r > 0 when a shop is restricted to sell ANY item type
	*/
	SELECT @shop_r = COUNT(*)
	FROM Restricted R
	WHERE R.shop_id = @shop_id

	/*
	If a shop is restricted and is bound to that item type, insert the new product
	*/
	IF (@shop_r > 0 AND @rows = 1)
	BEGIN
		INSERT INTO Product
		SELECT I.product_name, I.color, I.prod_description, I.price, I.size, I.p_type_id, I.shop_id
		FROM INSERTED I
	END
	
	/*
	If a shop is not restricted to any item type, they can sell it. So insert the new product
	*/
	IF (@shop_r = 0)
	BEGIN
		INSERT INTO Product
		SELECT I.product_name, I.color, I.prod_description, I.price, I.size, I.p_type_id, I.shop_id
		FROM INSERTED I
	END

	IF (@shop_r > 0 AND @rows = 0)
	BEGIN
		RAISERROR('Shop is not permitted to sell product', 16, 50000)
	END
GO