<?php
global $core, $payPalApi;
$this->update_fees('yes');

include(__DIR__.'/../../../../../bin/paypal/PayPalApi.php');
$paypalUrl = $payPalApi->getExpressCheckoutRedirect();
core::js('window.open("'.$paypalUrl.'");');
core::deinit();
?>