<?
$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'link'=>$core->view[1],
	'hubname'=>$core->view[2]
);

$body  = $this->email_start();
$body .= $this->handle_source($core->session['i18n']['email:reg_invite'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('Join '.$values['hubname'].' today!',$to_email,$body);
?>