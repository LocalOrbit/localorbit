<?php
$payments = core::model('v_payments')->collection()->filter('from_org_id' , $core->session['org_id']);
$payments->add_formatter('payable_info');

$payments_table = new core_datatable('payments','payments/payments',$payments);
$payments_table->add(new core_datacolumn('payment_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','payment_id'),' ',' '));
$payments_table->add(new core_datacolumn('creation_date','Date',true,'19%','{creation_date}','{creation_date}','{creation_date}'));
$payments_table->add(new core_datacolumn('to_domain_name','Hub',true,'19%','{to_domain_name}','{to_domain_name}','{to_domain_name}'));
$payments_table->add(new core_datacolumn('to_org_name','Organization',true,'19%','{to_org_name}','{to_org_name}','{to_org_name}'));
$payments_table->add(new core_datacolumn('description','Description',true,'19%',			'{description_html}','{description}','{description}'));
$payments_table->add(new core_datacolumn('amount','Amount',true,'19%',							'{amount}','{amount}','{amount}'));
//$invoices_table->add(new core_datacolumn('amount_due','Amount Due',true,'19%',			'{amount_due}','{amount_due}','{amount_due}'));
$payments_table->columns[1]->autoformat='date-short';
$payments_table->columns[5]->autoformat='price';

$payments_table->add_filter(new core_datatable_filter('to_org_id'));
$payments_table->filter_html .= core_datatable_filter::make_select(
	'payments',
	'lo_order.org_id',
	$items->filter_states['payments__filter__from_org_id'],
	new core_collection('select distinct from_org_id, from_org_name from v_payments where from_org_id = ' . $core->session['org_id'] . ';'),
	'from_org_id',
	'from_org_name',
	'Show from all buyers',
	'width: 270px;'
);
?>
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<?
$payments_table->render();
?>
	<!--
	<table class="dt">
		<col width="3%" />
		<col width="10%" />
		<col width="15%" />
		<col width="15%" />
		<col width="10%" />
		<col width="15%" />
		<col width="15%" />
		<col width="15%" />
		<tr>
			<td colspan="9" class="dt_filter_resizer">
				<div class="dt_filter">
					<select class="dt">
						<option>Org: All</option>
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
			<th class="dt"><input type="checkbox" /></td>
			<th class="dt">Hub</th>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Status</th>
			<th class="dt dt_sortable dt_sort_asc">Date Invoiced</th>
			<th class="dt dt_sortable dt_sort_asc">Date Due</th>
			<th class="dt dt_sortable dt_sort_asc">Date Paid</th>

		</tr>
		<tr class="dt">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">Detroit Western Market</td>
			<td class="dt">Seller A</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8233').toggle();">Orders</a>
				<div id="orders_8233" style="display: none;">
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-28323</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-28324</a><br />
				</div>
			</td>
			<td class="dt">$20.00</td>
			<td class="dt">Paid</td>
			<td class="dt">May 1, 2012</td>
			<td class="dt">May 7, 2012</td>
			<td class="dt">May 9, 2012</td>
		</tr>
		<tr class="dt1">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">Detroit Western Market</td>
			<td class="dt">Seller B</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8233').toggle();">Orders</a>
				<div id="orders_8233" style="display: none;">
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-28327</a><br />
				</div>
			</td>
			<td class="dt">$0.14</td>
			<td class="dt">Paid</td>
			<td class="dt">May 6, 2012</td>
			<td class="dt">May 16, 2012</td>
			<td class="dt">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="9" class="dt_exporter_pager">
				<div class="dt_exporter">
					Save as: Quickbooks | CSV | PDF
				</div>
				<div class="dt_pager">
					<select class="dt">
						<option>Page 1 of 1</option>
					</select>
				</div>
			</td>
		</tr>
	</table>
	-->
	<div class="buttonset" id="create_payment_button">
		<input type="button" onclick="$('#create_payment_form,#create_payment_button').toggle();" value="pay checked" class="button_primary" />
	</div>
	<br />&nbsp;<br />
	<? $this->payments__pay_payment();?>
</div>
