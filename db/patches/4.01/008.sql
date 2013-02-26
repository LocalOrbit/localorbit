INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('008', '');

  ALTER TABLE domains_branding
  MODIFY is_temp tinyint;
  
  ALTER TABLE lo_order_line_item
  MODIFY qty_delivered smallint(8) UNSIGNED DEFAULT '0';
  
  ALTER TABLE lo_order_line_item
  MODIFY lo_foid int(10) UNSIGNED;
  
  ALTER TABLE lo_order_line_item_inventory
  MODIFY qty_delivered decimal(10,2) DEFAULT '0';
  
