
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.072', '005', '51530693');

ALTER TABLE organizations ADD payment_allow_paypal_popup int DEFAULT 0;

UPDATE organizations SET payment_allow_paypal_popup = payment_allow_paypal;
UPDATE domains SET payment_allow_paypal_popup = payment_allow_paypal;
UPDATE domains SET payment_default_paypal_popup = payment_default_paypal;