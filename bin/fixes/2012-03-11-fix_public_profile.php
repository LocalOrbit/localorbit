<?
global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();

core_db::query('alter table organizations add facebook varchar(255);');
core_db::query('alter table organizations add twitter varchar(255);');

$vals = core_db::query('
	select cev.attribute_id,cev.value,ce.entity_id
	from customer_entity_varchar cev
	left join customer_entity ce on cev.entity_id=ce.entity_id
	where cev.attribute_id in (513,514)
');
while($val = core_db::fetch_assoc($vals))
{
	echo($val['value']);
	if($val['attribute_id'] == 13)
	{
		core_db::query('
			update organizations
			set facebook=\''.mysql_escape_string($how['value']).'\'
			where org_id='.$val['org_id'].'
		');
	}
	if($val['attribute_id'] == 14)
	{
		core_db::query('
			update organizations
			set twitter=\''.mysql_escape_string($how['value']).'\'
			where org_id='.$val['org_id'].'
		');
	}
}

?>