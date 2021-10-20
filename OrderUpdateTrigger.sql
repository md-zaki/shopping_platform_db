/*
OrdersTriggerUpdate will run after any row update in Orders
We aren't able to trigger using 'INSTEAD OF' because of cascading attributes
So we'll have to do prevent cancelling the long way
*/
CREATE TRIGGER OrdersTriggerUpdate ON Orders
AFTER UPDATE
AS
    /*
    Local variables for trigger
    */
    DECLARE @order_status varchar(255), @order_id int, @invoice_num int, @payment_count int,
            @order_count int, @shipped_count int

    /*
    Get values from edited row for our subquery
    */
    SELECT @order_id = order_id, @order_status = order_status
    FROM INSERTED;

    /*
    Get related invoice num for edited order
    */
    SELECT @invoice_num = invoice_num
    FROM Invoice
    WHERE order_id = @order_id;

    /*
    Get how many payments made for edited order
    */
    SELECT @payment_count = COUNT(*)
    FROM Payment
    WHERE invoice_num = @invoice_num;

    /*
    Get how many items are in the edited order
    */
    SELECT @order_count = COUNT(*)
    FROM OrderDetails
    WHERE order_id = @order_id;


    /*
    Get how many items shipped for the edited order
    */
    SELECT @shipped_count = COUNT(*)
    FROM Shipment
    WHERE invoice_num = @invoice_num;

    /*
    Change back to processing if payment has been made
    and there are still items to be shipped
    */
    IF (@order_status = 'cancelled' AND @payment_count > 0 AND @shipped_count < @order_count)
    BEGIN
        UPDATE Orders
        SET order_status = 'processing'
        WHERE order_id = @order_id;
    END

    /*
    Change back to 'completed' if payment has been made
    and all items have been shipped
    */
    IF (@order_status = 'cancelled' AND @payment_count > 0 AND @shipped_count = @order_count)
    BEGIN
        UPDATE Orders
        SET order_status = 'completed'
        WHERE order_id = @order_id;
    END

    /*
    Raise error to show the operation was not permitted
    */
    IF (@order_status = 'cancelled' AND @payment_count > 0)
    BEGIN
        RAISERROR('Payment has already been made, cannot cancel order', 16, 50002)
    END
GO