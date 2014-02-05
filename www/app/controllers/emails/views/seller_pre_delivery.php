<?
$to_email = $core->view[0];
$values = array(
	'first_name'=>$core->view[1],
	'last_name'=>$core->view[2],
	'domain_id'=>$core->view[3],
	'hub_name'=>$core->view[4],
	'mm_phone'=>$core->view[5],
);
core::log('trying to send email from domain '.$values['domain_id']);

$body  = $this->email_start($values['domain_id']);
$body .= $this->handle_source('<h1>Time to Pick, Pack &amp; Deliver.</h1>

      <p>Dear {first_name},</p>
      <p>You have orders to fill! It\'s almost time to deliver.</p>
      <p>Here\'s what to do next:</p>

      <table class="lo_steps">
        <tr>
          <td><span class="lo_step">1</span></td>
          <td>
            Log in to Your Market
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">2</span></td>
          <td>
          From your Dashboard, click on the Sales Information Tab.
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">3</span></td>
          <td>
            Then, click on Upcoming De-
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">4</span></td>
          <td>
          Print your Pick List and Packing Slips, taking note of the delivery 
          day, location and time.
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">5</span></td>
          <td>
            Deliver your orders accordingly, making sure to include the packing
            slip.
          </td>
        </tr>
        <tr>
          <td><span class="lo_step">6</span></td>
          <td>
            After you deliver your orders, please mark each of them
            "delivered." Remember, you will be paid only for items that are
            marked delivered.
            <span class="lo_hint">
              *Note, in some markets, the Market Manager is responsible for
              marking items delivered.
            </span>

          </td>
        </tr>
        <tr>
          <td><span class="lo_step">7</span></td>
          <td>
            Be sure to update your inventory for the coming week so buyers know
            what you have available.
          </td>
        </tr>
      </table>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$market_manager = core::model('domains')->get_domain_info($values['domain_id']);

$this->send_email('You have deliveries this week',
	$to_email,
	$body,
	array(),
	$market_manager['email'],
	$market_manager['name']
);
?>