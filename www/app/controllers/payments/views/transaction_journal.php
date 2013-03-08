<?
global $core;
#$payments = new core_collection('select v_payments.*,unix_timestamp(v_payments.creation_date) as creation_date from v_payments where (from_org_id = ' . $core->session['org_id'] . ' or to_org_id = '. $core->session['org_id'] . ')');

if(lo3::is_admin())
{
	# the admin sees all transactions
	$payments = core::model('v_payments')->collection();
}
else if(lo3::is_market())
{
	# the market manager sees only transactions that apply to orgs that they manage
	$payments = new core_collection('
		select *,
		UNIX_TIMESTAMP(creation_date) as creation_date
		from v_payments vp
		where (
			vp.from_org_id in (
				select otd1.org_id
				from organizations_to_domains otd1
				where otd1.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
			)
			or
			vp.to_org_id in (
				select otd1.org_id
				from organizations_to_domains otd1
				where otd1.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
			)
		)
	');
}
else
{
	# buyers and sellers only see transactions to/from themselves.
	$payments = new core_collection('
		select *,
		UNIX_TIMESTAMP(creation_date) as creation_date
		from v_payments vp
		where (
			vp.from_org_id = '.$core->session['org_id'].'
			or
			vp.to_org_id = '.$core->session['org_id'].'
		)
	');
}

$hub_from_filters = false;
$hub_to_filters = false;
$org_from_filters = false;
$org_to_filters = false;

if(lo3::is_admin())
{
	$hub_from_filters = core::model('domains')->collection()->sort('name');
	$hub_to_filters = core::model('domains')->collection()->sort('name');
	$org_to_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct to_org_id from v_payments)')
		->sort('name');
	$org_from_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct from_org_id from v_payments)')
		->sort('name');
}
else if(lo3::is_market())
{
	$assigned_domain_ids_including_admin = array_merge($core->session['domains_by_orgtype_id'][2], array(1));
	
	if(count($core->session['domains_by_orgtype_id'][2]) > 1)
	{
		$hub_from_filters = core::model('domains')
			->collection()
			->filter('domain_id','in',$assigned_domain_ids_including_admin)
			->sort('name');
		$hub_to_filters = core::model('domains')
			->collection()
			->filter('domain_id','in',$assigned_domain_ids_including_admin)
			->sort('name');
	}

	$org_to_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct to_org_id from v_payments)')
		->filter(
				'organizations.org_id' ,
				'in',
				'(
					select org_id
					 from organizations_to_domains
					where domain_id in ('.implode(',',$assigned_domain_ids_including_admin).')
				)'
		)
		->sort('name');
	$org_from_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct from_org_id from v_payments)')
		->filter(
			'organizations.org_id' ,
			'in',
			'(
					select org_id
					 from organizations_to_domains
					where domain_id in ('.implode(',',$assigned_domain_ids_including_admin).')
				)'
		)
		->sort('name');
}
else
{
}

function transaction_formatter($data)
{
	#core::log(print_r($data,true));
	switch(strtolower($data['payment_method']))
	{
		case 'check':
			$data['method_description'] = 'Check: '.$data['ref_nbr'];
			break;
		case 'ach':
			$data['method_description'] = 'ACH: '.$data['ref_nbr'];
			break;
		case 'paypal':
			$data['method_description'] = 'Paypal: '.$data['ref_nbr'];
			break;
		case 'cash':
			$data['method_description'] = 'Cash';
			break;
	}
	return $data;
}

$payments->add_formatter('payable_info');
$payments->add_formatter('payment_link_formatter');
$payments->add_formatter('payment_direction_formatter');
$payments->add_formatter('transaction_formatter');
$payments_table = new core_datatable('transactions','payments/transaction_journal',$payments);

$col_widths = (lo3::is_admin())?array('14%','10%','12%','12%'):array('22%','22%');

$payments_table->add(new core_datacolumn('payment_id','Description',true,'22%',			'<b>T-{payment_id}</b><br />{description_html}','{description}','{description}'));
$payments_table->add(new core_datacolumn('payment_info','Payment Info',false,'30%','{method_description}<br />{direction_info}','{direction_info}','{direction_info}'));
$payments_table->add(new core_datacolumn('creation_date','Date Paid',true,$col_widths[0],'{creation_date}','{creation_date}','{creation_date}'));
$payments_table->add(new core_datacolumn('payable_type','payable_type',true,'10%','{payable_type}'));
$payments_table->add(new core_datacolumn('amount','Amount',true,$col_widths[1],							'{amount}','{amount}','{amount}'));
if(lo3::is_admin())
{
	$payments_table->add(new core_datacolumn('transaction_fees','Trans. Fee',true,$col_widths[2],			'{transaction_fees}','{transaction_fees}','{transaction_fees}'));
	$payments_table->add(new core_datacolumn('net_amount','Net Amount',true,$col_widths[3],			'{net_amount}','{net_amount}','{net_amount}'));
	#$payments_table->columns[4]->autoformat='price';
	#$payments_table->columns[5]->autoformat='price';
}
#$payments_table->columns[2]->autoformat='date-long';
#$payments_table->columns[3]->autoformat='price';
$payments_table->sort_column = 0;
$payments_table->sort_direction = 'desc';
$payments_table = payments__add_standard_filters($payments_table,'transactionjournal');

?>

<div class="tabarea tab-pane" id="paymentstabs-a<?=$core->view[0]?>">

	<?
	$payments_table->render();
	?>
	<!--
	<div class="buttonset" id="payformtoggler">
		<input type="button" onclick="$('#payform,#payformtoggler').toggle();" class="button_primary" value="Mark as Paid" />
	</div>
	-->
	<div id="payform" style="display:none;">
		<br />
		<fieldset>
			<legend>Payment Info</legend>
			<table>
				<tr>
					<td class="label">Payment Method:</td>
					<td class="field">
						<select>
							<option>ACH: *****928323</option>
						</select>
					</td>
				</tr>
				<tr>
					<td class="label">Amount Owed:</td>
					<td class="field"><input type="text" value="$80.00" /></td>
				</tr>
				<tr>
					<td class="label">Amount to pay:</td>
					<td class="field"><input type="text" value="$80.00" /></td>
				</tr>
			</table>
			<div class="buttonset">
				<input type="button" onclick="$('#payform,#payformtoggler').toggle();" class="button_secondary" value="Cancel" />
				<input type="button" onclick="$('#payform,#payformtoggler').toggle();" class="button_secondary" value="Process Payments" />

			</div>
		</fieldset>
	</div>
</div>
