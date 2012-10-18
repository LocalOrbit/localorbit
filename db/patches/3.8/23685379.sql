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

create table payables (
	payable_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	payable_type_id int(10),
	parent_obj_id int(10),
	from_org_id bigint(20) NOT NULL,
	to_org_id bigint(20) NOT NULL,
	amount decimal(10,2) NOT NULL,
	invoice_id int(10),	
	creation_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00'
);

create table invoices (
	invoice_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	due_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
	from_org_id bigint(20) NOT NULL,
	to_org_id bigint(20) NOT NULL,
	amount decimal(10,2) NOT NULL,
	creation_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00'
);

create table payments (
	payment_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	amount decimal(10,2) NOT NULL,
	from_org_id bigint(20) NOT NULL,
	to_org_id bigint(20) NOT NULL,
	payment_method_id int(11) unsigned not null,
	ref_nbr varchar(255),
	admin_note text,
	creation_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00'
);

create table x_invoices_payments (
	x_invoices_payments_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	invoice_id int(10) unsigned NOT NULL,
	payment_id int(10) unsigned NOT NULL,
	amount_paid decimal(10,2)
);

create table  invoice_send_dates (
	invoice_send_date_id int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	invoice_id int(10) unsigned NOT NULL,
	send_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00'
);

create table payment_methods (
	payment_method_id int(11) unsigned not null auto_increment PRIMARY KEY,
	payment_method varchar(255) not null
);

insert into payment_methods (payment_method) values ('paypal');
insert into payment_methods (payment_method) values ('purchaseorder');
insert into payment_methods (payment_method) values ('ACH');
insert into payment_methods (payment_method) values ('check');
