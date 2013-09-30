INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.075', '005', '');

  
  
ALTER TABLE payables ADD lo_oid int(10);
ALTER TABLE payables ADD lo_liid int(10);

UPDATE payables
SET payables.lo_oid = payables.parent_obj_id
WHERE payable_type IN ('delivery fee');

UPDATE payables
SET payables.lo_liid = payables.parent_obj_id
WHERE payable_type IN ('buyer order','seller order','hub fees','lo fees');

UPDATE payables, lo_order_line_item
SET payables.lo_oid = lo_order_line_item.lo_oid
WHERE payables.lo_liid = lo_order_line_item.lo_liid

