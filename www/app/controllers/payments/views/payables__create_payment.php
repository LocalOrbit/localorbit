<fieldset id="create_payables_form" style="display: none;">
	<table class="dt">
		<tr>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Method</th>
			<th class="dt">Reference #</th>
		</tr>
		<?=core_datatable::render_fake_row(false,'Seller B','PY125','<input type="text" value="$0.17" style="width:80px;" />','<select><option>Choose method</option><option>Check</option><option>Cash</option><option>\'Favors\'</option></select>','<input type="text" value="" style="width:120px;" />')?>
	</table>
	<div class="buttonset">
		<input type="button" onclick="$('#create_payables_form,#create_payables_button').toggle();" class="btn btn-warning" value="cancel" />
		<input type="button" class="btn btn-primary" value="save payments" />
	</div>
</fieldset>