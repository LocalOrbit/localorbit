INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.074', '002', '56079156');


update phrases
set 
default_value='<span>{logo}&nbsp;&nbsp;<h2><a target="_blank" rel="nofollow" href="http://{hostname}/app.php#!orders-view_sales_order--lo_foid-{lo_foid}">LO #: {order_nbr}</a></h2></span><br />&nbsp;<br />You''ve received a new order from: <b>{buyer_name}</b> <br />&nbsp;<br />You can check the details of this and all of your current orders by following the link above and&nbsp;logging into your {hubname} account. <br />&nbsp;<br />{items}<br /><br />If you have any questions please respond to this email. <br />Thank you!<br />',
info_note='You have the following fields available: {fullname}, {order_nbr}, {items}, {payment_type}, {payment_confirm_code}, {hubname}, {logo}, {buyer_name}'

where label='email:order_seller';


update phrases 
set
default_value='<span>{logo}&nbsp;&nbsp;<h2><a target="_blank" rel="nofollow" href="http://{hostname}/app.php#!orders-view_order--lo_oid-{lo_oid}">LO #: {order_nbr}</a></h2></span><br />&nbsp;<br />You''ve received a new order from: <b>{buyer_name}</b><br />&nbsp;<br />You can check the details of this and all of your current orders by following the link above and&nbsp;logging into your {hubname} account. <br />&nbsp;<br />{items}<br /><br />If you have any questions please respond to this email.<br />Thank you!<br />',
info_note='You have the following fields available: {fullname}, {order_nbr}, {items}, {payment_type}, {payment_confirm_code}, {hubname}, {logo}, {buyer_name}'
where label='email:order_mm_notification';