INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.074', '006', '58544500');

alter table domains add login_enabled bool default true;