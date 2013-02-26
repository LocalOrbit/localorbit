<?
$to_email = $core->view[0];
$values = array(
	'domain_id'=>$core->view[1],
);
core::log('tryign to send email from domain '.$values['domain_id']);
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
core::log('domain name is '.$values['hub_name']);


$body  = $this->email_start();
$body .= $this->handle_source($core->session['i18n']['email:org_activated_verified'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email(
	'Hooray! You\'re All Set',
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']);
?>