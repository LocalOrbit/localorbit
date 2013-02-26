<?

core::ensure_navstate(array('left'=>'left_dashboard'),'emails-tests', 'marketing'); 
core::head('List Markets','asdfasdfasdfsdf');
core_ui::fullWidth();
lo3::require_permission();

page_header('E-mail Testing', null,null, null,null, 'envelop');
?>
<table class="form">
	<tr>
		<td class="label">E-mail</td>
		<td class="value"><input type="text" name="test_email" id="test_email" value="localorbit.testing@gmail.com" /></td>
	</tr>
</table>
<br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'order','force_email':$('#test_email').val()});" value="Order Confirmation Notice" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'order_seller','force_email':$('#test_email').val()});" value="Order Seller Confirmation Notice" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'registration_invite','force_email':$('#test_email').val()});" value="Registration Invite" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'new_registrant','force_email':$('#test_email').val()});" value="New User Email Verification" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'new_registrant_notification','force_email':$('#test_email').val()});" value="Registration MM Notification" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'buyer_welcome','force_email':$('#test_email').val()});" value="EV Confirmation_MM_buyer" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'buyer_welcome_activated','force_email':$('#test_email').val()});" value="EV Confirmation_NO MM_buyer" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'seller_welcome','force_email':$('#test_email').val()});" value="Registration confirmation - seller" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'seller_welcome_activated','force_email':$('#test_email').val()});" value="Registration confirmation - Activated seller" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'org_activated_not_verified','force_email':$('#test_email').val()});" value="MM Activation Notification_NO EV" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'org_activated_verified','force_email':$('#test_email').val()});" value="MM Activation Notification_EV" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'email_change','force_email':$('#test_email').val()});" value="E-mail change" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'simple_test','force_email':$('#test_email').val()});" value="Styles test" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'unit_request','force_email':$('#test_email').val()});" value="Unit Request" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'product_request','force_email':$('#test_email').val()});" value="Product Request" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'reset_password','force_email':$('#test_email').val()});" value="Reset Password" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'canceled_item_notification','force_email':$('#test_email').val()});" value="Item Cancelation Notification" /><br />
<input type="button" class="button_primary" onclick="core.doRequest('/emails/send_test',{'test':'manual_review_notification','force_email':$('#test_email').val()});" value="Manual Review Notification" /><br />
