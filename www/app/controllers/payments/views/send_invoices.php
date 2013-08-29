<?php
$rendered_ids = 0;  # this is used to see if we need to query for invoices to rsent
$ids = explode(',',$core->data['checked_receivables']);
$now = time();
$receivables = core::model('v_payables')->get_invoice_payables($ids);

$sendables    = array();
$resendables  = array();
$nonsendables = array();

foreach($receivables as $receivable)
{
	if(floatval($receivable['amount']) == 0 || $receivable['payable_type'] != 'buyer order')
	{
		$nonsendables[] = $receivable;
	}
	if($receivable['invoiced'] == 0 && floatval($receivable['amount']) > 0)
	{
		$sendables[] = $receivable;
	}
	else if($receivable['invoiced'] == 1 && floatval($receivable['amount']) > 0)
	{
		$resendables[] = $receivable;
	}
}

if(count($sendables) == 0 && count($resendables) == 0)
{
	core_ui::notification('None of receivables you checked can be invoiced. This may be because they have been paid, or because they are not for buyer orders.');
	core::deinit();
}

$header = '
	<col width="25%" />
	<col width="21%" />
	<col width="11%" />
	<col width="11%" />
	<col width="20%" />
	<col width="11%" />
	<tr>
		<th class="dt">Organization</th>
		<th class="dt">Description</th>
		<th class="dt">Amount</th>
		<th class="dt">Invoice Date</th>
		<th class="dt">Payment Terms</th>
		<th class="dt">Due Date</th>
	</tr>
';

if(count($sendables) > 0)
{
	echo('<div id="sendable_payables"><h2>Purchase Orders</h2><table class="dt" width="100%">'.$header);
	foreach($sendables as $receivable)
	{

		?>
		<tr>
			<td>
				From: <?=$receivable['from_org_name']?><br />
				To: <?=$receivable['to_org_name']?>
			</td>
			<td>
				<?=$receivable['ref_nbr_html']?>
			</td>
			<td>
				<?=core_format::price($receivable['amount'])?>
			</td>
			<td><?=core_format::date($now,'short')?></td>
			<td>
				<select name="invgroup_<?=$receivable['group_key']?>__terms" style="width: 90px;" onchange="core.payments.updateDueDates('<?=$receivable['group_key']?>',this.options[this.selectedIndex].value);">
					<option value="7"<?=(($receivable['po_due_within_days'] == 7)?' selected="selected"':'')?>>Net 7</option>
					<option value="14"<?=(($receivable['po_due_within_days'] == 14)?' selected="selected"':'')?>>Net 14</option>
					<option value="15"<?=(($receivable['po_due_within_days'] == 15)?' selected="selected"':'')?>>Net 15</option>
					<option value="30"<?=(($receivable['po_due_within_days'] == 30)?' selected="selected"':'')?>>Net 30</option>
					<option value="60"<?=(($receivable['po_due_within_days'] == 60)?' selected="selected"':'')?>>Net 60</option>
					<option value="90"<?=(($receivable['po_due_within_days'] == 90)?' selected="selected"':'')?>>Net 90</option>
				</select>
			</td>
			<td id="due_date_<?=$receivable['group_key']?>"><?=core_format::date($now + ($receivable['po_due_within_days'] * 86400),'short')?></td>
		</tr>
		<?php
	}
	?>
		</table>
		<div class="pull-right">
			<input type="button" onclick="core.payments.resetInvoiceSending();" class="btn btn-warning" value="Cancel" />
			<input type="button" onclick="core.payments.doSendInvoices();" class="btn btn-primary" value="Send Invoices" />
			<input type="hidden" name="has_sendables" value="1" />
		</div>
	</div>
	<?php
}
else
{
	echo('<input type="hidden" name="has_sendables" value="0" />');
}

if(count($resendables) > 0)
{	
	echo('<div id="resendable_payables"><br />&nbsp;<br /><h2>Receivables</h2><table class="dt" width="100%">'.$header);
	foreach($resendables as $receivable)
	{
		#print_r($receivable);
		?>
		<tr>
			<td>
				From: <?=$receivable['from_org_name']?><br />
				To: <?=$receivable['to_org_name']?>
			</td>
			<td>
				<?=$receivable['ref_nbr_html']?>
			</td>
			<td>
				<?=core_format::price($receivable['amount'])?>
			</td>
			<td><?=core_format::date($now,'short')?></td>
			<td>
				<?=$receivable['po_terms']?> days from first invoice
			</td>
			<td><?=core_format::date($now + ($receivable['po_due_within_days'] * 86400),'short')?></td>
		</tr>
		<?php
		
	}
	?>
		</table>
		<div class="pull-right">
			<input type="button" onclick="core.payments.resetInvoiceSending();" class="btn btn-warning" value="Cancel" />
			<input type="button" onclick="core.payments.doResendInvoices();" class="btn btn-primary" value="Re-send Invoices" />
			<input type="hidden" name="has_resendables" value="1" />
		</div>
	</div>
	<?php
}
else
{
	echo('<input type="hidden" name="has_resendables" value="0" />');
}

if(count($nonsendables) > 0)
{
	echo('<div id="paid_payables"><br />&nbsp;<br /><h2>Receipts</h2><table class="dt" width="100%">'.$header);
	foreach($nonsendables as $receivable)
	{

		?>
		<tr>
			<td>
				From: <?=$receivable['from_org_name']?><br />
				To: <?=$receivable['to_org_name']?>
			</td>
			<td>
				<?=$receivable['ref_nbr_html']?>
			</td>
			<td>
				<?=core_format::price($receivable['amount'])?>
			</td>
			<td colspan="3">
				
			</td>
		</tr>
		<?php
		
	}
	?>
		</table>
	</div>
	<?php
}


echo('<input type="hidden" name="payables_to_send" value="'.implode(',',$ids).'" />');

core::replace('receivables_actions');
core::js("core.payments.resetInvoiceSending();");

?>