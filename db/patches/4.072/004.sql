
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.072', '004', '51530693');

ALTER TABLE domains
CHANGE payment_allow_paypal_express_checkout payment_allow_paypal_popup int DEFAULT '1';

ALTER TABLE domains
CHANGE payment_default_paypal_express_checkout payment_default_paypal_popup int DEFAULT '1';