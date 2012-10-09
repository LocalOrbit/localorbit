=== Safety Dance ===

Example: select prod_id,name,category_ids from products where category_ids like '%,#,%' or category_ids regexp ',#,$';

select prod_id,name,category_ids from products where category_ids like '%,373,%' or category_ids regexp ',373$';
select prod_id,name,category_ids from products where category_ids like '%,372,%' or category_ids regexp ',372$';
select prod_id,name,category_ids from products where category_ids like '%,830,%' or category_ids regexp ',830$';
select prod_id,name,category_ids from products where category_ids like '%,831,%' or category_ids regexp ',831$';
select prod_id,name,category_ids from products where category_ids like '%,371,%' or category_ids regexp ',371$';
select prod_id,name,category_ids from products where category_ids like '%,659,%' or category_ids regexp ',659$';
select prod_id,name,category_ids from products where category_ids like '%,600,%' or category_ids regexp ',600$';
select prod_id,name,category_ids from products where category_ids like '%,670,%' or category_ids regexp ',670$';
select prod_id,name,category_ids from products where category_ids like '%,828,%' or category_ids regexp ',828$';
select prod_id,name,category_ids from products where category_ids like '%,603,%' or category_ids regexp ',603$';
select prod_id,name,category_ids from products where category_ids like '%,827,%' or category_ids regexp ',827$';
select prod_id,name,category_ids from products where category_ids like '%,829,%' or category_ids regexp ',829$';
select prod_id,name,category_ids from products where category_ids like '%,598,%' or category_ids regexp ',598$';
select prod_id,name,category_ids from products where category_ids like '%,660,%' or category_ids regexp ',660$';
select prod_id,name,category_ids from products where category_ids like '%,178,%' or category_ids regexp ',178$';
select prod_id,name,category_ids from products where category_ids like '%,177,%' or category_ids regexp ',177$';
select prod_id,name,category_ids from products where category_ids like '%,732,%' or category_ids regexp ',732$';
select prod_id,name,category_ids from products where category_ids like '%,816,%' or category_ids regexp ',816$';
select prod_id,name,category_ids from products where category_ids like '%,833,%' or category_ids regexp ',833$';
select prod_id,name,category_ids from products where category_ids like '%,832,%' or category_ids regexp ',832$';
select prod_id,name,category_ids from products where category_ids like '%,419,%' or category_ids regexp ',419$';
select prod_id,name,category_ids from products where category_ids like '%,834,%' or category_ids regexp ',834$';
select prod_id,name,category_ids from products where category_ids like '%,835,%' or category_ids regexp ',835$';
select prod_id,name,category_ids from products where category_ids like '%,733,%' or category_ids regexp ',733$';
select prod_id,name,category_ids from products where category_ids like '%,171,%' or category_ids regexp ',171$';
select prod_id,name,category_ids from products where category_ids like '%,836,%' or category_ids regexp ',836$';
select prod_id,name,category_ids from products where category_ids like '%,837,%' or category_ids regexp ',837$';
select prod_id,name,category_ids from products where category_ids like '%,179,%' or category_ids regexp ',179$';

=== Rename the categories === 
update categories set cat_name='Cured Meats' where cat_id=170; 

=== Create new categories ===

insert into categories (parent_id, cat_name) values (731, 'Sausage');
insert into categories (parent_id, cat_name) values (845, 'Chicken');
insert into categories (parent_id, cat_name) values (845, 'Pork');
insert into categories (parent_id, cat_name) values (845, 'Lamb');
insert into categories (parent_id, cat_name) values (845, 'Turkey');
insert into categories (parent_id, cat_name) values (845, 'Venison');

=== move categories ===
update categories set parent_id=741 where cat_id=373;
update categories set parent_id=741 where cat_id=600;
update categories set parent_id=741 where cat_id=732;

update categories set parent_id=845 where cat_id=372;
update categories set parent_id=845 where cat_id=830;
update categories set parent_id=845 where cat_id=831;
update categories set parent_id=845 where cat_id=371;
update categories set parent_id=845 where cat_id=659;
update categories set parent_id=845 where cat_id=829;
update categories set parent_id=845 where cat_id=660;
update categories set parent_id=845 where cat_id=178;
update categories set parent_id=845 where cat_id=177;

update categories set parent_id=846 where cat_id=670;
update categories set parent_id=846 where cat_id=828;
update categories set parent_id=846 where cat_id=603;
update categories set parent_id=846 where cat_id=827;
update categories set parent_id=846 where cat_id=179;

update categories set parent_id=848 where cat_id=816;
update categories set parent_id=848 where cat_id=833;
update categories set parent_id=848 where cat_id=832;

update categories set parent_id=847 where cat_id=598;
update categories set parent_id=847 where cat_id=419;
update categories set parent_id=847 where cat_id=834;
update categories set parent_id=847 where cat_id=835;
update categories set parent_id=847 where cat_id=733;

update categories set parent_id=849 where cat_id=171;
update categories set parent_id=849 where cat_id=836;

update categories set parent_id=850 where cat_id=837;

=== move products ===

update products set category_ids='2,169,731,741,373' where prod_id=5;
update products set category_ids='2,169,731,741,373' where prod_id=206;
update products set category_ids='2,169,731,741,373' where prod_id=424;
update products set category_ids='2,169,731,741,373' where prod_id=501;

update products set category_ids='2,169,731,845,372' where prod_id=12;
update products set category_ids='2,169,731,845,372' where prod_id=214;
update products set category_ids='2,169,731,845,372' where prod_id=262;
update products set category_ids='2,169,731,845,372' where prod_id=284;
update products set category_ids='2,169,731,845,372' where prod_id=437;
update products set category_ids='2,169,731,845,372' where prod_id=400;

update products set category_ids='2,169,731,845,371' where prod_id=6;
update products set category_ids='2,169,731,845,371' where prod_id=204;
update products set category_ids='2,169,731,845,371' where prod_id=227;

update products set category_ids='2,169,731,845,659' where prod_id=241;

update products set category_ids='2,169,731,845,660' where prod_id=261;
update products set category_ids='2,169,731,845,660' where prod_id=286;

update products set category_ids='2,169,731,845,177' where prod_id=15;
update products set category_ids='2,169,731,845,177' where prod_id=144;
update products set category_ids='2,169,731,845,177' where prod_id=439;

update products set category_ids='2,169,731,845,846,603' where prod_id=239;
update products set category_ids='2,169,731,845,846,179' where prod_id=519;

update products set category_ids='2,169,731,845,848,816' where prod_id=493;

update products set category_ids='2,169,731,845,847,598' where prod_id=145;

update products set category_ids='2,169,731,845,847,419' where prod_id=17;
update products set category_ids='2,169,731,845,847,419' where prod_id=283;


=== create new products ===

insert into categories (parent_id, cat_name) values (624,'Pure Leaf Lard');
insert into categories (parent_id, cat_name) values (176,'Scrapple');
insert into categories (parent_id, cat_name) values (176,'Scrapple, Gluten Free');
insert into categories (parent_id, cat_name) values (741,'Scrapple');
insert into categories (parent_id, cat_name) values (741,'Scrapple, Gluten Free');
insert into categories (parent_id, cat_name) values (741,'Bacon, No-Nitrate');
insert into categories (parent_id, cat_name) values (845,'Bratwurst, Micro-Brewed Beer');
insert into categories (parent_id, cat_name) values (845,'Irish Banger');

=== rename old categories===
update categories set cat_name='Bacon, Canadian' where cat_id=600;
update categories set cat_name='Bacon, Jowl' where cat_id=732;
update categories set cat_name='Breakfast, Bulk' where cat_id=371;
update categories set cat_name='Breakfast, Links' where cat_id=659;
update categories set cat_name='Chimichurri' where cat_id=829;
update categories set cat_name='Italian, Spicy' where cat_id=178;
update categories set cat_name='Italian, Sweet' where cat_id=177;
update categories set cat_name='Bratwurst' where cat_id=670;
update categories set cat_name='Sausage, Jerk' where cat_id=828;
update categories set cat_name='Sausage, Smoked' where cat_id=603;
update categories set cat_name='Sausage' where cat_id=179;
update categories set cat_name='Sausage, Vietnamese' where cat_id=827;
update categories set cat_name='Sausage' where cat_id=816;
update categories set cat_name='Sausage, Merguez' where cat_id=833;
update categories set cat_name='Sausage, Moroccan w/Fig' where cat_id=832;
update categories set cat_name='Sausage' where cat_id=419;
update categories set cat_name='Sausage, Apple & Sage' where cat_id=834;
update categories set cat_name='Sausage, Green Curry' where cat_id=835;
update categories set cat_name='Sausage, Seasoned Ground' where cat_id=733;
update categories set cat_name='Sausage' where cat_id=171;
update categories set cat_name='Sausage, Red Mole' where cat_id=836;
update categories set cat_name='Sausage, w/Berries' where cat_id=837;