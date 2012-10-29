<?
global $core;
$payables = new core_collection('select v_payables.*,unix_timestamp(v_payables.creation_date) as creation_date,unix_timestamp(v_payables.last_sent) as last_sent from v_payables where (from_org_id = ' . $core->session['org_id'] . ' or to_org_id = '. $core->session['org_id'] . ') and is_invoiced=0');
$payables->add_formatter('payable_desc');
$payables->add_formatter('org_amount');
$payables_table = new core_datatable('overview','payments/overview',$payables);
$payables_table->add(new core_datacolumn(null,'Organization',false,'19%','{org_name}','{org_name}','{org_name}'));
$payables_table->add(new core_datacolumn(null,'Hub',false,'19%','{hub_name}','{hub_name}','{hub_name}'));
$payables_table->add(new core_datacolumn(null,'Receivables',false,'19%',							'{in_amount}','{in_amount}','{in_amount}'));
$payables_table->add(new core_datacolumn(null,'Payables',false,'19%',			'{out_amount}','{out_amount}','{out_amount}'));

$receivables_ov = core::model('v_invoices')->add_custom_field('DATEDIFF(due_date, NOW()) as days_since')->collection()->filter('to_org_id', $core->session['org_id'])->load()->to_array();
$payables_ov = core::model('v_invoices')->add_custom_field('DATEDIFF(due_date, NOW()) as days_since')->collection()->filter('from_org_id', $core->session['org_id'])->load()->to_array();

$intervals = array('Overdue' => 0, 'Today' => 1, 'Next 7 days' => 7, 'Next 30 days' => 30);

$receivables_intervals = array_fill_keys(array_values($intervals), 0);
$payables_intervals = array_fill_keys(array_values($intervals), 0);

foreach ($intervals as $val) {
	for($index = 0; $index < count($receivables_ov); $index++) {
		if ($receivables_ov[$index]['days_since'] < $val) {
			$receivables_intervals[$val] += $receivables_ov[$index]['amount_due'];
		}

	}
	for($index = 0; $index < count($payables_ov); $index++) {
		if ($payables_ov[$index]['days_since'] < $val) {
			$payables_intervals[$val] += $payables_ov[$index]['amount_due'];
		}

	}
}
?>
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<table>
		<?=core_form::column_widths('48%','4%','48%')?>
		<tr>
			<td>
				<h2>Payables</h2>
				<table class="form">
					<?
					foreach ($intervals as $key=>$value) {
						echo core_form::value($key,
							(($value<=0)?'<div class="error">':'').
							core_format::price($payables_intervals[$val], false)
							.(($value<=0)?'</div>':''));
					}
?>
<!--
					<?=core_form::value('Overdue:','<div class="error">$10.00</div>')?>
					<?=core_form::value('Today:','$12.00')?>
					<?=core_form::value('Next 7 days:','$19.00')?>
					<?=core_form::value('Next 30 days:','$32.00')?>
-->
				</table>
			</td>
			<td>&nbsp;</td>
			<td>
				<? if(lo3::is_admin() || lo3::is_market() || $core->session['allow_sell'] ==1){?>
				<h2>Receivables</h2>
				<table class="form">
<?
					foreach ($intervals as $key=>$value) {
						echo core_form::value($key,
							(($value<=0)?'<div class="error">':'').
							core_format::price($receivables_intervals[$val], false)
							.(($value<=0)?'</div>':''));
					}
?>
<!--
					<?=core_form::value('Overdue:','<div class="error">$10.00</div>')?>
					<?=core_form::value('Today:','$12.00')?>
					<?=core_form::value('Next 7 days:','$19.00')?>
					<?=core_form::value('Next 30 days:','$32.00')?>
-->
				</table>
				<?}?>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<br />&nbsp;<br />
				<h3>Payables/Receivables by Organization</h3>
				<?
				$payables_table->render();
				?>
				<!--
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
			-->
			</td>
		</tr>
	</table>
</div>
