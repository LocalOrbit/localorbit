INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.075', '004', '');

ALTER TABLE sent_emails ADD attachment_file_location varchar(200);
