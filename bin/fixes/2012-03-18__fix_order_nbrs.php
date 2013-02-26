<?
global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();

# handle most old orders
$vals = core_db::query('
	select lo_order.*,domains.domain_id
	from lo_order
	left join domains on lo_order.store_id=domains.mag_store
	where lo3_order_nbr is null
');
while($val = core_db::fetch_assoc($vals))
{
	echo($val['store_id'] .' : '.$val['domain_id'] .' : '.$val['order_date']."\n");
	if(is_numeric($val['store_id']) && is_numeric($val['domain_id']))
	{
		$year = substr($val['order_date'],2,2);
		echo($year."\n");
		$lo3_id = 'LO-'.$year.'-'.str_pad($val['domain_id'],3,'0',STR_PAD_LEFT);
		$lo3_id .= '-'.str_pad($val['lo_oid'],7,'0',STR_PAD_LEFT);
		echo($lo3_id."\n");
		core_db::query('update lo_order set lo3_order_nbr=\''.$lo3_id.'\' where lo_oid='.$val['lo_oid']);
	}
	else
	{
		print_r($val);
	}
}

# handle more orders
$vals = core_db::query('
	select lo_order.*,domains.domain_id
	from lo_order
	left join organizations o on lo_order.org_id=o.org_id
	left join domains on o.domain_id=domains.domain_id
	where lo3_order_nbr is null
');
while($val = core_db::fetch_assoc($vals))
{
	echo($val['store_id'] .' : '.$val['domain_id'] .' : '.$val['order_date']."\n");
	if(is_numeric($val['domain_id']))
	{
		$year = substr($val['order_date'],2,2);
		echo($year."\n");
		$lo3_id = 'LO-'.$year.'-'.str_pad($val['domain_id'],3,'0',STR_PAD_LEFT);
		$lo3_id .= '-'.str_pad($val['lo_oid'],7,'0',STR_PAD_LEFT);
		echo($lo3_id."\n");
		core_db::query('update lo_order set lo3_order_nbr=\''.$lo3_id.'\' where lo_oid='.$val['lo_oid']);
	}
	else
	{
		print_r($val);
	}
}

# fix missing org_ids on fulfills
$vals = core_db::query('
	select lfo.lo_foid,lfo.seller_mage_customer_id,o.org_id
	from lo_fulfillment_order lfo
	left join customer_entity ce on lfo.seller_mage_customer_id=ce.entity_id
	left join organizations o on ce.org_id=o.org_id
	where lfo.org_id is null
');
while($val = core_db::fetch_assoc($vals))
{
	echo($val['lo_foid'].' : '.$val['org_id'].' : '.$val['seller_mage_customer_id']."\n");
	if(is_numeric($val['org_id']))
		core_db::query('update lo_fulfillment_order set org_id='.$val['org_id'].' where lo_foid='.$val['lo_foid']);
}


# handle more orders
$vals = core_db::query('
	select lo_fulfillment_order.*,domains.domain_id
	from lo_fulfillment_order
	left join organizations o on lo_fulfillment_order.org_id=o.org_id
	left join domains on o.domain_id=domains.domain_id
	where lo3_order_nbr is null
');
while($val = core_db::fetch_assoc($vals))
{
	echo($val['domain_id'] .' : '.$val['order_date']."\n");
	if(is_numeric($val['domain_id']))
	{
		$year = substr($val['order_date'],2,2);
		echo($year."\n");
		$lo3_id = 'LFO-'.$year.'-'.str_pad($val['domain_id'],3,'0',STR_PAD_LEFT);
		$lo3_id .= '-'.str_pad($val['lo_foid'],7,'0',STR_PAD_LEFT);
		echo($lo3_id."\n");
		core_db::query('update lo_fulfillment_order set lo3_order_nbr=\''.$lo3_id.'\' where lo_foid='.$val['lo_foid']);
	}
	else
	{
		print_r($val);
	}
}



exit();
?>