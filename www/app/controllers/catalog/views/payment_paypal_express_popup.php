<?php
$this->update_fees('yes');
$paypalUrl = $payPalApi->getExpressCheckoutRedirect();
core::js('window.open("'.$paypalUrl.'");');
core::deinit();
?>