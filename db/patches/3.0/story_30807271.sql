create table lo_order_item_status_changes (
	loi_scid int auto_increment primary key,
	lo_liid int,
	status varchar(50),
	user_id int,
	creation_date timestamp default CURRENT_TIMESTAMP
);



alter table lo_order_line_item add last_status_date timestamp default CURRENT_TIMESTAMP;