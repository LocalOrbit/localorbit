<?
global $core;
$payments = core::model('v_payments')->collection()->filter('(from_org_id = ' . $core->session['org_id'] . ' or to_org_id = '. $core->session['org_id'] . ')');
$payments->add_formatter('payable_info');
$payments->add_formatter('org_amount');
$payments_table = new core_datatable('transactions','payments/transactions',$payments);
$payments_table->add(new core_datacolumn('payment_id',array(core_ui::check_all('transactions'),'',''),false,'4%',core_ui::check_all('transactions','payment_id'),' ',' '));
$payments_table->add(new core_datacolumn('amount','Amount',true,'19%',							'{amount_value}','{amount_value}','{amount_value}'));
$payments_table->add(new core_datacolumn('creation_date','Date',true,'19%','{creation_date}','{creation_date}','{creation_date}'));
$payments_table->add(new core_datacolumn('org_name','Organization',true,'19%','{org_name}','{org_name}','{org_name}'));
$payments_table->add(new core_datacolumn('hub_name','Hub',true,'19%','{hub_name}','{hub_name}','{hub_name}'));
$payments_table->add(new core_datacolumn('description','Description',true,'19%',			'{description_html}','{description}','{description}'));
$payments_table->columns[1]->autoformat='price';
$payments_table->columns[2]->autoformat='date-short';
/*
$payments_table->add_filter(new core_datatable_filter('to_org_id'));
$payments_table->filter_html .= core_datatable_filter::make_select(
	'payments',
	'lo_order.org_id',
	$items->filter_states['transactions__filter__from_org_id'],
	new core_collection('select distinct from_org_id, from_org_name from v_payments where from_org_id = ' . $core->session['org_id'] . ';'),
	'from_org_id',
	'from_org_name',
	'Show from all buyers',
	'width: 270px;'
);
*/

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

<!--	<table class="dt">
		<?=core_form::column_widths('5%','15%','25%','15%','15%','15%')?>
		<tr>
			<td colspan="6" class="dt_filter_resizer">
				<div class="dt_filter">
					<select class="dt">
						<option>Org: Seller A</option>
					</select>
					<select class="dt">
						<option>Status: Unpaid</option>
					</select>
				</div>
				<div class="dt_resizer">
					<select class="dt">
						<option>Show 10 rows</option>
					</select>
				</div>
			</td>
		</tr>
		<tr class="dt">
			<th class="dt"><input type="checkbox" /></th>
			<th class="dt">Amount</th>
			<th class="dt dt_sortable dt_sort_asc">Date</th>
			<th class="dt">Description</th>
			<th class="dt">Status</th>
			<th class="dt">Orginization</th>
		</tr>
		<?=core_datatable::render_fake_row(false,'<input type="checkbox" />','$300.00','May 1, 2012',fake_order_area(1),'Unpaid','Seller A')?>
		<?=core_datatable::render_fake_row(true,'<input type="checkbox" />','$220.00','May 12, 2012',fake_order_area(2),'Partially Paid','Seller A')?>
		<?=core_datatable::render_fake_row(false,'<input type="checkbox" />','$100.00','May 23, 2012',fake_order_area(3),'Unpaid','Buyer A')?>
		<?=core_datatable::render_fake_row(true,'<input type="checkbox" />','$120.00','May 30, 2012',fake_order_area(4),'Unpaid','Buyer A')?>
	</table> -->
	<div class="buttonset" id="payformtoggler">
		<input type="button" onclick="$('#payform,#payformtoggler').toggle();" class="button_primary" value="Mark as Paid" />
	</div>
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
							<option>Visa: *****2398</option>
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
