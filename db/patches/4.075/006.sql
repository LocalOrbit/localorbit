INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.075', '006', '');

  
ALTER TABLE lo_order_delivery_fees
  MODIFY minimum_order decimal(10,2) DEFAULT '0';

