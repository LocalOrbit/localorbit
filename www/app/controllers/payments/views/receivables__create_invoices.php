<fieldset id="create_invoice_form" style="display:none;">
	<table class="dt">
		<tr>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Invoice Date</th>
			<th class="dt">Payment Terms</th>
			<th class="dt">Due Date</th>
		</tr>
		<tr class="dt">
			<td class="dt">Buyer A</td>
			<td class="dt">R234,R235</td>
			<td class="dt"><input type="text" value="$41.00" style="width:80px;" /></td>
			<td class="dt"><input type="text" value="2012-10-05" style="width:80px;" /></td>
			<td class="dt"><select><option>Net 15</option><option>Net 60</option><option>Net 90</option></select></td>
			<td class="dt"><input type="text" value="2012-12-05" style="width:80px;" /></td>
		</tr>
		<tr class="dt1">
			<td class="dt">Buyer B</td>
			<td class="dt">R236</td>
			<td class="dt"><input type="text" value="$35.00" style="width:80px;" /></td>
			<td class="dt"><input type="text" value="2012-10-05" style="width:80px;" /></td>
			<td class="dt"><select><option>Net 15</option><option selected="selected">Net 60</option><option>Net 90</option></select></td>
			<td class="dt"><input type="text" value="2012-12-05" style="width:80px;" /></td>
		</tr>
	</table>
	<div class="buttonset">
		<input type="button" onclick="$('#create_invoice_toggler,#create_invoice_form').toggle();" value="cancel" class="button_primary" />
		<input type="button" class="button_primary" value="send invoices" />
	</div>
</fieldset>