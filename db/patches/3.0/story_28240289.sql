create table lo_order_status_changes (
	lo_scid int auto_increment primary key,
	lo_oid int,
	status varchar(50),
	user_id int,
	creation_date timestamp default CURRENT_TIMESTAMP
);

create table lo_fulfillment_order_status_changes (
	lo_fscid int auto_increment primary key,
	lo_foid int,
	status varchar(50),
	user_id int,
	creation_date timestamp default CURRENT_TIMESTAMP
);

alter table lo_order add last_status_date timestamp default CURRENT_TIMESTAMP;
alter table lo_fulfillment_order add last_status_date timestamp default CURRENT_TIMESTAMP;

alter table events add domain_id int;
alter table events drop store_id;

insert into phrases (pcat_id,label,default_value,info_note,edit_type) values (8,'email:order_seller','','You have the following fields available: {fullname}, {order_nbr}, {items}, {payment_type}, {payment_confirm_code}, {hubname}, {logo}','rte');
