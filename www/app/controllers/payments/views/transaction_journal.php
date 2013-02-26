<?
global $core;
#$payments = new core_collection('select v_payments.*,unix_timestamp(v_payments.creation_date) as creation_date from v_payments where (from_org_id = ' . $core->session['org_id'] . ' or to_org_id = '. $core->session['org_id'] . ')');


# the admin sees all transactions
if(lo3::is_admin())
{
	$payments = core::model('v_payments')->collection();
}
# the market manager sees only transactions that apply to orgs that 
# they manage
else if(lo3::is_market())
{
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
# buyers and sellers only see transactions to/from themselves.
else
{
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
$payments_table->add(new core_datacolumn('amount','Amount',true,$col_widths[1],							'{amount}','{amount}','{amount}'));
if(lo3::is_admin())
{
	$payments_table->add(new core_datacolumn('transaction_fees','Trans. Fee',true,$col_widths[2],			'{transaction_fees}','{transaction_fees}','{transaction_fees}'));
	$payments_table->add(new core_datacolumn('net_amount','Net Amount',true,$col_widths[3],			'{net_amount}','{net_amount}','{net_amount}'));
	$payments_table->columns[4]->autoformat='price';
	$payments_table->columns[5]->autoformat='price';
}
$payments_table->columns[2]->autoformat='date-long';
$payments_table->columns[3]->autoformat='price';
$payments_table->sort_column = 0;
$payments_table->sort_direction = 'desc';
$payments_table = payments__add_standard_filters($payments_table);


function fake_order_area($id)
{
	return '
		<a href="#!payments-demo" onclick="$(\'#orders_'.$id.'\').toggle();">Orders</a>
		<div id="orders_'.$id.'" style="display: none;">
			<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-12-015-0002423</a><br />
			<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002431</a><br />
			<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002455</a><br />
		</div>
	';
}
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
