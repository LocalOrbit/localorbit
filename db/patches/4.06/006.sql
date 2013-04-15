ALTER TABLE migrations
  MODIFY version_id varchar(10) NOT NULL;


INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.06', '006', '47769593');

ALTER TABLE lo_order_deliveries
  ENGINE = InnoDB;

CREATE INDEX lo_order_deliveries_status_idx
  ON lo_order_deliveries
  (`status`);
  
  CREATE INDEX lo_order_deliveries_lo_oid_idx
  ON lo_order_deliveries  (lo_oid);

CREATE INDEX lo_order_deliveries_lo_foid_idx
  ON lo_order_deliveries  (lo_foid);