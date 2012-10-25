<?php
global $core;
$payables = core::model('v_payables')->collection()->filter('from_org_id' , $core->session['org_id']);
$payables->add_formatter('payable_desc');
$payables_table = new core_datatable('payables','payments/portal',$payables);
$payables_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','payment_id'),' ',' '));
$payables_table->add(new core_datacolumn('creation_date','Date',true,'19%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn('from_domain_name','Hub',true,'19%','{from_domain_name}','{from_domain_name}','{from_domain_name}'));
$payables_table->add(new core_datacolumn('to_org_name','Organization',true,'19%','{to_org_name}','{to_org_name}','{to_org_name}'));
$payables_table->add(new core_datacolumn('description','Description',true,'19%',			'{description_html}','{description}','{description}'));
$payables_table->add(new core_datacolumn('payable_amount','Amount',true,'19%',							'{payable_amount}','{payable_amount}','{payable_amount}'));
$payables_table->add(new core_datacolumn('amount_due','Amount Due',true,'19%',			'{amount_due}','{amount_due}','{amount_due}'));
$payables_table->columns[1]->autoformat='date-short';

$payables_table->add_filter(new core_datatable_filter('to_org_id'));
$payables_table->filter_html .= core_datatable_filter::make_select(
	'v_payables',
	'to_org_id',
	$items->filter_states['payables__filter__to_org_id'],
	new core_collection('select distinct to_org_id, to_org_name from v_payables where from_org_id = ' . $core->session['org_id'] . ';'),
	'to_org_id',
	'to_org_name',
	'Show from all buyers',
	'width: 270px;'
);

?>
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
<?php

$payables_table->render();

?>
<!--	<table class="dt">
		<?=core_form::column_widths('7%','13%','13%','20%','20%','20%','10%','10%')?>
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
			<th class="dt"></th>
			<th class="dt">ID#</th>
			<th class="dt dt_sortable dt_sort_asc">Date</th>
			<th class="dt">Hub</th>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Status</th>
		</tr>
		<?=core_datatable::render_fake_row(false,'<input type="checkbox" />','PY123','Oct 12, 2012','Detroit Western Market','Seller A','lo-28323','$12.00','Unpaid')?>
		<?=core_datatable::render_fake_row(true, '<input type="checkbox" />','PY124','Oct 13, 2012','Detroit Western Market','Seller A','lo-28324','$8.00','Unpaid')?>
		<?=core_datatable::render_fake_row(false,'<input type="checkbox" />','PY125','Oct 14, 2012','Detroit Western Market','Seller B','lo-28326','$0.20','Paid')?>
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
	</table>-->
	<? if(lo3::is_admin() || lo3::is_market()){?>
	<div class="buttonset" id="create_payables_button">
		<input type="button" onclick="$('#create_payables_form,#create_payables_button').toggle();" value="Create Payment from checked" class="button_primary" />
	</div>
	<br />&nbsp;<br />
	<? $this->payables__create_payment();?>
	<?}?>
</div>
