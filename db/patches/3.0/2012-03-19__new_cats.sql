insert into categories (parent_id,cat_name) values (170,'Chicken Sausage, Vietnamese');
insert into categories (parent_id,cat_name) values (170,'Chicken Sausage, Jerk');
insert into categories (parent_id,cat_name) values (170,'Chimichurri Sausage');
insert into categories (parent_id,cat_name) values (170,'Bratwurst, Bacon & Beer w/Aged Swiss');
insert into categories (parent_id,cat_name) values (170,'Bratwurst, Garlic & Juniper');
insert into categories (parent_id,cat_name) values (170,'Lamb Sausage, Moroccan Lamb & Fig');
insert into categories (parent_id,cat_name) values (170,'Lamb Sausage, Merguez');
insert into categories (parent_id,cat_name) values (170,'Pork Sausage, Apple & Sage');
insert into categories (parent_id,cat_name) values (170,'Pork Sausage, Green Curry');
insert into categories (parent_id,cat_name) values (170,'Turkey Sausage, Red Mole');
insert into categories (parent_id,cat_name) values (170,'Venison Sausage, w/Berries');

insert into categories (parent_id,cat_name) values (2,'Snacks');
insert into categories (parent_id,cat_name) values (0,'Chips');
insert into categories (parent_id,cat_name) values (0,'Potato Chips');
update categories set parent_id=(select cat_id from (select * from categories) as x where cat_name='Snacks') where cat_name='Chips';
update categories set parent_id=(select cat_id from (select * from categories) as x  where cat_name='Chips') where cat_name='Potato Chips';




 


 

