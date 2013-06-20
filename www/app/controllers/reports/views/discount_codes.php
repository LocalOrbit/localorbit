<?
# get the start and end times for the default filters
$start = $core->view[0];
$end = $core->view[1];

# setup placeholders for the totaling
$core->data['discount_totals'] = array(
	'gross'=>0,
	'lo'=>0,
	'payment'=>0,
	'net'=>0
);
# get the data :D
$col = core::model('lo_order_discount_codes')
	->add_order_joins()
	->add_formatter('discount_code_formatter')
	->collection();

$col->__model->autojoin(
	'left',
	'customer_entity',
	'(lo_order.buyer_mage_customer_id=customer_entity.entity_id)',
	array('first_name','last_name','email')
);
# these functions are used for the totaling, and for updating the totals table
function discount_code_formatter($data)
{
	global $core;
	$data['formatted_order_date'] = core_format::date($data['order_date']);
	if($data['discount_type'] == 'Fixed')
	{
		$data['formatted_discount'] = core_format::price($data['discount_amount'],false);
	}
	else
	{
		$data['formatted_discount'] = $data['discount_amount'].'%';
	}
	
	$gross   = $data['amount'];
	$lo      = $data['amount'] * ($data['fee_percen_lo']/100);
	$payment = $data['amount'] * (floatval($data[$data['payment_method'].'_processing_fee'])/100);
	$net     = $gross - $lo - $payment;
	
	$core->data['discount_totals']['gross']   += $gross;
	$core->data['discount_totals']['lo']      += $lo;
	$core->data['discount_totals']['payment'] += $payment;
	$core->data['discount_totals']['net']     += $net;
	
	return $data;
}

function discount_code_outputer($output_type,$dt)
{
	global $core;
	$js = '';
	$js .= "$('#discount_gross').html('".core_format::price($core->data['discount_totals']['gross'],false)."');";
	$js .= "$('#discount_lo').html('".core_format::price($core->data['discount_totals']['lo'],false)."');";
	$js .= "$('#discount_payment').html('".core_format::price($core->data['discount_totals']['payment'],false)."');";
	$js .= "$('#discount_net').html('".core_format::price($core->data['discount_totals']['net'],false)."');";
	core::js($js);
}

# construct the table
$codes = new core_datatable('discount_codes','reports/discount_codes',$col);



# add filters
core_format::fix_dates('discount_codes__filter__dfcreatedat1','discount_codes__filter__dfcreatedat2');
$codes->filter_html .= core_datatable_filter::make_date('discount_codes','dccreatedat1',core_format::date($start,'short'),'Placed on or after ');
$codes->filter_html .= core_datatable_filter::make_date('discount_codes','dccreatedat2',core_format::date($end,'short'),'Placed on or before ');
$codes->add_filter(new core_datatable_filter('dccreatedat1','lo_order.order_date','>','date',core_format::date($start,'db').' 00:00:00'));
$codes->add_filter(new core_datatable_filter('dccreatedat2','lo_order.order_date','<','date',core_format::date($end,'db').' 23:59:59'));
$codes->add_filter(new core_datatable_filter('dcorg_id','lo_order.org_id'));
$hubs = core::model('domains')->collection();						
if (lo3::is_market()) { 
	$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
} 

$hubs = $hubs->sort('name');

if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)
{	
	$codes->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$codes->filter_html .= core_datatable_filter::make_select(
		'discount_codes',
		'lo_order.domain_id',
		$codes->filter_states['discount_codes__filter__lo_order_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all markets',
		'width: 250px;'
	);
}


# do some settings, add columns, output
$codes->handler_onoutput = 'discount_code_outputer';
//~ $codes->render_resizer = false;
//~ $codes->render_page_select = false;
//~ $codes->render_page_arrows = false;
//~ $codes->size = (-1);
$codes->add(new core_datacolumn('lo_order.order_date','Placed On',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{formatted_order_date}<br />{lo3_order_nbr}</a>','{formatted_order_date}/{lo3_order_nbr}','{formatted_order_date}/{lo3_order_nbr}'));
$codes->add(new core_datacolumn('organizations.name','Buyer',true,'20%','<a href="#!organizations-edit--org_id-{buyer_org_id}">{buyer_org_name}</a><br />{first_name} {last_name}<br /><a href="mailTo:{email}">{email}</a>','{buyer_org_name}/{first_name} {last_name}/{email}','{buyer_org_name}/{first_name} {last_name}/{email}'));
$codes->add(new core_datacolumn('code','Code',true,'20%','{code}','{code}','{code}'));
$codes->add(new core_datacolumn('discount_type','Discount',true,'9%','{formatted_discount}','{formatted_discount}','{formatted_discount}'));
$codes->add(new core_datacolumn('applied_amount','Actual Discount',true,'9%'));
$codes->add(new core_datacolumn('grand_total','Order Total',true,'9%'));
#$codes->columns[1]->autoformat='date-long';
$codes->columns[4]->autoformat='price';
$codes->columns[5]->autoformat='price';
$codes->sort_direction = 'desc';
$codes->render();

# now we need an html structure to contain the totals
?>
<hr>

<h2>Total Discounts</h2>
<table class="table">
	<thead>
		<tr>
			<th class="dt">Gross Discounts</th>
			<th class="dt">LO Discounts</th>
			<th class="dt">Payment Processing Discounts</th>
			<th class="dt">Net Discounts</th>
		</tr>
	</thead>
	<tbody>
		<tr class="dt">
			<td class="dt" id="discount_gross">$0.00</td>
			<td class="dt" id="discount_lo">$0.00</td>
			<td class="dt" id="discount_payment">$0.00</td>
			<td class="dt" id="discount_net">$0.00</td>
		</tr>
	</tbody>
</table>