<?php	
	// inline version
	include($_SERVER['DOCUMENT_ROOT'].'/app/core/core.php');
	include($_SERVER['DOCUMENT_ROOT'].'/../bin/paypal/PayPalApi.php');	
	core::init();
	
	try {
		$transactionId = $payPalApi->confirmTransaction();		
		$core->session['paypal_popup_transaction_id'] = $transactionId;
		
	} catch (Exception $e) {
		$core->session['paypal_popup_error_message'] = $e->getMessage();
	}
	
	// I dont like the idea of this redirect and using session for this
	header("Location: /app.php#!catalog-checkout");
	die();
?>
