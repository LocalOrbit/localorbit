
<?php
core::load_library('core_phpmailer');
try {
	echo core_format::date('11/18/2013 17:05:16','long');
	echo "<br>";
	echo date('Y-m-d H:i:s',time());

	echo "<br>";
	echo date("I");
	
	
	$core->session['datatables']['enter_receipts__filter__lo_order.org_id'] = 111111;
	echo $core->session['datatables']['enter_receipts__filter__lo_order.org_id'];
	
	
	
	core_datatable::log_filters();
	
	
	/* echo "1";
	$emails = core::model('sent_emails')->collection()->filter('seml_id',19069)->load();
	foreach($emails as $email)
	{
		echo('trying to send email '.$email['seml_id'].' to '.$email['to_address']."\n");
		$email->send();
	}
	echo "2"; */


} catch (Exception $e) {
	echo($e->getMessage().'<pre>'.$e->getTraceAsString().'</pre>');
}

?>