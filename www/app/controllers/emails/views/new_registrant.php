<?
global $core;

$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'first_name'=>$core->view[1],
	'link'=>$core->view[2],
	'domain_id'=>$core->view[3],
);
$auto_activate = core_db::col('SELECT autoactivate_organization FROM domains where domain_id='.$values['domain_id'],'autoactivate_organization');
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
$values['hubname'] = $values['hub_name'];
core::log('domain name is '.$values['hub_name']);

$body  = $this->email_start();
$body .= $this->handle_source(($auto_activate?$core->session['i18n']['email:new_registrant_auto_activate']:$core->session['i18n']['email:new_registrant']),$values);
$body .= $this->footer();
$body .= $this->email_end();

core::log('final subject is '.'Verify your email address with '.$values['hub_name']);
$this->send_email(
	'Verify your email address with '.$values['hub_name'],
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']
);
?>
