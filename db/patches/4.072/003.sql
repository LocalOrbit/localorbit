
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.072', '003', '51530693');

ALTER TABLE payments  MODIFY payment_method enum ('paypal','purchaseorder','ACH','check','cash','paypal_popup');