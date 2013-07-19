<?php
# this contains all the configuration for lo3. Be careful and ask Mike Thorn!!!

global $core;

# base service configuration
$core->config['mailer'] = array(
	'SMTPAuth'=>true,
	'SMTPSecure'=>'ssl',
	'Host'=>'smtp.gmail.com',
	'Port'=>465,
	'Username'=>'service@localorb.it',
	'Password'=>'gr0wnl0cally',
	'From'=>'service@localorb.it',
	'FromName'=>'Localorb.it',
);

$core->config['db'] = array(
	'type'=>'mysql',
	'hostname'=>'localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com',
	'username'=>'localorb_www',
	'password'=>'l0cal1sdab3st',
	'database'=>'localorb_www_production',
);


$core->config['ach'] = array(
	'SSS'=>'RPP',
	'AccountSet'=>'01',
	'LocID'=>'2764',
	'Company'=>'LOCALORBITLLC001',
	'CompanyKey'=>'QSFTHJJP3JCMFBXGQEDBZWKDBPPHFM2',
	'url'=>'https://securesoap.achworks.com/dnet/achws.asmx?WSDL',
	'error_email'=>'localorbit.testing@gmail.com',
);

$core->config['mailchimp'] = array(
	'keys'=>array(
		'production'=>'5a19fb44d348ceed1180340c973bbe80',
		'qa'=>'6444d6106c928ca0fab894d1c99df724-us2',
		'testing'=>'8e86025dbed395f77cd43249f6329f04-us2',
		'dev'=>'8e86025dbed395f77cd43249f6329f04-us2',
	),
	'lists'=>array(
		'Last Order Reminder','Weekly Fresh Sheet','Low Inventory Reminder','Order Pickup Reminder',
		'Wholesale Delivery Reminder','Order Delivery Reminder','Delivery Confirmation Reminder',
		'Order Pickup Reminder','Newsletter','Inventory Update Reminder','Local Orbit News',
		'Local Orbit Registration','Confirm Delivery Reminder',
	),
	'fields'=>array(
		'EMAIL'=>array('EMAIL','Email Address','email'),
		'FNAME'=>array('FNAME','First Name','text'),
		'LNAME'=>array('LNAME','Last Name','text'),
		'ACC_TYPE'=>array('ACC_TYPE','Account Type','number'),
		'ACC_TYPE_N'=>array('ACC_TYPE_N','Account Type Name','text'),
		'WEBSITE_ID'=>array('WEBSITE_ID','Website ID','number'),
		'WEBSITE_N'=>array('WEBSITE_N','Website Name','text'),
		'ZIP'=>array('ZIP','Zip Code','text'),
		'L_ORD_DATE'=>array('L_ORD_DATE','Last Order Date','date'),
		'DO_EMAIL'=>array('DO_EMAIL','DO_EMAIL','number'),
		'MM_FNAME'=>array('MM_FNAME','MM First Name','text'),
		'MM_LNAME'=>array('MM_LNAME','MM Last Name','text'),
		'HUB_STREET'=>array('HUB_STREET','Hub Street','text'),
		'HUB_CITYST'=>array('HUB_CITYST','Hub City and State','text'),
		'LOW_PRODS'=>array('LOW_PRODS','Low Product','text'),
		'DAYS_ORDER'=>array('DAYS_ORDER','Days since order','text'),
		'O_DEV_DATE'=>array('O_DEV_DATE','Pickup or Deliv Date','text'),
		'O_DEV_TIME'=>array('O_DEV_TIME','Pickup or Deliv Time','text'),
		'TOMORROW'=>array('TOMORROW','Tomorrows date','text'),
		'DOMAIN_ID'=>array('DOMAIN_ID','Domain ID','number'),
		'LOGIN_LINK'=>array('LOGIN_LINK','Login Link','text'),
		'LOGO'=>array('LOGO','Logo','text'),
	),
);


$core->config['registration'] = array(
	'activate_hash_secret'=>'l0cal1sb3tt3r',
);

$core->config['sec_pin']  = '1318';
$core->config['app_page'] = 'app.php';
$core->config['stage'] = 'production';
$core->config['hostname_prefix'] = '';  # this is used by the domain loader (/app/controllers/domain/domain.php)
$core->config['session_domain'] = '.localorb.it';
$core->config['session_name'] = 'localorbit';
$core->config['session_time'] = 28800;
$core->config['registration_secret_key'] = 'hey localorbit why are you so cool';
$core->config['notification_email'] = 'service@localorb.it';
$core->config['cookie_auth_command'] = 'auth/cookie_auth';


# use this hostname for default settings:
$core->config['default_hostname'] = 'annarbor-mi.localorb.it';

# write emails sent via phpmailer to db
#$core->config['hooks']['phpmailer_onsend'] = 'phpmailer_onsend';

# change some logging stuff
$core->paths['logs'] = '/tmp';

# setup varous commands
$core->config['navstate_command'] = 'navstate/ensure';
$core->config['command-lists']['pre-request']['domain/init'] = true;
$core->config['command-lists']['pre-request']['cart/init'] = true;
$core->config['command-lists']['session-init']['dictionaries/load_into_session'] = true;

# lo3-specific libs
$core->config['includes'][] = '/../../libraries/misc.php';
$core->config['includes'][] = '/../../libraries/security.php';
$core->config['includes'][] = '/../../libraries/formatter.php';

# misc dat formatting
$core->config['formats']['dates']['long'] = 'M j, Y g:i a';
$core->config['formats']['dates']['long-wrapped'] = 'M j, Y<\b\r />g:i a';
$core->config['formats']['dates']['short'] = 'M j, Y';
$core->config['formats']['dates']['jsshort'] = 'M j, y';
$core->config['formats']['dates']['time'] = 'g:i a';
$core->config['formats']['dates']['short-weekday'] = 'l, M j, Y';
$core->config['formats']['dates']['shorter-weekday'] = 'l, M j';
$core->config['formats']['dates']['shortest-weekday'] = 'D, M jS';

# some messages/config options used
$core->config['error_ui_msg']= 'It appears there is a small bug in the system. We apologize for interrupting your experience. Our development team will fix this soon.';
$core->config['datatables']['render_filter_expander'] = false;
$core->response['replace']['full_width'] = '&nbsp;<br />';

# default paypal settings
$core->config['payments']['paypal'] = array(
	'password'=>'YM446S5GC36WTZAA',
	'username'=>'ank_api1.localorb.it',
	'signature'=>'AbTutOCFkGFRNQBuUmG2lDGzKJGqAfafePhnjstmH97h5rUU1x1rYPRJ',
	'url'=>'https://api-3t.paypal.com/nvp',
	'error_email'=>'localorbit.testing@gmail.com',
);

$core->config['title_prefix'] = 'Local Orbit - ';

#======================== STAGE SPECIFIC SETTINGS ============================#

if($_SERVER['HTTP_HOST'] == 'qa.localorb.it' || strpos(__FILE__,'/qa/') > 0)
{
	$core->config['stage'] = 'qa';
	$core->config['default_hostname'] = 'annarbor-mi.localorb.it';
	$core->config['session_domain']   = '.localorb.it';
	$core->config['session_name']    .= 'qa';
	$core->config['db']['database']   = 'localorb_www_qa';
	$core->config['db']['hostname'] = 'localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com';
	
	$core->config['payments']['paypal'] = array(
		'password'=>'1331137290',
		'username'=>'julie_1331137249_biz_api1.localorb.it',
		'signature'=>'An5ns1Kso7MWUdW4ErQKJJJ4qi4-A5NnmzyvwNlDn9R23U3X0TvhQXok',
		'url'=>'https://api-3t.sandbox.paypal.com/nvp',
	);
	$core->config['hostname_prefix']  = $core->config['stage'];

}

if($_SERVER['HTTP_HOST'] == 'current.localorb.it' || strpos(__FILE__,'/current/') > 0)
{
	$core->config['stage'] = 'current';
	$core->config['default_hostname'] = 'annarbor-mi.localorb.it';
	$core->config['session_domain']   = '.localorb.it';
	$core->config['session_name']    .= 'current';
	$core->config['db']['database']   = 'localorb_www_current';
	$core->config['db']['hostname']   = 'localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com';	

	$core->config['payments']['paypal'] = array(
		'password'=>'1331137290',
		'username'=>'julie_1331137249_biz_api1.localorb.it',
		'signature'=>'An5ns1Kso7MWUdW4ErQKJJJ4qi4-A5NnmzyvwNlDn9R23U3X0TvhQXok',
		'url'=>'https://api-3t.sandbox.paypal.com/nvp',
	);
	$core->config['hostname_prefix']  = $core->config['stage'];
}


if($_SERVER['HTTP_HOST'] == 'testing.localorb.it' || strpos(__FILE__,'/testing/') > 0)
{
	$core->config['stage'] = 'testing';
	$core->config['default_hostname'] = 'annarbor-mi.localorb.it';
	$core->config['session_domain']   = '.localorb.it';
	$core->config['session_name']    .= 'testing';
	$core->config['db']['database']   = 'localorb_www_testing';
	$core->config['db']['hostname'] = 'localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com';

	$core->config['payments']['paypal'] = array(
		'password'=>'1331153423',
		'username'=>'test_1331153383_biz_api1.localorb.it',
		'signature'=>'AFYqE2DluOQPGVmQcxxRIFQ289lfAeR95YuTxuE7wJSX68MHHvPRQIr.',
		'url'=>'https://api-3t.sandbox.paypal.com/nvp',
	);
	$core->config['hostname_prefix']  = $core->config['stage'];
}

if($_SERVER['HTTP_HOST'] == 'newui.localorb.it' || strpos(__FILE__,'/newui/') > 0)
{
	$core->config['stage'] = 'newui';
	$core->config['default_hostname'] = 'annarbor-mi.localorb.it';
	$core->config['session_domain']   = '.localorb.it';
	$core->config['session_name']    .= 'newui';
	$core->config['db']['database']   = 'localorb_www_newui';
	$core->config['db']['hostname']   = 'localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com';	

	$core->config['payments']['paypal'] = array(
		'password'=>'1331153423',
		'username'=>'test_1331153383_biz_api1.localorb.it',
		'signature'=>'AFYqE2DluOQPGVmQcxxRIFQ289lfAeR95YuTxuE7wJSX68MHHvPRQIr.',
		'url'=>'https://api-3t.sandbox.paypal.com/nvp',
	);
	$core->config['hostname_prefix']  = 'newui';
	$core->config['db']['hostname'] = '127.0.0.1';
}




if($_SERVER['HTTP_HOST'] == 'dev.localorb.it' || strpos(__FILE__,'/dev/') > 0 || strpos(__FILE__,'/projects/') > 0 ||  strpos(__FILE__,'/Clients/') > 0)
{
	$core->config['stage'] = 'dev';
	$core->config['default_hostname'] = 'annarbor-mi.localorb.it';
	$core->config['session_domain']   = '.localorb.it';
	$core->config['session_name']    .= 'dev';
	$core->config['db']['database']   = 'localorb_www_dev';
	$core->config['db']['hostname']   = '127.0.0.1';
	$core->config['db']['username']   = 'localorb_www';
	$core->config['db']['password']   = 'localorb_www_dev';
	$core->config['payments']['paypal'] = array(
		'password'=>'1331153423',
		'username'=>'test_1331153383_biz_api1.localorb.it',
		'signature'=>'AFYqE2DluOQPGVmQcxxRIFQ289lfAeR95YuTxuE7wJSX68MHHvPRQIr.',
		'url'=>'https://api-3t.sandbox.paypal.com/nvp',
	);
	$core->config['hostname_prefix']  = $core->config['stage'];
}

# this is the new definition for mike's local trunk checkout
if(strpos(__FILE__,'/trunk/')) {
	$core->config['stage'] = 'dev';
	$core->config['default_hostname'] = 'dev.localorb.it';
	$core->config['session_domain']   = '.localorb.it';
	$core->config['session_name']    .= 'dev';
	
	$core->config['db']['database']   = 'localorb_www_dev';
	$core->config['db']['hostname']   = 'localhost';
	$core->config['db']['username']   = 'localorb_www';
	$core->config['db']['password']   = 'localorb_www_dev';
	
	$core->config['hostname_prefix']  = $core->config['stage'];
	
	$core->config['payments']['paypal'] = array(
			'password'=>'1331153423',
			'username'=>'test_1331153383_biz_api1.localorb.it',
			'signature'=>'AFYqE2DluOQPGVmQcxxRIFQ289lfAeR95YuTxuE7wJSX68MHHvPRQIr.',
			'url'=>'https://api-3t.sandbox.paypal.com/nvp',
	);
}

# this is a branch, and therefore likely the 'current' production branch
if(strpos(__FILE__,'/branches/')) {
	$core->config['stage'] = 'devcurrent';
	$core->config['default_hostname'] = 'devcurrent.localorb.it';
	$core->config['session_domain']   = '.localorb.it';
	$core->config['session_name']    .= 'devcurrent';
	
	$core->config['db']['database']   = 'localorb_www_devcurrent';
	$core->config['db']['hostname']   = 'localhost';
	$core->config['db']['username']   = 'localorb_www';
	$core->config['db']['password']   = 'localorb_www_dev';
	
	$core->config['hostname_prefix']  = $core->config['stage'];
	
	$core->config['payments']['paypal'] = array(
			'password'=>'1331153423',
			'username'=>'test_1331153383_biz_api1.localorb.it',
			'signature'=>'AFYqE2DluOQPGVmQcxxRIFQ289lfAeR95YuTxuE7wJSX68MHHvPRQIr.',
			'url'=>'https://api-3t.sandbox.paypal.com/nvp',
	);
}

if($_SERVER['SERVER_ENV'] == 'chad') {
	$core->config['stage'] = 'dev';
	$core->config['default_hostname'] = 'dev.localorb.it';
	$core->config['session_domain']   = '.localorb.it';
	$core->config['session_name']    .= 'dev';
	
	$core->config['db']['database']   = 'localorb_www_dev';
	$core->config['db']['hostname']   = 'localhost';
	$core->config['db']['username']   = 'localorb_www';
	$core->config['db']['password']   = 'localorb_www_dev';
	
	$core->paths['logs'] = 'c:/xampp/apache/logs';
	$core->config['hostname_prefix']  = $core->config['stage'];
	
	$core->config['payments']['paypal'] = array(
			'password'=>'1331153423',
			'username'=>'test_1331153383_biz_api1.localorb.it',
			'signature'=>'AFYqE2DluOQPGVmQcxxRIFQ289lfAeR95YuTxuE7wJSX68MHHvPRQIr.',
			'url'=>'https://api-3t.sandbox.paypal.com/nvp',
	);
}

if($_SERVER['SERVER_ENV'] == 'jvavul') {
	$core->config['stage'] = 'dev';
	$core->config['default_hostname'] = 'dev.localorb.it';
	$core->config['session_domain']   = '.localorb.it';
	$core->config['session_name']    .= 'dev';
	$core->config['db']['username']   = 'root';
	$core->config['db']['database']   = 'localorb_www_dev';
	$core->config['db']['password']   = 'a1b2c3';
	$core->config['db']['hostname']   = '127.0.0.1';
	
	$core->paths['logs'] = 'd:/tmp';
	$core->config['payments']['paypal'] = array(
		'password'=>'1331153423',
		'username'=>'test_1331153383_biz_api1.localorb.it',
		'signature'=>'AFYqE2DluOQPGVmQcxxRIFQ289lfAeR95YuTxuE7wJSX68MHHvPRQIr.',
		'url'=>'https://api-3t.sandbox.paypal.com/nvp',
	);
	$core->config['hostname_prefix']  = $core->config['stage'];
}

#echo('<pre>');
#print_r($core->config);
#exit();
# finalize stage-specific settings
$core->config['log_prefix']       = $core->config['stage'].'-';
$core->config['mailchimp']['key'] = $core->config['mailchimp']['keys'][$core->config['stage']];

?>
