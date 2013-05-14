
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.061', '001', '47503141');

update phrases set pcat_id=8,edit_type='rte' where label in (
	'email:payments:payment_made_body','email:payments:payment_received_body'
);

update phrases set pcat_id=8,edit_type='text' where label in (
	'email:payments:payment_made_subject','email:payments:payment_received_subject'
);