INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.075', '003', '');

ALTER TABLE invoices ADD lo_oid int(10);
ALTER TABLE invoices ADD invoice_num varchar(20);

UPDATE invoices, payables
SET invoices.lo_oid = payables.parent_obj_id
WHERE invoices.invoice_id = payables.invoice_id
AND payable_type IN ('delivery fee');


UPDATE invoices, payables, lo_order_line_item
SET invoices.lo_oid = lo_order_line_item.lo_oid
WHERE lo_order_line_item.lo_oid = payables.parent_obj_id
AND invoices.invoice_id = payables.invoice_id
AND payable_type IN ('buyer order','seller order','hub fees','lo fees');


// payable_type   enum ('buyer order','seller order','hub fees','lo fees','service fee','delivery fee','paypal fee','payment processing fee'),
  
