alter table domains add feature_require_seller_all_delivery_opts int default 0;
alter table domains add feature_force_items_to_soonest_delivery int default 1;
update domains set feature_force_items_to_soonest_delivery = 1;

alter table delivery_days add pickup_address_id int;
update delivery_days set pickup_address_id = deliv_address_id;
alter table lo_order_deliveries change addr_id deliv_address_id int;

alter table lo_order_deliveries add pickup_address_id int;
update lo_order_deliveries set pickup_address_id=deliv_address_id;

alter table addresses add is_deleted int default 0;