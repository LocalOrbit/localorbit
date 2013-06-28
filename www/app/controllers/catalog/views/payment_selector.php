<div id="payment_selector_div">
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

if($org['payment_allow_paypal'] == 1) {
?>
	<label class="radio">
	<input name="payment_method" type="radio" value="paypal" onclick="$('.payment_option').hide();$('#payment_paypal,#placeorder_button').fadeIn(300);"/>
	Pay by Credit Card
	</label>
<?
}

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


if($org['payment_allow_paypal_popup'] == 1) 
{
	include($_SERVER['DOCUMENT_ROOT'].'/../bin/paypal/PayPalApi.php');	
	echo $payPalApi->getExpressCheckoutButton();
}
?>






<!-- 
this fails  {"append":[],"replace":[],"js":"Y29yZS5jaGVja291dC5oaWRlU3VibWl0UHJvZ3J
<form action="https://www.sandbox.paypal.com/cgi-bin/webscr" target="PPDGFrame">
	<input id="type" type="hidden" name="cmd" value="_express-checkout">
	<input id="token" type="hidden" name="token" value="EC-9YC63326WS826921V">	
	<input type="submit" id="submitBtn" value="Pay with PayPal"> 	
</form>

<script>
	var dgFlow = new PAYPAL.apps.DGFlow({ trigger: 'submitBtn' });
</script>

-->



















</div>