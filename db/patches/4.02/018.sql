
INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('018', '');

ALTER TABLE sent_emails
  MODIFY to_address text;