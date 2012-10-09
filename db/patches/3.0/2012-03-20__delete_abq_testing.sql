update customer_entity set org_id=690 where entity_id=7254;

delete from customer_entity where org_id=683;
delete from organizations   where org_id=683;
delete from products where  org_id=683;
delete from addresses where org_id=683;

delete from customer_entity where org_id=45;
delete from organizations   where org_id=45;
delete from products where  org_id=45;
delete from addresses where org_id=45;

delete from customer_entity where org_id=682;
delete from organizations   where org_id=682;
delete from products where  org_id=682;
delete from addresses where org_id=682;

delete from customer_entity where org_id=680;
delete from organizations   where org_id=680;
delete from products where  org_id=680;
delete from addresses where org_id=680;

delete from product_prices where prod_id not in (select prod_id from products);
delete from product_delivery_cross_sells where prod_id not in (select prod_id from products);
delete from product_images where prod_id not in (select prod_id from products);
delete from product_inventory where prod_id not in (select prod_id from products);