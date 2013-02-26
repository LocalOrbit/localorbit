-- lo_order_line_item columns
alter table lo_order_line_item 
	add column category_ids varchar(255) NOT NULL;

alter table lo_order_line_item 
	add column final_cat_id varchar(255) NOT NULL;

-- address columns for lo_order_line_item    
alter table lo_order_line_item 
	add column `producedat_address_id` bigint(20) NOT NULL;

alter table lo_order_line_item 
	add column `producedat_org_id` int(11) DEFAULT NULL;
  
alter table lo_order_line_item 
	add column `producedat_address` varchar(255) DEFAULT NULL;

alter table lo_order_line_item 
	add column `producedat_city` varchar(255) DEFAULT NULL;

alter table lo_order_line_item 
	add column `producedat_region_id` int(11) DEFAULT NULL;

alter table lo_order_line_item 
	add column `producedat_postal_code` varchar(12) DEFAULT NULL;

alter table lo_order_line_item 
	add column `producedat_telephone` varchar(50) DEFAULT NULL;

alter table lo_order_line_item 
	add column `producedat_fax` varchar(50) DEFAULT NULL;

alter table lo_order_line_item 
	add column `producedat_delivery_instructions` text;

alter table lo_order_line_item 
	add column `producedat_longitude` varchar(50) DEFAULT NULL;

alter table lo_order_line_item 
	add column `producedat_latitude` varchar(50) DEFAULT NULL;

-- lo_order_deliveries  

-- lo_order_delivery addresses
alter table lo_order_deliveries 
	add column `deliv_org_id` int(11) DEFAULT NULL;
  
alter table lo_order_deliveries 
	add column `deliv_address` varchar(255) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `deliv_city` varchar(255) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `deliv_region_id` int(11) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `deliv_postal_code` varchar(12) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `deliv_telephone` varchar(50) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `deliv_fax` varchar(50) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `deliv_delivery_instructions` text;

alter table lo_order_deliveries 
	add column `deliv_longitude` varchar(50) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `deliv_latitude` varchar(50) DEFAULT NULL;

-- lo_order_delivery pickup addresses
alter table lo_order_deliveries 
	add column `pickup_org_id` int(11) DEFAULT NULL;
  
alter table lo_order_deliveries 
	add column `pickup_address` varchar(255) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `pickup_city` varchar(255) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `pickup_region_id` int(11) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `pickup_postal_code` varchar(12) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `pickup_telephone` varchar(50) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `pickup_fax` varchar(50) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `pickup_delivery_instructions` text;

alter table lo_order_deliveries 
	add column `pickup_longitude` varchar(50) DEFAULT NULL;

alter table lo_order_deliveries 
	add column `pickup_latitude` varchar(50) DEFAULT NULL;