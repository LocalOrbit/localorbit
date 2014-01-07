<?
$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->view[1],
	'first_name'=>$core->view[2],
	'delivery_address'=>$core->view[3],
	'domain_id'=>$core->view[4],
	'login_link'=>"http://".$core->view[1]."/login.php",
);
core::log('tryign to send email from domain '.$values['domain_id']);
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
core::log('domain name is '.$values['hub_name']);

$body  = $this->email_start($values['domain_id']);
$body .= $this->handle_source('<h1>Welcome to {hub_name}. You are all set.</h1>
      <p>
        Thank you for verifying your email address with {hub_name}!
      </p>

      <p>
        The {hub_name} Market Manager has activated your account, so you\'re all
        set to log in and shop the fresh offerings of your amazing local food
        producers.
      </p>

      <div class="lo_call_to_action">
        <a href="{login_link}" class="lo_button lo_button_large">Log in to Your Account</a>
        <p>
          If clicking the button doesn\'t work, right click it and copy the link.<br>
          After you\'ve copied it, paste it into a new browser window.
        </p>
      </div>

      <p>Thank you for supporting your local food economy!</p>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email(
	'welcome to '.$values['hub_name'],
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']
);
?>