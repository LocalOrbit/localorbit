<?
$to_email = $core->view[0];
$values = array(
	'new_password'=>$core->view[1],
	'domain_id'=>$core->view[2],
);
core::log('tryign to send email from domain '.$values['domain_id']);
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
core::log('domain name is '.$values['hub_name']);

$body  = $this->email_start($values['domain_id']);
$body .= $this->handle_source('<h1>Your New Password</h1>
      <p>
        Hello, you recently requested that your password be reset.
      </p>
      <p>
        Your new password is: <strong>{new_password}</strong>
      </p>
      <p>
        It is important that your log in and change your password soon.
      </p>

      <div class="lo_call_to_action">
        <a href="{link}" class="lo_button lo_button_large">Log in to Your Account</a>
        <p>
          If clicking the button doesn\'t work, right click it and copy the link.<br>
          After you\'ve copied it, paste it into a new browser window.
        </p>
      </div>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('Your New Password',$to_email,$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']);
?>