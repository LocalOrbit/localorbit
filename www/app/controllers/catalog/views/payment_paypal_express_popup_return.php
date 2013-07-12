<?php
include($_SERVER['DOCUMENT_ROOT'].'/../bin/paypal/PayPalApi.php');	

	
try {
	$transactionId = $payPalApi->confirmTransaction();		
	$core->session['paypal_transaction_id'] = $transactionId;
	?>
	
	<script language="Javascript">
		window.opener.$("#payment_method_paypal").attr("checked",true);
		window.opener.core.checkout.process();
		window.close();
	</script>
	<?
} catch (Exception $e) {
	core::log($e->getMessage());
	echo "<script>";
		echo "window.opener.core.ui.popup('','','<strong>Error with Paypal</strong><br />".$e->getMessage()."','close');";
		echo "window.close();";
	echo "</script>";
}
exit();
?>

