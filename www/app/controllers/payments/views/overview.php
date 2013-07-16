<?
global $core;

$tab_id = $core->view[0];
$money_out_count = $core->view[1];

# prepare the data for the top metrics table.
$all = new core_collection("
	select vpo.* from v_payables_overview vpo 
	where amount > amount_paid
	and (vpo.from_org_id=".$core->session['org_id']." or vpo.to_org_id=".$core->session['org_id'].");
");

$intervals = array('Overdue' => 0, 'Today' => 1, 'Next 7 days' => 7, 'Next 30 days' => 30,'Purchase Orders'=>31);
$data['payables']    = array_fill_keys(array_values($intervals), 0);
$data['receivables'] = array_fill_keys(array_values($intervals), 0);
$total = array('payables'=>0,'receivables'=>0);

foreach($all as $item)
{
	$type = (($item['from_org_id'] == $core->session['org_id'])?'payables':'receivables');
	$total[$type]++;
	$amount_due = floatval(($item['amount'] - $item['amount_paid']));
	#print_r($item);
	
	if(!is_numeric($item['invoice_id']))
	{
		$data[$type][31] += $amount_due;
	}
	else
	{
		if($item['days_left'] < 0)
		{
			$data[$type][0] += $amount_due;
		}
		else if($item['days_left'] == 0)
		{
			$data[$type][1] += $amount_due;
		}
		else if($item['days_left'] > 0 and $item['days_left'] < 7)
		{
			$data[$type][7] += $amount_due;
		}
		else
		{
			$data[$type][30] += $amount_due;
		}
	}
}

$payables = $data['payables'];
$receivables = $data['receivables'];

?>

<div class="tabarea tab-pane active" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<div class="row row-top-margin-buffer">
		<? if($total['receivables'] > 0 || lo3::is_seller()){?>
		<div class="span4">
			<h2>Money In</h2>
			<?
			foreach ($intervals as $key => $value)
			{
				echo('<div class="overview-summary-list-item">');
				echo('<div class="overview-summary-list-item-label'.(($key=='Overdue')?' text-error':'').'">' . $key);
				if ($key == 'Purchase Orders'){	echo(' <i class="helpslug icon-question-sign" rel="popover" data-title="'.$core->i18n('payments:overview:po_note_title').'" data-content="'.$core->i18n('payments:overview:po_note_content').'" data-original-title=""></i>'); }
		
				echo('</div>
						<div class="overview-summary-list-item-value'.(($key=='Overdue')?' text-error':'').'">' . 
							(($receivables[$value] <= 0)?'<div class="error">':'').
							core_format::price($receivables[$value], false)
							.(($receivables[$value] <= 0)?'</div>':'') . 
						'</div></div>');
			}				
			?>
			
			<?php 
				if(!lo3::is_seller()) {
			?>
				<div class="span4 pagination-centered">
					<input type="button" class="btn btn-info" value="Enter Receipts" onclick="$('#paymentstabs #paymentstabs-s<?=(array_search('Receivables',$core->view[1]) + 2)?>').tab('show');" />
				</div>
			<?php 
				}
			?>
		</div>
		<?}?>
		<? if($money_out_count > 0 || (!lo3::is_seller())){?>
		<div class="span4">
			<? if($total['receivables'] > 0 || lo3::is_seller()){?>
			<h2>Money Out</h2>
			<?}?>
			<?
			foreach ($intervals as $key => $value)
			{
				echo('<div class="overview-summary-list-item">');
				echo('<div class="overview-summary-list-item-label'.(($key=='Overdue')?' text-error':'').'">' . $key);
				
				if ($key == 'Purchase Orders'){	echo(' <i class="helpslug icon-question-sign" rel="popover" data-title="'.$core->i18n('payments:overview:po_note_title').'" data-content="'.$core->i18n('payments:overview:po_note_content').'" data-original-title=""></i>'); }
		
				echo('</div>');
				echo('<div class="overview-summary-list-item-value'.(($key=='Overdue')?' text-error':'').'">' .
				(($payables[$value] <= 0)?'<div class="error">':'').
				core_format::price($payables[$value], false)
				.(($payables[$value] <= 0)?'</div>':'') .
				'</div></div>');
				
			}
			?>
			
			<?php 
				if(!lo3::is_fully_managed()) {
			?>
				<div class="span4 pagination-centered">
					<input type="button" class="btn btn-info " value="Make Payments" onclick="$('#paymentstabs #paymentstabs-s<?=(array_search('Review Orders &amp; Make Payments',$core->view[1]) + 3)?>').tab('show');" />
				</div>
			<?php 
				}
			?>		
		</div>
		<?}?>
		<div class="span4">
			<h2>&nbsp;</h2>
			<? echo get_inline_message("overview", 200);?>
		</div>
	</div>
</div>
