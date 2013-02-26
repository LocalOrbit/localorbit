<?
# the config array contains all the options used by the send_campaign function, which is defined
# in reminder_library.php
global $config;
$config = array(
	'list_name'=>'Wholesale Delivery Reminder',
	'subject'=>'wahoo your order is on the way',
	'template_name'=>'Wholesale Delivery Reminder',
	'days_offset'=>0,
	'seller_perspective'=>false,
	'delivery_type'=>'hub',
);

include('reminder_library.php');
send_campaign($config);
?>