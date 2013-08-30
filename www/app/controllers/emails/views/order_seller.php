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
foreach($values['items'] as $item)
{
	if($item['seller_org_id'] == $values['org_id'])
	{
		if($cur_seller != $item['seller_name'])
		{
			$cur_seller = $item['seller_name'];
			$item_html .= '
				<tr>
					<th class="dt">Item</th>
			';
			
			if($is_first)
			{
				$item_html .= '
					<th class="dt">Quantity</th>
					<th class="dt">Unit Price</th>
					<th class="dt">Subtotal</th>
				';
			}
			else
			{
				$item_html .= '
					<th class="dt" colspan="3">&nbsp;</th>
				';
			}
		
			$item_html .= '</tr>';
			
			$is_first = false;
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