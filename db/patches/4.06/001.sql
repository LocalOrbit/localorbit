ALTER TABLE migrations ADD tag varchar(20);

INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.06', '001', '27767687');

UPDATE phrases
SET default_value = '{1} is temporarily closed.<br /> Thanks for stopping by. Our market is temporarily closed while we make a few updates. We’ll reopen again soon, we promise.'
WHERE label = 'note:catalog:closed';