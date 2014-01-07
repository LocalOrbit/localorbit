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


$body  = $this->email_start($values['domain_id']);
$body .= $this->handle_source('<h1>Attention needed, please verify your account.</h1>
      <p>
        The {hub_name} Market Manager has activated your new account, but you
        still must verify your email address before you can use the system.
        Please click the link below to verify and you\'ll be all set.
      </p>

      <div class="lo_call_to_action">
        <a href="{link}" class="lo_button lo_button_large">Verify Your Account</a>
        <p>
          If clicking the button doesn\'t work, right click it and copy the link.<br>
          After you\'ve copied it, paste it into a new browser window.
        </p>
      </div>

      <p>Thank you for supporting {hub_name} and your local food producers!</p>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('Please Verify Your Email Address',$to_email,$body,array(),
	$core->config['mailer']['From'],
	$values['hub_name']);
?>