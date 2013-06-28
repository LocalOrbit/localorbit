<?php
global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();


$config = array(
	'check-lo-order'=>1,
	'check-lo-fulfillment-order'=>1,
	'check-limit'=>0,
	'do-adjust'=>0,
	'report-details'=>0,
	'report-sql'=>0,
	'only-lo-oids'=>0,
	'only-lo-foids'=>0,
);
array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}



if($config['check-lo-order'] == 1)
{
	echo("Step 1: lo_order\n");
	$sql = '
		select *
		from lo_order
		where ldstat_id<>1
		
	';
	
	if($config['only-lo-oids'] != 0)
	{
		$sql .= ' and lo_oid in ('.$config['only-lo-oids'].') ';
	}
	
	$sql .= ' order by lo_oid desc ';

	$checked=0;
	$orders = new core_collection($sql);
	foreach($orders as $order)
	{
		ob_start();
		echo("  Checking order ".$order['lo_oid']."\n");
		
		$correct_grand_total = 0;
		$correct_item_total = 0;
		$correct_adjusted_total = 0;
		
		$items = core::model('lo_order_line_item')->collection()->filter('lo_oid','=',$order['lo_oid']);
		foreach($items as $item)
		{
			$correct_item_total += floatval($item['row_total']);
			$correct_adjusted_total += (floatval($item['row_total']) - floatval($item['row_adjusted_total']));
			$correct_grand_total += floatval($item['row_adjusted_total']);
		}
		
		$fees = core::model('lo_order_delivery_fees')->collection()->filter('lo_oid','=',$order['lo_oid']);
		foreach($fees as $fee)
		{
			$correct_grand_total += floatval($fee['applied_amount']);
		}
		
		if($config['report-details'] == 1)
		{
			echo("          Item Total Correct / Current: ".round(floatval($correct_item_total),2)." / ".round(floatval($order['item_total']),2)."\n");
			echo("      Adjusted Total Correct / Current: ".round(floatval($correct_adjusted_total),2)." / ".round(floatval($order['adjusted_total']),2)."\n");
			echo("            Delivery Fee Total Correct: ".(round(floatval($correct_grand_total),2) - round(floatval($correct_adjusted_total),2))."\n");
			echo("         Grand Total Correct / Current: ".round(floatval($correct_grand_total),2)." / ".round(floatval($order['grand_total']),2)."\n");
		}
		
		if(
			round(floatval($correct_item_total),2) != round(floatval($order['item_total']),2)
			||
			round(floatval($correct_adjusted_total),2) != round(floatval($order['adjusted_total']),2)
			||
			round(floatval($correct_grand_total),2) != round(floatval($order['grand_total']),2)
		)
		{
			echo("    NEED TO ADJUST :(\n");
			
			$sql = '
				update lo_order set
					item_total='.round(floatval($correct_item_total),2).',
					adjusted_total='.round(floatval($correct_adjusted_total),2).',
					grand_total='.round(floatval($correct_grand_total),2).'
				where lo_oid='.$order['lo_oid'];
			if($config['report-sql'] == 1)
			{
				echo("\n$sql\n\n");
			}
			if($config['do-adjust'] == 1)
			{
				mysql_query($sql);
				echo("    ADJUST COMPLETE!\n");
			}
			else
			{
				echo("    Not adjusting. Use do-adjust:1 parameter\n");
			}
			ob_end_flush();
		}
		else if($config['report-good'] == 1)
		{
			echo("    ALL GOOD\n\n");
			ob_end_flush();
		}
		else
		{
			ob_end_clean();
		}
		
		$checked++;
		if($checked == $config['check-limit'])
			exit("\nReached check-limit: ".$checked."\n");
	}
}






if($config['check-lo-fulfillment-order'] == 1)
{
	echo("Step 2: lo_fulfillment_order\n");
	$sql = '
		select *
		from lo_fulfillment_order
		where ldstat_id<>1
		
	';
	
	if($config['only-lo-foids'] != 0)
	{
		$sql .= ' and lo_foid in ('.$config['only-lo-foids'].') ';
	}
	
	$sql .= ' order by lo_foid desc ';

	$checked=0;
	$orders = new core_collection($sql);
	foreach($orders as $order)
	{
		ob_start();
		echo("  Checking fulfillment order ".$order['lo_foid']."\n");
		
		$correct_grand_total = 0;
		$correct_item_total = 0;
		$correct_adjusted_total = 0;
		
		$items = core::model('lo_order_line_item')->collection()->filter('lo_foid','=',$order['lo_foid']);
		foreach($items as $item)
		{
			$correct_adjusted_total += (floatval($item['row_total']) - floatval($item['row_adjusted_total']));
			$correct_grand_total += floatval($item['row_adjusted_total']);
		}
		
		if($config['report-details'] == 1)
		{
			echo("      Adjusted Total Correct / Current: ".round(floatval($correct_adjusted_total),2)." / ".round(floatval($order['adjusted_total']),2)."\n");
			echo("         Grand Total Correct / Current: ".round(floatval($correct_grand_total),2)." / ".round(floatval($order['grand_total']),2)."\n");
		}
		
		if(
			round(floatval($correct_adjusted_total),2) != round(floatval($order['adjusted_total']),2)
			||
			round(floatval($correct_grand_total),2) != round(floatval($order['grand_total']),2)
		)
		{
			echo("    NEED TO ADJUST :(\n");
			
			$sql = '
				update lo_fulfillment_order set
					adjusted_total='.round(floatval($correct_adjusted_total),2).',
					grand_total='.round(floatval($correct_grand_total),2).'
				where lo_foid='.$order['lo_foid'];
			if($config['report-sql'] == 1)
			{
				echo("\n$sql\n\n");
			}
			if($config['do-adjust'] == 1)
			{
				mysql_query($sql);
				echo("    ADJUST COMPLETE!\n");
			}
			else
			{
				echo("    Not adjusting. Use do-adjust:1 parameter\n");
			}
			ob_end_flush();
		}
		else if($config['report-good'] == 1)
		{
			echo("    ALL GOOD\n\n");
			ob_end_flush();
		}
		else
		{
			ob_end_clean();
		}
		
		$checked++;
		if($checked == $config['check-limit'])
			exit("\nReached check-limit: ".$checked."\n");
			
	}
}

?>