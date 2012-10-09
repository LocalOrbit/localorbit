alter table weekly_specials add creation_date timestamp default CURRENT_TIMESTAMP;
update weekly_specials set creation_date=CURRENT_TIMESTAMP;
	