
ALTER TABLE lo_order_line_item  MODIFY unit_price decimal(12,2) NOT NULL DEFAULT '0.00';
ALTER TABLE lo_order_line_item  MODIFY row_adjusted_total decimal(12,2) NOT NULL DEFAULT '0.00';
ALTER TABLE lo_order_line_item  MODIFY row_total decimal(12,2) NOT NULL DEFAULT '0.00';

