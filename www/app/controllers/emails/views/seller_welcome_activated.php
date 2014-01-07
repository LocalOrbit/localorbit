<?
$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->view[1],
	'first_name'=>$core->view[2],
	'domain_id'=>$core->view[3],
	'login_link'=>"http://".$core->view[1]."/login.php",
);
core::log('tryign to send email from domain '.$values['domain_id']);
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
core::log('domain name is '.$values['hub_name']);


$body  = $this->email_start($values['domain_id']);
$body .= $this->handle_source('<h1>Welcome to Farm Fresh</h1>

      <p>
        Thank you for Verifying your email address with {hub_name}. It\'s time
        to get started selling! If you have questions, or need some help, feel
        free to reply to this email.
      </p>

      <table class="lo_steps">
        <tr>
          <td colspan="2" class="lo_call_to_action">
            <a href="{login_link}" class="lo_button lo_button_large">Log in to Your Account</a>
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">1</span></td>
          <td>
            Update your details
            <span class="lo_hint">
              Log in to check your profile and make sure your contact details
              are correct. Upload a farm photo, add your farm story, or change
              your password.
            </span>
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">2</span></td>
          <td>
            Add Your Products
            <span class="lo_hint">
              On your Dashboard page, click "Add a new product" to begin adding
              products to your inventory. Although adding photos and production
              details for each product brings more sales. Buyers care!
            </span>
          </td>
        </tr>
      </table>

      <p>
        When you\'ve finished updating your farm details and adding your
        products, you\'re all set! Product additions and changes are visible to
        buyers almost instantly.
      </p>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email("Thank you! You're all set!",
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']
);
?>