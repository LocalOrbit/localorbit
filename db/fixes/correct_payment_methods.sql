select * from lo_order where ldstat_id<>1 and (payment_method is null or payment_method='');

update lo_order 
set payment_method='paypal'
where ldstat_id<>1
and (payment_method='' or payment_method is null)
and lo_oid in (
	select lo_oid
	from lo_order_line_item
	where lo_liid in (
		select parent_obj_id 
		from payables 
		where payable_type = 'buyer order'
		and payable_id in (
			select payable_id
			from x_payables_payments
			where payment_id in (
				select payment_id
				from payments
				where payment_method='paypal'
			)
		)
	)
);

update lo_order 
set payment_method='purchaseorder'
where ldstat_id<>1
and (payment_method='' or payment_method is null)
and lo_oid in (
	select lo_oid
	from lo_order_line_item
	where lo_liid in (
		select parent_obj_id 
		from payables 
		where payable_type = 'buyer order'
		and payable_id in (
			select payable_id
			from x_payables_payments
			where payment_id in (
				select payment_id
				from payments
				where payment_method='ACH'
			)
		)
	)
);

update lo_order 
set payment_method='purchaseorder'
where ldstat_id<>1
and (payment_method='' or payment_method is null);