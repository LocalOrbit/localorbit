
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.072', '002', '51530693');

ALTER TABLE domains ADD payment_allow_paypal_express_checkout int DEFAULT 0;
ALTER TABLE domains ADD payment_default_paypal_express_checkout int DEFAULT 0;

UPDATE domains SET payment_allow_paypal_express_checkout = 0, payment_default_paypal_express_checkout = 0;
