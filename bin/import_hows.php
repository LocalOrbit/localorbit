<?

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

$hows = explode("\n",file_get_contents(dirname(__FILE__).'/import_hows.txt'));
foreach($hows as $line)
{
	$line = explode(':',$line);
	echo('updating customer '.$line[0].': '.base64_decode($line[1])."\n");
	if($line[1] != '')
	{
		$customer = core::model('customer_entity')->load($line[0]);
		if($customer && intval($customer['org_id']) > 0)
		{
			$org = core::model('organizations')->load($customer['org_id']);
			$org['product_how'] = base64_decode($line[1]);
			$org->save();
		}
		
	}
}




?>