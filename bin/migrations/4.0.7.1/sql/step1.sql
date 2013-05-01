

drop table if exists new_payables;
drop table if exists new_invoices;
drop table if exists new_payments;
drop table if exists x_po_payments;
drop table if exists x_payables_payments;

create table new_payables (
	payable_id int(10) auto_increment primary key,
	domain_id int(10),
	from_org_id int(10),
	to_org_id int(10),
	payable_type enum('buyer order','seller order','hub fee','lo fee','service fee'),
	parent_obj_id int(10),
	amount decimal(10,2),
	invoice_id int(10),
	creation_date int(10)
);


create table new_invoices (
	invoice_id int(10) auto_increment primary key,
	due_date int(10),
	creation_date int(10)
);

create table new_payments (
	payment_id int(10) auto_increment primary key,
	amount numeric(10,2),
	payment_method enum('paypal','purchaseorder','ACH','check','cash'),
	ref_nbr varchar(255),
	admin_note text,
	creation_date int(10)
);

create table x_payables_payments (
	xpp_id int(10) auto_increment primary key,
	payment_id int(10),
	payable_id int(10),
	amount numeric(10,2)
);
