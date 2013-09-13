
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.074', '003', '47769593');

delete from phrases where label='email:deliveries:seller_pre_delivery:subject';
delete from phrases where label='email:deliveries:seller_pre_delivery';

insert into phrases (pcat_id,label,default_value,tags,edit_type) 
values (9,'email:deliveries:seller_pre_delivery:subject','You have deliveries this week','emails','text');


insert into phrases (pcat_id,label,default_value,tags,info_note,edit_type) 
values (9,'email:deliveries:seller_pre_delivery','<h1>Time to Pick, Pack &amp; Deliver</h1><br />Dear {first_name}<br />&nbsp;<br />You have orders to fill! It''s almost time to deliver.<br />&nbsp;<br />Here''s what to do next<br /><ol><li>Login to {hub_name}.</li><li>From your Dashboard, click on the Sales Information Tab.</li><li>Click on Upcoming Deliveries</li><li>Print your Pick List and Packing Slips, taking note of the delivery day, location and time.</li><li>Deliver your orders accordingly, maknig sure to include the packing slip.</li><li>After you deliver your orders, you must mark each of them "delivered". Remember, you will be paid only for items that are marked delivered. * Note, in some Markets, the Market Manager is making items delivered.</li><li>Be sure to update your inventory for the coming week.</li></ol><br />&nbsp;<br />For further assistance, please contact your market manager at {mm_phone}.<br />&nbsp;<br />Thank you for producing great food!<br />','emails','You have access to the following fields: {first_name}, {last_name}, {hub_name}, {mm_phone}','rte');
