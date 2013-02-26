<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Payments','This page is to view payment information');
lo3::require_permission();

page_header('Payments');

echo(core_ui::tab_switchers('paytabs',array('Payments from Buyers','Payments to Sellers','Payments to Markets','Payments to Local Orbit')));
?>
<div class="tabarea" id="paytabs-a3">
	<table class="dt">
		<tr>
			<th class="dt">Payment #</th>
			<th class="dt">Amount</th>
			<th class="dt">From</th>
			<th class="dt">To</th>
			<th class="dt">Why</th>
			<th class="dt">Due by</th>
			<th class="dt">&nbsp;&nbsp;</th>
		</tr>
		<tr class="dt">
			<td class="dt">239842</td>
			<td class="dt">$0.01</td>
			<td class="dt">Local Orbit</td>
			<td class="dt">Z01</td>
			<td class="dt">Monthly Hub Fee</td>
			<td class="dt">October 30</td>
			<td class="dt">
			   Paid to Hub
         </td>
		</tr>
		<tr class="dt1">
			<td class="dt">239843</td>
			<td class="dt">$4.00</td>
			<td class="dt">Local Orbit</td>
			<td class="dt">Farmer 1</td>
			<td class="dt">LO-2342</td>
			<td class="dt">April 3</td>
			<td class="dt">
				<a href="#">Process via Paypal</a><br />
			</td>
		</tr>
		<tr class="dt">
			<td class="dt">239844</td>
			<td class="dt">$4.00</td>
			<td class="dt">Local Orbit</td>
			<td class="dt">Farmer 2</td>
			<td class="dt">LO-2344</td>
			<td class="dt">April 3</td>
			<td class="dt">
				<a href="#">E-mail check request</a><br />
				<a href="#">Mark as Paid via Check</a><br />
			</td>
		</tr>

		<tr class="dt1">
			<td class="dt">239845</td>
			<td class="dt">$30.00</td>
			<td class="dt">Buyer 1</td>
			<td class="dt">Local Orbit</td>
			<td class="dt">LO-2342</td>
			<td class="dt">March 29</td>
			<td class="dt">
				Paid during checkout
			</td>
		</tr>
		<tr class="dt">
			<td class="dt">239845</td>
			<td class="dt">$60.00</td>
			<td class="dt">Buyer 2</td>
			<td class="dt">Local Orbit</td>
			<td class="dt">LO-2345</td>
			<td class="dt">March 29</td>
			<td class="dt">
				<a href="#">Mark as paid on delivery</a>
			</td>
		</tr>
		<tr class="dt1 nopay" style="display:none;">
			<td class="dt">239847</td>
			<td class="dt">$4.00</td>
			<td class="dt">Local Orbit</td>
			<td class="dt">Farmer 3</td>
			<td class="dt">LO-2345</td>
			<td class="dt">April 3</td>
			<td class="dt">
				Buyer has not paid
			</td>
		</tr>
	</table>
	<?=core_ui::checkdiv('show_unready','Show payments not ready for processing',false,"$('.nopay').toggle();")?>
</div>
