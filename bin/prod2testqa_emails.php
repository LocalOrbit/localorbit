<?

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

if($core->config['production'])
{
	exit('not allowed to run this on production');
}

$custs = core::model('customer_entity')->collection()->filter('org_id','<>',1);
$count = 1;
foreach($custs as $cust)
{
	$cust['email'] = 'localorbit.testing+'.$cust['entity_id'].'@gmail.com';
	$cust->save();
	$count++;
}


?>