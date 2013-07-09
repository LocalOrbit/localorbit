<?php
	// http://devz01.localorb.it/app.php#!catalog-payment_paypal_express_popup
	global $core;

	try {
		$cart = $this->update_fees('yes');
		
		include(__DIR__.'/../../../../../bin/paypal/PayPalApi.php');
		$paypalUrl = $payPalApi->getExpressCheckoutRedirect($cart);
		//core::log('window.open("'.$paypalUrl.'");');
		//core::js('window.open(\''.$paypalUrl.'\',\'123654786441\',\'width=960,height=800,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0\');');
		//core::js('document.location="'.$paypalUrl.'";');
		//core::deinit(); 
	} catch (Exception $e) {
		echo "<strong>Error with Paypal</strong><br />".$e->getMessage();
	}
?>
