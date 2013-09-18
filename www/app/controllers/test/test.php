<?php 

$date = "2013-09-16 22:37:48";
echo $date."<br>";

echo core_format::date($date,'short')."<br>";

echo core::model('invoices')->getNextInvoiceNumber(15620)."<br>";


$invoice_id = mysql_insert_id();

$payable_ids = array();
$payable_ids[] = 4;
$payable_ids[] = 5;
$payable_ids[] = 6;
$payable_ids[] = 0;



echo implode(",", $payable_ids)."<br>";

$sql = "UPDATE payables SET invoice_id = ".$invoice_id." WHERE payable_id IN (".implode(",", $payable_ids).")";
?>