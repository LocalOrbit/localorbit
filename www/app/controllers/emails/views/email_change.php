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


$body  = $this->email_start($values['domain_id']);
$body .= $this->handle_source('<h1>Account Email successfully changed.</h1>

      <p>
        This email is confirmation that you\'ve changed your email address in
        {hub_name}. If you made this change just ignore this email, but if you
        didn\'t, please call customer service at (734) 545-8100.
      </p>

      <p>Thank you! Have a great day.</p>',$values);
$body .= $this->email_end();

$market_manager = core::model('domains')->get_domain_info($values['domain_id']);

$this->send_email('E-mail change confirmation',$to_email,$body,
	array(),
	$market_manager['email'],
	$market_manager['name']
);
?>