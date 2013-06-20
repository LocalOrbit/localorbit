<?
# get the start and end times for the default filters
$start = $core->view[0];
$end = $core->view[1];

# setup placeholders for the totaling
$core->data['devfee_totals'] = array(
	'gross'=>0,
	'lo'=>0,
	'payment'=>0,
	'net'=>0
);
# get the data :D
$col = core::model('lo_order_delivery_fees')
	->add_order_joins()
	->add_formatter('delivery_fee_formatter')
	->collection();

# these functions are used for the totaling, and for updating the totals table
function delivery_fee_formatter($data)
{
	global $core;
	
	$gross   = $data['amount'];
	$lo      = $data['amount'] * ($data['fee_percen_lo']/100);
	$payment = $data['amount'] * (floatval($data[$data['payment_method'].'_processing_fee'])/100);
	$net     = $gross - $lo - $payment;
	
	$core->data['devfee_totals']['gross']   += $gross;
	$core->data['devfee_totals']['lo']      += $lo;
	$core->data['devfee_totals']['payment'] += $payment;
	$core->data['devfee_totals']['net']     += $net;
	
	return $data;
}

function delivery_fee_outputer($output_type,$dt)
{
	global $core;
	$js = '';
	$js .= "$('#fees_gross').html('".core_format::price($core->data['devfee_totals']['gross'],false)."');";
	$js .= "$('#fees_lo').html('".core_format::price($core->data['devfee_totals']['lo'],false)."');";
	$js .= "$('#fees_payment').html('".core_format::price($core->data['devfee_totals']['payment'],false)."');";
	$js .= "$('#fees_net').html('".core_format::price($core->data['devfee_totals']['net'],false)."');";
	core::js($js);
}

# construct the table
$fees = new core_datatable('delivery_fees','reports/delivery_fees',$col);



# add filters
core_format::fix_dates('delivery_fees__filter__dfcreatedat1','delivery_fees__filter__dfcreatedat2');
$fees->filter_html .= core_datatable_filter::make_date('delivery_fees','dfcreatedat1',core_format::date($start,'short'),'Placed on or after ');
$fees->filter_html .= core_datatable_filter::make_date('delivery_fees','dfcreatedat2',core_format::date($end,'short'),'Placed on or before ');
$fees->add_filter(new core_datatable_filter('dfcreatedat1','lo_order.order_date','>','date',core_format::date($start,'db').' 00:00:00'));
$fees->add_filter(new core_datatable_filter('dfcreatedat2','lo_order.order_date','<','date',core_format::date($end,'db').' 23:59:59'));
$fees->add_filter(new core_datatable_filter('dforg_id','lo_order.org_id'));
$hubs = core::model('domains')->collection();						
if (lo3::is_market()) { 
	$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
} 

$hubs = $hubs->sort('name');
if (lo3::is_admin()) {
	$fees->add_filter(new core_datatable_filter('dforg_id','lo_order.org_id'));
	$fees->filter_html .= core_datatable_filter::make_select(
		'delivery_fees',
		'dforg_id',
		$fees->filter_states['delivery_fees__filter__dforg_id'],
		new core_collection('
			select org_id,name from organizations where org_id>0 
			 and org_id in (select org_id from lo_order where ldstat_id<>1)  order by name'),
		'org_id',
		'name',
		'Show from all buyers',
		'width: 230px;'
	);
} else if(lo3::is_market()) {	
	$fees->add_filter(new core_datatable_filter('sbporg_id','lo_fulfillment_order.org_id'));
	$fees->filter_html .= core_datatable_filter::make_select(
		'delivery_fees',
		'dforg_id',
		$fees->filter_states['delivery_fees__filter__dforg_id'],
		new core_collection('
			select organizations.org_id, CONCAT(d.name, \': \', organizations.name) as name from organizations 
			left join organizations_to_domains otd on (organizations.org_id = otd.org_id and otd.is_home=1)
			left join domains d on otd.domain_id = d.domain_id
			where otd.domain_id in ('.implode(',', $core->session['domains_by_orgtype_id'][2]).') order by d.name, organizations.name'),
		'org_id',
		'name',
		'Show from all buyers',
		'width: 230px;');
}

if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)
{	
	$fees->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$fees->filter_html .= core_datatable_filter::make_select(
		'delivery_fees',
		'lo_order.domain_id',
		$fees->filter_states['delivery_fees__filter__lo_order_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all markets',
		'width: 250px;'
	);
}

$fees->add_filter(new core_datatable_filter('dfpayment_method','lo_order.payment_method'));
$fees->filter_html .= core_datatable_filter::make_select(
	'delivery_fees',
	'dfpayment_method',
	$fees->filter_states['delivery_fees__filter__dfpayment_method'],
	array('paypal'=>'Paypal','purchaseorder'=>'Purchase Order'),
	null,
	null,
	'Show all payment types',
	'width: 230px;'
);


$fees->add_filter(new core_datatable_filter('lo_order_line_item.ldstat_id'));
$fees->filter_html .= core_datatable_filter::make_select(
	'delivery_fees',
	'lo_order.ldstat_id',
	$fees->filter_states['delivery_fees__filter__lo_order_ldstat_id'],
	array(
		'2'=>'Pending',
		'3'=>'Canceled',
		'4'=>'Delivered',
		'5'=>'Partially Delivered',
		'6'=>'Contested',
	),
	null,
	null,
	'Show All Delivery Statuses',
	'width: 230px;'
);


$fees->add_filter(new core_datatable_filter('lo_order.lbps_id'));
$fees->filter_html .= core_datatable_filter::make_select(
	'delivery_fees',
	'lo_order.lbps_id',
	$fees->filter_states['delivery_fees__filter__lo_order_lbps_id'],
	array(
		'1'=>'Unpaid',
		'2'=>'Paid',
		'3'=>'Invoice Issued',
		'4'=>'Partially Paid',
		'5'=>'Refunded',
		'6'=>'Manual Review',
	),
	null,
	null,
	'Show All Buyer Payment Statuses',
	'width: 270px;'
);


# do some settings, add columns, output
$fees->handler_onoutput = 'delivery_fee_outputer';
//~ $fees->render_resizer = false;
//~ $fees->render_page_select = false;
//~ $fees->render_page_arrows = false;
//~ $fees->size = (-1);
$fees->add(new core_datacolumn('lo_oid','Order #',true,'20%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{lo3_order_nbr}</a>','{lo3_order_nbr}','{lo3_order_nbr}'));
$fees->add(new core_datacolumn('order_date','Order Date',true,'20%','{order_date}','{order_date}','{order_date}'));
$fees->add(new core_datacolumn('amount','Fee',true,'15%','{amount}','{amount}','{amount}'));
$fees->add(new core_datacolumn('domains.name','Hub',true,'15%','{domain_name}','{domain_name}','{domain_name}'));
$fees->add(new core_datacolumn('organizations.name','Buyer',true,'15%','{buyer_org_name}','{buyer_org_name}','{buyer_org_name}'));
$fees->add(new core_datacolumn('lo_order.payment_method','Payment Method',true,'10%','{payment_method}','{payment_method}','{payment_method}'));
$fees->add(new core_datacolumn('delivery_status','Delivery Status',true,'10%','{delivery_status}','{delivery_status}','{delivery_status}'));
$fees->add(new core_datacolumn('buyer_payment_status','Payment Status',true,'10%','{buyer_payment_status}','{buyer_payment_status}','{buyer_payment_status}'));
$fees->columns[1]->autoformat='date-long';
$fees->columns[2]->autoformat='price';
$fees->sort_direction = 'desc';
$fees->render();

# now we need an html structure to contain the totals
?>

<h2>Total Fees</h2>
<table class="dt table table-striped">
	<thead>
	<tr>
		<th class="dt">Gross Fees</th>
		<th class="dt">Local Orbit Fees</th>
		<th class="dt">Payment Processing Fees</th>
		<th class="dt">Net Fees</th>
	</tr>
	</thead>
	<tbody>
	<tr class="dt">
		<td class="dt" id="fees_gross">$0.00</td>
		<td class="dt" id="fees_lo">$0.00</td>
		<td class="dt" id="fees_payment">$0.00</td>
		<td class="dt" id="fees_net">$0.00</td>
	</tr>
	<tbody>
</table>