INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.071', '007', '51524895');

UPDATE phrases
SET default_value = '<table width=\"100%\"> 		<colgroup><col width=\"1%\"> 		<col width=\"1%\"> 		<col width=\"98%\"> 		</colgroup><tbody><tr> 			<td>{logo}</td> 			<td>&nbsp;&nbsp;</td> 			<td> 				<h2><a href="http://{hostname}/app.php#!orders-view_order--lo_oid-{order_id}">LO #: {order_nbr}</a></h2> 			</td> 		</tr> 	</tbody></table> 	<br>&nbsp;<br> 	You\'ve received a new order!<br>You can check the details of this and all your current orders by logging into your {hubname} account. <br>&nbsp;<br>	 	{items}  	<br><br>If you have any questions please respond to this email.<br>'
WHERE label ='email:order_mm_notification';