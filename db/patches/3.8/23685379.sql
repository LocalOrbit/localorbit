drop table if exists payables;
drop table if exists invoices;
drop table if exists payments;
drop table if exists x_invoices_payments;
drop table if exists invoice_send_dates;

create table payables (
	payables_id int(10) unsigned NOT NULL AUTO_INCREMENT,
	payables_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
	from_org_id bigint(20) NOT NULL,
	to_org_id bigint(20) NOT NULL,
	amount decimal(10,2) NOT NULL,
	invoice_id int(10) unsigned NOT NULL	
);

create table invoices (
	invoice_id int(10) unsigned NOT NULL AUTO_INCREMENT,
	invoice_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
	due_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
	from_org_id bigint(20) NOT NULL,
	to_org_id bigint(20) NOT NULL,
	amount decimal(10,2) NOT NULL,
	amount_due decimal(10,2) NOT NULL
);

create table payments (
	payment_id int(10) unsigned NOT NULL AUTO_INCREMENT,
	amount decimal(10,2) NOT NULL,
	from_org_id bigint(20) NOT NULL,
	to_org_id bigint(20) NOT NULL
);

create table x_invoices_payments (
	x_invoices_payments_id int(10) unsigned NOT NULL AUTO_INCREMENT,
	invoice_id int(10) unsigned NOT NULL,
	payment_id int(10) unsigned NOT NULL
);

create table  invoice_send_dates (
	invoice_send_date_id int(10) unsigned NOT NULL AUTO_INCREMENT,
	invoice_id int(10) unsigned NOT NULL,
	send_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00'
);
