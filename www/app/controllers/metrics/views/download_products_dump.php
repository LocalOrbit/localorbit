<?

global $core;

lo3::require_orgtype('admin');

header("Content-type: application/csv");
header('Content-Type: application/force-download'); 
header("Content-Type: application/download"); 
header("Content-Disposition: attachment; filename=products_dump.csv");
header("Pragma: no-cache");
header("Expires: 0");

$now = getdate();
$start_date = mktime(0,0,0) - ($core->data['day'] * 86400) -  $core->session['time_offset'];
$end_date = $start_date + 86400;

$product_changes = core::model('versions_products')
	->collection()
	->filter('start_date','>=',date('Y-m-d H:i:s',$start_date))
	->filter('start_date','<',date('Y-m-d H:i:s',$end_date));

//$outstream = fopen("php://temp", 'r+');
?>
prod_id,name,addr_id
<?
foreach ($product_changes as $change) 
{
?>
<?=$change['prod_id']?>,"<?=$change['name']?>",<?=$change['addr_id']?>		
<?php
}

exit();

?>
