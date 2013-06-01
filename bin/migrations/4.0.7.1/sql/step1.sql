

drop table if exists new_payables;
drop table if exists new_invoices;
drop table if exists new_payments;
drop table if exists x_po_payments;
drop table if exists x_payables_payments;
drop view if exists v_invoices;
drop view if exists v_new_payables;
drop view if exists v_new_payments;

create table new_payables (
	payable_id int(10) auto_increment primary key,
	domain_id int(10),
	from_org_id int(10),
	to_org_id int(10),
	payable_type enum('buyer order','seller order','hub fees','lo fees','service fee','delivery fee'),
	parent_obj_id int(10),
	amount decimal(10,2),
	invoice_id int(10),
	creation_date int(10)
) engine=InnoDB;
CREATE INDEX x_new_payables_idx1 ON new_payables (domain_id);
CREATE INDEX x_new_payables_idx2 ON new_payables (from_org_id);
CREATE INDEX x_new_payables_idx3 ON new_payables (to_org_id);
CREATE INDEX x_new_payables_idx4 ON new_payables (payable_type);
CREATE INDEX x_new_payables_idx5 ON new_payables (invoice_id);
CREATE INDEX x_new_payables_idx6 ON new_payables (parent_obj_id);
CREATE INDEX x_new_payables_idx7 ON new_payables (invoice_id);



create table new_invoices (
	invoice_id int(10) auto_increment primary key,
	first_invoice_date int(10),
	due_date int(10),
	creation_date int(10)
) engine=InnoDB;

create table new_payments (
	payment_id int(10) auto_increment primary key,
	amount numeric(10,2),
	payment_method enum('paypal','purchaseorder','ACH','check','cash'),
	admin_note text,
	ref_nbr varchar(255),
	creation_date int(10)
) engine=InnoDB;
CREATE INDEX x_new_payments_idx1 ON new_payments (payment_method);



create table x_payables_payments (
	xpp_id int(10) auto_increment primary key,
	payment_id int(10),
	payable_id int(10),
	amount numeric(10,2)
) engine=InnoDB;
CREATE INDEX x_payables_payments_idx1 ON x_payables_payments (payment_id);
CREATE INDEX x_payables_payments_idx2 ON x_payables_payments (payable_id);

