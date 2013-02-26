drop table if exists payables;
drop table if exists invoices;
drop table if exists payments;
drop table if exists x_invoices_payments;
drop table if exists invoice_send_dates;
drop table if exists payment_methods;
drop table if exists payable_types;

create table payable_types (
	payable_type_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	payable_type varchar(50)
);

insert into payable_types (payable_type) values ('buyer order');
insert into payable_types (payable_type) values ('seller order');
insert into payable_types (payable_type) values ('hub fees');
insert into payable_types (payable_type) values ('lo fees');

create table payables (
	payable_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	domain_id int,
	payable_type_id int(10),
	parent_obj_id int(10),
	description varchar(255),
	from_org_id bigint(20) NOT NULL,
	to_org_id bigint(20) NOT NULL,
	amount decimal(10,2) NOT NULL,
	invoice_id int(10),	
	invoicable bool default false,
    is_imported bool default false,
	creation_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

insert into payables(domain_id,payable_type_id,parent_obj_id,from_org_id,to_org_id,amount,invoicable,invoice_id)
values (26,1,2854,1086,1,20,true,1);
insert into payables(domain_id,payable_type_id,parent_obj_id,from_org_id,to_org_id,amount,invoicable,invoice_id)
values (26,1,2853,1086,1,10,true,2);
insert into payables(domain_id,payable_type_id,parent_obj_id,from_org_id,to_org_id,amount,invoicable)
values (26,1,2849,1086,1,8,false);

create table invoices (
	invoice_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	due_date timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
	from_org_id bigint(20) NOT NULL,
	to_org_id bigint(20) NOT NULL,
	amount decimal(10,2) NOT NULL,
    is_imported bool default false,
	creation_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

insert into invoices (due_date,from_org_id,to_org_id,amount)
values ('2012-10-25 12:00:00',1086,1,20);
insert into invoices (due_date,from_org_id,to_org_id,amount)
values ('2012-10-27 12:00:00',1086,1,10);

create table payments (
	payment_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	from_org_id bigint(20) NOT NULL,
	to_org_id bigint(20) NOT NULL,
	amount decimal(10,2) NOT NULL,
	payment_method_id int(11) unsigned not null,
	ref_nbr varchar(255),
	admin_note text,
    is_imported bool default false,
	creation_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

insert into payments (from_org_id,to_org_id,amount,payment_method_id,ref_nbr,admin_note,creation_date)
values (1086,1,20,4,'CHECK 239829372','This is an admin note','2012-10-22 12:00:00');

create table x_invoices_payments (
	x_invoices_payments_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	invoice_id int(10) unsigned NOT NULL,
	payment_id int(10) unsigned NOT NULL,
	amount_paid decimal(10,2)
);

insert into x_invoices_payments (invoice_id,payment_id,amount_paid)
values (1,1,20);


create table  invoice_send_dates (
	invoice_send_date_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	invoice_id int(10) unsigned NOT NULL,
	send_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

insert into invoice_send_dates(invoice_id,send_date)
values (1,'2012-10-21 12:00:00');
insert into invoice_send_dates(invoice_id,send_date)
values (1,'2012-10-25 12:00:00');
insert into invoice_send_dates(invoice_id,send_date) values (2,'2012-10-26 12:00:00');

create table payment_methods (
	payment_method_id int(11) unsigned not null auto_increment PRIMARY KEY,
	payment_method varchar(255) not null
);

insert into payment_methods (payment_method) values ('paypal');
insert into payment_methods (payment_method) values ('purchaseorder');
insert into payment_methods (payment_method) values ('ACH');
insert into payment_methods (payment_method) values ('check');





drop view  if exists v_payables;

CREATE VIEW v_payables AS 
	select p.payable_id,p.amount as payable_amount,p.creation_date,
	(p.invoice_id is not null) as is_invoiced,
	p.invoicable,
	d.name as domain_name,
	p.from_org_id,
	o1.name as from_org_name,
	p.to_org_id,
	o2.name as to_org_name,
	from_org_domains.domain_id as from_domain_id,
	from_org_domains.name as from_domain_name,
	to_org_domains.domain_id as to_domain_id,
	to_org_domains.name as to_domain_name,
	order_domains.domain_id as order_domain_id,
	order_domains.name as order_domain_name,
	fulfillment_order_domains.domain_id as fulfillment_order_domain_id,
	fulfillment_order_domains.name as fulfillment_order_domain_name,
	pt.payable_type,
	lo.lo3_order_nbr as buyer_order_identifier,
	lfo.lo3_order_nbr as seller_order_identifier,
	p.description,
	
	
	COALESCE((
		select sum(xip.amount_paid) 
		from x_invoices_payments xip
		where xip.invoice_id=iv.invoice_id), 0.0
	) as amount_paid,
	
	COALESCE(
		(select sum(xip.amount_paid) - p.amount 
		from x_invoices_payments xip
		where xip.invoice_id=iv.invoice_id), p.amount
	) as amount_due,

	(
		select UNIX_TIMESTAMP(max(send_date)) from invoice_send_dates
		where invoice_send_dates.invoice_id = p.invoice_id
	) as last_sent
	
	from payables p
	
	inner join domains d on p.domain_id=d.domain_id
	inner join organizations o1 on p.from_org_id=o1.org_id
	inner join organizations o2 on p.to_org_id=o2.org_id
	inner join payable_types pt on pt.payable_type_id = p.payable_type_id
	
	left join invoices iv on iv.invoice_id=p.invoice_id
	left join lo_order lo on p.parent_obj_id=lo.lo_oid
	left join lo_fulfillment_order lfo on p.parent_obj_id=lfo.lo_foid
    left join organizations_to_domains from_otd on p.from_org_id = from_otd.org_id and from_otd.is_home = 1
    left join organizations_to_domains to_otd on p.to_org_id = to_otd.org_id and to_otd.is_home = 1
    left join domains order_domains on lo.domain_id = order_domains.domain_id
    left join domains fulfillment_order_domains on lfo.domain_id = fulfillment_order_domains.domain_id
    left join domains from_org_domains on from_otd.domain_id = from_org_domains.domain_id
    left join domains to_org_domains on to_otd.domain_id = to_org_domains.domain_id;
	
select * from v_payables;


drop view  if exists v_payments;

CREATE VIEW v_payments AS 
select pv.payment_id,pv.amount,pv.creation_date,
pm.payment_method,
if(pv.payment_method_id=1,((3/100) * pv.amount),if(pv.payment_method_id=3,0.30,0)) as transaction_fees,
(pv.amount - if(pv.payment_method_id=1,((3/100) * pv.amount),if(pv.payment_method_id=3,0.30,0))) as net_amount,
pv.from_org_id,
o1.name as from_org_name,
pv.to_org_id,
o2.name as to_org_name,
(
select group_concat(concat_ws('|',p.description,pt.payable_type,p.parent_obj_id) SEPARATOR '$$')
from payables p 
inner join payable_types pt on pt.payable_type_id=p.payable_type_id
inner join x_invoices_payments on p.invoice_id = x_invoices_payments.invoice_id
where pv.payment_id=x_invoices_payments.payment_id

) as payable_info
from payments pv
inner join organizations o1 on pv.from_org_id=o1.org_id
inner join organizations o2 on pv.to_org_id=o2.org_id
inner join payment_methods pm on pm.payment_method_id=pv.payment_method_id;

select * from v_payments;

drop view  if exists v_invoices;

CREATE VIEW v_invoices AS 
	select iv.invoice_id,iv.due_date,iv.amount,iv.creation_date,
	iv.from_org_id,
	o1.name as from_org_name,
	iv.to_org_id,
	o2.name as to_org_name,
	from_org_domains.domain_id as from_domain_id,
	from_org_domains.name as from_domain_name,
	to_org_domains.domain_id as to_domain_id,
	to_org_domains.name as to_domain_name,
	
	(
		select if(sum(xip.amount_paid) is null,0,sum(xip.amount_paid))
		from x_invoices_payments xip
		where xip.invoice_id=iv.invoice_id
	) as amount_paid,
	
	
	iv.amount - (
		select if(sum(xip.amount_paid) is null,0,sum(xip.amount_paid))
		from x_invoices_payments xip
		where xip.invoice_id=iv.invoice_id
	)  as amount_due,
	
	(
		select GROUP_CONCAT(UNIX_TIMESTAMP(isd.send_date)  ORDER BY isd.send_date desc SEPARATOR ',')
		from invoice_send_dates isd
		where isd.invoice_id=iv.invoice_id
	) as send_dates,
	
	(
		select group_concat(concat_ws('|',p.description,pt.payable_type,p.parent_obj_id) SEPARATOR '$$')
		from payables p 
		inner join payable_types pt on pt.payable_type_id=p.payable_type_id
		where p.invoice_id=iv.invoice_id
	
	) as payable_info
	
	from invoices iv
	
	inner join organizations o1 on iv.from_org_id=o1.org_id
	inner join organizations o2 on iv.to_org_id=o2.org_id
    left join organizations_to_domains from_otd on iv.from_org_id = from_otd.org_id and from_otd.is_home = 1
    left join organizations_to_domains to_otd on iv.to_org_id = to_otd.org_id and to_otd.is_home = 1
    left join domains from_org_domains on from_otd.domain_id = from_org_domains.domain_id
    left join domains to_org_domains on to_otd.domain_id = to_org_domains.domain_id;

select * from v_invoices;


alter table domains add payables_create_on enum('delivery','buyer_paid','buyer_paid_and_delivered');



delete from phrases where label in ('email:payments:new_invoice_body','email:payments:new_invoice_subject');
INSERT INTO `phrases`
(
`pcat_id`,
`label`,
`default_value`,
`edit_type`)
VALUES
(
8,
'email:payments:new_invoice_subject',
'New Invoices',
'text'
);

INSERT INTO `phrases`
(
`pcat_id`,
`label`,
`default_value`,
`edit_type`,info_note)
VALUES
(
8,
'email:payments:new_invoice_body',
'<h1>Invoice Info</h1><br /><b>Nbr: {invoicenbr}<br />Amount: {amount}<br />Due Date: {duedate}<br />&nbsp;<br /><h2>Payables</h2>{payables}<br />click here to pay now: <a href="{pay_link}">{pay_link}</a>',
'rte',
'You have the following fields available: {hubname}, {invoicenbr}, {amount}, {duedate}, {payables}, {pay_link}'
);
