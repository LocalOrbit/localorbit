drop table if exists organization_payment_methods;
create table organization_payment_methods(
	opm_id int auto_increment primary key,
	org_id int,
	payment_method_id int default 3,
	label varchar(255),
	name_on_account varchar(255),
	nbr1 varchar(255),
	nbr1_last_4 varchar(4),
	nbr2 varchar(255),
	nbr2_last_4 varchar(4),
	last_updated timestamp
);