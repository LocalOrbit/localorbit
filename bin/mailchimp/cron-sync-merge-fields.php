#!/usr/bin/php
<?php
# load the core libs
define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();

# startup mailchimp
echo("starting mc sync\n");
core::load_library('mailchimp');
$mc = new core_mailchimp();

# set some basic vars, disable output buffering
ob_get_clean();
$now = time();
$tomorrow = date('F jS',($now + 86400));

# get the data
$customers = core::model('customer_entity')
	->add_custom_field(
		'(select max(UNIX_TIMESTAMP(order_date)) from lo_order where lo_order.buyer_mage_customer_id=customer_entity.entity_id) as last_order'
	)
	->autojoin(
		'left',
		'organizations',
		'(customer_entity.org_id=organizations.org_id)',
		array('organizations.name as ORG_NAME','allow_sell')
	)
	->autojoin(
		'left',
		'organizations_to_domains',
		'(organizations.org_id=organizations_to_domains.org_id and organizations_to_domains.is_home=1)',
		array()
	)
	->autojoin(
		'left',
		'domains',
		'(organizations_to_domains.domain_id=domains.domain_id)',
		array('domains.domain_id','secondary_contact_name','secondary_contact_email','secondary_contact_phone','domains.name as website_name','hostname')
	)
	->autojoin(
		'left',
		'addresses',
		'(addresses.org_id=organizations.org_id and addresses.default_billing=1)',
		array('address','city','postal_code')
	)->autojoin(
		'left',
		'directory_country_region dcr',
		'(addresses.region_id=dcr.region_id)',
		array('code as state')
	)->collection();
	
$updates = array();


echo("building update data\n");
$core->paths['web'] = '';
foreach($customers as $cust)
{
	# do some data manipulation
	if(is_numeric($cust['last_order']))
		$days = floor( ( $now - $cust['last_order']) / 86400);
	else
		$days = 0;
	
	# build the main data array
	$values = array(
		'EMAIL'=>$cust['email'],
		'EMAIL_TYPE'=>'html',
		'FNAME'=>$cust['first_name'],
		'LNAME'=>$cust['last_name'],
		'ORG_NAME'=>$cust['org_name'],
		'DOMAIN_ID'=>$cust['domain_id'],
		'HUB_NAME'=>$cust['domain_name'],
		'DO_EMAIL'=>0,
		'ACC_TYPE'=>(($cust['allow_sell'] == 1)?1:2),
		'ACC_TYPE_N'=>(($cust['allow_sell'] == 1)?'seller':'buyer'),
		'MM_FNAME'=>$cust['secondary_contact_name'],
		'HUB_STREET'=>$cust['address'],
		'HUB_CITYST'=>$cust['city'].', '.$cust['state'],
		'ZIP'=>$cust['postal_code'],
		'LOW_PRODS'=>'',
		'DAYS_ORDER'=>$days ,
		'TOMORROW'=>$tomorrow,
		'WEBSITE_N'=>$cust['website_name'],
		'LOGIN_LINK'=>'http://'.$cust['hostname'].'/#!auth-form',
		'LOGO'=>'http://www.localorb.it/app'.image('logo-email',$cust['domain_id']).'',
		#'LOGO'=>'',
	);
	#
	print_r($values);

	$custs[] = $values;
}
#exit();
echo("update data complete\n");

# loop through the lists and update their data
for ($i = 0; $i < count($core->config['mailchimp']['lists']); $i++)
{
	$id = $mc->get_list_id($core->config['mailchimp']['lists'][$i]);
	echo('update list '.$id.': '.$core->config['mailchimp']['lists'][$i]."\n");
	$result = $mc->api->listBatchSubscribe(
		$id,
		$custs,
		false,
		true,
		false
	);
	if ($mc->api->errorCode){
		echo "batch update failed failed!\n";
		echo "code:".$mc->api->errorCode."\n";
		echo "msg :".$mc->api->errorMessage."\n";
		exit();
	} 
	
	print_r($result);
	# print out any errors if there are any, and then exit
	if(count($result['errors']) > 0)
	{
		echo("FAILURE: \n");
		#print_r($result['errors']);
		#exit();
	}
	#exit();
}	
echo("COMPLETE\n");
	
?>