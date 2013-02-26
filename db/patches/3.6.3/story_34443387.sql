DROP TABLE IF EXISTS `versions_products`;
DROP TABLE IF EXISTS `versions_product_prices`;

CREATE TABLE `versions_products` (
  `v_prod_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL default '9999-12-31 23:59:59',
  `prod_id` bigint(20) NOT NULL,
  `org_id` int(11) DEFAULT NULL,
  `unit_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `how` text,
  `category_ids` varchar(255) DEFAULT NULL,
  `final_cat_id` varchar(255) DEFAULT NULL,
  `addr_id` int(11) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `postal_code` varchar(12) DEFAULT NULL,
  `telephone` varchar(50) DEFAULT NULL,
  `fax` varchar(50) DEFAULT NULL,
  `default_billing` int(11) DEFAULT '0',
  `default_shipping` int(11) DEFAULT '0',
  `delivery_instructions` text,
  `longitude` varchar(50) DEFAULT NULL,
  `latitude` varchar(50) DEFAULT NULL,
  `inventory_qty` decimal(10,2) DEFAULT NULL,
  `who` text,
  PRIMARY KEY (`v_prod_id`),
  KEY `versions_products_idx1` (`org_id`) USING HASH,
  KEY `versions_products_idx2` (`addr_id`) USING HASH,
  KEY `versions_products_idx3` (`unit_id`) USING HASH,
  KEY `versions_products_idx4` (`prod_id`) USING HASH,
  KEY `versions_products_idx5` (`start_date`) USING HASH,
  KEY `versions_products_idx6` (`end_date`) USING HASH
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `versions_product_prices` (
  `v_price_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL default '9999-12-31 23:59:59',  
  `price_id` bigint(20) NOT NULL,
  `prod_id` int(11) DEFAULT NULL,
  `org_id` int(11) DEFAULT '0',
  `domain_id` int(11) DEFAULT '0',
  `price` decimal(10,2) DEFAULT NULL,
  `min_qty` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`v_price_id`),
  KEY `v_product_prices_idx1` (`v_price_id`) USING HASH,
  KEY `versions_product_prices_idx2` (`org_id`) USING HASH,
  KEY `versions_product_prices_idx3` (`domain_id`) USING HASH,
  KEY `versions_product_prices_idx4` (`price_id`) USING HASH,
  KEY `versions_product_prices_idx5` (`start_date`) USING HASH,
  KEY `versions_product_prices_idx6` (`end_date`) USING HASH
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

ALTER TABLE `products` ADD COLUMN `last_modified` TIMESTAMP;
ALTER TABLE `product_prices` ADD COLUMN `last_modified` TIMESTAMP;

update products set last_modified = now();
update product_prices set last_modified = now();

alter table products modify column `last_modified` TIMESTAMP not null;
alter table products modify column `last_modified` TIMESTAMP not null;
