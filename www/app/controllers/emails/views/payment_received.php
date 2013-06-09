<?php
global $core;


# these are being passed in 
$received_from_org_id = $core->view[0];
$to_org_id = $core->view[1];
$amount = $core->view[2];
$invoices = $core->view[3];
$date_received = core_format::date(time(),'short');

 
$to_org = core::model('organizations')->load($to_org_id);
$from_org = core::model('organizations')->load($received_from_org_id);



$values = array();
$values['paid_to'] = $to_org['name'];
$values['received_from'] = $from_org['name'];
$values['amount'] = core_format::price($amount);
$values['date_received'] = core_format::date(time(),'short');
$values['invoice_ids'] = explode(',',$invoices['invoice_id']);



core::log('payment_received ' . print_r($values, true));
//echo print_r($values, true);



/* $values['payables'] = '
<table class="dt">
	<col width="20%" />
	<col width="20%" />
	<col width="20%" />
	<col width="20%" />
	<col width="20%" />
	<tr>
		<th class="dt">Reference</th>
		<th class="dt">Description</th>
		<th class="dt">Date Received</th>
		<th class="dt">Amount</th>
	</tr>
';


$counter = false;
foreach($invoices as $invoice)
{
	$values['payables'] .= '
		<tr class="dt'.$counter.'">
			<td class="dt">'.$invoice['description'].'</td>
			<td class="dt">'.$invoice['to_org_name'].'</td>
			<td class="dt">'.core_format::date(time(),'long-wrapped').'</td>
			<td class="dt">'.core_format::price($invoice['amount_due']).'</td>
		</tr>';
	$counter = (!$counter);
}
$values['payables'] .='</table>'; */


// made payment
$emails = core_db::col('
	SELECT group_concat(email) AS emails
	FROM customer_entity
	WHERE org_id='.$from_org['org_id'].'
		AND is_active=1 AND is_deleted=0
	GROUP BY org_id;','emails');

$body  = $this->email_start();
$body .= $this->handle_source($core->i18n['email:payments:payment_made_body'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email(
	$core->i18n['email:payments:payment_made_subject'],
	$emails,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['received_from']
);



// received payment
if($core->config['stage'] == 'production')
{
	$emails = core_db::col('
		SELECT group_concat(email) AS emails
		FROM customer_entity
		WHERE org_id='.$to_org['org_id'].'
			AND is_active=1 AND is_deleted=0
		GROUP BY org_id;','emails');
}
else
{
	$emails = 'localorbit.testing@gmail.com';
}
//$emails = "jvavul@gmail.com";

$body  = $this->email_start();
$body .= $this->handle_source($core->i18n['email:payments:payment_received_body'],$values);
$body .= $this->footer();
$body .= $this->email_end();
#echo($body);

$this->send_email(
		$core->i18n['email:payments:payment_received_subject'],
		$emails,
		# emails
		$body,
		array(),
		$core->config['mailer']['From'],
		$values['paid_to']
);


?>