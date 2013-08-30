<?php
# load up this orgnization's payment method settings
global $org,$core;
$org = core::model('organizations')->load($core->session['org_id']);

# figure out how many payment methods they have
$paymethods = 0;
$paymethods += intval($org['payment_allow_authorize']);
$paymethods += intval($org['payment_allow_ach']);
$paymethods += intval($org['payment_allow_paypal']);
$paymethods += intval($org['payment_allow_purchaseorder']);

# if they've got more than one, show a radio selector
#if($paymethods > 1)
#{
	$this->payment_selector();
#}
/*
#else
{
	#otherwise, create a hidden option to store the payment method
	if(intval($org['payment_allow_authorize']) == 1)
		$method = 'authorize';
	if(intval($org['payment_allow_paypal']) == 1)
		$method = 'paypal';
	if(intval($org['payment_allow_purchaseorder']) == 1)
		$method = 'purchaseorder';
	if(intval($org['payment_allow_ach']) == 1)
		$method = 'ach';
	echo('<input type="hidden" id="payment_method" name="payment_method" value="'.$method.'" />');
}
**/

# print all the payment forms. Each view function 
# will determine whether or not it needs to actually be rendered.
#$this->payment_authorize($paymethods);
$this->payment_paypal($paymethods);
$this->payment_purchaseorder($paymethods);
$this->payment_ach($paymethods);
?>
<!--
<div class="span3" id="placeorder_button" class="buttonset"<?=(($paymethods > 1)?' style="display:none;"':'')?>>
	<input type="button" onclick="location.href='#!catalog-shop';" value="back to cart" class="button_secondary button_back_to_cart" />
	<input type="button" value="place order" class="button_primary button_place_order" onclick="core.checkout.process();" />
</div>
<div class="span3" id="loading_progress" style="display: none;">
	<img src="<?=image('loading-progress')?>" />
</div>
-->
<?if($paymethods > 1){?>
<input id="radio_payment_method_none" name="payment_method" type="radio" value="cash" style="display:none;" />
<?}?>
<div id="payment_none" class="payment_option span6 form" style="display: none;">
	<b>The discount code you're using completely covers the cost of your order. You must click Place Order to complete this transaction.</b>
</div>