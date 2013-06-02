
create or replace view v_payables as 

select p.*,
	o1.name as from_org_name,
	o2.name as to_org_name,
	d.name as domain_name,
	ifnull(i.due_date,9999999999999) as due_date,
	i.creation_date as invoice_date,
	if(payable_type='seller order',lfo.lo3_order_nbr,lo.lo3_order_nbr) as order_nbr,
	FLOOR((i.due_date - UNIX_TIMESTAMP(CURRENT_TIMESTAMP)) /86400) as days_left,
	concat_ws(
		'|',
		if(payable_type='seller order',lfo.lo3_order_nbr,lo.lo3_order_nbr),
		p.payable_type,
		if(payable_type='seller order',loi.lo_foid,loi.lo_oid),
		loi.product_name,
		loi.qty_ordered,
		loi.seller_name,
		loi.seller_org_id,
		UNIX_TIMESTAMP(lo.order_date),
		loi.row_adjusted_total
	) as payable_info,

	(
		if(p.payable_type='seller order',lod.delivery_start_time,
			if(lod.pickup_start_time=0,lod.delivery_start_time,lod.pickup_start_time)
		)
	) as delivery_start_time,
	(
		if(p.payable_type='seller order',lod.delivery_end_time,
			if(lod.pickup_end_time=0,lod.delivery_end_time,lod.pickup_end_time)
		)
	) as delivery_end_time,
	
	round(COALESCE((
		select sum(xpp.amount) 
		from x_payables_payments xpp
		where xpp.payable_id=p.payable_id), 0.0
	),2) as amount_paid,
	lo.payment_ref as po_number,
	(
		round(COALESCE((
		select sum(xpp.amount) 
		from x_payables_payments xpp
		where xpp.payable_id=p.payable_id), 0.0
		),2) > 0
	) as status,
	if(ifnull(i.invoice_id,0)=0,0,1) as invoiced,
	i.creation_date as last_invoiced,
	ceiling((i.due_date - i.first_invoice_date ) / 86400) as po_terms,
	lods.delivery_status,

	lbps.buyer_payment_status as  payable_status,
		
	CASE 
		WHEN loi.ldstat_id=2 THEN 'awaiting delivery'
		WHEN loi.lbps_id in (1,3,4) THEN 'awaiting buyer payment'
		WHEN loi.lbps_id=2 AND loi.ldstat_id=4 THEN 'delivered, payment pending'
	END AS receivable_status,
	
	CASE 
		WHEN (p.amount - round(COALESCE((
			select sum(xpp.amount) 
			from x_payables_payments xpp
			where xpp.payable_id=p.payable_id), 0.0
		),2) > 0 and UNIX_TIMESTAMP(CURRENT_TIMESTAMP) > i.due_date and p.invoice_id is not null) THEN 'overdue'
		WHEN (p.amount - round(COALESCE((
			select sum(xpp.amount) 
			from x_payables_payments xpp
			where xpp.payable_id=p.payable_id), 0.0
		),2) > 0 and UNIX_TIMESTAMP(CURRENT_TIMESTAMP) <= i.due_date and p.invoice_id is not null) THEN 'invoiced'
		WHEN (p.amount - round(COALESCE((
			select sum(xpp.amount) 
			from x_payables_payments xpp
			where xpp.payable_id=p.payable_id), 0.0
		),2) <= 0) THEN 'paid'
		WHEN (p.invoice_id is null) THEN 'purchase_orders'
	END AS payment_status,
	
	CASE 
		WHEN (loi.lbps_id<>2) THEN 'buyer_payment'
		WHEN (loi.ldstat_id<>4) THEN 'delivery'
		else 'transfer'
	END AS pending,
	
	concat_ws(' ',loi.product_name,lo.payment_ref,if(payable_type='seller order',lfo.lo3_order_nbr,lo.lo3_order_nbr),p.amount) as searchable_fields

from payables p
	inner join organizations o1 on (p.from_org_id=o1.org_id)
	inner join organizations o2 on (p.to_org_id=o2.org_id)
	inner join domains d on (d.domain_id=p.domain_id)
	left join invoices i on (i.invoice_id=p.invoice_id)
	left join lo_order_line_item loi on (loi.lo_liid=p.parent_obj_id)
	left join lo_buyer_payment_statuses lbps on (loi.lbps_id=lbps.lbps_id)
	left join lo_order_deliveries lod on (loi.lodeliv_id=lod.lodeliv_id)
	left join lo_order lo on (lo.lo_oid=loi.lo_oid)
	left join lo_fulfillment_order lfo on (lfo.lo_foid=loi.lo_foid)
	left join lo_delivery_statuses lods on (loi.ldstat_id=lods.ldstat_id)
	
;



CREATE or replace VIEW v_payments AS 
select 
	pv.payment_id,
	group_concat(UNIX_TIMESTAMP(lo3.order_date)  SEPARATOR '|') as order_date,
	p3.from_org_id,
	o1.name as from_org_name,
	p3.to_org_id,
	o2.name as to_org_name,
	pv.creation_date as payment_date,
	pv.payment_method,
	pv.ref_nbr,
	pv.admin_note,
	
	pv.amount,
	round(if(pv.payment_method='paypal',((3/100) * pv.amount),if(pv.payment_method='ACH',0.30,0)),2) as transaction_fees,
	round(
		(
			(pv.amount - 
				round((if(pv.payment_method='paypal',((3/100) * pv.amount),if(pv.payment_method='ACH',0.30,0))),2)
			)
		)
	,2) as net_amount,
	
	(
		select 
			group_concat(
				concat_ws(
					'|',
					if(p1.payable_type='seller order',lfo1.lo3_order_nbr,lo1.lo3_order_nbr),
					p1.payable_type,
					if(payable_type='seller order',loi1.lo_foid,loi1.lo_oid),
					loi1.product_name,
					loi1.qty_ordered,
					loi1.seller_name,
					loi1.seller_org_id,
					UNIX_TIMESTAMP(lo1.order_date)
				) SEPARATOR '$$'
			)
			from payables p1 
			inner join x_payables_payments xpp1 on p1.payable_id = xpp1.payable_id
			left join lo_order_line_item loi1 on (loi1.lo_liid=p1.parent_obj_id)
			left join lo_order lo1 on (lo1.lo_oid=loi1.lo_oid)
			left join lo_fulfillment_order lfo1 on (lfo1.lo_foid=loi1.lo_foid)
			
			where pv.payment_id=xpp1.payment_id

	) as payable_info,
	(
		select 
			group_concat(
				concat_ws(
					' ',
					loi2.product_name,
					lo2.payment_ref,
					if(p2.payable_type='seller order',lfo2.lo3_order_nbr,lo2.lo3_order_nbr),
					p2.amount
				) SEPARATOR ' '
			)
			from payables p2 
			inner join x_payables_payments xpp2 on p2.payable_id = xpp2.payable_id
			left join lo_order_line_item loi2 on (loi2.lo_liid=p2.parent_obj_id)
			left join lo_order lo2 on (lo2.lo_oid=loi2.lo_oid)
			left join lo_fulfillment_order lfo2 on (lfo2.lo_foid=loi2.lo_foid)
			
			where pv.payment_id=xpp2.payment_id

	) as searchable_fields
	from payments pv
	left join x_payables_payments xpp3 on (xpp3.payment_id=pv.payment_id)
	left join payables p3 on (p3.payable_id=xpp3.payable_id)
	left join lo_order_line_item loi3 on (loi3.lo_liid=p3.parent_obj_id)
	left join lo_order lo3 on (lo3.lo_oid=loi3.lo_oid)
	left join organizations o1 on (o1.org_id=p3.from_org_id)
	left join organizations o2 on (o2.org_id=p3.to_org_id)
	group by pv.payment_id
;

/* dictionary entries */
delete from phrases where label in (
	'button:payments:enter_offline_payments',
	'button:payments:enter_online_payments',
	'button:payments:send_invoices',
	'button:payments:mark_items_delivered'
);

insert into phrases (pcat_id,edit_type,label,default_value)
values (1,'text','button:payments:enter_offline_payments','Record Offline Payments');

insert into phrases (pcat_id,edit_type,label,default_value)
values (1,'text','button:payments:enter_online_payments','Make Online Payments');


insert into phrases (pcat_id,edit_type,label,default_value)
values (1,'text','button:payments:send_invoices','Send Invoices');

insert into phrases (pcat_id,edit_type,label,default_value)
values (1,'text','button:payments:mark_items_delivered','Mark Items as Delivered');














