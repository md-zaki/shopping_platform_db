/*
PaymentCountTrigger will trigger after any successful payment is added to the Payment table
*/
CREATE TRIGGER PaymentSuccessTrigger ON Payment
AFTER INSERT
AS
	/*
	Local variables for trigger
	*/
	DECLARE @payment_amt money, @paid_amt money, @total_amt money, @invoice_num int

	/*
	Get values from inserted row for our subquery
	*/
	SELECT @payment_amt = payment_amount, @invoice_num = invoice_num
	FROM INSERTED

	/*
	Get current total amount paid
	*/
	SELECT @paid_amt = amount_paid, @total_amt = amount_total
	FROM Invoice
	WHERE invoice_num = @invoice_num

	/*
	Update total amount paid with += payment_amount
	No need to worry with overpaying as we've settled that in PaymentCountTrigger
	*/
	UPDATE Invoice
	SET amount_paid = @paid_amt + @payment_amt
	WHERE invoice_num = @invoice_num

	/*
	Set status to paid if fully paid
	*/
	IF ((@payment_amt + @paid_amt) = @total_amt)
	BEGIN
		UPDATE Invoice
		SET invoice_status = 'paid', is_fully_paid = 1
		WHERE invoice_num = @invoice_num
	END
GO