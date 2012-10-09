<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Order Management','This page is used to manage orders');
lo3::require_permission();
lo3::require_login();
core_ui::tabset('paymentstabs');
$tabs = array('Overview','Payables / Receivables','Payments','Metrics');

page_header('Payments Portal');
?>
<?=core_ui::tab_switchers('paymentstabs',$tabs)?>
<div class="tabarea" id="paymentstabs-a1">
	<table>
		<col width="48%" />
		<col width="4%" />
		<col width="48%" />
		<tr>
			<td>
				<h2>Payables</h2>
				<table>
					<tr>
						<td class="label">Overdue:</td>
						<td class="field">
							<a href="#!payments-demo" onclick="$('#payables_overdue').toggle();"><div class="error">$70.00</div></a>
							<div id="payables_overdue" style="display: none;">
								United General Hospital: $70 <a href="#!payments-demo">Send Reminder</a><br />
								Mike's Fruits: $50 <a href="#!payments-demo">Send Reminder</a><br />
							</div>
						</td>
					</tr>
					<tr>
						<td class="label">Today:</td>
						<td class="field">$30.00</td>
					</tr>
					<tr>
						<td class="label">Next 7 days:</td>
						<td class="field">$129.00</td>
					</tr>
					<tr>
						<td class="label">Next 30 days:</td>
						<td class="field">$328.00</td>
					</tr>
				</table>	
			</td>
			<td>&nbsp;</td>
			<td>
				<h2>Receivables</h2>
				<table>
					<tr>
						<td class="label">Overdue:</td>
						<td class="field"><div class="error">$10.00</div></td>
					</tr>
					<tr>
						<td class="label">Today:</td>
						<td class="field">$12.00</td>
					</tr>
					<tr>
						<td class="label">Next 7 days:</td>
						<td class="field">$19.00</td>
					</tr>
					<tr>
						<td class="label">Next 30 days:</td>
						<td class="field">$32.00</td>
					</tr>
				</table>	
			</td>
		</tr>
	</table>
	<br />
	<h2>Graph of awesome</h2>
	<select>
		<option>Last 30 days</option>
		<option>Last 60 days</option>
		<option>Last 90 days</option>
	</select>
	<br />
	<img src="/img/demo_graph.png" />
</div>
<div class="tabarea" id="paymentstabs-a2">
	<table class="dt">
		<col width="5%" />
		<col width="15%" />
		<col width="25%" />
		<col width="15%" />
		<col width="15%" />
		<col width="15%" />
		<col width="15%" />
		<tr>
			<td colspan="7" class="dt_filter_resizer">
				<div class="dt_filter">
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
			<th class="dt dt_sortable dt_sort_asc">Date</th>
			<th class="dt">Description</th>
			<th class="dt">Owed</th>
			<th class="dt">Paid</th>
			<th class="dt">Due by</th>
			<th class="dt">Status</th>
		</tr>
		<tr class="dt">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">May 1, 2012</td>
			<td class="dt">Order LO-283-29382</td>
			<td class="dt">$300.00</td>
			<td class="dt">$300</td>
			<td class="dt">May 5, 2012</td>
			<td class="dt">Paid</td>
		</tr>
		<tr class="dt1">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">May 6, 2012</td>
			<td class="dt">Order LO-283-29389</td>
			<td class="dt">$220.00</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#payments_8233').toggle();">$150</a>
				<div id="payments_8233" style="display:none;">
					May 5: $30.00 (transaction 2382)<br />
					May 11: $120.00 (transaction 2382)<br />
				</div>
			</td>
			<td class="dt"><div class="error">May 11, 2012</div></td>
			<td class="dt">Partially Paid</td>
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
		<input type="button" onclick="$('#payform,#payformtoggler').toggle();" class="button_primary" value="Pay Checked Items" />
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
<div class="tabarea" id="paymentstabs-a3">
	
	<table class="dt">
		<col width="15%" />
		<col width="25%" />
		<col width="20%" />
		<col width="20%" />
		<col width="20%" />
		<tr>
			<td colspan="5" class="dt_filter_resizer">
				<div class="dt_filter">
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
			<th class="dt">Description</th>
			<th class="dt">Method</th>
			<th class="dt">Auth code</th>
			<th class="dt">Amount</th>
		</tr>
		<tr class="dt">
			<td class="dt">May 1, 2012</td>
			<td class="dt">Monthly fees</td>
			<td class="dt">Visa:*2353</td>
			<td class="dt">TZ23923</td>
			<td class="dt"><div class="error">(-$300.00)</div></td>
		</tr>
		<tr class="dt1">
			<td class="dt">May 7, 2012</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8233').toggle();">Orders</a>
				<div id="orders_8233" style="display: none;">
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-12-015-0002423</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002431</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002455</a><br />
				</div>
			</td>
			<td class="dt">ACH:*8032</td>
			<td class="dt">TZ232323</td>
			<td class="dt">$65.00</td>
		</tr>	
		<tr class="dt">
			<td class="dt">Jun 1, 2012</td>
			<td class="dt">Monthly fees</td>
			<td class="dt">Visa:*2353</td>
			<td class="dt">TZ23923</td>
			<td class="dt"><div class="error">(-$300.00)</div></td>
		</tr>
		<tr class="dt1">
			<td class="dt">Jun 18, 2012</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8232').toggle();">Orders</a>
				<div id="orders_8232" style="display: none;">
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-12-015-0002453</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002481</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002511</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002623</a><br />
				</div>
			</td>
			<td class="dt">ACH:*8032</td>
			<td class="dt">TZ23239</td>
			<td class="dt">$191.00</td>
		</tr>	
		<tr class="dt">
			<td class="dt">Jul 1, 2012</td>
			<td class="dt">Monthly fees</td>
			<td class="dt">Visa:*2353</td>
			<td class="dt">TZ23924</td>
			<td class="dt"><div class="error">(-$300.00)</div></td>
		</tr>
		<tr class="dt1">
			<td class="dt">Jul 13, 2012</td>
			<td class="dt">
				<a href="#!payments-demo" onclick="$('#orders_8231').toggle();">Orders</a>
				<div id="orders_8231" style="display: none;">
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-12-015-0002491</a><br />
					<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002489</a><br />
				</div>
			</td>
			<td class="dt">ACH:*8032</td>
			<td class="dt">TZ23926</td>
			<td class="dt">$35.00</td>
		</tr>
		<tr>
			<td colspan="5" class="dt_exporter_pager">
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
</div>
<div class="tabarea" id="paymentstabs-a4">
</div>

