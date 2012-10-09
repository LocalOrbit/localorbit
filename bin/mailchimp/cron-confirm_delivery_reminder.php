<?
# the config array contains all the options used by the send_campaign function, which is defined
# in reminder_library.php
global $config;
$config = array(
	'list_name'=>'Delivery Confirmation Reminder',
	'subject'=>'don\'t forget',
	'template_name'=>'Confirm Delivery Reminder',
	'days_offset'=>0,
	'seller_perspective'=>true,
	'delivery_type'=>'hub',
);

include('reminder_library.php');
send_campaign($config);
?>