
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.074', '004', '56079832');

delete from phrases where label='email:mm_underdelivery:subject';
delete from phrases where label='email:mm_underdelivery';

insert into phrases (pcat_id,label,default_value,tags,edit_type) 
values (8,'email:mm_underdelivery:subject','Discount Code Required','emails','text');


insert into phrases (pcat_id,label,default_value,tags,info_note,edit_type) 
values (8,'email:mm_underdelivery','Hello {first_name},<br />&nbsp;<br />Recently an item was delivered but the quantity delivered was less than the amount ordered.  Please issue a <a href="https://localorbit.zendesk.com/entries/22434743-How-to-Create-Discount-Codes">discount code</a> for the buyer, making sure the discount only applies to products sold by this seller. ','emails','You have access to the following fields: {first_name}, {last_name}, {order_id}, {order_nbr}','rte');
