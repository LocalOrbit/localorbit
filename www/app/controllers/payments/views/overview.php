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
	$receivables_ov->filter('from_domain_id','in','('.implode(',',$core->session['domains_by_orgtype_id'][2]).')');
	$payables_ov->filter('from_domain_id','in','('.implode(',',$core->session['domains_by_orgtype_id'][2]).')');
	$payables_dt->filter('from_domain_id','in','('.implode(',',$core->session['domains_by_orgtype_id'][2]).')');
}
else
{
	# otherwise, we want payables only for our organization.
	$receivables_ov->filter('to_org_id','=',$core->session['org_id']);
	$receivables_ov->filter('from_org_id','=',$core->session['org_id']);
	$payables_dt->filter('invoice_id','in','(select invoice_id from v_invoices where to_org_id='.$core->session['org_id'].' or from_org_id='.$core->session['org_id'].')');
}

$payables_ov    = $payables_ov->load()->to_array();
$receivables_ov = $receivables_ov->load()->to_array();

$intervals = array('Overdue' => 0, 'Today' => 1, 'Next 7 days' => 7, 'Next 30 days' => 30);

$receivables_intervals = array_fill_keys(array_values($intervals), 0);
$payables_intervals    = array_fill_keys(array_values($intervals), 0);

foreach ($intervals as $val) 
{
	for($index = 0; $index < count($receivables_ov); $index++)
	{
		if ($receivables_ov[$index]['days_since'] < $val)
		{
			$receivables_intervals[$val] += $receivables_ov[$index]['amount_due'];
		}
	}
	
	for($index = 0; $index < count($payables_ov); $index++)
	{
		if ($payables_ov[$index]['days_since'] < $val)
		{
			$payables_intervals[$val] += $payables_ov[$index]['amount_due'];
		}
	}
}

function overview_payables_formatter($data)
{
	if(lo3::is_admin() || lo3::is_market())
	{
		$data['direction_info'] = 'From: '.$data['from_org_name'].'<br />';
		$data['direction_info'] .= 'To: '.$data['to_org_name'].'<br />';
		$data['payable_amount' ] = core_format::price($data['amount_due']);
	}
	else
	{
		if($data['to_org_id'] == $core->session['org_id'])
		{
			$data['direction_info'] = $data['from_org_name'];
			$data['in_amount' ] = core_format::price($data['amount_due']);
			$data['out_amount' ] = '';
		}
		else
		{
			$data['direction_info'] = $data['to_org_name'];
			$data['out_amount' ] = core_format::price((-1 * $data['amount_due']));
			$data['in_amount' ] = '';
		}
	}
	return $data;
}
$payables_dt->add_formatter('overview_payables_formatter');

# this is data for the table of payables at the bottom
#$payables = new core_collection('select v_payables.*,unix_timestamp(v_payables.creation_date) as creation_date,unix_timestamp(v_payables.last_sent) as last_sent from v_payables where (from_org_id = ' . $core->session['org_id'] . ' or to_org_id = '. $core->session['org_id'] . ') and is_invoiced=0');
#$payables->add_formatter('payable_desc');
#$payables->add_formatter('org_amount');
$payables_table = new core_datatable('overview','payments/overview',$payables_dt);

$payables_table->add(new core_datacolumn('creation_date','Date',false,'19%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn(null,'Payment Info',false,'19%','{direction_info}','{direction_info}','{direction_info}'));
if(lo3::is_admin() || lo3::is_market())
{
	$payables_table->add(new core_datacolumn(null,'Amount',false,'19%',	'{payable_amount}','{payable_amount}','{payable_amount}'));
}
else
{
	$payables_table->add(new core_datacolumn(null,'Amount',false,'19%',	'{in_amount}','{payable_amount}','{payable_amount}'));
	$payables_table->add(new core_datacolumn(null,'Payables',false,'19%','{out_amount}','{out_amount}','{out_amount}'));
}

$payables_table->columns[0]->autoformat='date-short';


?>
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<table>
		<?=core_form::column_widths('48%','4%','48%')?>
		<tr>
			<td>
				<h2>Payments Owed</h2>
				<table class="form">
				<?
				foreach ($intervals as $key=>$value)
				{
					echo core_form::value($key,
						(($value<=0)?'<div class="error">':'').
						core_format::price($payables_intervals[$val], false)
						.(($value<=0)?'</div>':''));
				}
				?>
				</table>
			</td>
			<td>&nbsp;</td>
			<td>
				<? if(lo3::is_admin() || lo3::is_market() || $core->session['allow_sell'] ==1){?>
				<h2>Invoices Due</h2>
				<table class="form">
				<?
				foreach ($intervals as $key=>$value)
				{
					echo core_form::value($key,
						(($value<=0)?'<div class="error">':'').
						core_format::price($receivables_intervals[$val], false)
						.(($value<=0)?'</div>':''));
				}
				?>
				</table>
				<?}?>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<br />&nbsp;<br />
				<h3>Payables/Receivables by Organization</h3>
				<?
				$payables_table->render();
				?>
			</td>
		</tr>
	</table>
</div>
