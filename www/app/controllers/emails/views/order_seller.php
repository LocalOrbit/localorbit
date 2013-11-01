<?
$to_email = $core->view[0];
$values = array(
	'fullname'=>$core->view[1],
	'order_nbr'=>$core->view[2],
	'items'=>$core->view[3],
	'payment_type'=>(($values['payment_type'] == 'purchaseorder')?'Purchase Order':'Credit Card'),
	'payment_confirm_code'=>$core->view[5],
	'domain_id'=>$core->view[6],
	'hostname'=>$core->view[7],
	'hubname'=>$core->view[8],
	'logo'=>'<img src="http://'.$core->view[7].image('logo-email',$core->view[6]).'" />',
	'org_id'=>$core->view[9],
	'buyer_name'=>$core->session['org_name']
);

#core::log('email values: '.print_r($values,true));

//get order_id for use in email
$order_nbr = explode("-", $values['order_nbr']);
$values['lo_foid'] = intval($order_nbr[3]);


$body  = $this->email_start();


# we need to generate the html for the items table in the email
$item_html = '	
	<table class="dt">
		
';

$counter = false;
$cur_seller = '';
$is_first = true;

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

foreach($items as $item)
{
	if($cur_deliv_time != $item['delivery_start_time'])
	{
		if($cur_deliv_time != 0)
			$item_html .= '</table><br />';
		
		$cur_deliv_time = $item['delivery_start_time'];
		
		$item_html .= '<b>Items for delivery between '.core_format::date($item['delivery_start_time']).' '.core_format::date($item['delivery_end_time']).' '.$core->session['tz_name'].'</b>
		<table width="100%">
			<col width="40%" />
			<col width="20%" />
			<col width="20%" />
			<col width="20%" />
		';
		$item_html .= '
			<tr>
				<th class="dt">Item</th>
				<th class="dt">Quantity</th>
				<th class="dt">Unit Price</th>
				<th class="dt">Subtotal</th>
			</tr>
		';
	}

	$item_html .= '
		<tr class="dt'.$counter.'">
			<td class="dt">'.$item['product_name'].'</td>
			<td class="dt">'.$item['qty_ordered'].' '.$item['unit_plural'].'</td>
			<td class="dt">'.core_format::price($item['unit_price']).'</td>
			<td class="dt">'.core_format::price($item['row_total']).'</td>
		</tr>
	';
	$counter = (!$counter);
}

$item_html .= '</table>';

$values['items'] = $item_html;
$body .= $this->handle_source($core->session['i18n']['email:order_seller'],$values);

$body .= $this->footer();
$body .= $this->email_end();

$this->send_email(
	'You have a new order!',
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hubname']
);
?>