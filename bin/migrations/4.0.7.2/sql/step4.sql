
drop view if exists v_buyer_orders;

create view v_buyer_orders as 
	select 
		bo.*,
		o1.name as buyer_name,
		d.name as domain_name,d.hostname,
		sum(oi.qty_ordered * oi.unit_price) as ordered_original_total,
		sum(oi.qty_ordered * oi.discount_unit_price)  as ordered_discount_total,
		sum(oi.qty_delivered * oi.unit_price) as delivered_original_total,
		sum(oi.qty_delivered * oi.discount_unit_price)  as delivered_discount_total,
		sum(od.fee) as delivery_fees,
		(sum(oi.qty_ordered * oi.discount_unit_price) + sum(od.fee)) as grand_total
		
	from buyer_orders bo
	inner join organizations o1 on bo.buyer_org_id=o1.org_id
	inner join domains d on bo.domain_id=d.domain_id
	inner join order_items oi on oi.buyer_order_id=bo.buyer_order_id	
	inner join order_deliveries od on (od.buyer_order_id=bo.buyer_order_id)
	group by bo.buyer_order_id
;

drop view if exists v_seller_orders;

create view v_seller_orders as 
	select 
		so.*,
		bo.fee_percent_lo,bo.fee_percent_market,bo.fee_percent_paypal,bo.lo3_order_nbr as buyer_lo3_order_nbr,
		bo.buyer_org_id,
		o1.name as buyer_name,
		o2.name as seller_name,
		d.name as domain_name,d.hostname,
		sum(oi.qty_ordered * oi.unit_price) as ordered_original_total,
		sum(oi.qty_ordered * oi.discount_unit_price)  as ordered_discount_total,
		sum(oi.qty_delivered * oi.unit_price) as delivered_original_total,
		sum(oi.qty_delivered * oi.discount_unit_price)  as delivered_discount_total
		
	from seller_orders so
	inner join buyer_orders bo on (so.buyer_order_id=bo.buyer_order_id)
	inner join organizations o1 on (bo.buyer_org_id=o1.org_id)
	inner join organizations o2 on (so.seller_org_id=o2.org_id)
	inner join order_items oi on oi.seller_order_id=so.seller_order_id
	inner join domains d on (bo.domain_id=d.domain_id)
	group by so.seller_order_id
;



drop view if exists v_order_items;

create view v_order_items as 
	select 
		oi.*,
		o1.name as buyer_name,
		o2.name as seller_name,
		bo.domain_id,
		(oi.qty_ordered * oi.unit_price) as ordered_original_total,
		(oi.qty_ordered * oi.discount_unit_price) as ordered_discount_total,
		(oi.qty_delivered * oi.unit_price) as delivered_original_total,
		(oi.qty_delivered * oi.discount_unit_price) as delivered_discount_total
		
	from order_items oi
	inner join buyer_orders bo on (oi.buyer_order_id=bo.buyer_order_id)
	inner join seller_orders so on (oi.seller_order_id=so.seller_order_id)
	inner join organizations o1 on (bo.buyer_org_id=o1.org_id)
	inner join organizations o2 on (so.seller_org_id=o2.org_id)
	inner join domains d on (bo.domain_id=d.domain_id)
;



