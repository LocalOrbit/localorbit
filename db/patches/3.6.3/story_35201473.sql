insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3272,'2012-08-02 08:04:59');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3335,'2012-08-05 17:04:31');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3395,'2012-08-07 08:53:57');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3396,'2012-08-07 08:53:57');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3401,'2012-08-07 08:53:57');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3451,'2012-08-08 22:15:36');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3453,'2012-08-08 22:53:07');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3482,'2012-08-09 11:24:05');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3573,'2012-08-12 13:04:43');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3612,'2012-08-14 09:17:13');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3629,'2012-08-14 12:24:54');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3631,'2012-08-14 11:05:45');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3632,'2012-08-14 11:05:45');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3663,'2012-08-15 22:40:35');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3692,'2012-08-16 15:12:36');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3719,'2012-08-17 00:51:46');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3742,'2012-08-21 10:42:07');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3743,'2012-08-24 10:42:07');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3745,'2012-08-21 10:42:07');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3816,'2012-08-20 09:26:23');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3872,'2012-08-24 21:11:51');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3874,'2012-08-24 21:11:51');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3879,'2012-08-24 21:11:51');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3883,'2012-08-24 21:11:51');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3886,'2012-08-24 21:11:51');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3901,'2012-08-24 11:12:52');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3911,'2012-08-24 11:12:52');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3912,'2012-08-24 11:12:52');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3914,'2012-08-24 11:12:52');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3915,'2012-08-24 11:12:52');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3916,'2012-08-24 11:12:52');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3938,'2012-08-24 22:55:03');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,3939,'2012-08-24 22:55:03');

insert into lo_order_item_status_changes (user_id,ldstat_id,lo_liid,creation_date)
	values (5687,4,4023,'2012-08-23 17:55:27');


select loi.lo_liid,loi.product_name,loi.lo_oid from lo_order_line_item loi
left join lo_order lo on (loi.lo_oid=lo.lo_oid)
where loi.ldstat_id=4 
and lo_liid not in (
	select lo_liid from lo_order_item_status_changes
) 
and lo_liid> 3100 
order by loi.lo_oid;

-- should give no results
