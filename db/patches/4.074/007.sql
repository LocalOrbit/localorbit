
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.074', '001', '65824692');

alter table customer_entity add send_newsletter tinyint(1) default 1;
alter table customer_entity add send_freshsheet tinyint(1) default 1;
CREATE INDEX customer_entity_send_newsletter ON customer_entity (send_newsletter);
CREATE INDEX customer_entity_send_freshsheet ON customer_entity (send_freshsheet);
