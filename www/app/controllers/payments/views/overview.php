<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<table>
		<?=core_form::column_widths('48%','4%','48%')?>
		<tr>
			<td>
				<h2>Payables</h2>
				<table class="form">
					<?=core_form::value('Overdue:','<div class="error">$10.00</div>')?>
					<?=core_form::value('Today:','$12.00')?>
					<?=core_form::value('Next 7 days:','$19.00')?>
					<?=core_form::value('Next 30 days:','$32.00')?>
				</table>
			</td>
			<td>&nbsp;</td>
			<td>
				<? if(lo3::is_admin() || lo3::is_market() || $core->session['allow_sell'] ==1){?>
				<h2>Receivables</h2>
				<table class="form">
					<?=core_form::value('Overdue:','<div class="error">$10.00</div>')?>
					<?=core_form::value('Today:','$12.00')?>
					<?=core_form::value('Next 7 days:','$19.00')?>
					<?=core_form::value('Next 30 days:','$32.00')?>
				</table>
				<?}?>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<br />&nbsp;<br />
				<h3>Payables/Receivables by Organization</h3>
				<table class="dt">
					<?=core_form::column_widths('25%','25%','25%','25%')?>
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
					<?=core_datatable::render_fake_row(false,'Detroit Western Market','Buyer A','$7.00','$0.00')?>
					<?=core_datatable::render_fake_row(true,'Detroit Western Market','Seller A','$0.17','$0.00')?>
					<?=core_datatable::render_fake_row(false,'Detroit Western Market','Buyer B','$3.60','$0.00')?>
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
