<fieldset id="create_payment_form_here" style="display: none;">
	<h3>Record invoice payment</h3>
	<form>
		<table class="form">
			<tr>
				<td class="label">Organziation:</td>
				<td class="value"><select name="organiz"><option>Buyer A</option></select></td>
			</tr>
			<?=core_form::input_text('Amount','amount')?>
			<tr>
				<td class="label">Payment Method:</td>
				<td class="value"><select style="width:100px;"><option>Choose a method</option><option>Check</option><option>Cash</option><option>'Favors'</option></select></td>
			</tr>
			<?=core_form::input_textarea('Memo:')?>
		</table>
		<br />
		<table class="dt">
			<?=core_form::column_widths('15%','25%','15%','15%','15%')?>
			<tr class="dt">
				<th class="dt dt_sortable dt_sort_asc">Date</th>
				<th class="dt">Hub</th>
				<th class="dt">Organization</th>
				<th class="dt">Description</th>
				<th class="dt">Amount</th>
				<th class="dt">Applied Amount</th>
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
				<td class="dt"><input type="text" style="width: 120px;" /></td>
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
				<td class="dt"><input type="text" style="width: 120px;" /></td>
			</tr>
		</table>
		<div class="buttonset">
			<input type="button" onclick="$('#create_payment_form_here,#create_payment_form_toggler').toggle();" class="button_secondary" value="cancel" />
			<input type="button" class="button_secondary" value="save payment" />
		</div>
	</form>
</fieldset>