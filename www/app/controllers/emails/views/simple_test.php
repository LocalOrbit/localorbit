<?
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'testname'=>$core->view[0],
);

$body  = $this->email_start();
$body .= $this->handle_source('<h1>{testname}</h1>
<p><strong>This</strong> is a test. It is only a test.</p>',$values);
$body .= $this->email_end();

$this->send_email('simple test of styling','localorbit.testing@gmail.com',$body);
?>