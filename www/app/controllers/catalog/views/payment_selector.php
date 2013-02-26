<h3 id="payment_selector"><i class="icon-coins"/>Method</h3>
<br />
<?
global $org;
if($org['payment_allow_authorize'] == 1) {
?>
	<label class="radio">
	<input name="payment_method" type="radio" value="authorize" onclick="$('.payment_option').hide();$('#payment_authorize,#placeorder_button').fadeIn(300);"/>
	Pay by Authorize.net
	</label>
<?
}
//	echo(core_ui::radiodiv('show_payment_authorize','Pay by Authorize.net',false,'payment_method',false,"$('.payment_option').hide();$('#payment_authorize,#placeorder_button').fadeIn(300);").'<br />');
if($org['payment_allow_paypal'] == 1) {
?>
	<label class="radio">
	<input name="payment_method" type="radio" value="paypal" onclick="$('.payment_option').hide();$('#payment_paypal,#placeorder_button').fadeIn(300);"/>
	Pay by Credit Card
	</label>
<?
}
//	echo(core_ui::radiodiv('show_payment_paypal','Pay by Credit Card',false,'payment_method',false,"$('.payment_option').hide();$('#payment_paypal,#placeorder_button').fadeIn(300);").'<br />');
if($org['payment_allow_purchaseorder'] == 1) 
{
?>
	<label class="radio">
	<input name="payment_method" type="radio" value="purchaseorder" onclick="$('.payment_option').hide();$('#payment_purchaseorder,#placeorder_button').fadeIn(300);"/>
	Pay by Purchase Order
	</label>
<?
}

if($org['payment_allow_ach'] == 1) 
{
?>
	<label class="radio">
	<input name="payment_method" type="radio" value="ach" onclick="$('.payment_option').hide();$('#payment_ach,#placeorder_button').fadeIn(300);"/>
	Pay by ACH
	</label>
<?
}
//	ech
//	echo(core_ui::radiodiv('show_payment_purchaseorder','Pay by Purchase Order',false,'payment_method',false,"$('.payment_option').hide();$('#payment_purchaseorder,#placeorder_button').fadeIn(300);").'<br />');
?>