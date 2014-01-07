<?
$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->config['domain']['hostname'],
	'link'=>$core->view[1],
	'hub_name'=>$core->view[2]
);

$body  = $this->email_start();
$body .= $this->handle_source('<h1>Join {hub_name} today!</h1>
      <p>
        Hello! You have been invited to join {hub_name} by a member of your organization.
      </p>

      <div class="lo_call_to_action">
        <a href="{link}" class="lo_button lo_button_large">Join {hub_name}</a>
        <p>
          If clicking the button doesn\'t work, right click it and copy the link.<br>
          After you\'ve copied it, paste it into a new browser window.
        </p>
      </div>

      <p>Thank you for supporting Farm Fresh and your local food producers!</p>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email('Join '.$values['hub_name'].' today!',$to_email,$body);
?>