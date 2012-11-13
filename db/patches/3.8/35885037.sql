create table service_fee_schedules
(
	sfs_id int auto_increment primary key,
	name varchar(255)
);

insert into service_fee_schedules (name) values ('Monthly');
insert into service_fee_schedules (name) values ('6 Months');
insert into service_fee_schedules (name) values ('Annual');

alter table domains add service_fee numeric(10,2);
alter table domains add sfs_id int;
alter table domains add opm_id int;
alter table domains add service_fee_last_paid timestamp default '0000-00-00 00:00:00';

