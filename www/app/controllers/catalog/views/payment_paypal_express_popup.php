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
			$paypalUrl = $payPalApi->getExpressCheckoutRedirect();
			
			echo "<script>";
				echo 'document.location="'.$paypalUrl.'";';
			echo "</script>";
		} catch (Exception $e) {
			// show error, close popup
			echo "<script>";
				echo "window.opener.core.ui.popup('','','<strong>Error with Paypal</strong><br />".$e->getMessage()."','close');";
				echo "window.close();";
				//echo "window.opener.location.href = window.opener.location.href;";
			echo "</script>";
		}
	?>
</body>
</html>
