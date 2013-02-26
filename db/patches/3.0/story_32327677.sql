insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (
	8,
	'email:canceled_item_notification',
	'You have received this notification because an item ({product_name}) that was paid for 
	via paypal has been canceled. 
	This action occured on order {lo3_order_nbr}. Click this link to view the order: <a href="{order_link}">{order_link}</a>
	<br />&nbsp;<br />
	This action was performed on hub {hub_name} by {canceled_by}.',
	'You have the following fields available: {lo3_order_nbr}, {order_link}, {product_name}, {hub_name}, {canceled_by}',
	'rte'
);
