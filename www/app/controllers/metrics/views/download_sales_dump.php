<?

global $core;

lo3::require_orgtype('admin');

header("Content-type: application/csv");
header('Content-Type: application/force-download'); 
header("Content-Type: application/download"); 
header("Content-Disposition: attachment; filename=sales_dump.csv");
header("Pragma: no-cache");
header("Expires: 0");

$now = getdate();
$start_date = mktime(0,0,0) - ($core->data['day'] * 86400) -  $core->session['time_offset'];
$end_date = $start_date + 86400;

$product_changes = core::model('lo_order_line_item')
	->autojoin(
		'left', 
		'lo_order',
		'(lo_order_line_item.lo_oid = lo_order.lo_oid)',
		array())
	->collection()
	->filter('order_date','>=',date('Y-m-d H:i:s',$start_date))
	->filter('order_date','<',date('Y-m-d H:i:s',$end_date));

core::log(print_r($product_changes, true));
//$outstream = fopen("php://temp", 'r+');
?>
prod_id,seller_name,category_ids,final_cat_id,producedat_addr_id
<?
foreach ($product_changes as $change) 
{
?>
<?=$change['prod_id']?>,"<?=$change['seller_name']?>","<?=$change['category_ids']?>",<?=$change['final_cat_id']?>,<?=$change['producedat_address_id']?>	
<?php
}

exit();

?>
