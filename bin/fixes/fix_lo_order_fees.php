#!/usr/bin/php
<?php

# basic sectup
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();

$config = array(
	'buyer-org-id'=>0,  # allows you to restrict the query to a single vendor
	'report-sql'=>0,
	'do-adjust'=>0,
	'domain-ids'=>0,
	'check-limit'=>0,
	'exit-on-error'=>0,
	'start-lo-oid'=>6400,
	'report-good'=>0,
);

array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

$sql = '
	select 
	lo.lo_oid,
	lo.fee_percen_lo as lo_order_fee_percen_lo,lo.fee_percen_hub as lo_order_fee_percen_hub,
	d.fee_percen_lo as domains_fee_percen_lo,d.fee_percen_hub as domains_fee_percen_hub
	from lo_order lo
	inner join domains d on (lo.domain_id=d.domain_id)
';

if($config['buyer-org-id'] != 0)
	$sql .= ' and lo.org_id='.$config['buyer-org-id'].' ';
if($config['domain-ids'] != 0)
	$sql .= ' and lo.domain_id in ('.$config['domain-ids'].') ';
if($config['start-lo-oid'] != 0)
	$sql .= ' and lo.lo_oid >= '.$config['start-lo-oid'].' ';

if($config['report-sql'] == 1)	echo("\n$sql\n\n");

$orders = new core_collection($sql);
$checked = 0;
foreach($orders as $order)
{
	$lo = array(
		round(floatval($order['lo_order_fee_percen_lo']),2),
		round(floatval($order['domains_fee_percen_lo']),2)
	);
	$market = array(
		round(floatval($order['lo_order_fee_percen_hub']),2),
		round(floatval($order['domains_fee_percen_hub']),2)
	);
	
	if($lo[0] == $lo[1] && $market[0] == $market[1] && $config['report-good'] == 1)
	{
		echo("Checking ".$order['lo_oid'].": GOOD\n");
	}
	if($lo[0] != $lo[1] || $market[0] != $market[1])
	{
		echo("Checking ".$order['lo_oid'].": BAD\n");
		echo("\t    LO Fee is/should be: ".$lo[0].'/'.$lo[1]."\n");
		echo("\tMarket Fee is/should be: ".$market[0].'/'.$market[1]."\n");
		
		$sql = '
			update lo_order set
				fee_percen_lo = '.$lo[1].',fee_percen_hub='.$market[1].'
			where lo_oid='.$order['lo_oid'];
			
		if($config['report-sql'] == 1)	
			echo("$sql\n\n");
		if($config['do-adjust'] == 1)	
			mysql_query($sql);
		if($config['exit-on-error'] == 1)	
			exit("exiting on error \n");
	}
	
	$checked++;
	if($config['check-limit'] != 0 && $checked == $config['check-limit'])
		exit("check limit reached\n");
}


exit("complete. ".$checked." orders where checked.\n");
?>