<?
$to_email = $core->view[0];
$values = array(
	'domain_id'=>$core->view[1],
);
core::log('tryign to send email from domain '.$values['domain_id']);
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
core::log('domain name is '.$values['hub_name']);


$body  = $this->email_start($values['domain_id']);
$body .= $this->handle_source('<h1>You\'re all set!</h1>

      <p>
        The {hub_name} Market Manager has activated your account and you are
        officially ready to shop the market. Log in to quickly and easily buy
        great food produced right near you.
      </p>

      <p>Thank you for supporting your local food producers.</p>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email(
	'Hooray! You\'re All Set',
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']);
?>