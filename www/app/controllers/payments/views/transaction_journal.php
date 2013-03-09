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

function transaction_formatter($data)
{
	global $core;
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
	
	$data['payment_method'] = ucfirst($data['payment_method']);
	
	if ($data['from_org_id'] == $core->session['org_id'])
	{
		$data['formatted_amount'] = '<span class="text-error">(-' . core_format::price($data['amount']) . ')</span>';
		#$data['amount'] = -$data['amount'];
	}
	else
	{
		$data['formatted_amount'] = '$' . number_format($data['amount'], 2);
	}
	
	switch(strtolower($data['payable_type']))
	{
		case 'buyer order':
			$data['payable_type_formatted'] = 'Purchase';
			break;
		case 'seller order':
			$data['payable_type_formatted'] = 'Seller Pmt';
			break;
		case 'hub fees':
			$data['payable_type_formatted'] = 'Hub Fees';
			break;
		case 'lo fees':
			$data['payable_type_formatted'] = 'LO Fees';
			break;
		case 'monthly fees':
			$data['payable_type_formatted'] = 'Monthly Fees';
			break;
		default:
			$data['payable_type_formatted'] = ucfirst($data['payable_type']);
			break;
	}
	
	return $data;
}

$payments->add_formatter('payable_info');
$payments->add_formatter('payment_link_formatter');
$payments->add_formatter('payment_direction_formatter');
$payments->add_formatter('transaction_formatter');
$payments_table = new core_datatable('transactions','payments/transaction_journal',$payments);

$payments_table->add(new core_datacolumn('payment_id','Reference',true,'17%','{description_html}','{description}','{description}'));

$payments_table->add(new core_datacolumn('payable_type','Type',true,'10%','{payable_type_formatted}','{payable_type_formatted}','{payable_type_formatted}'));

$payments_table->add(new core_datacolumn('creation_date','Date Paid',true,'18%','{creation_date}','{creation_date}','{creation_date}'));

$payments_table->add(new core_datacolumn('payment_info','Description',false,'30%','{direction_info}','{direction_info}','{direction_info}'));

$payments_table->add(new core_datacolumn('payment_method','Method',false,'15%','{payment_method}','{payment_method}','{payment_method}'));

$payments_table->add(new core_datacolumn('amount','Amount',true,'10%','{formatted_amount}','{formatted_amount}','{formatted_amount}'));

$payments_table->columns[2]->autoformat='date-long';
$payments_table->sort_column = 0;
$payments_table->sort_direction = 'desc';
$payments_table = payments__add_standard_filters($payments_table,'transactionjournal');

?>
<div class="tabarea tab-pane" id="paymentstabs-a<?=$core->view[0]?>"<?=(($core->view[1]==1)?' style="display: block;"':'')?>>


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
