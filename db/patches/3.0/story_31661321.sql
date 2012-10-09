drop table if exists lo_delivery_statuses;

create table lo_delivery_statuses (
	ldstat_id int auto_increment primary key,
	delivery_status varchar(255)
);

insert into lo_delivery_statuses (delivery_status) values ('Cart');
insert into lo_delivery_statuses (delivery_status) values ('Pending');
insert into lo_delivery_statuses (delivery_status) values ('Canceled');
insert into lo_delivery_statuses (delivery_status) values ('Delivered');
insert into lo_delivery_statuses (delivery_status) values ('Partially Delivered');
insert into lo_delivery_statuses (delivery_status) values ('Contested');

drop table if exists lo_buyer_payment_statuses;

create table lo_buyer_payment_statuses (
	lbps_id int auto_increment primary key,
	buyer_payment_status varchar(255)
);

insert into lo_buyer_payment_statuses (buyer_payment_status) values ('Unpaid');
insert into lo_buyer_payment_statuses (buyer_payment_status) values ('Paid');
insert into lo_buyer_payment_statuses (buyer_payment_status) values ('Invoice Issued');
insert into lo_buyer_payment_statuses (buyer_payment_status) values ('Partially Paid');
insert into lo_buyer_payment_statuses (buyer_payment_status) values ('Refunded');
insert into lo_buyer_payment_statuses (buyer_payment_status) values ('Manual Review');

drop table if exists  lo_seller_payment_statuses;

create table lo_seller_payment_statuses (
	lsps_id int auto_increment primary key,
	seller_payment_status varchar(255)
);

insert into lo_seller_payment_statuses (seller_payment_status) values ('Unpaid');
insert into lo_seller_payment_statuses (seller_payment_status) values ('Paid');
insert into lo_seller_payment_statuses (seller_payment_status) values ('Partially Paid');

alter table lo_order add ldstat_id int;
alter table lo_order add lbps_id int;
alter table lo_fulfillment_order add ldstat_id int;
alter table lo_fulfillment_order add lsps_id int;
alter table lo_order_line_item add lbps_id int;
alter table lo_order_line_item add ldstat_id int;
alter table lo_order_line_item add lsps_id int;

update lo_order set ldstat_id=1,lbps_id=1 where status = 'cart';
update lo_order set ldstat_id=2 where status = 'ORDERED';
update lo_order set ldstat_id=3 where status = 'CANCELED';
update lo_order set ldstat_id=4 where status = 'DELIVERED';
update lo_order set ldstat_id=4 where status = 'PAID';
update lo_order set ldstat_id=4 where status = 'PARTIALLY PAID';
update lo_order set ldstat_id=5 where status = 'PARTIALLY DELIVERED';





update lo_order set lbps_id=2 
where status in ('ORDERED','DELIVERED','PARTIALLY DELIVERED') 
and payment_method in ('free','authorizenet','authorize','paypal');

update lo_order set lbps_id=1 
where status in ('ORDERED','DELIVERED','PARTIALLY DELIVERED') 
and payment_method='purchaseorder';

update lo_order set lbps_id=2 
where status in ('PAID','PARTIALLY PAID');

update lo_order set lbps_id=2 
where status in ('CANCELED');


update lo_fulfillment_order set lsps_id=1 
where status in ('ORDERED','DELIVERED','PARTIALLY DELIVERED');

update lo_fulfillment_order set lsps_id=2 
where status in ('PAID');

update lo_fulfillment_order set lsps_id=3
where status in ('PARTIALLY PAID');







update lo_fulfillment_order set ldstat_id=1 where status = 'cart';
update lo_fulfillment_order set ldstat_id=2 where status = 'ORDERED';
update lo_fulfillment_order set ldstat_id=3 where status = 'CANCELED';
update lo_fulfillment_order set ldstat_id=4 where status = 'DELIVERED';
update lo_fulfillment_order set ldstat_id=4 where status = 'PAID';
update lo_fulfillment_order set ldstat_id=4 where status = 'PARTIALLY PAID';
update lo_fulfillment_order set ldstat_id=5 where status = 'PARTIALLY DELIVERED';

update lo_order_line_item set ldstat_id=2 where status = 'ORDERED';
update lo_order_line_item set ldstat_id=4 where status = 'DELIVERED';
update lo_order_line_item set ldstat_id=4 where status = 'PAID';
update lo_order_line_item set ldstat_id=3 where status = 'CANCELLED';
update lo_order_line_item set ldstat_id=3 where status = 'CANCELED';

update lo_order_line_item set lbps_id=1;
update lo_order_line_item set lbps_id=2 where status is not null and lo_oid in (select lo_oid from lo_order where payment_method='paypal');

update lo_order_line_item set lsps_id=1;
update lo_order_line_item set lsps_id=2 where status is not null and lo_foid in (select lo_foid from lo_fulfillment_order where status='PAID');


alter table lo_order drop status;
alter table lo_fulfillment_order drop status;
alter table lo_order_line_item drop status;

alter table lo_order_status_changes add lbps_id int;
alter table lo_order_status_changes add ldstat_id int;

alter table lo_order_item_status_changes add lbps_id int;
alter table lo_order_item_status_changes add ldstat_id int;
alter table lo_order_item_status_changes add lsps_id int;

alter table lo_fulfillment_order_status_changes add ldstat_id int;
alter table lo_fulfillment_order_status_changes add lsps_id int;









update lo_order_item_status_changes set ldstat_id=2 where status = 'ORDERED';
update lo_order_item_status_changes set ldstat_id=4 where status = 'DELIVERED';
update lo_order_item_status_changes set ldstat_id=4 where status = 'PAID';
update lo_order_item_status_changes set ldstat_id=3 where status = 'CANCELLED';
update lo_order_item_status_changes set ldstat_id=3 where status = 'CANCELED';


update lo_order_item_status_changes set lbps_id=2 
where status in ('ORDERED','DELIVERED','PARTIALLY DELIVERED') 
and lo_liid in (select lo_liid from lo_order_line_item inner join lo_order on lo_order_line_item.lo_oid = lo_order.lo_oid where payment_method in ('free','authorizenet','authorize','paypal'));

update lo_order_item_status_changes set lbps_id=1 
where status in ('ORDERED','DELIVERED','PARTIALLY DELIVERED') 
and lo_liid in (
	select lo_liid 
	from lo_order_line_item 
	inner join lo_order on (lo_order_line_item.lo_oid = lo_order.lo_oid)
	where payment_method='purchaseorder'
);

update lo_order_item_status_changes set lbps_id=2 
where status in ('PAID','PARTIALLY PAID');

update lo_order_item_status_changes set lbps_id=2 
where status in ('CANCELED');


update lo_order_item_status_changes set lsps_id=1 
where status in ('ORDERED','DELIVERED','PARTIALLY DELIVERED');







update lo_order_item_status_changes set lsps_id=2 
where status in ('PAID');

update lo_order_item_status_changes set lsps_id=3
where status in ('PARTIALLY PAID');

update lo_order_status_changes set ldstat_id=2 where status = 'ORDERED';
update lo_order_status_changes set ldstat_id=4 where status = 'DELIVERED';
update lo_order_status_changes set ldstat_id=4 where status = 'PAID';
update lo_order_status_changes set ldstat_id=3 where status = 'CANCELLED';
update lo_order_status_changes set ldstat_id=3 where status = 'CANCELED';
update lo_order_status_changes set ldstat_id=5 where status = 'PARTIALLY DELIVERED';

update lo_order_status_changes set lbps_id=2 
where status in ('ORDERED','DELIVERED','PARTIALLY DELIVERED') 
and lo_oid in (select lo_oid from lo_order where payment_method in ('free','authorizenet','authorize','paypal'));

update lo_order_status_changes set lbps_id=1 
where status in ('ORDERED','DELIVERED','PARTIALLY DELIVERED') 
and lo_oid in (select lo_oid from lo_order where payment_method='purchaseorder');

update lo_order_status_changes set lbps_id=2 
where status in ('PAID','PARTIALLY PAID');

update lo_order_status_changes set lbps_id=2 
where status in ('CANCELED');

update lo_order_status_changes set lbps_id=2 
where status in ('CANCELLED');


update lo_fulfillment_order_status_changes set lsps_id=1 
where status in ('ORDERED','DELIVERED','PARTIALLY DELIVERED');

update lo_fulfillment_order_status_changes set lsps_id=2 
where status in ('PAID');

update lo_fulfillment_order_status_changes set lsps_id=3
where status in ('PARTIALLY PAID');


update lo_fulfillment_order_status_changes set ldstat_id=1 where status = 'cart';
update lo_fulfillment_order_status_changes set ldstat_id=2 where status = 'ORDERED';
update lo_fulfillment_order_status_changes set ldstat_id=3 where status = 'CANCELED';
update lo_fulfillment_order_status_changes set ldstat_id=4 where status = 'DELIVERED';
update lo_fulfillment_order_status_changes set ldstat_id=4 where status = 'PAID';
update lo_fulfillment_order_status_changes set ldstat_id=4 where status = 'PARTIALLY PAID';
update lo_fulfillment_order_status_changes set ldstat_id=5 where status = 'PARTIALLY DELIVERED';

alter table lo_order_item_status_changes drop status;
alter table lo_order_status_changes drop status;
alter table lo_fulfillment_order_status_changes drop status;


alter table domains add lo_pays_sellers bool default 0;
alter table domains add lo_invoices_buyers bool default 0;
alter table domains drop lo_pays_sellers;
alter table domains drop lo_invoices_buyers;

alter table domains add seller_payer varchar(50) default 'hub';
alter table domains add buyer_invoicer varchar(50) default 'hub';

alter table lo_order add admin_notes text;






insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (
	8,
	'email:manual_review_notification',
	'You have received this notification because an item ({product_name}) has been marked for manual review.
	<br />
	This action occured on order {lo3_order_nbr}. Click this link to view the order: <a href="{order_link}">{order_link}</a>
	<br />&nbsp;<br />
	This action was performed on hub {hub_name} by {marked_by}.',
	'You have the following fields available: {lo3_order_nbr}, {order_link}, {product_name}, {hub_name}, {marked_by}',
	'rte'
);

insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (
	3,
	'error:status:mm_denied_buyer_pmt',
	'market manager denied changing buyer pay stat',
	null,
	'text'
);

insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (
	3,
	'error:status:testng',
	'testing error messages',
	null,
	'text'
);

insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (
	3,
	'error:status:mm_denied_seller_pmt',
	'MM denied changing seller pay stat',
	null,
	'text'
);

insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (
	3,
	'error:status:mm_denied_seller_pmt_not_delivered',
	'MM denied changing seller pay, item not delivered',
	null,
	'text'
);

update lo_order_line_item set qty_delivered=qty_ordered where ldstat_id=4;



