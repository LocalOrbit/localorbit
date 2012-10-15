<fieldset id="create_payables_form" style="display: none;">
	<table class="dt">
		<tr>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Method</th>
			<th class="dt">Reference #</th>
		</tr>
		<tr class="dt">
			<td class="dt">Seller B</td>
			<td class="dt">PY125</td>
			<td class="dt"><input type="text" value="$0.17" style="width:80px;" /></td>
			<td class="dt"><select><option>Choose method</option><option>Check</option><option>Cash</option><option>'Favors'</option></select></td>
			<td class="dt"><input type="text" value="" style="width:120px;" /></td>
		</tr>
	</table>
	<div class="buttonset">
		<input type="button" onclick="$('#create_payables_form,#create_payables_button').toggle();" class="button_primary" value="cancel" />
		<input type="button" class="button_primary" value="save payments" />
	</div>
</fieldset>