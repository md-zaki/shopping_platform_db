	/*
	ShipmentInsertedTrigger will trigger after any shipment is added to the Shipment table
	handles changing order_item from 'processing' to 'shipped'
	as well as changing order from 'processing' to 'completed' when all items are shipped
	*/
	CREATE TRIGGER ShipmentInsertedTrigger ON Shipment
	AFTER INSERT
	AS
		/*
		Local variables for trigger
		*/
		DECLARE @invoice_num int, @order_id int, @shipped_count int, @order_count int, @product_id int, @order_status varchar(255)

		/*
		Get values from inserted row to find related order
		*/
		SELECT @product_id = product_id, @invoice_num = invoice_num
		FROM INSERTED

		/*
		Gets the order_id for the shipment
		*/
		SELECT @order_id = order_id
		FROM Invoice
		WHERE invoice_num = @invoice_num

		/*
		Gets the order_status for shipment's order
		*/
		SELECT @order_status = order_status 
		FROM OrderDetails
		WHERE order_id = @order_id AND product_id = @product_id

		/*
		Only change from processing->shipped, not shipped->shipped
		*/
		IF (@order_status = 'processing')
		BEGIN
			UPDATE OrderDetails
			SET order_status = 'shipped'
			WHERE order_id = @order_id AND product_id = @product_id
		END
		
		/*
		Get number of item shipped for order
		*/
		SELECT @shipped_count = COUNT(*)
		FROM Shipment
		WHERE invoice_num = @invoice_num
		
		/*
		Get number of items in order
		*/
		SELECT @order_count = COUNT(*)
		FROM OrderDetails
		WHERE order_id = @order_id
		
		
		/*
		Update order to completed
		Assume all shipments are by individual items
		All items are shipped with the ordered quantity :)
		*/
		IF (@shipped_count = @order_count)
		BEGIN
			UPDATE Orders
			SET order_status = 'completed'
			WHERE order_id = @order_id
		END
	GO