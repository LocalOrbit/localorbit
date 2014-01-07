<?php
$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'company'=>$core->view[1],
	'fullname'=>$core->view[2],
	'email'=>$core->view[3],
	'activate'=>$core->view[4],
	'user_type'=>$core->view[5],
	'domain_id'=>$core->view[6],
	'dashboard'=>$core->view[7]
);
core::log('tryign to send email from domain '.$values['domain_id']);
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
core::log('domain name is '.$values['hub_name']);	

$body  = $this->email_start($values['domain_id']);
$body .= $this->handle_source('<h1>Hooray!</h1>

<p>A new organization has registered for your market! Their contact info is below:

<dl>
  <dt>Company:</dt>
  <dd>{company}</dd>
</dl>

<dl>
  <dt>Name:</dt>
  <dd>{fullname}</dd>
</dl>

<dl>
  <dt>Email:</dt>
  <dd>{email}</dd>
</dl>

<p>To activate this organization:</p>

<ul>
  <li>log in to your market</li>
  <li>click on Market Admin</li>
  <li>click on Organizations - The new organization should be located near the top of the list.</li>
  <li>click the Activate button</li>
</ul>

<p>Thank you!</p>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('Hooray!',$to_email,$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']
);
?>