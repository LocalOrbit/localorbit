<?php
include($_SERVER['DOCUMENT_ROOT'].'/../bin/paypal/PayPalApi.php');	

	
	try {
		$transactionId = $payPalApi->confirmTransaction();		
		$core->session['paypal_popup_transaction_id'] = $transactionId;
		core::js('window.opener.$("#payment_method_paypal_popup").attr("checked",true);window.opener.core.checkout.process();window.close();');
		core::deinit();
	} catch (Exception $e) {
		core::log($e->getMessage());
		echo "<script>";
			echo "window.opener.core.ui.popup('','','<strong>Error with Paypal</strong><br />".$e->getMessage()."','close');";
			echo "window.close();";
		echo "</script>";
	}
	
	// dont send back json
	ob_end_flush();
	exit();
?>

