<?php
$invoices = core::model('v_invoices')->collection();
$invoices->add_formatter('payable_info');
$invoices_table = new core_datatable('payments','payments/portal',$invoices);
$invoices_table->add(new core_datacolumn('creation_date','Date',true,'19%','{creation_date}','{creation_date}','{creation_date}'));
//$invoices_table->add(new core_datacolumn('hub_name','Hub',true,'19%','{hub_name}','{hub_name}','{hub_name}'));
$invoices_table->add(new core_datacolumn('from_org_name','Organization',true,'19%','{from_org_name}','{from_org_name}','{from_org_name}'));
$invoices_table->add(new core_datacolumn('description_html','Description',true,'19%',			'{description_html}','{description}','{description}'));
$invoices_table->add(new core_datacolumn('amount','Amount',true,'19%',							'{amount}','{amount}','{amount}'));
$invoices_table->add(new core_datacolumn('amount_due','Amount Due',true,'19%',			'{amount_due}','{amount_due}','{amount_due}'));
$invoices_table->columns[0]->autoformat='date-short';

function payable_info ($data) {
	$payable_info = array_map(function ($item) { return explode('|',$item); }, explode('$$', $data['payable_info']));

   if (count($payable_info) == 1) {
      $info = $payable_info[0];
      $data['description'] = format_text($info);
      $data['description_html'] = format_html($info);
   } else {
      $data['description'] = '';
      $title = '';
      if (stripos($payable_info[0][0], 'order') >= 0) {
         $title = 'Orders';
      } else if (stripos($payable_info[0][0], 'hub fees') >= 0) {
         $title = 'Fees';
      } else {
         $title = $payable_info[0][0];
      }

      $id = str_replace(' ', '_', $payable_info[0][0]) . '_' . $payable_info[0][1];
      $data['description_html'] = '<a href="#!payments-demo" onclick="$(\'#' . $id . '\').toggle();">' . $title . '</a><div id="' . $id .'" style="display: none;">';

      for ($index = 0; $index < count($payable_info); $index++) {
         $info = $payable_info[0];

         $data['description'] .= (($index>0)?', ':'') . format_text($info);
         $data['description_html'] .= (($index>0)?'<br/>':'') .format_html($info);
      }

      $data['description_html'] .= '</div>';
   }
   return $data;
}

function format_html ($info) {
   $text = '';
   if (count($info) > 0) {
      if (strcmp($info[0],'buyer order') == 0) {
         $text .= '<a href="#!orders-view_order--lo_oid-' . $info[1] . '">';
         $text .= 'Order #' . $info[1];
         $text .= '</a>';
      } else if ($info[0] === 'seller order') {
         $text .= 'Seller Order #' . $info[1];
      } else if ($info[0] === 'hub fees') {
         $text .= 'Hub Fees';
      } else {
         $text .= $info[0];
         if (count($info) > 1) {
            $text .= ' #' . $info[1];
         }
      }
   }
   return $text;
}

function format_text ($info) {
   $text = '';
   if (count($info) > 0) {
      if (strcmp($info[0],'buyer order') == 0) {
         $text .= 'Order #' . $info[1];
      } else if ($info[0] === 'seller order') {
         $text .= 'Seller Order #' . $info[1];
      } else if ($info[0] === 'hub fees') {
         $text .= 'Hub Fees';
      } else {
         $text .= $info[0];
         if (count($info) > 1) {
            $text .= ' #' . $info[1];
         }
      }
   }
   return $text;
}

?>
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<?
$invoices_table->render();
	?>
	<!--
	<table class="dt">
		<?=core_form::column_widths('15%','25%','15%','15%','15%')?>
		<tr>
			<td colspan="6" class="dt_filter_resizer">
				<div class="dt_filter">
					<select>
						<option> Filter by Hub: All Hubs</option>
					</select>
					<select class="dt">
						<option>Org: All</option>
					</select>
					<select class="dt">
						<option>Status: Unpaid</option>
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
			<th class="dt dt_sortable dt_sort_asc">Date</th>
			<th class="dt">Hub</th>
			<th class="dt">Organization</th>
			<th class="dt">Description</th>
			<th class="dt">Amount</th>
			<th class="dt">Status</th>
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
			<td class="dt">Unpaid</td>
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
			<td class="dt">Partially Paid</td>
		</tr>
		<tr>
			<td colspan="6" class="dt_exporter_pager">
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
	<div class="buttonset" id="create_payment_form_toggler">
		<input type="button" onclick="$('#create_payment_form_here,#create_payment_form_toggler').toggle();" class="button_primary" value="Record Payments" />
	</div>
	<br />&nbsp;<br />
	<? $this->invoices__record_payment()?>

</div>
