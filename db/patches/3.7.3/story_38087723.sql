insert into lo_order_discount_codes (lo_oid,disc_id,code,discount_amount,discount_type,applied_amount) values (2928,null,'lo-adjustment',15,'Percent',(select 0.15 * grand_total from lo_order where lo_oid=2928));

update lo_order_line_item set row_adjusted_total = 0.85 * row_total where lo_oid=2928;

update lo_order set grand_total=0.85 * item_total where lo_oid=2928;

update lo_fulfillment_order set adjusted_total = 0.85 * adjusted_total where lo_foid in (select lo_foid from lo_order_line_item where lo_oid=2928);