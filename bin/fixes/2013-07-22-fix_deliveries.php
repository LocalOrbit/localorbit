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


$order = core_db::row('
	select lo_order.domain_id,lo_order.org_id,UNIX_TIMESTAMP(order_date) as start_time,
	d.tz_id,tz.offset_seconds,d.do_daylight_savings
	from lo_order 
	inner join domains d on (lo_order.domain_id=d.domain_id)
	inner join timezones tz on (d.tz_id=tz.tz_id)
	where lo_oid='.$config['oid']
);
$start_time = $order['start_time'];
$domain_id  = $order['domain_id'];
$org_id     = $order['org_id'];

$core->config['domain'] = array(
	'offset_seconds'=>$order['offset_seconds'],
	'do_daylight_savings'=>$order['do_daylight_savings'],

);
$core->session['time_offset'] = $order['offset_seconds'] + (3600 * $order['do_daylight_savings']);

$items = core::model('lo_order_line_item')
	->collection()
	->filter('lo_oid','=',$config['oid']);


echo("checking all items:\n");
$deliveries = array();
foreach($items as $item)
{
	echo("\t".$item['product_name']."\n");
	$deliv_opts = core::model('delivery_days')->get_days_for_prod($item['prod_id'],$domain_id);
	$current_best = 9999999999;
	$best = null;
	foreach($deliv_opts as $deliv_opt)
	{
		$deliv_opt->next_time($start_time);
		
		if($deliv_opt['delivery_start_time'] < $current_best)
		{
			 $current_best = $deliv_opt['delivery_start_time'];
			 $best = $deliv_opt;
		}
		echo("\t\topt ".$deliv_opts['dd_id']." : ".date('Y-m-d H:i:s',$deliv_opt['delivery_start_time'])."\n");
	}
	echo("\t\t------best opt is: ".$best['dd_id'].", ".date('Y-m-d H:i:s',$current_best)."\n");
	if(!isset($deliveries[$best['dd_id']]))
	{
		$deliveries[$best['dd_id']] = array();
	}
	$deliveries[$best['dd_id']][] = $item['lo_liid'];
}

print_r($deliveries);

foreach($deliveries as $dd_id=>$items)
{
	$delivery = core::model('delivery_days')->load($dd_id);
	$delivery->next_time($start_time);
	
	
	$order_delivery = core::model('lo_order_deliveries');
	$order_delivery['lo_oid'] = $config['oid'];
	$order_delivery['dd_id'] = $dd_id;
	$order_delivery['dd_id_group'] = $dd_id;
	
	$order_delivery['delivery_start_time'] = $delivery['delivery_start_time'];
	$order_delivery['delivery_end_time'] = $delivery['delivery_end_time'];
	$order_delivery['pickup_start_time'] = $delivery['pickup_start_time'];
	$order_delivery['pickup_end_time'] = $delivery['pickup_end_time'];
	
	$need_set_deliv  = true;
	$need_set_pickup = true;
	if(intval($delivery['deliv_address_id']) == 0)
	{
		$address1 = core::model('addresses')->collection()->filter('org_id','=',$org_id)->to_array();
		$order_delivery['deliv_org_id'] = $address1[0]['org_id'];
		$order_delivery['deliv_address_id'] = $address1[0]['address_id'];
		$order_delivery['deliv_address'] = $address1[0]['address'];
		$order_delivery['deliv_city'] = $address1[0]['city'];
		$order_delivery['deliv_region_id'] = $address1[0]['region_id'];
		$order_delivery['deliv_postal_code'] = $address1[0]['postal_code'];
		$order_delivery['deliv_telephone'] = $address1[0]['telephone'];
		$order_delivery['deliv_fax'] = $address1[0]['fax'];
		$order_delivery['deliv_delivery_instructions'] = $address1[0]['delivery_instructions'];
		$order_delivery['deliv_longitude'] = $address1[0]['longitude'];
		$order_delivery['deliv_latitude'] = $address1[0]['latitude'];
		$need_set_deliv = false;
		$need_set_pickup = false;
	}
	else if(intval($delivery['pickup_address_id']) == 0)
	{
		$address2 = core::model('addresses')->collection()->filter('org_id','=',$org_id)->to_array();
		$order_delivery['pickup_org_id'] = $address2[0]['org_id'];
		$order_delivery['pickup_address_id'] = $address2[0]['address_id'];
		$order_delivery['pickup_address'] = $address2[0]['address'];
		$order_delivery['pickup_city'] = $address2[0]['city'];
		$order_delivery['pickup_region_id'] = $address2[0]['region_id'];
		$order_delivery['pickup_postal_code'] = $address2[0]['postal_code'];
		$order_delivery['pickup_telephone'] = $address2[0]['telephone'];
		$order_delivery['pickup_fax'] = $address2[0]['fax'];
		$order_delivery['pickup_delivery_instructions'] = $address2[0]['delivery_instructions'];
		$order_delivery['pickup_longitude'] = $address2[0]['longitude'];
		$order_delivery['pickup_latitude'] = $address2[0]['latitude'];
		$need_set_pickup = false;
	}
	
	
	if($need_set_deliv  || $need_set_pickup)
	{
		if($need_set_deliv)
		{
			echo("\tsetting delivery to hub address\n");
			$address1 = core::model('addresses')->load($delivery['deliv_address_id']);
			$order_delivery['deliv_org_id'] = $address1['org_id'];
			$order_delivery['deliv_address_id'] = $address1['address_id'];
			$order_delivery['deliv_address'] = $address1['address'];
			$order_delivery['deliv_city'] = $address1['city'];
			$order_delivery['deliv_region_id'] = $address1['region_id'];
			$order_delivery['deliv_postal_code'] = $address1['postal_code'];
			$order_delivery['deliv_telephone'] = $address1['telephone'];
			$order_delivery['deliv_fax'] = $address1['fax'];
			$order_delivery['deliv_delivery_instructions'] = $address1['delivery_instructions'];
			$order_delivery['deliv_longitude'] = $address1['longitude'];
			$order_delivery['deliv_latitude'] = $address1['latitude'];
		}
		
		if($need_set_pickup)
		{
			echo("\tsetting pickup to hub address\n");
			$address2 = core::model('addresses')->load($delivery['pickup_address_id']);
			$order_delivery['pickup_org_id'] = $address2['org_id'];
			$order_delivery['pickup_address_id'] = $address2['address_id'];
			$order_delivery['pickup_address'] = $address2['address'];
			$order_delivery['pickup_city'] = $address2['city'];
			$order_delivery['pickup_region_id'] = $address2['region_id'];
			$order_delivery['pickup_postal_code'] = $address2['postal_code'];
			$order_delivery['pickup_telephone'] = $address2['telephone'];
			$order_delivery['pickup_fax'] = $address2['fax'];
			$order_delivery['pickup_delivery_instructions'] = $address2['delivery_instructions'];
			$order_delivery['pickup_longitude'] = $address2['longitude'];
			$order_delivery['pickup_latitude'] = $address2['latitude'];
		}
	}

	print_r($order_delivery->__data);
	
	
	if($config['do-adjust'] == 1)
		$order_delivery->save();
	else
		$order_delivery['lodeliv_id'] = 0;
	
	$sql = 'update lo_order_line_item set lodeliv_id='.$order_delivery['lodeliv_id'].' where lo_liid in ('.implode(',',$items).');';
	
	if($config['report-sql'] == 1)
		echo($sql."\n");
		
	if($config['do-adjust'] == 1)
		core_db::query($sql);
}

?>