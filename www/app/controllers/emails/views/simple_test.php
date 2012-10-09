<?
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'testname'=>$core->view[0],
);

$body  = $this->email_start();
$body .= $this->handle_source($core->session['i18n']['email:simple_test'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('simple test of styling','localorbit.testing@gmail.com',$body);
?>