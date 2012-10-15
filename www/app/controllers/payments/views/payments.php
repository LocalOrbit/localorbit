<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
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
			<th class="dt dt_sortable dt_sort_asc">Date Paid</th>
			<th class="dt">Hub</th>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Status</th>
		</tr>
		<tr class="dt">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">May 1, 2012</td>
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
		</tr>
		<tr class="dt1">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">May 6, 2012</td>
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
		
	<div class="buttonset" id="create_payment_button">
		<input type="button" onclick="$('#create_payment_form,#create_payment_button').toggle();" value="pay checked" class="button_primary" />
	</div>
	<br />&nbsp;<br />
	<? $this->payments__pay_payment();?>
</div>
