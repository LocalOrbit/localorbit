<?php 

$date = "2013-09-16 22:37:48";
echo $date."<br>";

echo core_format::date($date,'short')."<br>";

echo core::model('invoices')->getNextInvoiceNumber(15620);

?>