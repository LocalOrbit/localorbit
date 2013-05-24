
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.071', '001', '');

ALTER TABLE lo_order_delivery_fees
  MODIFY fee_type varchar(255);	 


ALTER TABLE lo_order_delivery_fees
  MODIFY fee_calc_type_id int;

ALTER TABLE lo_order_delivery_fees
  MODIFY amount decimal(10,2) DEFAULT '0';
  
  