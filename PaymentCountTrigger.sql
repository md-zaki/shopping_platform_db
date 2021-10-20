/*
PaymentCountTrigger will intercept any incoming payments added to the Payment table
*/
CREATE TRIGGER PaymentCountTrigger ON Payment
INSTEAD OF INSERT
AS
	/*
	Local variables for trigger
	*/
	DECLARE @cust_id int, @payment_amt money, @invoice_num int,
			@payment_count int, @rem int

	/*
	Get values from inserted row for our subquery
	*/
	SELECT @cust_id = cust_id, @payment_amt = payment_amount, @invoice_num = invoice_num
	FROM INSERTED

	/*
	Gets total amount of payments for the current invoice
	*/
	SELECT @payment_count = COUNT(*)
	FROM Payment
	WHERE cust_id = @cust_id AND invoice_num = @invoice_num

	/*
	Gets the remaining left to be paid for the current invoice
	*/
	SELECT @rem = amount_total - amount_paid
	FROM Invoice
	WHERE invoice_num = @invoice_num

	/*
	Do not allowing overpaying for the invoice
	*/
	IF (@payment_amt > @rem)
	BEGIN
		SET @payment_amt = @rem
	END

	/*
	Constraint specified in lab manual
	*/
	IF (@payment_count = 2 AND @rem > @payment_amt OR @payment_amt = 0 OR @payment_count >= 3)
	BEGIN
		RAISERROR('Payment is unabled to be accepted', 16, 50001)
	END

	/*
	If constraints are met, add payment to table
	*/
	ELSE
	BEGIN
		INSERT INTO Payment
		SELECT payment_date, @payment_amt, cust_id, invoice_num
		FROM INSERTED
	END
GO