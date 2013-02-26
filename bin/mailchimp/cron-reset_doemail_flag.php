#!/usr/bin/php
<?php
# load the core libs
define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_get_clean();

# startup mailchimp
echo("starting mc sync\n");
core::load_library('mailchimp');
$mc = new core_mailchimp();

# get the list of all customers
echo("getting customer list\n");
$custs = core::model('customer_entity')->collection();
$values = array();
foreach($custs as $cust)
{
	$values[] = array(
		'EMAIL'=>$cust['email'],
		'DO_EMAIL'=>0,
	);
}
echo("customer list complete\n");
	
# loop through the lists and update their data
for ($i = 0; $i < count($core->config['mailchimp']['lists']); $i++)
{
	$id = $mc->get_list_id($core->config['mailchimp']['lists'][$i]);
	echo('update list '.$id.': '.$core->config['mailchimp']['lists'][$i]."\n");
	$result = $mc->api->listBatchSubscribe(
		$id,
		$values,
		false,
		true,
		false
	);
	
	# print out any errors if there are any, and then exit
	if(count($result['errors']) > 0)
	{
		echo("FAILURE: \n");
		print_r($result['errors']);
		exit();
	}
}
echo("COMPLETE\n");
?>