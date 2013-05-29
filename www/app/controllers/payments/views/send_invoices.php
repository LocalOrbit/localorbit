<?php
$rendered_ids = 0;  # this is used to see if we need to query for invoices to rsent
$ids = explode(',',$core->data['checked_receivables']);
$now = time();
$receivables = core::model('v_payables')->get_invoice_payables($ids);

$has_sendables = false;
$has_resendables = false;

foreach($receivables as $receivable)
{
	if($receivable['invoiced'] == 0)
	{
		$has_sendables = true;
	}
	else
	{
		$has_resendables = true;
	}
}

$header = '
	<tr>
		<th class="dt">Organization</th>
		<th class="dt">Description</th>
		<th class="dt">Amount</th>
		<th class="dt">Invoice Date</th>
		<th class="dt">Payment Terms</th>
		<th class="dt">Due Date</th>
	</tr>
';

if($has_sendables)
{
	echo('<div id="sendable_payables"><h2>New Invoices</h2><table class="dt" width="100%">'.$header);
	foreach($receivables as $receivable)
	{
		if($receivable['invoiced'] == 0)
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
			<td><?=core_format::date($now + ($receivable['po_due_within_days'] * 86400),'short')?></td>
		</tr>
		<?php
		}
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

if($has_resendables)
{
	
	echo('<div id="resendable_payables"><h2>Re-send Invoices</h2><table class="dt" width="100%">'.$header);
	foreach($receivables as $receivable)
	{
		if($receivable['invoiced'] == 1)
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
			<td><?=core_format::date($now + ($receivable['po_due_within_days'] * 86400),'short')?></td>
		</tr>
		<?php
		}
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

echo('<input type="hidden" name="payables_to_send" value="'.implode(',',$ids).'" />');

core::replace('receivables_actions');
core::js("core.payments.resetInvoiceSending();");

?>