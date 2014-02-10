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
$body .= $this->handle_source('<h1>You\'re growing!</h1>
      <p>A new organization has registered for your market!</p>

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

      <p>Here is how to activate this new organization:</p>

      <table class="lo_steps">
        <tr>
          <td><span class="lo_step">1</span></td>
          <td>
            <a href="{dashboard}" class="lo_button">Log in to Your Market</a>
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">2</span></td>
          <td>
            Click on Market Admin
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">3</span></td>
          <td>
            Click on Organizations<br>
            <span class="lo_hint">The New Organization should be located near the top of the list.</span>
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">4</span></td>
          <td>
            Click the Activate button.
          </td>
        </tr>
      </table>',$values);
$body .= $this->email_end();

$market_manager = core::model('domains')->get_domain_info($values['domain_id']);

$this->send_email('Hooray!',$to_email,$body,
	array(),
	$market_manager['email'],
	$market_manager['name']
);
?>