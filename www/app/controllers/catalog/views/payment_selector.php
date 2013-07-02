<div id="payment_selector_div" style="display:none;">
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

if($org['payment_allow_paypal_popup'] == 1)
{
	include($_SERVER['DOCUMENT_ROOT'].'/../bin/paypal/PayPalApi.php');
	echo $payPalApi->getExpressCheckoutButton();
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
?>
</div>

<style>
	// hack until core::js('window.setTimeout("core.checkout.requestUpdatedFees();",1000);'); is fixed
	function showPaymentSelector() {
		$("#payment_selector_div").show();
	}
	core::js('window.setTimeout("showPaymentSelector()",2000);');
</style>