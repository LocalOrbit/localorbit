<!DOCTYPE html>
<html lang="en">
<head>
	<title></title>
</head>
<body>
	<?php
		include($_SERVER['DOCUMENT_ROOT'].'/app/core/core.php');
		include($_SERVER['DOCUMENT_ROOT'].'/../bin/paypal/PayPalApi.php');	
		core::init();
		
		try {
			$transactionId = $payPalApi->confirmTransaction();		
			$core->session['paypal_popup_transaction_id'] = $transactionId;
			
			echo "<script>";
				echo 'window.opener.$("#payment_method_paypal_popup").attr("checked",true);';
				echo 'window.opener.core.checkout.process();';
			echo "</script>";
		} catch (Exception $e) {
			// show error, close popup
			echo "<script>";
				echo "window.opener.core.ui.popup('','','<strong>Error with Paypal</strong><br />".$e->getMessage()."','close');";
				//echo "window.opener.location.href = window.opener.location.href;";
			echo "</script>";
		}
	?>
	<script>
		//window.close();
	</script>
</body>
</html>
