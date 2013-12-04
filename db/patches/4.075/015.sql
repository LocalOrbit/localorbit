INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.075', '015', '60792252');

ALTER TABLE sent_emails ADD merge_vars text default null;
