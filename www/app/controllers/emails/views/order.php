<?
$to_email = $core->view[0];
$items = $core->view[3];
$values = array(
	'fullname'=>$core->view[1],
	'order_nbr'=>$core->view[2],
	'payment_confirm_code'=>$core->view[5],
	'domain_id'=>$core->view[6],
	'hostname'=>$core->view[7],
	'hub_name'=>$core->view[8],
	'logo'=>'<img src="http://'.$core->view[7].image('logo-email',$core->view[6]).'" />',
	'buyer_name'=>$core->session['org_name']
);

if ($core->view[4] == 'purchaseorder') {
  $values['payment_type'] = 'Purchase Order';
} else if ($core->view[4] == 'ach') {
  $values['payment_type'] = 'ACH';
} else {
  $values['payment_type'] = 'Credit Card';
}

$body  = $this->email_start($values['domain_id']);

# we need to generate the html for the items table in the email
$item_html = '';
$cur_seller = '';
$total = 0.0;
foreach($items as $item)
{
  if($cur_seller != $item['seller_name'])
  {
    $cur_seller = $item['seller_name'];
    $item_html .= '
        <tr>
          <th colspan="4" class="lo_vendor">'.$item['seller_name'].'</th>
        </tr>';
  }
  $item_html .= '
    <tr>
      <td>'.$item['product_name'].'</td>
      <td>'.$item['qty_ordered'].' '.$item['unit_plural'].'</td>
      <td class="lo_currency">'.core_format::price($item['unit_price']).'</td>
      <td class="lo_currency">'.core_format::price($item['row_total']).'</td>
    </tr>
  ';
  $total += floatval($item['row_total']);
}

$body .= $this->handle_source('<h1>Your order has been placed.</h1>
      <p>
        <span class="lo_order_number">Order Number: {order_nbr}</span>
      </p>
      <p>
        Thank you for your order through {hub_name}!<br>
        You can check the status of your order by following the link above and
        logging in to your account.
      </p>

    <table class="lo_order">
      <thead>
        <tr>
          <th>Product</th>
          <th>Quantity</th>
          <th class="lo_currency">Unit Price</th>
          <th class="lo_currency">Subtotal</th>
        </tr>
      </thead>
      '.$item_html.'
      <tfoot>
        <tr>
          <th colspan="3">Total</th>
          <td class="lo_currency">'.core_format::price("$total").'</td>
        </tr>
      </tfoot>

    </table>

    <h2>Method of Payment</h2>
    <dl>
      <dt>{payment_type}:</dt>
      <dd>{payment_confirm_code}</dd>
    </dl>


    <p>Thank your for supporting {hub_name}!</p>
      ',$values);

$body .= $this->footer();
$body .= $this->email_end();

$this->send_email(
	'Thank you for your order!',
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']
);


$mm_emails = array();
$mm_emails = core::model('domains')->get_mm_emails($values['domain_id']);
if(count($mm_emails) > 0)
{
  # send the MM notification
  $body  = $this->email_start($values['domain_id']);
  $body .= $this->handle_source('<h1>You\'ve received a new order.</h1>

      <table>
        <tr>
          <td>
            <span class="lo_order_number">Order Number: {order_nbr}</span>
          </td>
          <td class="lo_placed_by">
            Order Placed By: <strong>{buyer_name}</strong>
          </td>
        </tr>
      </table>

      <table class="lo_order">
        <thead>
          <tr>
            <th>Product</th>
            <th>Quantity</th>
            <th class="lo_currency">Unit Price</th>
            <th class="lo_currency">Subtotal</th>
          </tr>
        </thead>
        '.$item_html.'
        <tfoot>
          <tr>
            <th colspan="3">Total</th>
            <td class="lo_currency">'.core_format::price("$total").'</td>
          </tr>
        </tfoot>

      </table>
      ',$values);
  $body .= $this->footer();
  $body .= $this->email_end();

  $this->send_email(
    'New order on '.$values['hub_name'],
    implode(',',$mm_emails),
    $body,
    array(),
    $core->config['mailer']['From'],
    $values['hub_name']
  );
}
?>