<?
global $core;

$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'first_name'=>$core->view[1],
	'link'=>$core->view[2],
	'domain_id'=>$core->view[3],
);
$auto_activate = core_db::col('SELECT autoactivate_organization FROM domains where domain_id='.$values['domain_id'],'autoactivate_organization');
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
core::log('domain name is '.$values['hub_name']);

$body  = $this->email_start($values['domain_id']);
if ($auto_activate) {
  $subject = "Almost there!";
  $body .= $this->handle_source('<h1>You are almost there!</h1>
      <p>
        Dear {first_name},
      </p>
      <p>
        Than you for registering with {hub_name}, your online ordering service
        for local food.
      </p>
      <p>
        To activate your account, please click on the following link:
      </p>

      <div class="lo_call_to_action">
        <a href="{link}" class="lo_button lo_button_large">Log in to Your Account</a>
        <p>
          If clicking the button doesn\'t work, right click it and copy the link.<br>
          After you\'ve copied it, paste it into a new browser window.
        </p>
      </div>',$values);
} else {
  $subject = "Please click the link below";
  $body .= $this->handle_source('<h1>Attention needed, please verify your account.</h1>
      <p>
        Thank you for registering with {hub_name}. To shop or sell online, you 
        must verify your email address. Once the {hub_name} Market Manager
        activates your account, you\'ll be all set!
      </p>

      <div class="lo_call_to_action">
        <a href="{link}" class="lo_button lo_button_large">Verify Email Address</a>
        <p>
          If clicking the button doesn\'t work, right click it and copy the link.<br>
          After you\'ve copied it, paste it into a new browser window.
        </p>
      </div>

      <p>Thank you for supporting {hub_name} and your local food producers!</p>',$values);
}
$body .= $this->footer();
$body .= $this->email_end();

$market_manager = core::model('domains')->get_domain_info($values['domain_id']);

core::log('final subject is '.$subject);
$this->send_email(
	$subject,
	$to_email,
	$body,
	array(),
	$market_manager['email'],
	$market_manager['name']
);
?>
