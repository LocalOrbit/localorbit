<?
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'username'=>$core->view[0],
	'unitsingle'=>$core->view[1],
	'unitplural'=>$core->view[2],
	'notes'=>$core->view[3],
	'prod_id'=>$core->view[4],
	'prod_name'=>$core->view[5],
);


$body  = $this->email_start();
$body .= $this->handle_source($core->session['i18n']['email:unit_request'],$values);
$body .= $this->footer();
$body .= $this->email_end();

if($core->config['stage'] == 'qa' || $core->config['stage'] == 'testing')
{
	$this->send_email('New Unit Request','localorbit.testing@gmail.com',$body);
}
else
{
	$this->send_email('New Unit Request','service@localorb.it',$body);
}

?>