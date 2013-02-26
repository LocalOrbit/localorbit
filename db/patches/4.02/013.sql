
INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('013', '44119349');

UPDATE phrases  SET default_value = 'Market Admin' WHERE default_value = 'Market Administration';
