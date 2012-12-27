<h3 id="payment_selector">Payment Method</h3>
<?
global $org;
if($org['payment_allow_authorize'] == 1)
	echo(core_ui::radiodiv('show_payment_authorize','Pay by Authorize.net',false,'payment_method',false,"$('.payment_option').hide();$('#payment_authorize,#placeorder_button').fadeIn(300);").'<br />');
if($org['payment_allow_paypal'] == 1)
	echo(core_ui::radiodiv('show_payment_paypal','Pay by Credit Card',false,'payment_method',false,"$('.payment_option').hide();$('#payment_paypal,#placeorder_button').fadeIn(300);").'<br />');
if($org['payment_allow_purchaseorder'] == 1)
	echo(core_ui::radiodiv('show_payment_purchaseorder','Pay by Purchase Order',false,'payment_method',false,"$('.payment_option').hide();$('#payment_purchaseorder,#placeorder_button').fadeIn(300);").'<br />');
if($org['payment_allow_ach'] == 1)
	echo(core_ui::radiodiv('show_payment_ach','Pay by ACH',false,'payment_method',false,"$('.payment_option').hide();$('#payment_ach,#placeorder_button').fadeIn(300);").'<br />');
?>