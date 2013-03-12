<?
global $core;

# prepare the data for the top metrics table.
$receivables_ov = core::model('v_invoices')
	->add_custom_field('DATEDIFF(due_date, NOW()) as days_since')
	->collection()->filter('amount_due', '>', 0);
$payables_ov    = core::model('v_invoices')
	->add_custom_field('DATEDIFF(due_date, NOW()) as days_since')
	->collection()->filter('amount_due', '>', 0);
	
if(lo3::is_admin())
{
	# if we're an admin, we don't have to filter this at all.
}
else if (lo3::is_market())
{
	# if we're a market manager, we only want payables that apply to our market
	$receivables_ov->filter('from_domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	$payables_ov->filter('from_domain_id','in',$core->session['domains_by_orgtype_id'][2]);
}
else
{
	# otherwise, we want payables only for our organization.
	$receivables_ov->filter('to_org_id','=',$core->session['org_id']);
	$payables_ov->filter('from_org_id','=',$core->session['org_id']);
}

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
		if ($receivables_ov[$index]['days_since'] <= $val && ($val == $previousIndex || ($val != $previousIndex && $receivables_ov[$index]['days_since'] > 0)))
		{
			$receivables_intervals[$val] += $receivables_ov[$index]['amount_due'];
		}
	}
	
	for($index = 0; $index < count($payables_ov); $index++)
	{
		if ($payables_ov[$index]['days_since'] <= $val && ($val == $previousIndex || ($val != $previousIndex && $payables_ov[$index]['days_since'] > 0)))
		{
			$payables_intervals[$val] += $payables_ov[$index]['amount_due'];
		}
	}
	$previousIndex = $val;
}
?>
<div class="tabarea tab-pane active" id="paymentstabs-a<?=$core->view[0]?>">
	<div class="row row-top-margin-buffer">
		<? if(count($receivables_ov) > 0 ){?>
		<div class="span4">
			<h2>Receivables</h2>
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
				<input type="button" class="btn btn-info" value="Enter Receipts" onclick="$('#paymentstabs #paymentstabs-s<?=(array_search('Receivables',$core->view[1]) + 1)?>').tab('show');" />
			</div>
		</div>
		<?}?>
		<div class="span4">
				<h2>Payables</h2>
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
				<input type="button" class="btn btn-info " value="Make Payments" onclick="$('#paymentstabs #paymentstabs-s<?=(array_search('Payables',$core->view[1]) + 1)?>').tab('show');" />
			</div>
		
		</div>
	</div>
</div>
