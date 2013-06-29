INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.071', '008', '51590999');

UPDATE customer_entity 
SET login_note_viewed =0;