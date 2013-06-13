#!/usr/bin/php
<?php

# basic sectup
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();

$config = array(
	'do-adjusts'=>0, # pass do-adjusts:1 to make this actually perform updates
	'report-sql'=>0, # pass report-sql:1 to make this actually echo sql
);

# parse the arguments
array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

# this query finds all of the item payables and determines how many seller payables there are.
$sql = "
	select *,FROM_UNIXTIME(creation_date) as item_date from v_payables where payable_id in (4030,4777,3702,4602,6745,3986,4660,3696,4550,6667,3746,4656,4305,6663,3682,3736,4648,6812,4034,4779,3728,4604,6747,3992,4662,3700,4600,6669,3984,4658,3684,4548,6665,3738,4650,6814,4301,4805,3678,3730,4644,6810);
";
if($config['report-sql'] == 1)	echo($sql."\n\n");

$items = new core_collection($sql);

echo("looping through items\n");
foreach($items as $item)
{
	$sql = "
		select payment_method,row_adjusted_total,payable_id
		from lo_order_line_item loi
		inner join lo_order lo on (lo.lo_oid=loi.lo_oid)
		inner join payables p on (loi.lo_liid=p.parent_obj_id and p.payable_type='seller order' and p.from_org_id<>1)
		where loi.lo_liid=".$item['parent_obj_id']."
	";
	if($config['report-sql'] == 1)	echo($sql."\n\n");
	
	$details = mysql_query($sql);
	$details = mysql_fetch_assoc($details);
	
	$fee = 2;
	if($details['payment_method'] == 'paypal')
		$fee += 3;
		
	$old_amount = round(floatval($item['amount']),2);
	$new_amount = round((floatval($details['row_adjusted_total']) * ((100 - $fee) / 100)),2);
	
	
	if($old_amount != $new_amount)
	{
		echo("we need to adjust payables ".$item['payable_id'].",".$details['payable_id']);
		echo(" from ".$old_amount." to ".$new_amount."\n");
		

		$sql = "
			update payables 
			set amount=".$new_amount." 
			where payable_id in (".$item['payable_id'].",".$details['payable_id'].");";
		if($config['report-sql'] == 1)	echo($sql."\n\n");

		if($config['do-adjust'] == 1)
			mysql_query($sql);
		
	}
	else
	{
		echo ("no need to adjust ".$item['payable_id'].",".$details['payable_id']."\n");
	}
	
		
}
?>
