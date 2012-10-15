<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<table class="dt">
		<col width="15%" />
		<col width="25%" />
		<col width="15%" />
		<col width="15%" />
		<col width="15%" />
		<tr>
			<td colspan="6" class="dt_filter_resizer">
				<div class="dt_filter">
					<select>
						<option> Filter by Hub: All Hubs</option>
					</select>
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
			<th class="dt dt_sortable dt_sort_asc">Date</th>
			<th class="dt">Hub</th>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Status</th>
		</tr>
		<tr class="dt">
			<td class="dt">May 1, 2012</td>
			<td class="dt">Detroit Western Market</td>
			<td class="dt">Buyer A</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8233').toggle();">Orders</a>
				<div id="orders_8233" style="display: none;">
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-12-015-0002423</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002431</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002455</a><br />
				</div>
			</td>
			<td class="dt">$300.00</td>
			<td class="dt">Unpaid</td>
		</tr>
		<tr class="dt1">
			<td class="dt">May 6, 2012</td>
			<td class="dt">Detroit Western Market</td>
			<td class="dt">Buyer A</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8233').toggle();">Orders</a>
				<div id="orders_8233" style="display: none;">
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-12-015-0002423</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002431</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002455</a><br />
				</div>
			</td>
			<td class="dt">$220.00</td>
			<td class="dt">Partially Paid</td>
		</tr>
		<tr>
			<td colspan="6" class="dt_exporter_pager">
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
	<div class="buttonset" id="create_payment_form_toggler">
		<input type="button" onclick="$('#create_payment_form_here,#create_payment_form_toggler').toggle();" class="button_primary" value="Record Payments" />
	</div>
	<br />&nbsp;<br />
	<? $this->invoices__record_payment()?>
</div>