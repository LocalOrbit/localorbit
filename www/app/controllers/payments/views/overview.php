<?
global $core;

# prepare the data for the top metrics table.
$receivables_ov = core::model('v_payables')
	->collection()
	->filter('to_org_id','=',$core->session['org_id'])
	->filter('(amount - amount_paid)', '>', 0)
	->filter('invoiced','=','1');
$payables_ov    = core::model('v_payables')
	->collection()
	->filter('from_org_id','=',$core->session['org_id'])
	->filter('(amount - amount_paid)', '>', 0)
	->filter('invoiced','=','1');

$payables_ov    = $payables_ov->load()->to_array();
$receivables_ov = $receivables_ov->load()->to_array();

$intervals = array('Overdue' => 0, 'Today' => 1, 'Next 7 days' => 7, 'Next 30 days' => 30);

$receivables_intervals = array_fill_keys(array_values($intervals), 0);
$payables_intervals    = array_fill_keys(array_values($intervals), 0);

$previousIndex = 0;
foreach ($intervals as $val) 
{
	for($index = 0; $index < count($receivables_ov); $index++)
	{
		if ($receivables_ov[$index]['days_left'] <= $val && ($val == $previousIndex || ($val != $previousIndex && $receivables_ov[$index]['days_left'] > 0)))
		{
			$receivables_intervals[$val] += $receivables_ov[$index]['amount'] -$receivables_ov[$index]['amount_paid'];
		}
	}
	
	for($index = 0; $index < count($payables_ov); $index++)
	{
		if ($payables_ov[$index]['days_left'] <= $val && ($val == $previousIndex || ($val != $previousIndex && $payables_ov[$index]['days_left'] > 0)))
		{
			$payables_intervals[$val] += $payables_ov[$index]['amount'] -$payables_ov[$index]['amount_paid'];
		}
	}
	$previousIndex = $val;
}
?>

<div class="tabarea tab-pane active" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<div class="row row-top-margin-buffer">
		<? if(count($receivables_ov) > 0 || lo3::is_seller()){?>
		<div class="span4">
			<h2>Money In</h2>
			<?
			foreach ($intervals as $key => $value)
			{
				echo '<div class="overview-summary-list-item">
						<div class="overview-summary-list-item-label">' . $key . '</div>
						<div class="overview-summary-list-item-value">' . 
							(($receivables_intervals[$value] <= 0)?'<div class="error">':'').
							core_format::price($receivables_intervals[$value], false)
							.(($receivables_intervals[$value] <= 0)?'</div>':'') . 
						'</div></div>';
			}				
			?>
			<div class="span4 pagination-centered">
				<input type="button" class="btn btn-info" value="Enter Receipts" onclick="$('#paymentstabs #paymentstabs-s<?=(array_search('Receivables',$core->view[1]) + 2)?>').tab('show');" />
			</div>
		</div>
		<?}?>
		<? if((count($payables_ov) > 0 && lo3::is_seller()) || (!lo3::is_seller())){?>
		<div class="span4">
				<h2>Money Out</h2>
				<?
				foreach ($intervals as $key => $value)
				{
					echo '<div class="overview-summary-list-item">
					<div class="overview-summary-list-item-label">' . $key . '</div>
					<div class="overview-summary-list-item-value">' .
					(($payables_intervals[$value] <= 0)?'<div class="error">':'').
					core_format::price($payables_intervals[$value], false)
					.(($payables_intervals[$value] <= 0)?'</div>':'') .
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
