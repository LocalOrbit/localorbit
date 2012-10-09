<?
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

# get a list of the delivery days that need to be applied
$dds = new core_collection('
	select dd_id,domain_id 
	from delivery_days 
	where domain_id in (3)
');
$dds = $dds->to_hash('domain_id');

# get a list of products to apply the delivery days to
$prods = new core_collection('
	select p.prod_id,p.org_id,o.domain_id,
	(select sum(qty) from product_inventory inv where inv.prod_id=p.prod_id) as inventory
	from products p
	left join organizations o on (p.org_id=o.org_id)
	where  domain_id in (3)
');

# loop through the products
foreach($prods as $prod)
{
	# for each one, apply the delivery days
	echo('examining product '.$prod['prod_id'].":".$prod['inventory']."\n");
	if(floatval($prod['inventory']) > 0)
	{
		foreach($dds[$prod['domain_id']] as $dd)
		{
			echo("\tadding dd ".$dd['dd_id']."\n");
			$sql = '
				insert into product_delivery_cross_sells 
					(prod_id,dd_id)
				values
					('.$prod['prod_id'].','.$dd['dd_id'].');
			';
			echo($sql."\n");
			#core_db::query($sql);
		}
	}
	else
	{
		echo("no inventory\n");
	}
}
?>