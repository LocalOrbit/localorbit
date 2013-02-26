<?php
$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'company'=>$core->view[1],
	'fullname'=>$core->view[2],
	'email'=>$core->view[3],
	'activate'=>$core->view[4],
	'user_type'=>$core->view[5],
	'domain_id'=>$core->view[6]
);
core::log('tryign to send email from domain '.$values['domain_id']);
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
$values['hubname'] = $values['hub_name'];
core::log('domain name is '.$values['hub_name']);	

$body  = $this->email_start();
$body .= $this->handle_source($core->session['i18n']['email:reg_mm_notification'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('hooray, a new user!',$to_email,$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']
);
?>