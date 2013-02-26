<?
$to_email = $core->view[0];
$values = array(
	'new_email'=>$core->view[1],
	'first_name'=>$core->view[2],
	'domain_id'=>$core->view[3],
);

core::log('tryign to send email from domain '.$values['domain_id']);
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
core::log('domain name is '.$values['hub_name']);


$body  = $this->email_start();
$body .= $this->handle_source($core->session['i18n']['email:email_change'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('E-mail change confirmation',$to_email,$body,
	array(),
	$core->config['mailer']['From'],
	$values['hubname']);
?>