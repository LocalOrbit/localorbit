
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.06', '004', '');


ALTER TABLE events
  ADD text1 text;
  
INSERT INTO event_types
(name)
VALUES
('ACH RQ');

INSERT INTO event_types
(name)
VALUES
('ACH RS');  