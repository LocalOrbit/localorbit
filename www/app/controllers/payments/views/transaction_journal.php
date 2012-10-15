<div class="tabarea" id="paymentstabs-a6">
	<table class="dt">
		<col width="5%" />
		<col width="15%" />
		<col width="25%" />
		<col width="15%" />
		<col width="15%" />
		<col width="15%" />
		<tr>
			<td colspan="7" class="dt_filter_resizer">
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
		<tr class="dt">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">$300.00</td>
			<td class="dt">May 1, 2012</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8233').toggle();">Orders</a>
				<div id="orders_8233" style="display: none;">
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-12-015-0002423</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002431</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002455</a><br />
				</div>
			</td>
			<td class="dt">Unpaid</td>
			<td class="dt">Seller A</td>
		</tr>
		<tr class="dt1">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">$220.00</td>
			<td class="dt">May 6, 2012</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8233').toggle();">Orders</a>
				<div id="orders_8233" style="display: none;">
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-12-015-0002423</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002431</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002455</a><br />
				</div>
			</td>
			<td class="dt">Partially Paid</td>
			<td class="dt">Seller A</td>
		</tr>
		<tr>
			<td colspan="7" class="dt_exporter_pager">
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