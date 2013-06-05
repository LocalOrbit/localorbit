<?
global $core;

# prepare the data for the top metrics table.
$all = new core_collection("
	select from_org_id,to_org_id,amount,amount_paid,days_left,invoice_id from v_payables 
	where payment_status <> 'paid'
	and payable_id in (select payable_id from payables where from_org_id=1 or to_org_id=1);
");


$intervals = array('Overdue' => 0, 'Today' => 1, 'Next 7 days' => 7, 'Next 30 days' => 30,'Purchase Orders'=>31);
$data['payables']    = array_fill_keys(array_values($intervals), 0);
$data['receivables'] = array_fill_keys(array_values($intervals), 0);

foreach($all as $item)
{
	$type = (($item['from_org_id'] == 1)?'payables':'receivables');
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
		<? if(count($receivables) > 0 || lo3::is_seller()){?>
		<div class="span4">
			<h2>Money In</h2>
			<?
			foreach ($intervals as $key => $value)
			{
				echo '<div class="overview-summary-list-item">
						<div class="overview-summary-list-item-label">' . $key . '</div>
						<div class="overview-summary-list-item-value">' . 
							(($receivables[$value] <= 0)?'<div class="error">':'').
							core_format::price($receivables[$value], false)
							.(($receivables[$value] <= 0)?'</div>':'') . 
						'</div></div>';
			}				
			?>
			<div class="span4 pagination-centered">
				<input type="button" class="btn btn-info" value="Enter Receipts" onclick="$('#paymentstabs #paymentstabs-s<?=(array_search('Receivables',$core->view[1]) + 2)?>').tab('show');" />
			</div>
		</div>
		<?}?>
		<? if((count($payables) > 0 && lo3::is_seller()) || (!lo3::is_seller())){?>
		<div class="span4">
				<h2>Money Out</h2>
				<?
				foreach ($intervals as $key => $value)
				{
					echo '<div class="overview-summary-list-item">
					<div class="overview-summary-list-item-label">' . $key . '</div>
					<div class="overview-summary-list-item-value">' .
					(($payables[$value] <= 0)?'<div class="error">':'').
					core_format::price($payables[$value], false)
					.(($payables[$value] <= 0)?'</div>':'') .
					'</div></div>';
					
				}
				?>
			<div class="span4 pagination-centered">
				<input type="button" class="btn btn-info " value="Make Payments" onclick="$('#paymentstabs #paymentstabs-s<?=(array_search('Review Orders &amp; Make Payments',$core->view[1]) + 2)?>').tab('show');" />
			</div>
		
		</div>
		<?}?>
		<div class="span4">
			<h2>&nbsp;</h2>
			<? echo get_inline_message("overview", 200);?>
		</div>
	</div>
</div>
