<?
global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();

core_db::query('alter table organizations add product_how text;');

$hows = core_db::query('
	select cet.value,ce.org_id
	from customer_entity_text cet
	left join customer_entity ce on cet.entity_id=ce.entity_id
	where cet.attribute_id=510
');
while($how = core_db::fetch_assoc($hows))
{
	echo($how['value']);
	core_db::query('
		update organizations
		set product_how=\''.mysql_escape_string($how['value']).'\'
		where org_id='.$how['org_id'].'
	');
}

?>