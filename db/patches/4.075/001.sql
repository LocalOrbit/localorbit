INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.075', '001', '54494112');

delete from phrases where label='note:inventory:optional';

insert into phrases (pcat_id,label,edit_type,default_value) values (5,'note:inventory:optional','textarea','If you use Lot Numbers or another identifier, you can enter whatever number works with your system. If your products have Good from and Expiration dates, you can include them here as well.');