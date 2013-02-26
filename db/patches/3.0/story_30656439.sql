insert into phrases (pcat_id,label,edit_type,default_value) values (4,'field:delivery_days:seller_deliv_section','text','Seller drop off or delivery info');
insert into phrases (pcat_id,label,edit_type,default_value) values (4,'field:delivery_days:buyer_deliv_section','text','Buyer pick up or delivery info');
insert into phrases (pcat_id,label,edit_type,default_value) values (4,'field:checkout_delivery','text','Items for delivery');
insert into phrases (pcat_id,label,edit_type,default_value) values (4,'field:checkout_pickup','text','Items for pickup');
insert into phrases (pcat_id,label,edit_type,default_value) values (2,'order:paymentbypaypal','text','Credit Card');
insert into phrases (pcat_id,label,edit_type,default_value) values (2,'order:paymentbypo','text','Purchase Order');

insert into phrases (pcat_id,label,edit_type,default_value) values (5,'hub:features:req_selr_all_delv_opts','text','Ank and Ragan will determine');
insert into phrases (pcat_id,label,edit_type,default_value) values (5,'hub:features:items_to_1st_delv','text','Ank and Ragan will determine');

update phrases set default_value='Ank and Ragan: hub:features:req_selr_all_delv_opts' where label='hub:features:req_selr_all_delv_opts';
update phrases set default_value='Ank and Ragan: hub:features:items_to_1st_delv' where label='hub:features:items_to_1st_delv';