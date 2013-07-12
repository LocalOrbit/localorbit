
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.072', '003', '51530693');

UPDATE payments
SET payment_method = 'paypal' 
WHERE payment_method = 'paypal_popup';

ALTER TABLE payments  MODIFY payment_method enum ('paypal','purchaseorder','ACH','check','cash');


ALTER TABLE domains
DROP payment_allow_paypal_popup;

ALTER TABLE domains
DROP payment_default_paypal_popup;


ALTER TABLE organizations
DROP payment_allow_paypal_popup;
