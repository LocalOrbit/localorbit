insert into phrases (pcat_id,label,default_value,info_note,edit_type) values (8,'email:buyer_welcome_activated','','You have the following fields available: {hostname}, {first_name}, {delivery_address}, {domain_id}','rte');
insert into phrases (pcat_id,label,default_value,info_note,edit_type) values (8,'email:seller_welcome_activated','','You have the following fields available: {hostname}, {first_name}','rte');

insert into phrases (pcat_id,label,default_value,info_note,edit_type) values (8,'email:org_activated_verified','','You have the following fields available: {hostname}','rte');
insert into phrases (pcat_id,label,default_value,info_note,edit_type) values (8,'email:org_activated_not_verified','','You have the following fields available: {hostname}','rte');

insert into phrases (pcat_id,label,default_value,info_note,edit_type) values (8,'email:email_change','','You have the following fields available: {new_email}','rte');

update phrases set info_note='You have the following fields available: {new_email}, {first_name}, {hub_name}' where label='email:email_change';

insert into phrases (pcat_id,label,default_value,edit_type) values (6,'nav2:marketadmin:sold_items','Sold Items','text');

alter table events add domain_id int8;
alter table events drop store_id;

insert into phrases (pcat_id,label,default_value,info_note,edit_type) values (8,'email:order','','You have the following fields available: {fullname}, {order_nbr}, {items}, {payment_type}, {payment_confirm_code}, {hubname}, {logo}','rte');
