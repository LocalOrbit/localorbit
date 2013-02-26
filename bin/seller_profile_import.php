<?

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

$sellers = new core_collection('
	select ce.entity_id,o.org_id
	from customer_entity ce
	left join organizations o on ce.org_id=o.org_id
	where o.allow_sell=1

');

$lo2_path = '/home/localorb/sites/production/www/lo2/img/profiles/';
$lo3_path = '/var/www/production/www/img/organizations/';
foreach($sellers as $seller)
{
	echo('locating old profile: '.$seller['entity_id'].' for new profile '.$seller['org_id']."\n");
	$cmd = 'scp lo-old:'.$lo2_path.$seller['entity_id'].'.jpg '.$lo3_path.$seller['org_id'].'.jpg;';
	echo($cmd."\n");
	exec('scp lo-old:'.$lo2_path.$seller['entity_id'].'.jpg '.$lo3_path.$seller['org_id'].'.jpg;');
		
}


?>