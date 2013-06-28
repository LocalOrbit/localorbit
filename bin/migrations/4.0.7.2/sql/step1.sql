




drop table if exists buyer_orders;
create table buyer_orders(
	buyer_order_id int AUTO_INCREMENT,
	lo3_order_nbr varchar(50),
	buyer_org_id int8,
	domain_id int8,
	order_date int8,
	fee_percent_lo decimal(10,2),
	fee_percent_market decimal(10,2),
	fee_percent_paypal decimal(10,2),
	admin_notes text,
	PRIMARY KEY(buyer_order_id)
) engine=InnoDB;

drop trigger if exists buyer_orders__set_lo3_order_nbr;

CREATE TRIGGER buyer_orders__set_lo3_order_nbr BEFORE INSERT ON buyer_orders
FOR EACH ROW 
 
	set NEW.lo3_order_nbr=concat(
		'LO-',
		RIGHT(YEAR(FROM_UNIXTIME(NEW.order_date)),2),
		'-',
		LPAD(NEW.domain_id,3,'0'),
		'-',
		LPAD((SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='buyer_orders'),6,'0')
	);


insert into buyer_orders (order_date,fee_percent_lo,fee_percent_market,fee_percent_paypal,domain_id,buyer_org_id) values (UNIX_TIMESTAMP(CURRENT_TIMESTAMP),4,6,3,15,704);


drop table if exists seller_orders;
create table seller_orders(
	seller_order_id int8 AUTO_INCREMENT,
	lo3_order_nbr varchar(50),
	buyer_order_id int8,
	seller_org_id int8,
	admin_notes text,
	PRIMARY KEY(seller_order_id)
) engine=InnoDB;

drop trigger if exists seller_orders__set_lo3_order_nbr;

CREATE TRIGGER seller_orders__set_lo3_order_nbr BEFORE INSERT ON seller_orders
FOR EACH ROW 
 
	set NEW.lo3_order_nbr=concat(
		'LFO-',
		(select RIGHT(YEAR(FROM_UNIXTIME(order_date)),2) from buyer_orders where buyer_order_id=NEW.buyer_order_id),
		'-',
		(select LPAD(domain_id,3,'0') from buyer_orders where buyer_order_id=NEW.buyer_order_id),
		'-',
		(
			SELECT LPAD(AUTO_INCREMENT,6,'0') 
			FROM information_schema.TABLES 
			WHERE TABLE_SCHEMA=DATABASE() 
			AND TABLE_NAME='seller_orders'
		));
insert into seller_orders (buyer_order_id,seller_org_id) values (1,1466);

drop table if exists order_deliveries;
create table order_deliveries (
	order_delivery_id int8 AUTO_INCREMENT,
	buyer_order_id int8,
	dd_id int8,
	fee numeric(10,2),
	PRIMARY KEY(order_delivery_id)
) engine=InnoDB;

insert into order_deliveries (buyer_order_id,dd_id,fee) values (1,5,6);


drop table if exists order_delivery_steps;
create table order_delivery_steps (
	odstep_id int8 AUTO_INCREMENT,
	order_delivery_id int8,
	address_id int8,
	start_time int8,
	end_time int8,
	org_id int8,
	PRIMARY KEY(odstep_id)
) engine=InnoDB;


drop table if exists order_items;
create table order_items(
	item_id int8 AUTO_INCREMENT,
	buyer_order_id int8,
	seller_order_id int8,
	order_delivery_id int8,
	qty_ordered numeric(10,2),
	qty_delivered numeric(10,2),
	unit_price numeric(10,2),
	discount_unit_price numeric(10,2),	
	prod_id int8,
	product_name varchar(255),
	unit_single varchar(50),
	unit_plural varchar(50),
	ldstat_id int8,
	lbps_id int8,
	lsps_id int8,
	PRIMARY KEY(item_id)
) engine=InnoDB;


insert into order_items (buyer_order_id,seller_order_id,qty_ordered,qty_delivered,
  unit_price,discount_unit_price,prod_id,product_name,unit_single,unit_plural,
  ldstat_id,lbps_id,lsps_id)
  
 values (1,1,5,5,6.00,6.00,2997,'Spinach','Bag','Bags',2,2,1);

insert into order_items (buyer_order_id,seller_order_id,qty_ordered,qty_delivered,
  unit_price,discount_unit_price,prod_id,product_name,unit_single,unit_plural,
  ldstat_id,lbps_id,lsps_id)
  
 values (1,1,2,2,10.00,8.00,2679,'Arugula','Half Pounds','Half Pound',2,2,1);
