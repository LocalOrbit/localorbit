select prod_id,name,category_ids from products where category_ids like '%,#127,%' or category_ids regexp ',127$';

update products set category_ids='2,121,125' where prod_id=426;

select prod_id,name,category_ids from products where category_ids like '%,#461,%' or category_ids regexp ',461$';
select prod_id,name,category_ids from products where category_ids like '%,#460,%' or category_ids regexp ',460$';
select prod_id,name,category_ids from products where category_ids like '%,#126,%' or category_ids regexp ',126$';

delete from categories where cat_id=127;
delete from categories where cat_id=461;
delete from categories where cat_id=460;
delete from categories where cat_id=126;

insert into categories (parent_id, cat_name) values (125, 'Watermelon');

update products set category_ids='2,121,125,1027' where prod_id=426;


insert into categories (parent_id, cat_name) values (406, 'Middle Eastern Squash');
insert into categories (parent_id, cat_name) values (242, 'Buttercup Squash');
insert into categories (parent_id, cat_name) values (231, 'Shanghai Cabbage');
