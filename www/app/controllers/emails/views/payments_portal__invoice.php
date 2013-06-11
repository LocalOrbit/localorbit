<?php
global $core;

# these are being passed in from the payments portal
$from_org_id = $core->view[0];
$amount    = $core->view[1];
$invoice   = $core->view[2];
$payables  = $core->view[3];
$domain_id = $core->view[4];
$due_date  = $core->view[5];

$values = array();

# figure out how to send this to
if($from_org_id == 1)
{
	$emails = 'mike@localorb.it';
}
else
{
	$emails = core_db::col('
		select group_concat(email) as emails
		from customer_entity
		where org_id='.$from_org_id.'
		and is_active=1 and is_deleted=0
		group by org_id;','emails');
}

$domain = core::model('domains')->load($domain_id);
$values['hubname'] = $domain['name'];
$values['invoicenbr'] = 'LINV-'.str_pad($invoice,6,'0',STR_PAD_LEFT);
$values['duedate'] = $due_date;
$values['amount'] = core_format::price($amount);
$values['pay_link'] = 'https://'.$domain['hostname'].'/app.php#!payments-home--link_payables-yes';


$values['payables'] = '
<table class="dt">
	<col width="30%" />
	<col width="40%" />
	<col width="30%" />
	<tr>
		<th class="dt">Ref #</th>
		<th class="dt">Description</th>
		<th class="dt">Order Date</th>
	</tr>
';


$counter = false;
foreach($payables as $payable)
{
	core::log(print_r($payable,true));
	#$values['payables'] .= 
	#$payable = core::model('v_payables')->load($payable);
	if($payable['payable_type'] == 'buyer order')
	{
		#$info = explode('|',$payable['payable_info']);
		$values['payables'] .= '
			<tr class="dt'.$counter.'">
				<td class="dt">'.$paayble['lo3_order_nbr'].'</td>
				<td class="dt">'.$payable['product_name'].' ('.$payable['qty_ordered'].')</td>
				<td class="dt">'.core_format::date($payable['order_date'],'short').'</td>
			</tr>';
	}
	if($payable['payable_type'] == 'delivery fee')
	{
		$info = explode('|',$payable['payable_info']);
		$values['payables'] .= '
			<tr class="dt'.$counter.'">
				<td class="dt">'.$info[0].'</td>
				<td class="dt">Delivery Fee</td>
				<td class="dt"></td>
				<td class="dt">'.core_format::price($payable['amount']).'</td>
			</tr>';
	}
	
	$counter = (!$counter);
}
$values['payables'] .='</table>';



$body  = $this->email_start();
$body .= $this->handle_source($core->i18n['email:payments:new_invoice_body'],$values);
$body .= $this->footer();
$body .= $this->email_end();

#core::log($body);
#core::log($emails);

$this->send_email(
	$core->i18n['email:payments:new_invoice_subject'],$emails,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hubname']
);
?>