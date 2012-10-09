<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();
core::load_library('core_phpmailer');

# get the list of emails to send
$emails = core::model('sent_emails')->collection()->filter('emailstatus_id',1)->load();

# toggle the status of all of these to pending
$set_status_sql = '
	update sent_emails 
	set emailstatus_id=(
		select emailstatus_id
		from email_statuses
		where name=\'Pending\'
	) 
	where emailstatus_id=1';
core_db::query($set_status_sql);

echo("\nstarting send\n");


# determine which emails are in this queue run, and send them
foreach($emails as $email)
{
	echo('trying to send email '.$email['seml_id'].' to '.$email['to_address']."\n");
	$email->send();
}

exit("complete\n");
?>