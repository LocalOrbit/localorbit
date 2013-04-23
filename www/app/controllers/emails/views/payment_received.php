<?php
global $core;

# these are being passed in 
$new_payment = $core->view[0];
$trace_nbr = $core->view[1];
$invoices = $core->view[2];
$to_org = core::model('organizations')->load($new_payment['to_org_id']);

$values = array();
$values['hubname'] = $to_org['name'];
$values['amount'] = $new_payment['amount'];
$values['date_received'] = core_format::date(time() + (7 * 86400),'short');
$values['invoice_ids'] = explode(',',$invoices['invoice_id']);
//$values['trace_nbr'] = $trace_nbr;



$emails = core_db::col('
	SELECT group_concat(email) AS emails
	FROM customer_entity
	WHERE org_id='.$new_payment['to_org_id'].'
		AND is_active=1 AND is_deleted=0
	GROUP BY org_id;','emails');
$emails = "jvavul@gmail.com";




core::log('payment_received ' . print_r($values));

echo $values['hubname'] . "<br>";
echo $emails . "<br>";
echo $values['amount'] . "<br>";
echo $values['trace_nbr'] . "<br>";
echo $values['invoice_ids'] . "<br>";



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


// paid via ACH
if($new_payment['payment_method_id']  == 3) {
	$body  = $this->email_start();
	$body .= $this->handle_source($core->i18n['email:payments:payment_received_body_ach'],$values);
	$body .= $this->footer();
	$body .= $this->email_end();
	
	$this->send_email(
		$core->i18n['email:payments:payment_received_subject_ach'],$emails,
		$body,
		array(),
		$core->config['mailer']['From'],
		$values['hubname']
	);
	
} else {
	$body  = $this->email_start();
	$body .= $this->handle_source($core->i18n['email:payments:payment_received_body_other'],$values);
	$body .= $this->footer();
	$body .= $this->email_end();
	
	$this->send_email(
			$core->i18n['email:payments:payment_received_subject_other'],$emails,
			$body,
			array(),
			$core->config['mailer']['From'],
			$values['hubname']
	);
}

die();
?>