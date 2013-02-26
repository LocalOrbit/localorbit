<?
# the config array contains all the options used by the send_campaign function, which is defined
# in reminder_library.php
try
{
	global $config;
	$config = array(
		'list_name'=>'Delivery Confirmation Reminder',
		'subject'=>'Prepare for your deliveries',
		'template_name'=>'Order Delivery & Inventory Update Reminder',
		'days_offset'=>1,
		'seller_perspective'=>true,
		'delivery_type'=>'hub',
	);

	include('reminder_library.php');
	send_campaign($config);
}
catch(Exception $e)
{
	# add some code to notify mike
}

?>