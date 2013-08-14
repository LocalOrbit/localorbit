DROP TABLE IF  EXISTS buyer_orders;
CREATE TABLE buyer_orders (
  buyer_order_id      int(10) UNSIGNED AUTO_INCREMENT NOT NULL,
  buyer_org_id        int(10) UNSIGNED,
  domain_id            int(10) UNSIGNED,
  order_date              datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  fee_percent_lo           decimal(10,2) DEFAULT '0.00',
  fee_percent_market           decimal(10,2) DEFAULT '0.00',
  fee_percent_paypal           decimal(10,2) DEFAULT '0.00',
  admin_notes     text,
  PRIMARY KEY (buyer_order_id),
  
   CONSTRAINT buyer_orders_buyer_org_id_fk
    FOREIGN KEY (buyer_org_id)
    REFERENCES organizations(org_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
   CONSTRAINT buyer_orders_domain_id_fk
    FOREIGN KEY (domain_id)
    REFERENCES domains(domain_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
    
) ENGINE = InnoDB
  CHARACTER SET latin1 COLLATE latin1_swedish_ci;

CREATE INDEX buyer_orders_domain_id_idx1
  ON buyer_orders
  (order_date);






CREATE TABLE seller_orders (
  seller_order_id                  int(10) UNSIGNED AUTO_INCREMENT NOT NULL,
  buyer_order_id        int(10) UNSIGNED,
  seller_org_id           int(10) UNSIGNED,
  admin_notes     text,
  PRIMARY KEY (seller_order_id),
    
   CONSTRAINT seller_orders_buyer_order_id_fk
    FOREIGN KEY (buyer_order_id)
    REFERENCES buyer_orders(buyer_order_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
   CONSTRAINT seller_orders_seller_org_id_fk
    FOREIGN KEY (seller_org_id)
    REFERENCES organizations(org_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT 
  
) ENGINE = InnoDB
  CHARACTER SET latin1 COLLATE latin1_swedish_ci;











ALTER TABLE delivery_days
  ENGINE = InnoDB;
ALTER TABLE delivery_days
  MODIFY dd_id int(10) UNSIGNED AUTO_INCREMENT NOT NULL;
  
DROP TABLE IF  EXISTS order_deliveries;
CREATE TABLE order_deliveries (
  order_delivery_id                  int(10) UNSIGNED AUTO_INCREMENT NOT NULL,
  buyer_order_id        int(10) UNSIGNED,
  delivery_days_id           int(10) UNSIGNED,
  fee      	decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (order_delivery_id),
  
   CONSTRAINT order_deliveries_buyer_order_id_fk
    FOREIGN KEY (buyer_order_id)
    REFERENCES buyer_orders(buyer_order_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
   CONSTRAINT order_deliveries_delivery_days_id_fk
    FOREIGN KEY (delivery_days_id)
    REFERENCES delivery_days(dd_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
  
) ENGINE = InnoDB
  CHARACTER SET latin1 COLLATE latin1_swedish_ci;
  
  
  
  
  
  
  
  
DROP TABLE IF  EXISTS order_discount_codes;
CREATE TABLE order_discount_codes (
  order_discount_code_id                  int(10) UNSIGNED AUTO_INCREMENT NOT NULL,
  buyer_order_id        int(10) UNSIGNED,
  applied_amount      	decimal(10,2) DEFAULT '0.00',
  code 				 varchar(255),
  discount_amount      	decimal(10,2) DEFAULT '0.00',
  discount_type              enum ('Fixed','Percent'),
  restrict_to_product_id     int(10) DEFAULT '0',
  restrict_to_seller_org_id  int(10) DEFAULT '0',
  min_order                  decimal(10,2) DEFAULT '0.00',
  max_order                  decimal(10,2) DEFAULT '0.00',  
  PRIMARY KEY (order_discount_code_id),
  
  
   CONSTRAINT order_discount_codes_buyer_order_id_fk
    FOREIGN KEY (buyer_order_id)
    REFERENCES buyer_orders(buyer_order_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT   
    
) ENGINE = InnoDB
  CHARACTER SET latin1 COLLATE latin1_swedish_ci;
  
  
  
  




ALTER TABLE addresses
  ENGINE = InnoDB;
ALTER TABLE addresses
  MODIFY address_id int(10) UNSIGNED AUTO_INCREMENT NOT NULL;
DROP TABLE IF  EXISTS order_delivery_steps;
CREATE TABLE order_delivery_steps (
  order_delivery_step_id                  int(10) UNSIGNED AUTO_INCREMENT NOT NULL,
  order_delivery_id        int(10) UNSIGNED,
  address_id        int(10) UNSIGNED,
  start_time        decimal(10,2),
  end_time        decimal(10,2),
  org_id        int(10) UNSIGNED,
  PRIMARY KEY (order_delivery_step_id),
  
   CONSTRAINT order_delivery_stepsorder_delivery_id_fk
    FOREIGN KEY (order_delivery_id)
    REFERENCES delivery_days(dd_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
   CONSTRAINT order_delivery_address_id_fk
    FOREIGN KEY (address_id)
    REFERENCES addresses(address_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT  
    
    
) ENGINE = InnoDB
  CHARACTER SET latin1 COLLATE latin1_swedish_ci;






DROP TABLE IF  EXISTS order_items;
CREATE TABLE order_items (
  order_item_id                  int(10) UNSIGNED AUTO_INCREMENT NOT NULL,
  buyer_order_id        int(10) UNSIGNED,
  seller_order_id        int(10) UNSIGNED,
  order_delivery_id        int(10) UNSIGNED,
  qty_ordered        int(10) UNSIGNED,
  qty_delivered        int(10) UNSIGNED,  
  unit_price        decimal(10,2),
  discount_unit_price    decimal(10,2),  
  product_id        int(10) UNSIGNED,
  product_name   varchar(255),  
  unit_single    varchar(32),  
  unit_plural    varchar(32),    
  delivery_status        enum ('Cart','Pending','Canceled','Delivered','Partially Delivered','Contested'),
  buyer_payment_statuses         enum ('Unpaid','Paid','Invoice Issued','Partially Paid','Refunded','Manual Review'),
  seller_payment_statuses         enum ('Unpaid','Paid','Partially Paid'),
  PRIMARY KEY (order_item_id),
  
  
   CONSTRAINT order_items_buyer_order_id_fk
    FOREIGN KEY (buyer_order_id)
    REFERENCES buyer_orders(buyer_order_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
   CONSTRAINT order_items_seller_order_id_fk
    FOREIGN KEY (seller_order_id)
    REFERENCES seller_orders(seller_order_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,    
    
   CONSTRAINT order_items_order_delivery_id_fk
    FOREIGN KEY (order_delivery_id)
    REFERENCES order_deliveries(order_delivery_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
  
) ENGINE = InnoDB
  CHARACTER SET latin1 COLLATE latin1_swedish_ci;
  
  





  
  