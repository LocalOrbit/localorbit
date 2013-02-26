-- story 42367463

INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('011', '');

drop table social_options;

create table social_options (
	social_option_id tinyint PRIMARY KEY auto_increment,
	display_name varchar(255) not null,
	is_disabled tinyint(1) default 0
);

alter table organizations add column social_option_id tinyint;

insert into social_options (display_name) values ('Facebook'), ('Twitter');