
<?php
# basics
global $core;

#$start = microtime();

if($core->config['domain']['is_closed'] == 1)
{
	$this->store_closed();
}
# logic before julie's change 5/7/12
#else if($core->session['is_active'] != 1 || $core->session['org_is_active'] != 1)
#{
#	$this->not_activated();
#}
else if(
	(
		$core->session['is_active'] != 1 ||
		$core->session['org_is_active'] != 1
	)
	&&
	$core->config['domain']['feature_allow_anonymous_shopping'] != 1
)
{
	#core::log('user active state: '.$core->session['is_active']);
	#core::log('org  active state: '.$core->session['org_is_active']);

	if($core->session['is_active'] != 1)
	{
		$this->not_emailconfirm();
	}
	else
	{
		$this->not_activated();
	}
}
else
{

	# if the buyer is reaching this page after logging in, show the news
	if($core->data['show_news'] == 'yes')
	{
		core::process_command('dashboard/release_news');
	}

	#core::ensure_navstate(array('left'=>'left_shop'));
	core::head('Buy Local Food','Buy local food on Local Orbit');
	lo3::require_permission();

	# retrieve all necessary data
	global $prods,$sellers,$prices,$delivs;

	# get the full list of products
	$prods = core::model('products')->get_catalog()->load();

	if($prods->__num_rows == 0)
	{
		$this->no_valid_products();
	}
	else
	{

		# get teh unique keys for sub tables
		$cat_ids   = $prods->get_unique_values('category_ids',true,true);
		$dd_ids    = $prods->get_unique_values('dd_ids',true,true);
		$price_ids = $prods->get_unique_values('price_ids',true,true);
		$org_ids   = $prods->get_unique_values('org_id');

		# load sub table data
		$cats  = core::model('categories')->load_for_products($cat_ids);
		$sellers   = core::model('organizations')->collection()->sort('name');
		$sellers	  = $sellers->filter('organizations.org_id','in',$org_ids)->to_hash('org_id');
		$orgmodel  = core::model('organizations');

		# get the seller photos
		foreach($sellers as $key=>$seller)
			list(
				$sellers[$key][0]['has_image'],$sellers[$key][0]['img_webpath'],$sellers[$key][0]['img_filepath']
			) = $orgmodel->get_image($sellers[$key][0]['org_id']);
		$prices    = core::model('product_prices')->get_valid_prices($price_ids, $core->config['domain']['domain_id'],$core->session['org_id']);
 		//collection()->filter('price_id','in',$price_ids)->filter('price','>',0)->to_hash('prod_id');
		$delivs    = core::model('delivery_days')
			->collection()
			->filter('delivery_days.dd_id','in',$dd_ids)
			->filter('domain_id','=',$core->config['domain']['domain_id']);
		$deliveries = array();
		$addrs = array(0); // 0 in case no $delivs set
		foreach ($delivs as $value) {
			$value->next_time();
			if($value['deliv_address_id'] != 0)
				$addrs[] = $value['deliv_address_id'];
			if($value['pickup_address_id'] != 0)
				$addrs[] = $value['pickup_address_id'];
	
			$deliveries[$value['dd_id']] = array($value->__data);
		}
		
		# get a list of all addresses that are used by for deliveries 
		$addresses = core::model('addresses')->add_formatter('simple_formatter')->collection()->filter('address_id','in',$addrs)->to_hash('address_id');
		#print_r($addresses);

		$delivs = $deliveries;
		#print_r($deliveries);
		//print_r($delivs->to_hash('dd_id'));

		# reformat the products to an array
		$prods = $prods->to_array();

		# build a column based on text category names that we can sort the product list on
		for ($i = 0; $i < count($prods); $i++)
		{
			# convert comma separated list to an array
			$prods[$i]['cat_list'] = explode(',',$prods[$i]['category_ids']);
			# the first category is the catalog root, so just remove it
			array_shift($prods[$i]['cat_list']);

			# create a new property called sort_col, then append on the text version
			# of the first two categories
			$prods[$i]['sort_col'] = '';
			$prods[$i]['sort_col'] .= $cats->by_id[$prods[$i]['cat_list'][0]][0]['cat_name'].'-';
			$prods[$i]['sort_col'] .= $cats->by_id[$prods[$i]['cat_list'][1]][0]['cat_name'].'-';
			$prods[$i]['sort_col'] .= $cats->by_id[$prods[$i]['cat_list'][2]][0]['cat_name'];
			$prods[$i]['sort_col'] .= '-'.$prods[$i]['name'];

			# lowercase the sort_col just to make sure we're comparing in a way that will
			# make sense to the user
			$prods[$i]['sort_col'] = strtolower($prods[$i]['sort_col']);
		}
		$days = array();
		foreach($delivs as $deliv)
		{
			$time = (($deliv[0]['pickup_address_id'] == 0 || $deliv[0]['deliv_address_id']==0) ? 'Delivered' : 'Pick Up') . '-' . strtotime('midnight',$deliv[0]['pickup_address_id'] ? $deliv[0]['pickup_end_time'] : $deliv[0]['delivery_end_time']);
			
			$time .= '-'.$deliv[0]['deliv_address_id'];
			$time .= '-'.$deliv[0]['pickup_address_id'];
			if (!array_key_exists($time, $days)) {
				$days[$time] = array();
			}
			foreach ($deliv as $value) {
				//print_r($deliv);
				$days[$time][$value['dd_id']] = $value;
			}
		}
		function day_sort($a,$b)
		{
			list($type, $atime) = explode('-', $a);
			list($type, $btime) = explode('-', $b);
			return intval($atime) - intval($btime);
		}

		uksort($days,'day_sort');
		# define a custom sorting function that uses our new sort column
		function prod_sort($a,$b)
		{
			return strcmp($a['sort_col'], $b['sort_col']);
		}
		# apply the sort
		usort($prods,'prod_sort');

		# handle the cart
		$cart = core::model('lo_order')->get_cart();
		$cart->load_items();

		# write out necessary javascript, including the complete product/pricing/delivery listing
		core_ui::load_library('js','catalog.js');
		core::js('core.categories ='.json_encode($cats->by_parent).';');
		core::js('core.products ='.json_encode($prods).';');
		core::js('core.sellers ='.json_encode($sellers).';');
		core::js('core.prices ='.json_encode($prices).';');
		core::js('core.delivs ='.json_encode($delivs).';');
		core::js('core.cart = '.$cart->write_js(true).';');
		core::js('core.dds = '.json_encode($days) . ';');
		core::js('core.addresses = '.json_encode($addresses).';');

		# reorganize the cart into a hash by prod_id, so we can look up quantities easier
		# while rendering the catalog
		$item_hash = $cart->items->to_hash('prod_id');
		#print_r($item_hash);
		
		# render the filters on the left side
		core::ensure_navstate(array('left'=>'left_blank'), 'catalog-shop');
		core::write_navstate();
		$this->left_filters($cats,$sellers,$days,$addresses);
		core::hide_dashboard();

		#===============================
		# now render the main product listing
		#===============================

		# these are used to track the row styling
		$cat1 = 0;
		$cat2 = 0;
		$style = 1;

		# this array is used to keep track of whether or not to render a new category start row
		$rendering_cats = array(0,0,0);
		# this array keeps track of the style for each row type
		$styles =array(1,1);

		
		
		
		# 1st total line
		echo('<div id="filter_container"><ol id="filter_list"/></div>');
		echo('<form name="cartForm">');
		$this->weekly_special(
			$prods,
			$prices,
			$sellers,
			$delivs,
			$item_hash,
			$days,
			$addresses
		);
		//$this->render_total_line(1);
		$this->render_no_products_line();
		$this->render_cart_empty_line();

		foreach($prods as $prod)
		{
			# only render products with prices
			if(count($prices[$prod['prod_id']]) > 0)
			{
				# get the actual starting categories
				$prod['cats'] = explode(',',$prod['category_ids']);

				# If this is a new 1st level cat, render it.
				if($rendering_cats[0] != $prod['cats'][1])
				{
					# if we started rendering 2nd/3rd level cats, close them.
					if($rendering_cats[1] > 0)
					{
						# reset teh 2nd level style
						$styles[1] = 1;
						$this->render_cat2_end($rendering_cats[1],$cats->by_id[$rendering_cats[1]][0]['cat_name'],$rendering_cats[2],$cats->by_id[$rendering_cats[2]][0]['cat_name'],$styles[0]);
					}

					# if we started rendering 1st level cats, close them
					if($rendering_cats[0] > 0)
					{
						$this->render_cat1_end($rendering_cats[0],$cats->by_id[$rendering_cats[0]][0]['cat_name']);
					}

					# reset 2nd/3rd level cat taht we're rendering
					$rendering_cats[1] = 0;
					$rendering_cats[2] = 0;
					$rendering_cats[0] = $prod['cats'][1];

					# reset the 1st level style
					$styles[0] = ($styles[0]==1)?2:1;
					$this->render_cat1_start($rendering_cats[0],$cats->by_id[$rendering_cats[0]][0]['cat_name'],$styles[0]);
				}

				# if this is a new 2nd or 3rd level cat
				if($rendering_cats[1] != $prod['cats'][2])
				{
					# if we started rendering 2nd/3rd level cats, close them.
					if($rendering_cats[1] > 0)
					{
						# reset teh 2nd level style
						$styles[1] = 1;
						$this->render_cat2_end($rendering_cats[1],$cats->by_id[$rendering_cats[1]][0]['cat_name'],$rendering_cats[2],$cats->by_id[$rendering_cats[2]][0]['cat_name'],$styles[0]);
					}
					$rendering_cats[1] = $prod['cats'][2];
					$rendering_cats[2] = $prod['cats'][3];
					$this->render_cat2_start($rendering_cats[1],$cats->by_id[$rendering_cats[1]][0]['cat_name'],$rendering_cats[2],$cats->by_id[$rendering_cats[2]][0]['cat_name'],$styles[0]);
				}
				# actually render the product
				$this->render_product(
					$prod,
					$cats->by_id,
					$sellers[$prod['org_id']][0],
					$prices[$prod['prod_id']],
					$delivs,
					$styles[0],
					$styles[1],
					$item_hash[$prod['prod_id']][0]['qty_ordered'],
					$item_hash[$prod['prod_id']][0]['row_total'],
					$days,
					$item_hash[$prod['prod_id']][0]['dd_id'],
					$addresses
				);
				$styles[1] = ($styles[1] == 1)?2:1;
			}
		}


		# perform final closeups
		# if we started rendering 2nd/3rd level cats, close them.
		if($rendering_cats[1] > 0)
		{
			$this->render_cat2_end($rendering_cats[1],$cats->by_id[$rendering_cats[1]][0]['cat_name'],$rendering_cats[2],$cats->by_id[$rendering_cats[2]][0]['cat_name']);
		}

		# if we started rendering 1st level cats, close them
		if($rendering_cats[0] > 0)
		{
			$this->render_cat1_end($rendering_cats[0],$cats->by_id[$rendering_cats[0]][0]['cat_name']);
		}

		# 2nd total line
		//$this->render_total_line(2);
		echo('</form>');
	}

	//$this->weekly_special();
}
#print_r($core->data);
$js = "core.catalog.initCatalog();";
if(is_numeric(trim($core->data['cat1'])))
	$js .= 'core.catalog.setFilter(\'cat1\','.intval(trim($core->data['cat1'])).');';
core::js("window.setTimeout('".$js."',1000);");
core::js("$('[rel=\"clickover\"]').clickover({ html : true, onShown : function () { core.changePopoverExpandButton(this, true); }, onHidden : function () { core.changePopoverExpandButton(this, false); } });");
core_ui::showLeftNav();


#core::log('total time on server: '.($end - $start))
?>


<div id="deliveryDateModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
    <h3 id="myModalLabel">Delivery Date Change</h3>
  </div>
  <div class="modal-body">
    <p>Are you sure you want to change the delivery date<br/> to &quot;<span id="modalDeliveryDate"></span>&quot;?</p><p>This may remove some of your items from your cart.</p>
  </div>
  <div class="modal-footer">
    <button class="btn" data-dismiss="modal" aria-hidden="true" onclick="core.catalog.confirmDeliveryDateChange(false);">No</button>
    <button class="btn btn-primary" data-dismiss="modal" onclick="core.catalog.confirmDeliveryDateChange(true);">Yes</button>
  </div>
</div>

<input type="hidden" id="emptyCart"/>

