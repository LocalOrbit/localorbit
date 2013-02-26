<?
global $core;

# prepare the data for the top metrics table.
$receivables_ov = core::model('v_invoices')
	->add_custom_field('DATEDIFF(due_date, NOW()) as days_since')
	->collection()->filter('amount_due', '>', 0);
$payables_ov    = core::model('v_invoices')
	->add_custom_field('DATEDIFF(due_date, NOW()) as days_since')
	->collection()->filter('amount_due', '>', 0);
$payables_dt = core::model('v_invoices')->collection()->filter('amount_due', '>', 0);
	
if(lo3::is_admin())
{
	# if we're an admin, we don't have to filter this at all.
}
else if (lo3::is_market())
{
	# if we're a market manager, we only want payables that apply to our market
	$receivables_ov->filter('from_domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	$payables_ov->filter('from_domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	$payables_dt->filter('from_domain_id','in',$core->session['domains_by_orgtype_id'][2]);
}
else
{
	# otherwise, we want payables only for our organization.
	$receivables_ov->filter('to_org_id','=',$core->session['org_id']);
	$payables_ov->filter('from_org_id','=',$core->session['org_id']);
	$payables_dt->filter('invoice_id','in','(select invoice_id from v_invoices where to_org_id='.$core->session['org_id'].' or from_org_id='.$core->session['org_id'].')');
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


$payables_dt->add_formatter('payment_direction_formatter');

# this is data for the table of payables at the bottom
#$payables = new core_collection('select v_payables.*,unix_timestamp(v_payables.creation_date) as creation_date,unix_timestamp(v_payables.last_sent) as last_sent from v_payables where (from_org_id = ' . $core->session['org_id'] . ' or to_org_id = '. $core->session['org_id'] . ') and is_invoiced=0');
#$payables->add_formatter('payable_desc');
#$payables->add_formatter('org_amount');
$payables_table = new core_datatable('overview','payments/overview',$payables_dt);

$payables_table->add(new core_datacolumn(null,'Payment Info',false,'50%','{direction_info}','{direction_info}','{direction_info}'));
$payables_table->add(new core_datacolumn('creation_date','Date',true,'25%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn(null,'Amount',false,'25%',	'{amount_due}','{amount_due}','{amount_due}'));
$payables_table->columns[1]->autoformat='date-long';



#echo('<h1>'.core_format::date(time()).'-'.$core->session['time_offset'].'</h1>');

?>

<div class="tabarea tab-pane active" id="paymentstabs-a<?=$core->view[0]?>">
	<h1>Financial Management coming soon!</h1>
	<div class="row row-top-margin-buffer">
		<div class="span4">
			<h2>Payments Owed</h2>
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
		</div>
		<div class="span4">
			<? if(lo3::is_admin() || lo3::is_market() || $core->session['allow_sell'] ==1){?>
				<h2>Invoices Due</h2>
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
			<?}?>
		</div>
	</div>
	<div class="row row-top-margin-buffer">
		<div class="span10">
			<h3>Payables/Receivables by Organization</h3>
			<?
			$payables_table->render();
			?>
		</div>
	</div>
</div>
