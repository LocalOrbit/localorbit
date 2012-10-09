<?

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

$orgs = core::model('organizations')->collection();
foreach($orgs as $org)
{
	echo('updating '.$org['name']."\n");
	$addresses = core::model('addresses')->collection()->filter('org_id',$org['org_id'])->to_array();
	$has_default_ship = false;
	$has_default_bill = false;
	foreach($addresses as $address)
	{
		if($address['default_billing'] == 1)
			$has_default_bill = true;
		if($address['default_shipping'] == 1)
			$has_default_ship = true;
	}
	if($has_default_bill)
		echo("\tyes default bill, ");
	else
		echo("\tno default bill, ");
		
	if($has_default_ship)
		echo("yes default ship\n");
	else
		echo("no default ship\n");
		
	if(!$has_default_bill && count($addresses) > 0)
	{
		echo("\t\t setting default bill to ".$addresses[0]['address_id']."\n");
		$address = core::model('addresses')->load($addresses[0]['address_id']);
		$address->set('default_billing',1)->save();
		$has_default_bill = true;
	}
	if(!$has_default_ship && count($addresses) > 0)
	{
		echo("\t\t setting default ship to ".$addresses[0]['address_id']."\n");
		$address = core::model('addresses')->load($addresses[0]['address_id']);
		$address->set('default_shipping',1)->save();
		$has_default_ship = true;
	}
}




?>