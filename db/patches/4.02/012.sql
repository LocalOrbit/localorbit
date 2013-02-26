-- story 42367463

INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('012', '');

alter table domains add column facebook varchar(255) DEFAULT NULL;
alter table domains add column twitter varchar(255) DEFAULT NULL;

alter table domains add column social_option_id tinyint;
