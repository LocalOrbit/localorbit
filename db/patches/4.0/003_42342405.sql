drop table if exists dashboard_notes;

create table dashboard_notes(
	dn_id int auto_increment primary key,
	domain_id int8 default 0,
	title varchar(255),
	body text,
	days_expires int8,
	dismiss_permanent tinyint default 1,
	creation_date timestamp default CURRENT_TIMESTAMP
);


drop table if exists dashboard_note_views;
create table dashboard_note_views(
	dnv_id int auto_increment primary key,
	dn_id int8,
	user_id int8,
	creation_date timestamp default CURRENT_TIMESTAMP
);

