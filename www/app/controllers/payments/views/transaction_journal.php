<?
global $core;
$payments = new core_collection('select v_payments.*,unix_timestamp(v_payments.creation_date) as creation_date from v_payments where (from_org_id = ' . $core->session['org_id'] . ' or to_org_id = '. $core->session['org_id'] . ')');
$payments->add_formatter('payable_info');
$payments->add_formatter('org_amount');
$payments_table = new core_datatable('transactions','payments/transactions',$payments);
$payments_table->add(new core_datacolumn('payment_id',array(core_ui::check_all('transactions'),'',''),false,'4%',core_ui::check_all('transactions','payment_id'),' ',' '));
$payments_table->add(new core_datacolumn('amount','Payment Method',true,'25%','Visa','Credit Card','Credit Card'));
$payments_table->add(new core_datacolumn('amount','Amount',true,'19%',							'{amount_value}','{amount_value}','{amount_value}'));
$payments_table->add(new core_datacolumn('creation_date','Date',true,'19%','{creation_date}','{creation_date}','{creation_date}'));
$payments_table->add(new core_datacolumn('org_name','Organization',true,'19%','{org_name}','{org_name}','{org_name}'));
$payments_table->add(new core_datacolumn('hub_name','Hub',true,'19%','{hub_name}','{hub_name}','{hub_name}'));
$payments_table->add(new core_datacolumn('description','Description',true,'19%',			'{description_html}','{description}','{description}'));
$payments_table->columns[2]->autoformat='price';
$payments_table->columns[3]->autoformat='date-short';

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
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">

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
