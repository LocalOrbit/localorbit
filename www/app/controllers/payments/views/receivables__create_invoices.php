<?php
global $core;

$payables = core::model('v_payables')
	->get_buyer_grouped_payables()
	->filter('p.payable_id','in',explode(',',$core->data['payable_id']))
	->group('concat_ws(\'_\',p.from_org_id,p.to_org_id)');
	
?>
<div id="create_invoice_form">
	<table class="dt span12">
		<?=core_form::column_widths('21%','31%','12%','12%','12%','12%')?>
		<tr>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Invoice Date</th>
			<th class="dt">Payment Terms</th>
			<th class="dt">Due Date</th>
		</tr>
		<?
		$counter = 0;
		$p_group = '';
		$style = true; 
		foreach($payables as $payable)
		{ 
			
			$style = (!$style);
			$group_key = str_replace(',','-',$payable['payables']);
			$payable = payable_info($payable);
			$payable = payment_link_formatter($payable);
			$payable = payment_direction_formatter($payable);
			$payable = lfo_accordion($payable);
		
			#print_r($payable);
		?>
		<tr class="dt<?=$style?>">
			<td class="dt">
				From: <?=$payable['from_org_name']?><br />
				To: <?=$payable['to_org_name']?>
				<input type="hidden" name="invoicecreate_<?=$counter?>" value="<?=$group_key?>" />
				<input type="hidden" name="invoicecreate_<?=$group_key?>__to" value="<?=$payable['to_org_id']?>" />
				<input type="hidden" name="invoicecreate_<?=$group_key?>__from" value="<?=$payable['from_org_id']?>" />
			</td>
			<td class="dt">
				<?=$payable['description_html']?>
			</td>
			<td class="dt">
				<?=core_format::price($payable['receivable_total'])?>
				<input name="invoicecreate_<?=$group_key?>__amount" type="hidden" value="<?=$payable['receivable_total']?>" />
			<td class="dt"><?=core_format::date($payable['invoice_date'],'short')?></td>
			<td class="dt">
				<select name="invoicecreate_<?=$group_key?>__terms" style="width: 90px;" onchange="core.payments.updateDueDates('<?=$group_key?>',this.options[this.selectedIndex].value);">
					<option value="7"<?=(($payable['po_due_within_days'] == 7)?' selected="selected"':'')?>>Net 7</option>
					<option value="14"<?=(($payable['po_due_within_days'] == 14)?' selected="selected"':'')?>>Net 14</option>
					<option value="15"<?=(($payable['po_due_within_days'] == 15)?' selected="selected"':'')?>>Net 15</option>
					<option value="30"<?=(($payable['po_due_within_days'] == 30)?' selected="selected"':'')?>>Net 30</option>
					<option value="60"<?=(($payable['po_due_within_days'] == 60)?' selected="selected"':'')?>>Net 60</option>
					<option value="90"<?=(($payable['po_due_within_days'] == 90)?' selected="selected"':'')?>>Net 90</option>
				</select>
			</td>
			<td class="dt" id="due_date_<?=$group_key?>"><?=core_format::date($payable['due_date'],'short')?></td>
		</tr>
		
		<?
			$counter++;
		}
		?>
	</table>
	<input type="hidden" name="invoicecreate_groupcount" value="<?=$counter?>" />
	<br />&nbsp;<br />
	<div class="pull-right" id="invoice_create_buttonset">
		<input type="button" onclick="$('#receivables_create_area,#all_receivables').toggle();" value="cancel" class="btn btn-warning" />
		<input type="button" onclick="core.payments.createInvoices();" class="btn btn-primary" value="send invoices" />
	</div>
	<div class="buttonset" id="invoice_create_loading_progress" style="display: none;">
		<img src="<?=image('loading-progress')?>" />
		
	</div>
	<br /> &nbsp;<br />
</div>
<?
core::replace('receivables_create_area');
core::js("$('[rel=\"clickover\"]').clickover({ html : true, onShown : function () { core.changePopoverExpandButton(this, true); }, onHidden : function () { core.changePopoverExpandButton(this, false); } });");
core::js("$('#receivables_create_area,#all_receivables').toggle();");
?>