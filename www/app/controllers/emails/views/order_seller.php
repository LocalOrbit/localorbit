<?
$to_email = $core->view[0];
$values = array(
	'fullname'=>$core->view[1],
	'order_nbr'=>$core->view[2],
	'payment_type'=>(($values['payment_type'] == 'purchaseorder')?'Purchase Order':'Credit Card'),
	'payment_confirm_code'=>$core->view[5],
	'domain_id'=>$core->view[6],
	'hostname'=>$core->view[7],
	'hub_name'=>$core->view[8],
	'logo'=>'<img src="http://'.$core->view[7].image('logo-email',$core->view[6]).'" />',
	'org_id'=>$core->view[9],
	'buyer_name'=>$core->session['org_name']
);

//get order_id for use in email
$order_nbr = explode("-", $values['order_nbr']);
$values['lo_foid'] = intval($order_nbr[3]);

$body = $this->email_start($values['domain_id']);

# we need to generate the html for the items table in the email
$item_html = '';

$sql = '
  select loi.qty_ordered,loi.product_name,loi.qty_ordered,
  loi.unit_plural,loi.unit_price,
  loi.row_total,lod.delivery_start_time,lod.delivery_end_time
  from lo_order_line_item loi
  inner join lo_order_deliveries lod on (lod.lodeliv_id=loi.lodeliv_id)
  where loi.lo_foid='.$values['lo_foid'].'
  
  order by lod.delivery_start_time
';
$items = new core_collection($sql);
$cur_deliv_time = 0;
$total = 0.0;

foreach($items as $item) {
  if($cur_deliv_time != $item['delivery_start_time']) {
    $cur_deliv_time = $item['delivery_start_time'];
    $item_html .= '
        <tr>
          <th colspan="4" class="lo_vendor">Items for delivery between '.core_format::date($item['delivery_start_time']).' and '.core_format::date($item['delivery_end_time']).' '.$core->session['tz_name'].'</th>
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

$body .= $this->handle_source('<h1>You have a new order!</h1>
    <p>
      <span class="lo_order_number">Order Number: {lo_foid}</span>
    </p>
    <p>
      An order was just placed by <strong>{buyer_name}</strong>.
      Your can check the details of this and all of your current orders by
      following the link above and logging in to your {hub_name} account.
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

  <p>Thank you for supporting {hub_name}!</p>',$values);

$body .= $this->footer();
$body .= $this->email_end();

$this->send_email(
	'You have a new order!',
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']
);
?>