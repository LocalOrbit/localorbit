<?php

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

core_db::query('delete from categories');

$cats = core_db::query('
	select cce.entity_id,cce.parent_id,ccev.value as name
	from catalog_category_entity cce 
	left join catalog_category_entity_varchar ccev on (ccev.entity_id=cce.entity_id and ccev.attribute_id=31);
');

$old2new = array();

while($cat = core_db::fetch_assoc($cats))
{
	if($cat['name'].'' != '')
	{
		$sql = 'insert into categories (cat_name) values (\''.core_db::escape_string(trim($cat['name'])).'\');';
		#echo($sql."\n");
		core_db::query($sql);
		$old2new[$cat['entity_id']] = mysql_insert_id();
	}
}

mysql_data_seek($cats,0);

while($cat = core_db::fetch_assoc($cats))
{
	if(isset($old2new[$cat['parent_id']]) && isset($old2new[$cat['entity_id']]))
	{
		$sql = 'update categories set parent_id='.$old2new[$cat['parent_id']].' where cat_id='.$old2new[$cat['entity_id']];
		#echo($sql."\n");
		core_db::query($sql);
	}
}

$prods = core_db::query('select * from products');
while($prod = core_db::fetch_assoc($prods))
{
	$cats = explode(',',$prod['category_ids']);
	for ($i = 0; $i < count($cats); $i++)
	{
		$cats[$i] = $old2new[$cats[$i]];
	}
	
	$sql = 'update products set category_ids=\''.implode(',',$cats).'\' where prod_id='.$prod['prod_id'];
	#echo($sql."\n");
	core_db::query($sql);
}

?>