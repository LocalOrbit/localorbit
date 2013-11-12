
<?php
core::load_library('core_phpmailer');
try {
	echo "1";
	$emails = core::model('sent_emails')->collection()->filter('seml_id',19069)->load();
	foreach($emails as $email)
	{
		echo('trying to send email '.$email['seml_id'].' to '.$email['to_address']."\n");
		$email->send();
	}
	echo "2";


} catch (Exception $e) {
	echo($e->getMessage().'<pre>'.$e->getTraceAsString().'</pre>');
}

?>