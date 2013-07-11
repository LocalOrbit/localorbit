<?php
include($_SERVER['DOCUMENT_ROOT'].'/../bin/paypal/PayPalApi.php');	
core::init();
	
	try {
		$transactionId = $payPalApi->confirmTransaction();		
		$core->session['paypal_popup_transaction_id'] = $transactionId;
		core::js('window.opener.$("#payment_method_paypal_popup").attr("checked",true);window.opener.core.checkout.process();window.close();');
		core::deinit();
	} catch (Exception $e) {
		core::log($e->getMessage());
	}
?>
<script>
	
	</script>
</body>
</html>
