<?php
global $core;

# these are being passed in from the payments portal
$invoice   = $core->view[0];
$payables  = $core->view[1];
$domain_id = $core->view[2];
$due_date  = $core->view[3];

$values = array();

# figure out how to send this to
if($invoice['from_org_id'] == 1)
{
	$emails = 'mike@localorb.it';
}
else
{
	$emails = core_db::col('
		select group_concat(email) as emails
		from customer_entity
		where org_id='.$invoice['from_org_id'].'
		and is_active=1 and is_deleted=0
		group by org_id;','emails');
}

$domain = core::model('domains')->load($domain_id);
$values['hubname'] = $domain['name'];
$values['invoicenbr'] = 'LINV-'.$invoice['invoice_id'];
$values['duedate'] = $due_date;
$values['amount'] = core_format::price($invoice['amount']);
$values['pay_link'] = 'https://'.$domain['hostname'].'/app.php#!payments-demo';


$values['payables'] = '
<table class="dt">
	<col width="20%" />
	<col width="40%" />
	<col width="40%" />
	<tr>
		<th class="dt">Payable</th>
		<th class="dt">Description</th>
		<th class="dt">Amount</th>
	</tr>
';


$counter = false;
foreach($payables as $payable)
{
	#$values['payables'] .= print_r($payable->__data,true);
	$values['payables'] .= '
		<tr class="dt'.$counter.'">
			<td class="dt">P-'.$payable['payable_id'].'</td>
			<td class="dt">'.$payable['description'].'</td>
			<td class="dt">'.core_format::price($payable['amount']).'</td>
		</tr>';
	$counter = (!$counter);
}
$values['payables'] .='</table>';

$body  = $this->email_start();
$body .= $this->handle_source($core->i18n['email:payments:new_invoice_body'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email(
	$core->i18n['email:payments:new_invoice_subject'],$emails,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hubname']
);
?>