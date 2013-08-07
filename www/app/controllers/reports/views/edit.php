<?php

# figure out the start/end ranges for the filters

core::ensure_navstate(array('left'=>'left_dashboard'),'reports-edit',
	array('reports', 'reports','sales-information','account'));

core_ui::fullWidth();
core::head('Create Custom Reports','This page is to create a custom report');
lo3::require_permission();
lo3::require_login();
core_ui::tabset('reportstabs');
page_header('Reports',null,null, null,null, 'bars');

# build the list of report tabs
$reports = array();

# these reports MIGHT be present, depending on rules

if(lo3::is_market() || lo3::is_seller() || lo3::is_admin())
	$reports['Total Sales'] = 'total_sales';
if(lo3::is_market() || lo3::is_seller() || lo3::is_admin())
	$reports['Sales by Product'] = 'sales_by_product';
if(lo3::is_market() || lo3::is_seller() || lo3::is_admin())
	$reports['Sales by Buyer'] = 'sales_by_buyer';
if(lo3::is_market() || lo3::is_seller() || lo3::is_admin())
	$reports['Sales by Payment Type'] = 'sales_by_payment_type';
if(lo3::is_market() || lo3::is_admin())
	$reports['Sales by Seller'] = 'sales_by_seller';
if(lo3::is_market() || lo3::is_admin() || lo3::is_seller())
	$reports['Items Delivered'] = 'orders_delivered';
	
# these reports are always present
$reports['Total Purchases'] = 'total_purchases';
$reports['Purchases by Product'] = 'purchases_by_product';




if(lo3::is_market() || lo3::is_admin())
{
	$reports['Discount Code Use'] = 'discount_codes';
	$reports['Discount Code by Product'] = 'discount_code_use_per_product';
}

/*
if(lo3::is_market() || lo3::is_admin())
	$reports['Delivery Fees'] = 'delivery_fees';
*/


# figure out the start and end times for this report
#print_r($core->session);
$end = mktime(23,59,59) - $core->session['time_offset'];
$start = $end - (30 * 86400) - $core->session['time_offset'];

?>
<form name="reportsForm" method="post" action="/reports/update" onsubmit="return core.submit('/reports/update',this);" enctype="multipart/form-data">
	<ul class="nav nav-tabs">
		<?
		$count = 1;
		foreach($reports as $label=>$function):
		?>
			<li <? if ($count == 1): ?>class="active"<? endif; ?>><a href="#reportstabs-a<?= $count ?>" data-toggle="tab"><?= $label ?></a></li>
		<? $count++; endforeach; ?>
	</ul>
	
	<div class="tab-content">
	<?
	$count = 1;
	foreach($reports as $label=>$function): ?>
		<div class="tab-pane <? if ($count == 1): ?>active<? endif; ?>" id="reportstabs-a<?= $count ?>">
	<?
		#core::replace('center');
		#if($function == 'sales_by_seller')
		$this->$function($start,$end);
		echo('</div>');
		$count++;
	endforeach; ?>
	</div>

</form>


<!--
<h1>General Rules</h1>
<ul>
<li> For all reports default ot past calendar month and make dates customizable
<li>All reports should have totals - gross and net - on bottom for same info as LO2
<li>If a MM or Seller has more than one market, they will always be able to select a specific market for each report type - or an aggregate report across all or selected markets
</ul>
-->
<!--
<div class="tabarea" id="reportstabs-a1">
		date, item, amount, status
	</div>
	<div class="tabarea" id="reportstabs-a2">
		date, product cat, item, amount, status (filter by produ cat and filter by item specific to producer - see Featured Promotions for example
	</div>
	<div class="tabarea" id="reportstabs-a3">
		relevant buyers by date, item, amount, status
	</div>
	<div class="tabarea" id="reportstabs-a4">
		date, produ cat, item, amount, status, payment method (NOTE: If market has only one payment type, this report tab does not show up)
	</div>
	<div class="tabarea" id="reportstabs-a5">
		date, prod cat, item, amount, status (filter by producer)
	</div>
	<div class="tabarea" id="reportstabs-a6">
		date, amount, status, order number
	</div>
	<div class="tabarea" id="reportstabs-a7">
		date, product cat, item, amount, status (filter by item specific to producer - see Featured Promotions)
	</div>
-->




