<?
$to_email = $core->view[0];
$values = array(
	'domain_id'=>$core->view[1],
	'user'=>$core->view[2],
	'domain_hostname'=>$core->view[3],
);

$values['user'] = $values['user']['entity_id'];

# get the activation link
$values['link'] = core::process_command(
	'registration/generate_verify_link',
	true,
	$values['domain_hostname'],
	$values['user']
);

$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');


$body  = $this->email_start();
$body .= $this->handle_source($core->session['i18n']['email:org_activated_not_verified'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('Please Verify Your Email Address',$to_email,$body,array(),
	$core->config['mailer']['From'],
	$values['hub_name']);
?>