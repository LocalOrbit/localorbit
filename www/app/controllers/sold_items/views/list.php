<?php
core::ensure_navstate(array('left'=>'left_dashboard'), 'sold_items-list','products-delivery');
core_ui::fullWidth();
core::head('Orders','');
lo3::require_permission();
lo3::require_login();

core_ui::load_library('js','sold_items.js');

# get the start and end times for the default filters
$start = ($core->config['time'] - (86400*30));
$end = $core->config['time'] + 86400;


$sql = '
	select 
	loi.product_name,loi.qty_ordered,loi.row_total,loi.row_adjusted_total,loi.row_total,
	loi.unit_price,loi.seller_name,
	o.name as buyer_name,o.org_id as buyer_org_id,d.name as domain_name,
	ds.delivery_status,bps.buyer_payment_status,sps.seller_payment_status,
	lo.fee_percen_lo,lo.fee_percen_hub,lo.payment_method,UNIX_TIMESTAMP(lfo.order_date) as order_date,
	lfo.lo3_order_nbr as lfo3_order_nbr,lo.lo3_order_nbr,lo.lo_oid,lfo.lo_foid
	from lo_order_line_item loi
	inner join lo_order lo on (loi.lo_oid=lo.lo_oid and lo.ldstat_id<>1)
	inner join lo_fulfillment_order lfo on (loi.lo_foid=lfo.lo_foid and lfo.ldstat_id<>1)
	inner join organizations o on (lo.org_id=o.org_id)
	inner join domains d on (lo.domain_id=d.domain_id)
	inner join lo_delivery_statuses ds on (loi.ldstat_id=ds.ldstat_id)
	inner join lo_buyer_payment_statuses bps on (loi.lbps_id=bps.lbps_id)
	inner join lo_seller_payment_statuses sps on (loi.lsps_id=sps.lsps_id)
	
';
$col = new core_collection($sql);

$hubs = core::model('domains')->collection();						
$hubs = $hubs->sort('name');

# apply permissions
if(lo3::is_market())
{
	$col->filter('lo_order.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	$buyer_sql  = 'select distinct o.org_id,o.name from organizations o inner join lo_order lo on (lo.org_id=o.org_id and lo.domain_id in ('.implode(',', $core->session['domains_by_orgtype_id'][2]).')) where lo.ldstat_id<>1 order by name;';
	$seller_sql = 'select distinct o.org_id,o.name from organizations o inner join lo_fulfillment_order lfo on (lfo.org_id=o.org_id and lfo.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')) where lfo.ldstat_id<>1 order by name;';
}
else if(lo3::is_customer())
{
	$col->filter('lo_fulfillment_order.org_id',$core->session['org_id']);	
	$buyer_sql  = 'select org_id,name from organizations where org_id in (select org_id from lo_order left join lo_order_line_item using lo_oid where lo_order.ldstat_id<>1 and lo_order_line_item.seller_org_id='.$core->session['org_id'].') order by name';
}
else
{
	$buyer_sql  = 'select distinct o.org_id,o.name from organizations o inner join lo_order lo on (lo.org_id=o.org_id) where lo.ldstat_id<>1 order by name;';
	$seller_sql = 'select distinct o.org_id,o.name from organizations o inner join lo_fulfillment_order lfo on (lfo.org_id=o.org_id) where lfo.ldstat_id<>1 order by name;';
}

# this stores the totals
$core->data['sold_items_data'] = array(
	'gross'=>0,
	'lo'=>0,
	'hub'=>0,
	'proc'=>0,
	'discount'=>0,
	'net'=>0,
);

# the formatter is used to add up each row
function sold_items_formatter($data)
{
	global $core;

	# calculate the totals for each type of fee
	$lo   = round($data['row_adjusted_total'] * (floatval($data['fee_percen_lo']) / 100), 2);
	$hub  = round($data['row_adjusted_total'] * (floatval($data['fee_percen_hub']) / 100), 2);
	$proc = round($data['row_adjusted_total'] * (floatval($data[$data['payment_method'].'_processing_fee']) / 100), 2);
	$discount = $data['row_total'] - $data['row_adjusted_total'];
	
	
	# but we only want to add up non-canceled items
	if($data['status'] != 'CANCELED' && $data['status'] != 'CANCELLED')
	{
		$core->data['sold_items_data']['gross'] += $data['row_total'];
		$core->data['sold_items_data']['lo']  += $lo;
		$core->data['sold_items_data']['hub'] += $hub;
		$core->data['sold_items_data']['proc'] += $proc;
		$core->data['sold_items_data']['discount'] += $discount;
		$core->data['sold_items_data']['net'] += $data['row_adjusted_total'] - $lo - $hub - $proc;
	}
	
	$data['unit_price'] = core_format::price($data['unit_price']);
	$data['row_total'] = core_format::price($data['row_total']);
	
	$data['discount'] = core_format::price($discount,false);
	$data['row_adjusted_total'] = core_format::price($data['row_adjusted_total'],false);
	return $data;
}

# this handler is used to update the totals table whenver the table is refreshed.
function sold_items_output($output_type,$dt)
{
	global $core;
	$js = '';
	$js .= "$('#gross').html('".core_format::price($core->data['sold_items_data']['gross'],false)."');";
	$js .= "$('#hub').html('".core_format::price($core->data['sold_items_data']['hub'],false)."');";
	$js .= "$('#lo').html('".core_format::price($core->data['sold_items_data']['lo'],false)."');";
	$js .= "$('#proc').html('".core_format::price($core->data['sold_items_data']['proc'],false)."');";
	$js .= "$('#discount').html('".core_format::price($core->data['sold_items_data']['discount'],false)."');";
	$js .= "$('#net').html('".core_format::price($core->data['sold_items_data']['net'],false)."');";
	core::js($js);
}

# setup the basic table
$col->add_formatter('sold_items_formatter');
$items = new core_datatable('sold_items','sold_items/list',$col);
$items->handler_onoutput = 'sold_items_output';

# this particular data table is meant to show EVERYTHING in the date range.
# don't bother with paging
$items->render_resizer = false;
$items->render_page_select = false;
$items->render_page_arrows = false;
$items->size = (-1);

# add filters
#$items->filter_html .= '</table>';

$items->filter_html .= '<div class="clearfix">';

core_format::fix_dates('sold_items__filter__sicreatedat1','sold_items__filter__sicreatedat2');
$items->add_filter(new core_datatable_filter('sicreatedat1','lfo.order_date','>','date',core_format::date($start,'db')));
$items->add_filter(new core_datatable_filter('sicreatedat2','lfo.order_date','<','date',core_format::date($end,'db')));
#$items->filter_html .= '<table>';
$items->filter_html .= core_datatable_filter::make_date('sold_items','sicreatedat1',core_format::date($start,'short'),'Placed on or after ');
$items->filter_html .= core_datatable_filter::make_date('sold_items','sicreatedat2',core_format::date($end,'short'),'Placed on or before ');

$items->add_filter(new core_datatable_filter('searchables','concat_ws(\' \',seller_name,o.name,lo.lo3_order_nbr,lfo.lo3_order_nbr,product_name)','~','search'));
$items->filter_html .= core_datatable_filter::make_text('sold_items','searchables',$items->filter_states['sold_items__filter__searchables'],'Search');

$items->filter_html .= '</div>';


$items->filter_html .= '<div class="clearfix">';

if(isset($core->i18n['title:sold_items_filters1']))
	$items->filter_html .= '<strong class="filter-title pull-left">'.$core->i18n['title:sold_items_filters1'].':</strong> ';


# everyone can use the status filter
$items->add_filter(new core_datatable_filter('loi.ldstat_id'));
$items->filter_html .= core_datatable_filter::make_select(
	'sold_items',
	'lo_order_line_item.ldstat_id',
	$items->filter_states['sold_items__filter__loi_ldstat_id'],
	array(
		'2'=>'Pending',
		'3'=>'Canceled',
		'4'=>'Delivered',
		'5'=>'Partially Delivered',
		'6'=>'Contested',
	),
	null,
	null,
	'All Delivery Statuses'
);


$items->add_filter(new core_datatable_filter('loi.lbps_id'));
$items->filter_html .= core_datatable_filter::make_select(
	'sold_items',
	'lo_order_line_item.lbps_id',
	$items->filter_states['sold_items__filter__loi_lbps_id'],
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
	'All Buyer Payment Statuses'
);


$items->add_filter(new core_datatable_filter('loi.lsps_id'));
$items->filter_html .= core_datatable_filter::make_select(
	'sold_items',
	'lo_order_line_item.lsps_id',
	$items->filter_states['sold_items__filter__loi_lsps_id'],
	array(
		'1'=>'Unpaid',
		'2'=>'Paid',
		'3'=>'Partially Paid',
	),
	null,
	null,
	'All Seller Payment Statuses'
);

$items->filter_html .= '</div>';
$items->filter_html .= '<div class="clearfix">';

if(isset($core->i18n['title:sold_items_filters2']))
	$items->filter_html .= '<strong class="filter-title pull-left">'.$core->i18n['title:sold_items_filters2'].':</strong> ';

# only admins can filter by hub
if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)
{
	$items->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'sold_items',
		'lo_order.domain_id',
		$items->filter_states['sold_items__filter__lo_order_org_id'],
		$hubs,
		'domain_id',
		'name',
		'All Markets'
	);
}

# everyone can use the buyer filter
$items->add_filter(new core_datatable_filter('lo_order.org_id'));
$items->filter_html .= core_datatable_filter::make_select(
	'sold_items',
	'lo_order.org_id',
	$items->filter_states['sold_items__filter__lo_order_org_id'],
	new core_collection($buyer_sql),
	'org_id',
	'name',
	'All Buyers'
);

# only MMs and admins get a seller filter
if(lo3::is_market() || lo3::is_admin())
{
	$items->add_filter(new core_datatable_filter('lo_fulfillment_order.org_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'sold_items',
		'lo_fulfillment_order.org_id',
		$items->filter_states['sold_items__filter__lo_fulfillment_order_org_id'],
		new core_collection($seller_sql),
		'org_id',
		'name',
		'All Sellers'
	);
}

$items->filter_html .= '</div>';



#relevant buyers by date, item, amount, status
$order_link = '<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">';
$items->add(new core_datacolumn('lo_liid',array(core_ui::check_all('solditem'),'',''),false,'4%',core_ui::check_all('solditem','lo_liid'),' ',' '));

if (lo3::is_admin() || lo3::is_market()) {
	#$items->add(new core_datacolumn('order_date','&nbsp;',false,'14%','<a onclick="core.sold_items.editAdminNotes({lo_oid}, this);" style="cursor: pointer;">Note</a>'));
}


#if(lo3::is_admin())
#{
	$items->add(new core_datacolumn('order_date','Order',true,'29%','{order_date}<br>
	<a href="#!orders-view_order--lo_oid-{lo_oid}">{lo3_order_nbr}</a>
	<br />
	<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{lfo3_order_nbr}</a>'
	,'{lo3_order_nbr}/{lfo3_order_nbr}','{lo3_order_nbr}/{lfo3_order_nbr}'));
#}

# do not link customers to org profiles.
#if(lo3::is_customer())
	$items->add(new core_datacolumn('o.name','Buyer',true,'20%','{buyer_name}','{buyer_name}','{buyer_name}'));
#else
#	$items->add(new core_datacolumn('o1.name','Buyer',true,'20%',$order_link.'{buyer_name}</a>','{buyer_name}','{buyer_name}'));

# do
$items->add(new core_datacolumn('seller_name','Seller',true,'20%','{seller_name}<br><small>{domain_name}</small>'));
$items->add(new core_datacolumn('product_name','Product',true,'25%',$order_link.'{product_name}</a>'));
$items->add(new core_datacolumn('qty_ordered','Qty',true,'8','{qty_ordered}x'));
$items->add(new core_datacolumn('unit_price','Row Total',true,'14%','<small>Unit:</small>&nbsp;{unit_price}<br><small>Row&nbsp;Total:</small>&nbsp;{row_total}'));
$items->add(new core_datacolumn('discount','Discount',true,'14%','<small>Discount:</small>&nbsp;{discount}<br><small>Discounted&nbsp;Total:</small>&nbsp;{row_adjusted_total}'));
$items->add(new core_datacolumn('delivery_status','Delivery',true,'14%',$order_link.'{delivery_status}</a>'));
$items->add(new core_datacolumn('buyer_payment_status','Buyer',true,'14%',$order_link.'{buyer_payment_status}</a>'));
$items->add(new core_datacolumn('seller_payment_status','Seller',true,'14%',$order_link.'{seller_payment_status}</a>'));


# setup formatters
$items->columns[1]->autoformat='date-short';
#$items->columns[8]->autoformat='price';
#$items->columns[9]->autoformat='price';
#$items->columns[10]->autoformat='price';
#$items->columns[11]->autoformat='price';

$items->sort_direction = 'desc';
$items->action_html .= $this->get_actions_menus(1);

# add a hidden area to put the editor into
echo('<div id="qtyDeliveredForm" style="display: none;"></div>');
echo('<div id="statusErrors" style="display: none;"></div>');

page_header('Sold Items',null,null, null,null, 'stack-checkmark');
?>
<form name="itemForm">
	<? $items->render(); ?>
	<div class="buttonset">
	</div>
	<? $this->totals_table(); ?>
</form>