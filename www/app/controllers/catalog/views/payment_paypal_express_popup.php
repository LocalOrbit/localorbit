<?php
	// http://devz01.localorb.it/app.php#!catalog-payment_paypal_express_popup
	global $core;
	core::log('trying to load');

	try {
		$cart = core::model('lo_order')->get_cart();
		$cart->load_items(true);
		
		include(__DIR__.'/../../../../../bin/paypal/PayPalApi.php');
		$paypalUrl = $payPalApi->getExpressCheckoutRedirect($cart);
		echo('<script>location.href="'.$paypalUrl.'";</script>');
 
	} catch (Exception $e) {
		core::log('paypal error: '.$e->getMessage());
		echo "<script>";
			echo "window.opener.core.ui.popup('','','<strong>Error with Paypal</strong><br />".$e->getMessage()."','close');";
			echo "window.close();";
		echo "</script>";
	}
	
	// dont send back json
	exit();
?>
