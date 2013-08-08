INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.075', '001', '54494112');

delete from phrases where label='note:inventory:optional';

insert into phrases (pcat_id,label,edit_type,default_value) values (5,'note:inventory:optional','textarea','update this guys');