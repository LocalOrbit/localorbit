<?php
$payables = core::model('v_payables')->collection();
$payables->add_formatter('payable_desc');
$payables_table = new core_datatable('payables','payments/portal',$payables);
$payables_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','payment_id'),' ',' '));
$payables_table->add(new core_datacolumn('payable_id','#ID',true,'5%','{payable_id}','{payable_id}','{payable_id}'));
$payables_table->add(new core_datacolumn('creation_date','Date',true,'19%','{creation_date}','{creation_date}','{creation_date}'));
//$invoices_table->add(new core_datacolumn('hub_name','Hub',true,'19%','{hub_name}','{hub_name}','{hub_name}'));
$payables_table->add(new core_datacolumn('from_org_name','Organization',true,'19%','{from_org_name}','{from_org_name}','{from_org_name}'));
$payables_table->add(new core_datacolumn('description','Description',true,'19%',			'{description_html}','{description}','{description}'));
$payables_table->add(new core_datacolumn('payable_amount','Amount',true,'19%',							'{payable_amount}','{payable_amount}','{payable_amount}'));
$payables_table->add(new core_datacolumn('invoice_status','Invoice Status',true,'19%',							'{invoice_status}','{invoice_status}','{invoice_status}'));
$payables_table->add(new core_datacolumn('last_sent','Last Sent',true,'19%',							'{last_sent}','{last_sent}','{last_sent}'));
$payables_table->columns[2]->autoformat='date-short';
$payables_table->columns[7]->autoformat='date-short';
?>

<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">

<?php
$payables_table->render();
?>
<!--	<table class="dt">
		<col width="5%" />
		<col width="8%" />
		<col width="20%" />
		<col width="15%" />
		<col width="15%" />
		<col width="15%" />
		<col width="15%" />
		<col width="15%" />
		<col width="15%" />
		<tr>
			<td colspan="9" class="dt_filter_resizer">
				<div class="dt_filter">
					<select>
						<option> Filter by Hub: All Hubs</option>
					</select>
					<select style="width: 300px;">
						<option>Filter by org: Buyer A</option>
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
			<th class="dt">ID#</th>
			<th class="dt dt_sortable dt_sort_asc">Date</th>
			<th class="dt">Hub</th>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Invoice Status</th>
			<th class="dt">Last Sent</th>
		</tr>
		<tr class="dt1">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">R234</td>
			<td class="dt">May 7, 2012</td>
			<td class="dt">Detroit Western Market</td>
			<td class="dt">Buyer A</td>

			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8231').toggle();">lo-2821</a>
			</td>
			<td class="dt">$9.00</td>
			<td class="dt">Invoiced</td>
			<td class="dt">2012-10-12</td>
		</tr>
		<tr class="dt">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">R235</td>
			<td class="dt">Jun 18, 2012</td>
			<td class="dt">Detroit Western Market</td>
			<td class="dt">Buyer A</td>

			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8231').toggle();">lo-2822</a>
			</td>
			<td class="dt">$32.00</td>
			<td class="dt">Invoiced</td>
			<td class="dt">2012-10-10, 2012-10-01</td>
		</tr>
		<tr class="dt1">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">R236</td>
			<td class="dt">Jul 13, 2012</td>
			<td class="dt">Detroit Western Market</td>
			<td class="dt">Buyer B</td>

			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8231').toggle();">lo-2823</a>
			</td>
			<td class="dt">$35.00</td>
			<td class="dt">Pending</td>
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
	</table> -->
	<div class="buttonset" id="create_invoice_toggler">
		<input type="button" onclick="$('#create_invoice_toggler,#create_invoice_form').toggle();" style="width:300px;" value="create invoices from checked" class="button_primary" />
	</div>
	<br />&nbsp;<br />
	<? $this->receivables__create_invoices(); ?>
</div>
