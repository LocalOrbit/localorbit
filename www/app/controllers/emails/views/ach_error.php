<?php
global $core;

$subject  = $core->view[0];
$body = $core->view[1];
$body = str_replace("\n",'<br />',$body);
$body = str_replace("\t",'&nbsp;&nbsp;&nbsp;',$body);

echo("called \n"); 
$body  = $this->email_start(). $body . $this->email_end();

$this->send_email(
	$subject,
	$core->config['ach']['error_email'],
	$body,
	array(),
	$core->config['mailer']['From'],
	'Local Orbit'
);
?>