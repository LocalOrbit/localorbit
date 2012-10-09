select prod_id,name,category_ids from products where category_ids like '%405%'; 

update products set category_ids='2,227,241,405' where prod_id=341;
update products set category_ids='2,227,241,405' where prod_id=380;
update products set category_ids='2,227,241,405' where prod_id=733;
update products set category_ids='2,227,241,405' where prod_id=1210;
update products set category_ids='2,227,241,405' where prod_id=1353;
update products set category_ids='2,227,241,405' where prod_id=1354;
update products set category_ids='2,227,241,405' where prod_id=1355;

delete from categories where cat_id=450;
delete from categories where cat_id=449;

select prod_id,name,category_ids from products where category_ids like '%236%';

update products set category_ids='2,227,236' where prod_id=737;
update products set category_ids='2,227,236' where prod_id=868;
update products set category_ids='2,227,236' where prod_id=1240;
update products set category_ids='2,227,236' where prod_id=1241;
update products set category_ids='2,227,236' where prod_id=1242;
update products set category_ids='2,227,236' where prod_id=1243;

delete from categories where cat_id=299;
delete from categories where cat_id=944;
delete from categories where cat_id=943;