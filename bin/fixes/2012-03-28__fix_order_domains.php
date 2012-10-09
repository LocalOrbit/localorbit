<?
global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();

# handle most old orders
$vals = core_db::query('
	select lo_order.*,organizations.domain_id as org_domain_id
	from lo_order
	left join organizations using (org_id)
	where lo_order.domain_id is null;
');
while($val = core_db::fetch_assoc($vals))
{
	core_db::query('update lo_order set domain_id='.intval($val['org_domain_id']).' where lo_oid='.$val['lo_oid']);
}


# handle more orders
$vals = core_db::query('
	select lo_fulfillment_order.*,organizations.domain_id as org_domain_id
	from lo_fulfillment_order
	left join organizations using (org_id)
	where lo_fulfillment_order.domain_id is null;
');
while($val = core_db::fetch_assoc($vals))
{
	core_db::query('update lo_fulfillment_order set domain_id='.intval($val['org_domain_id']).' where lo_foid='.$val['lo_foid']);
}



exit();
?>