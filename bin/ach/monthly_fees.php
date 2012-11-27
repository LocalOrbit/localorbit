#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();


$domains = core::model('domains')->collection();
foreach($domains as $domain)
{
	echo('checking '.$domain['name']."\n");
	echo("\tservice fee is:      ".$domain['service_fee']."\n");
	echo("\tservice schedule is: ".$domain['sfs_id']."\n");
	echo("\tlast paid is:        ".$domain['service_fee_last_paid']."\n");
}

exit("done\n");

?>