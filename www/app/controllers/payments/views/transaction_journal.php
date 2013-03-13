<?
global $core;
#$payments = new core_collection('select v_payments.*,unix_timestamp(v_payments.creation_date) as creation_date from v_payments where (from_org_id = ' . $core->session['org_id'] . ' or to_org_id = '. $core->session['org_id'] . ')');
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
	
	
	return $data;
}

$payments->add_formatter('payable_info');
$payments->add_formatter('payment_link_formatter');
$payments->add_formatter('payment_direction_formatter');
$payments->add_formatter('transaction_formatter');
$payments->add_formatter('type_formatter');
if(lo3::is_market() || lo3::is_admin())
	$payments->add_formatter('lfo_accordion');

$payments_table = new core_datatable('transactions','payments/transaction_journal',$payments);

$payments_table->add(new core_datacolumn('payment_id','Reference',true,'17%','{description_html}','{description}','{description}'));

$payments_table->add(new core_datacolumn('payable_type','Type',true,'10%','{payable_type_formatted}','{payable_type_formatted}','{payable_type_formatted}'));

$payments_table->add(new core_datacolumn('creation_date','Date Paid',true,'11%','{creation_date}','{creation_date}','{creation_date}'));

$payments_table->add(new core_datacolumn('payment_info','Description',false,'36%','{direction_info}','{direction_info}','{direction_info}'));

$payments_table->add(new core_datacolumn('payment_method','Method',false,'15%','{payment_method}','{payment_method}','{payment_method}'));

$payments_table->add(new core_datacolumn('amount','Amount',true,'10%','{formatted_amount}','{formatted_amount}','{formatted_amount}'));

$payments_table->columns[2]->autoformat='date-long-wrapped';
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
