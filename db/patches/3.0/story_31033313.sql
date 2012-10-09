create table email_statuses (
	emailstatus_id int auto_increment primary key,
	name varchar(255),
	creation_date timestamp default CURRENT_TIMESTAMP
);

insert into email_statuses (name) values ('Unsent');
insert into email_statuses (name) values ('Sent');
insert into email_statuses (name) values ('Error');
insert into email_statuses (name) values ('Pending');


alter table sent_emails add emailstatus_id int default 1;
update sent_emails set emailstatus_id=2;

alter table sent_emails add from_email varchar(255);
alter table sent_emails add from_name varchar(255);