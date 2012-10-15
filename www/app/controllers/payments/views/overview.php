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
		<tr>
			<td colspan="3">
				<br />&nbsp;<br />
				<h3>Payables/Receivables by Organization</h3>
				<table class="dt">
					<col width="25%" />
					<col width="25%" />
					<col width="25%" />
					<col width="25%" />
					<tr>
						<td colspan="4" class="dt_filter_resizer">
							<div class="dt_filter">
								<select style="width: 160px;">
									<option>Filter by hub: All Hubs</option>
								</select>
								<select style="width: 220px;">
									<option>Filter by organization: All Orgs</option>
								</select>
								<select style="width: 240px;">
									<option>Owed: Both Payables and Receivables</option>
									<option>Owed: Payables only</option>
									<option>Owed: Receivables only</option>
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
						<th class="dt">Hub</th>
						<th class="dt dt_sortable dt_sort_asc">Organization</th>
						<th class="dt">Payables</th>
						<th class="dt">Receivables</th>
					</tr>
					<tr class="dt1">
						<td class="dt">Detroit Western Market</td>
						<td class="dt"><a href="#">Buyer A</a></td>
						<td class="dt"><a href="#">$7.00</a></td>
						<td class="dt"><a href="#">$0.00</a></td>
					</tr>
					<tr class="dt">
						<td class="dt">Detroit Western Market</td>
						<td class="dt"><a href="#">Seller B</a></td>
						<td class="dt"><a href="#">$0.17</a></td>
						<td class="dt"><a href="#">$0.00</a></td>
					</tr>
					<tr class="dt1">
						<td class="dt">Detroit Western Market</td>
						<td class="dt"><a href="#">Buyer B</a></td>
						<td class="dt"><a href="#">$3.60</a></td>
						<td class="dt"><a href="#">$0.00</a></td>
					</tr>
					<tr>
						<td colspan="4" class="dt_exporter_pager">
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
			</td>
		</tr>
	</table>
</div>
