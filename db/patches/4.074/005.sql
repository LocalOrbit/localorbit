INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.074', '005', '55232730');

alter table payments add processing_status enum('confirmed','pending','refunded') default 'pending';

insert into lo_buyer_payment_statuses (buyer_payment_status) values ('Pending');
insert into lo_seller_payment_statuses (seller_payment_status) values ('Pending');

update payments 
	set processing_status='confirmed' 
	where payment_method in ('paypal','check','cash');




create or replace view v_payables as 
select p.*,
	/* double query forces inner to eval first */
	(select o1.name from organizations o1 where p.from_org_id=o1.org_id) as from_org_name,
	(select o2.name from organizations o2 where p.to_org_id=o2.org_id) as to_org_name,
	otd1.domain_id as from_domain_id,
	otd2.domain_id as to_domain_id,
	
	ifnull(i.due_date,9999999999999) as due_date,
	i.creation_date as invoice_date,
	if(p.payable_type='seller order',lfo.lo3_order_nbr,lo.lo3_order_nbr) as order_nbr,
	FLOOR((i.due_date - UNIX_TIMESTAMP(CURRENT_TIMESTAMP)) /86400) as days_left,
	
	if(p.payable_type = 'delivery fee',
		concat_ws(
			'|',
			lo.lo3_order_nbr,
			p.payable_type,
			d.domain_id
		),
		concat_ws(
			'|',
			if(p.payable_type='seller order',lfo.lo3_order_nbr,lo.lo3_order_nbr),
			p.payable_type,
			if(
				p.payable_type='seller order',
				loi.lo_foid,
				if(
					p.payable_type='service fee',
					d.domain_id,
					lo.lo_oid
				)
			),
			if(p.payable_type='service fee',d.name,ifnull(loi.product_name,' ')),
			ifnull(loi.qty_ordered,' '),
			ifnull(loi.seller_name,' '),
			ifnull(loi.seller_org_id,' '),
			UNIX_TIMESTAMP(lo.order_date)
		)
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
	
	COALESCE(sum(xpp.amount),0) as amount_paid,
	COALESCE(group_concat(distinct py.processing_status),'pending') as payment_processing_statuses,
	lo.payment_ref as po_number,

	if(ifnull(i.invoice_id,0)=0,0,1) as invoiced,
	i.creation_date as last_invoiced,
	ceiling((i.due_date - i.first_invoice_date ) / 86400) as po_terms,
	
	if(p.payable_type='delivery fee',lo.lbps_id,loi.lbps_id) as lbps_id,
	if(p.payable_type='delivery fee',lo.ldstat_id,loi.ldstat_id) as ldstat_id,
	
	case if(p.payable_type='delivery fee',lo.ldstat_id,loi.ldstat_id)
		when 	2 then 'Pending'
		when 	3 then 'Canceled'
		when 	4 then 'Delivered'
		when 	5 then 'Partially Delivered'
		when 	6 then 'Contested'
	end as delivery_status,
	
	
	case if(p.payable_type='delivery fee',lo.lbps_id,loi.lbps_id)
		when 	1 then 'Unpaid'
		when 	2 then 'Paid'
		when 	3 then 'Invoice Issued'
		when 	4 then 'Partially Paid'
		when 	5 then 'Refunded'
		when 	6 then 'Manual Review'
	end as payable_status,
		
	CASE 
		WHEN if(p.payable_type='delivery fee',lo.lbps_id,loi.lbps_id) in (1,3,4) and if(p.payable_type='delivery fee',lo.ldstat_id,loi.ldstat_id)=2 THEN 'awaiting delivery / buyer payment'
		WHEN if(p.payable_type='delivery fee',lo.ldstat_id,loi.ldstat_id)=2 THEN 'awaiting delivery'
		WHEN if(p.payable_type='delivery fee',lo.lbps_id,loi.lbps_id) in (1,3,4) THEN 'awaiting buyer payment'
		WHEN if(p.payable_type='delivery fee',lo.lbps_id,loi.lbps_id)=2 AND if(p.payable_type='delivery fee',lo.ldstat_id,loi.ldstat_id)=4 THEN 'delivered, seller payment pending'
	END AS receivable_status,

	if(
		(p.amount - COALESCE(sum(xpp.amount),0) = 0),
		'paid',
		if(p.invoice_id is null,'purchase orders',if(UNIX_TIMESTAMP(CURRENT_TIMESTAMP) > i.due_date,'overdue','invoiced'))
	) as payment_status,
			
	
	CASE 
		WHEN (loi.lbps_id<>2) THEN 'buyer_payment'
		WHEN (loi.ldstat_id<>4) THEN 'delivery'
		else 'transfer'
	END AS pending,
	
	concat_ws(' ',loi.product_name,lo.payment_ref,if(p.payable_type='seller order',lfo.lo3_order_nbr,lo.lo3_order_nbr),p.amount) as searchable_fields

from payables p
	inner join organizations_to_domains otd1 force index for join (`organizations_to_domains_idx5`) on (otd1.org_id=p.from_org_id and otd1.is_home=1)
	inner join organizations_to_domains otd2 force index for join (`organizations_to_domains_idx5`)  on (otd2.org_id=p.to_org_id and otd2.is_home=1)
	left join x_payables_payments xpp on (xpp.payable_id=p.payable_id)
	left join invoices i on (i.invoice_id=p.invoice_id)
	left join lo_order_line_item loi  on (loi.lo_liid=p.parent_obj_id)
	left join lo_order_deliveries lod on (loi.lodeliv_id=lod.lodeliv_id)
	left join lo_order lo on (lo.lo_oid=if(p.payable_type='delivery fee',p.parent_obj_id,loi.lo_oid))
	left join lo_fulfillment_order lfo on (lfo.lo_foid=loi.lo_foid)	
	left join domains d on (d.domain_id=p.parent_obj_id)
	
	
	left join payables p2 on (p.parent_obj_id=p2.parent_obj_id and p2.from_org_id=lo.org_id and p2.payable_type=if(p.payable_type='delivery fee','delivery fee','buyer order'))
	left join x_payables_payments xpp2 on (xpp2.payable_id=p2.payable_id)
	left join payments py on (xpp2.payment_id=py.payment_id)

	group by p.payable_id
;