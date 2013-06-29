INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.071', '007', '51524895');

UPDATE phrases
SET default_value = '<table width=\"100%\"> 		<colgroup><col width=\"1%\"> 		<col width=\"1%\"> 		<col width=\"98%\"> 		</colgroup><tbody><tr> 			<td>{logo}</td> 			<td>&nbsp;&nbsp;</td> 			<td> 				<h2><a href="http://{hostname}/app.php#!orders-view_order--lo_oid-{lo_oid}">LO #: {order_nbr}</a></h2> 			</td> 		</tr> 	</tbody></table> 	<br>&nbsp;<br> 	You\'ve received a new order!<br>You can check the details of this and all your current orders by logging into your {hubname} account. <br>&nbsp;<br>	 	{items}  	<br><br>If you have any questions please respond to this email.<br>'
WHERE label ='email:order_mm_notification';


UPDATE phrases
SET default_value = '<span>{logo}&nbsp;&nbsp;<span><h2>Order #: <a href="http://{hostname}/app.php#!orders-view_sales_order--lo_foid-{lo_foid}">LO #: {order_nbr}</a></h2></span></span>
<br>&nbsp;<br>&nbsp;<br>
You\'ve received a new order! <br>You can check the details of this and all of your current orders by logging into your {hubname} account. 
<br>&nbsp;<br>
{items}<br><br>If you have any questions please respond to this email. <br>Thank you!<br>'
WHERE label ='email:order_seller';




UPDATE phrases
SET default_value = '<span>{logo}&nbsp;&nbsp;<span><h2>Order #: <a href="http://{hostname}/app.php#!orders-view_sales_order--lo_oid-{lo_oid}">LO #: {order_nbr}</a></h2></span></span>
<br>&nbsp;<br>
Hello!<br>&nbsp;<br>
Thank you for your order through {hubname}!. <br>
You can check the status of your order by logging into your account. 
<br>&nbsp;<br>
{items}
<br><br>
<h2>Method of Payment</h2>
{payment_type}:
<b>{payment_confirm_code}</b>
<br>&nbsp;<br><br>If you have any questions please respond to this email. <br>Thank you for supporting {hubname}!<br>'
WHERE label ='email:order';