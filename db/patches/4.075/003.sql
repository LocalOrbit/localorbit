INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.075', '003', '');

ALTER TABLE invoices ADD lo_oid int(10);
ALTER TABLE invoices ADD invoice_num varchar(20);



UPDATE invoices, payables
SET invoices.lo_oid = payables.lo_oid
WHERE invoices.invoice_id = payables.invoice_id;



UPDATE invoices
SET invoice_num = CONCAT('LO-INV-',invoice_id);

