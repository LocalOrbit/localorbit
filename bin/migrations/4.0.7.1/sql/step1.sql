

drop table if exists purchase_orders;
drop table if exists new_invoices;
drop table if exists new_payments;
drop table if exists x_po_payments;

create table purchase_orders (
	po_id int8 auto_increment primary key,
	domain_id int8,
	from_org_id int8,
	to_org_id int8,
	po_type enum('buyer order','seller order','hub fee','lo fee','service fee'),
	parent_obj_id int8,
	amount decimal(10,2),
	invoice_id int8,
	creation_date int8
);


create table new_invoices (
	invoice_id int8 auto_increment primary key,
	due_date int8,
	creation_date int8
);

create table new_payments (
	payment_id int8 auto_increment primary key,
	amount numeric(10,2),
	payment_method_id int8,
	ref_nbr varchar(255),
	admin_note text,
	creation_date int8
);

create table x_po_payments (
	xpp_id int8 auto_increment primary key,
	payment_id int8,
	po_id int8,
	amount numeric(10,2)
);
