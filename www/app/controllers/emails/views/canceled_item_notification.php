<?
$to_email = $core->view[0];
$values = array(
	'lo3_order_nbr'=>$core->view[1],
	'order_link'=>$core->view[2],
	'product_name'=>$core->view[3],
	'hub_name'=>$core->view[4],
	'canceled_by'=>$core->view[5],
);

$body  = $this->email_start();
$body .= $this->handle_source('<h1>Item Cancelation</h1>
      <p>
        You have received this notification because an item ({product_name}) that was
        paid for via paypal has been canceled. This action occurred on order
        number <span class="lo_order_number">{lo3_order_nbr}</span>.
      </p>

      <div class="lo_call_to_action">
        <a href="{order_link}" class="lo_button lo_button_large">View This Order</a>
        <p>
          If clicking the button doesn\'t work, right click it and copy the link.<br>
          After you\'ve copied it, paste it into a new browser window.
        </p>
      </div>

      <p>This cancelation was performed at {hub_name} by {canceled_by}.</p>',$values);
$body .= $this->footer();
$body .= $this->email_end();

$market_manager = core::model('domains')->get_domain_info($values['domain_id']);

$this->send_email(
	'Item cancelation Notification',
	$to_email,
	$body,
	array(),
	$market_manager['email'],
	$market_manager['name']
);
?>