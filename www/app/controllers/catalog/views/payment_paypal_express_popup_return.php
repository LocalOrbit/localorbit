<?php
include($_SERVER['DOCUMENT_ROOT'].'/../bin/paypal/PayPalApi.php');	

	
try {
	$cart = $this->update_fees('yes');
	$transactionId = $payPalApi->confirmTransaction();		
	$core->session['paypal_transaction_id'] = $transactionId;
	$core->data['payment_method'] = 'paypal';
	$cart->place_order(array(
			'paypal'=>$this->paypal_rules(),
			'authorize'=>$this->authorize_rules(),
			'purchaseorder'=>$this->purchaseorder_rules(),
			'ach'=>$this->ach_rules()
		),
		true
	);
	$core->session['last_oid'] = $cart['lo_oid'];
	
	?>
	
	<script language="Javascript">
		try{
			window.opener.location.href='/app.php#!catalog-confirmation_message';
			window.close();
		}
		catch(e){
			location.href='/app.php#!catalog-confirmation_message';
		}
		//window.close();
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

