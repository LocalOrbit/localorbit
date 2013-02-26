drop table if exists lo_order_line_item_inventory;

create table lo_order_line_item_inventory (
    loinv_id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    lo_liid int(11) NOT NULL,
    inv_id int(11) NOT NULL,
    qty decimal(10,2) NOT NULL,
    qty_delivered decimal(10,2) NOT NULL
);

alter table product_inventory add column qty_allocated decimal(10,2) not null default 0;

update product_inventory set good_from = null where good_from = '0000-00-00 00:00:00';
update product_inventory set expires_on = null where expires_on = '0000-00-00 00:00:00';