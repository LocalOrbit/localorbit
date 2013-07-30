#!/usr/bin/php
<?php

# basic sectup
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();

$config = array(
	'report-sql'=>0,
	'do-adjust'=>0,
	'lo-oid'=>0,
);

array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

echo("config: ");
print_r($config);

# get the right fees from domains
$sql = '
	select domains.fee_percen_lo,domains.fee_percen_hub,domains.paypal_processing_fee,payment_method
	from domains
	inner join lo_order on (lo_order.domain_id=domains.domain_id)
	where lo_order.lo_oid='.$config['lo-oid'].'
';
if($config['report-sql'] == 1)	echo($sql)."\n\n";
$fees = mysql_query($sql);
if($fees === false)
	exit("Could not find data for order ".$config['lo-oid']."\n");
$fees = mysql_fetch_assoc($fees);

# build a hash of the percentages of the row total that each payable type *should* be.
$final_fees = array(
	'seller order'=>((100 - (
		$fees['fee_percen_hub'] + $fees['fee_percen_lo'] + (($fees['payment_method'] == 'paypal')?$fees['paypal_processing_fee']:0)
	)) / 100),
	'hub fees'=>($fees['fee_percen_hub'] / 100),
	'lo fees'=>($fees['fee_percen_lo'] / 100),
);
echo("fees: ");
print_r($final_fees);

# load all items and their payables:
$sql = '
	select loi.row_adjusted_total,loi.lo_liid
	from lo_order_line_item loi
	where lo_oid='.$config['lo-oid'].'
';
if($config['report-sql'] == 1)	echo($sql)."\n\n";
$items = mysql_query($sql);
while($item = mysql_fetch_assoc($items))
{
	echo("examining item ".$item['lo_liid']."\n");
	
	# now load all of the payables for the item
	$sql = '
		select * from payables 
		where parent_obj_id='.$item['lo_liid'].'
		and payable_type in (\'seller order\',\'hub fees\',\'lo fees\');
	';
	if($config['report-sql'] == 1)	echo($sql)."\n\n";
	$payables = mysql_query($sql);
	
	# loop through and correct if necessary
	while($payable = mysql_fetch_assoc($payables))
	{
		echo("\tchecking payable ".$payable['payable_id']." : ".$payable['payable_type']." : ".$payable['amount']." : ");
		$correct_amount = round(floatval($item['row_adjusted_total'] * $final_fees[$payable['payable_type']]),2);
		$current_amount = round(floatval($payable['amount']),2);
		
		if($correct_amount !== $current_amount)
		{
			echo("WRONG!\n\t\tShould've been $correct_amount, was $current_amount\n");
			$sql = '
				update payables
					set amount='.$correct_amount.'
					where payable_id='.$payable['payable_id'].'
			';
			if($config['report-sql'] == 1)	echo($sql)."\n\n";
			if($config['do-adjust'] == 1)	mysql_query($sql);
		}
		else
		{
			echo("OK!\n");
		}
	}
}




exit("complete\n");

?>