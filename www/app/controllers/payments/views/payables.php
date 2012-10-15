<div class="tabarea" id="paymentstabs-a2">
	<table class="dt">
		<col width="7%" />
		<col width="13%" />
		<col width="13%" />
		<col width="20%" />
		<col width="20%" />
		<col width="20%" />
		<col width="10%" />
		<col width="10%" />
		<tr>
			<td colspan="8" class="dt_filter_resizer">
				<div class="dt_filter">
					<select style="width: 300px;">
						<option>Filter by organization: Seller A</option>
					</select>
					<select style="width: 300px;">
						<option>Filter by Payment Status: Unpaid</option>
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
			<th class="dt">Status</th>
		</tr>
		<tr class="dt">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">PY123</td>
			<td class="dt">Oct 12, 2012</td>
			<td class="dt">Detroit Western Market</td>
			<td class="dt">Seller A</td>
			<td class="dt">lo-28323</td>
			<td class="dt">$12.00</td>
			<td class="dt">Unpaid</td>
		</tr>
		<tr class="dt1">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">PY124</td>
			<td class="dt">Oct 13, 2012</td>
			<td class="dt">Detroit Western Market</td>
			<td class="dt">Seller A</td>
			<td class="dt">lo-28324</td>
			<td class="dt">$8.00</td>
			<td class="dt">Unpaid</td>
		</tr>
		<tr class="dt">
			<td class="dt"><input type="checkbox" /></td>
			<td class="dt">PY125</td>
			<td class="dt">Oct 14, 2012</td>
			<td class="dt">Z01</td>
			<td class="dt">Seller B</td>
			<td class="dt">lo-02746</td>
			<td class="dt">$0.20</td>
			<td class="dt">Unpaid</td>
		</tr>
		<tr>
			<td colspan="8" class="dt_exporter_pager">
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
	<div class="buttonset" id="create_payables_button">
		<input type="button" onclick="$('#create_payables_form,#create_payables_button').toggle();" value="Create Payment from checked" class="button_primary" />
	</div>
	<br />&nbsp;<br />
	<? $this->payables__create_payment();?>
</div>