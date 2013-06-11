
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.072', '001', '51185873');


alter table organization_payment_methods add account_type enum('Personal','Business') default 'Business';
update organization_payment_methods set account_type='Business';