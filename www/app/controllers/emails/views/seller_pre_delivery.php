<?
$to_email = $core->view[0];
$values = array(
	'first_name'=>$core->view[1],
	'last_name'=>$core->view[2],
	'domain_id'=>$core->view[3],
	'hub_name'=>$core->view[4],
	'mm_phone'=>$core->view[5],
	
);
core::log('trying to send email from domain '.$values['domain_id']);


$body  = $this->email_start();
$body .= $this->handle_source($core->session['i18n']['email:deliveries:seller_pre_delivery'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email($core->session['i18n']['email:deliveries:seller_pre_delivery:subject'],
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']
);
?>