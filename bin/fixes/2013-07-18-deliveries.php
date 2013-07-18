<?php
global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();


$config = array(
	'do-adjust'=>0,
	'report-details'=>0,
	'report-sql'=>0,
	'limit'=>0,
	'report-good'=>0,
	'start-oid'=>9000,
	'exit-on-error'=>1,
	'ignore-domains'=>'26,3',
	'report-oids'=>0,
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


$sql = '
	select lod.lodeliv_id,lo.lo_oid,lo.org_id,
		dd.deliv_address_id as orig_deliv_address_id,
		dd.pickup_address_id as orig_pickup_address_id,
		lod.deliv_address_id,
		lod.pickup_address_id,
		a1.org_id as deliv_org_id,
		a2.org_id as pickup_org_id,
		lod.dd_id,lo.domain_id
		
	from lo_order_deliveries lod
	inner join lo_order_line_item loi on (loi.lodeliv_id=lod.lodeliv_id)
	inner join lo_order lo on (lo.lo_oid=loi.lo_oid)
	inner join delivery_days dd on (lod.dd_id=dd.dd_id)
	left join addresses a1 on (a1.address_id = lod.deliv_address_id)
	left join addresses a2 on (a2.address_id = lod.pickup_address_id)
	
	where lo.lo_oid > '.$config['start-oid'].'
	and lo.ldstat_id<>1
	and lo.domain_id not in ('.$config['ignore-domains'].')
	order by lo_oid desc
';

if($config['limit'] != 0)
{
	$sql .= ' limit '.$config['limit'];
}


$bad_count = 0;
$good_count = 0;
$order_nbrs = array();
$delivs = new core_collection($sql);
foreach($delivs as $deliv)
{
	
	$needs_fix = false;
	$prefix = '';
	if($deliv['orig_deliv_address_id'] == 0)
	{
		# seller -> buyer
		$prefix = 'deliv';
		if($deliv['deliv_org_id'] != $deliv['org_id'])
		{
			$needs_fix = true;
		}
	}
	else if ($deliv['orig_deliv_address_id'] != 0 && $deliv['orig_pickup_address_id'] == 0)
	{
		# seller -> market -> buyer
		$prefix = 'pickup';
		if($deliv['pickup_org_id'] != $deliv['org_id'])
		{
			$needs_fix = true;
		}
	}
	
	
	if(!$needs_fix)
	{
		if($config['report-good'] == 1)
		{
			echo('Order '.$deliv['lo_oid'].', delivery '.$deliv['lodeliv_id'].": ");
			echo(" ALL GOOD\n");
		}
		$good_count++;
	}
	else
	{
		echo('Order '.$deliv['lo_oid'].', delivery '.$deliv['lodeliv_id'].": ");
		echo(" BROKEN\n");
		
		$order_nbrs[$deliv['lo_oid']] = true;
		
		$addresses = core::model('addresses')
			->collection()
			->filter('org_id','=',$deliv['org_id'])
			->filter('is_deleted','=',0)
			->to_array();
			
		
		
		if(count($addresses) > 1 || count($addresses) == 0)
		{
			echo("\tError: nbr of addresses: ".count($addresses)." \n");
			print_r($deliv);
			print_r($addresses);
			if($config['exit-on-error'] == 1)
			{
				exit();
			}
		}
		else
		{
			echo("\tAssigning to ".$addresses[0]['address']."\n");
			if($config['do-adjust'] == 1)
			{
				$delivery = core::model('lo_order_deliveries')->load($deliv['lodeliv_id']);
				$delivery[$prefix.'_address_id'] = $addresses[0]['address_id'];
				$delivery[$prefix.'_org_id'] = $addresses[0]['org_id'];
				$delivery[$prefix.'_address'] = $addresses[0]['address'];
				$delivery[$prefix.'_city'] = $addresses[0]['city'];
				$delivery[$prefix.'_region_id'] = $addresses[0]['region_id'];
				$delivery[$prefix.'_postal_code'] = $addresses[0]['postal_code'];
				$delivery[$prefix.'_telephone'] = $addresses[0]['telephone'];
				$delivery[$prefix.'_fax'] = $addresses[0]['fax'];
				$delivery[$prefix.'_latitude'] = $addresses[0]['latitude'];
				$delivery[$prefix.'_longitude'] = $addresses[0]['longitude'];
				#print_r($delivery->__data);
				$delivery->save();
			}
			else
			{
				echo("\tNOT adjusting\n");
			}
		}
		
		$bad_count++;
	}
}

if($config['report-oids'] == 1)
{
	$oids = array_keys($order_nbrs);
	if(count($oids) > 0)
	{
		echo("lo_oids: ".implode(',',$oids)."\n");
	}
	else
	{
		echo("lo_oids: none!\n");
	}
}

exit("\ncomplete. ".$bad_count." bad deliveries, ".$good_count." good\n");

?>