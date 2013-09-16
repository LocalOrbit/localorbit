#!/usr/bin/php
<?php

# basic sectup
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();

$config = array(
	'do-send'=>0,  # allows you to run in test mode only
	'start-days-in-future'=>1,
	'days-after-start'=>1,
	'exclude-domains'=>0,
	'only-domains'=>0,
	'report-sql'=>0,
);



array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}


$start_time = time() + (86400 * $config['start-days-in-future']);
$end_time = $start_time + (86400 * $config['days-after-start']);

echo("Final date range is: ".date('Y-m-d H:i:s',$start_time).' -> '.date('Y-m-d H:i:s',$end_time)."\n\n");
$sql = '
	select ce.entity_id,ce.email,ce.first_name,ce.last_name,d.domain_id,
	d.name as market_name,d.hostname,d.secondary_contact_phone
	from lo_fulfillment_order lfo
	inner join lo_order_line_item loi on (loi.lo_foid=lfo.lo_foid)
	inner join lo_order_deliveries lod on (lod.lodeliv_id=loi.lodeliv_id)
	inner join domains d on lfo.domain_id=d.domain_id
	inner join organizations o on (lfo.org_id=o.org_id)
	inner join customer_entity ce on (ce.org_id=o.org_id)
	where ce.is_active=1 and ce.is_deleted=0 and ce.is_enabled=1
	and o.is_active=1 and o.is_deleted=0 and o.is_enabled=1
	and loi.ldstat_id in (2,5)
	and lod.delivery_start_time >= '.$start_time.' 
	and lod.delivery_end_time < '.$end_time.'
';

if($config['exclude-domains'] !== 0)
{
	$sql .= ' and d.domain_id not in ('.$config['exclude-domains'].') ';
}
if($config['only-domains'] !== 0)
{
	$sql .= ' and d.domain_id in ('.$config['only-domains'].') ';
}

$sql .= ' group by ce.entity_id';

if($config['report-sql'] == 1)
{
	echo($sql."\n\n");
}

# change some path settings to help with the market logo
$email_controller = core::controller('emails');
$core->paths['base'] = '/var/www/'.$core->config['stage'].'/www/app';
$core->paths['web'] = '/app';
$core->config['domain'] = array();

$users = new core_collection($sql);
foreach($users as $user)
{
	echo(print_r($user,true));
	$core->config['domain']['domain_id'] = $user['domain_id'];
	$core->config['domain']['hostname']  = $user['hostname'];
	if($config['do-send'] == 1)
	{
		echo(" :: SENDING\n");
		$email_controller->seller_pre_delivery(
			$user['email'],
			$user['first_name'],
			$user['last_name'],
			$user['domain_id'],
			$user['market_name'],
			$user['secondary_contact_phone']
		);
	}
	else
	{
		echo(" :: NOT SENDING\n");
	}
}

exit("\nDONE\n");

?>