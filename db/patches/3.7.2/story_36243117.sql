drop table if exists lo_order_discount_codes;
drop table if exists lo_order_delivery_fees;
drop table if exists lo_fulfillment_order_discount_codes;

create table lo_order_discount_codes(
	`lodisc_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`lo_oid` int(11),
	disc_id int,
	code varchar(255),
	discount_amount decimal(10,2),
	discount_type enum('Fixed','Percent'),
	
	restrict_to_product_id int,
	restrict_to_seller_org_id int,
	 `applied_amount` decimal(10,2) default 0
);


-- insert into lo_order_discount_codes (disc_id,code,discount_amount,discount_type) values (1,'ASDF',20,'Percent');

create table lo_order_delivery_fees(
	`lodevfee_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`lo_oid` int(11),
    `devfee_id` int(11),
    `dd_id` int(11) NOT NULL,
    `fee_type` varchar(255) NOT NULL,
    `fee_calc_type_id` int(11) NOT NULL,
    `amount` decimal(10, 2) NOT NULL,
    `minimum_order` decimal(10,2) NOT NULL,
    `applied_amount` decimal(10,2) default 0
);

alter table discount_uses drop user_id;
alter table discount_uses add org_id int8;
delete from discount_uses;

alter table lo_order_discount_codes add restrict_to_buyer_org_id int8;
alter table lo_order_discount_codes add min_order numeric(10,2);
alter table lo_order_discount_codes add max_order numeric(10,2);



