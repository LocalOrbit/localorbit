#!/bin/sh
<?php

global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();


$config = array(
	'do-adjust'=>0,
	'report-sql'=>0,
	'report-good'=>0,
	'update-order'=>0,
	'oid'=>9000,
);
array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

echo("Executing with config: \n");
print_r($config);
echo("\n");


$items = core::model('lo_order_line_item')->collection()->filter('lo_oid','=',$config['oid']);

foreach($items as $item)
{
	$correct_row_total = ($item['qty_ordered'] * $item['unit_price']);
	if($item['ldstat_id'] == 3 || ($item['ldstat_id'] == 4 && $item['qty_delivered'] == 0))
	{
		$correct_row_total = 0;
	}
	
	if(round($correct_row_total,2) != round($item['row_total'],2))
	{
	
		echo('checking '.$item['lo_liid'].":\n");
		echo("\t     ldstat_id: ".$item['ldstat_id']."\n");
		
		echo("\t   qty_ordered: ".$item['qty_ordered']."\n");
		echo("\t qty_delivered: ".$item['qty_delivered']."\n");
		echo("\t    unit_price: ".$item['unit_price']."\n");
		echo("\t     row_total: ".$item['row_total']."\n");
		echo("\t  adjust_total: ".$item['row_adjusted_total']."\n");
		echo("\t      discount: ".($item['row_total'] - $item['row_adjusted_total'])."\n");
		echo("NEED TO ADJUST THIS ITEM :(\n");
		echo("--------------------------------\n");
		
		$sql = 'update lo_order_line_item set row_total='.$correct_row_total.' where lo_liid='.$item['lo_liid'];
		if($config['report-sql'] == 1)
		{
			echo($sql."\n\n");
		}
		if($config['do-adjust'] == 1)
		{
			core_db::query($sql);
			$config['update-order'] = 1;
		}
	}
	else
	{
		if($config['report-good'] == 1)
		{
				
			echo('checking '.$item['lo_liid'].":\n");
			echo("\t     ldstat_id: ".$item['ldstat_id']."\n");
			echo("\t   qty_ordered: ".$item['qty_ordered']."\n");
			echo("\t qty_delivered: ".$item['qty_delivered']."\n");
			echo("\t    unit_price: ".$item['unit_price']."\n");
			echo("\t     row_total: ".$item['row_total']."\n");
			echo("\t  adjust_total: ".$item['row_adjusted_total']."\n");
			echo("\t      discount: ".($item['row_total'] - $item['row_adjusted_total'])."\n");
			echo("No need to adjust this item :)\n");
			echo("--------------------------------\n");
		}
	}
	
}

if($config['update-order']  == 1 && $config['do-adjust'] == 1)
{
	echo("item checks complete, now fixing up order: \n");
	$order = core::model('lo_order')->load($config['oid']);
	$core->config['domain'] = core::model('domains')->load($order['domain_id']);
	$order->rebuild_totals_payables(true);

	echo("Order update complete, now checking payables: \n");
	
	$sql = "
		select * from v_payables
		where payable_type = 'buyer order'
		and parent_obj_id in (
			select lo_liid
			from lo_order_line_item
			where lo_oid=".$config['oid']."
		);
	";
	if($config['report-sql'] == 1)
	{
		echo($sql."\n\n");
	}
	$payables = new core_collection($sql);
	foreach($payables as $payable)
	{
		echo("           item id: ".$payable['parent_obj_id']."\n");
		echo("  original amouunt: ".round(floatval($payable['amount']),2)."\n");
		echo("       amount paid: ".round(floatval($payable['amount_paid']),2)."\n");
		if(
			floatval($payable['amount_paid']) > 0 && 
			round(floatval($payable['amount_paid']),2) != round(floatval($payable['amount']),2)
		){
			echo("\tproblem with this payable, buyer paid ".round(floatval($payable['amount_paid']),2));
			echo(",\n\tbut real total should have been ".round(floatval($payable['amount']),2));
			echo("------------------------\n");
		}
		else
		{
			echo("\tALL GOOD!\n");
			echo("------------------------\n");
		}
	}
}




exit("\ncomplete\n");
?>