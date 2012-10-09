update categories set cat_name='Walleye' where cat_id=92;
delete from categories where cat_id=303;

update categories set parent_id=74 where cat_id=109;
update categories set parent_id=74 where cat_id=107;
update categories set parent_id=74 where cat_id=89;
update categories set parent_id=74 where cat_id=88;
update categories set parent_id=74 where cat_id=87;
update categories set parent_id=74 where cat_id=86;
update categories set parent_id=74 where cat_id=85;
update categories set parent_id=74 where cat_id=84;
update categories set parent_id=74 where cat_id=82;
update categories set parent_id=74 where cat_id=80;
update categories set parent_id=74 where cat_id=78;
update categories set parent_id=74 where cat_id=76;

update categories set parent_id=74 where cat_id=108;
update products set category_ids='2,73,74,108' where prod_id=442;

update categories set parent_id=74 where cat_id=106;
update products set category_ids='2,73,74,106' where prod_id=499;

update categories set parent_id=74 where cat_id=83;
update products set category_ids='2,73,74,83' where prod_id=443;

update categories set parent_id=74 where cat_id=79;
update products set category_ids='2,73,74,79' where prod_id=444;

update categories set parent_id=74 where cat_id=77;
update products set category_ids='2,73,74,77' where prod_id=445;

update categories set parent_id=74 where cat_id=75;
update products set category_ids='2,73,74,75' where prod_id=495;

------ Removing bogus products ------------
delete from products where prod_id=563;
delete from products where prod_id=562;
delete from products where prod_id=561;
delete from products where prod_id=560;
delete from products where prod_id=557;
delete from products where prod_id=559;
delete from products where prod_id=548;
delete from products where prod_id=550;
delete from products where prod_id=554;
delete from products where prod_id=567;
delete from products where prod_id=553;
delete from products where prod_id=523;
delete from products where prod_id=520;
