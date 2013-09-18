<?php
# basics
global $core;

lo3::user_can_shop();

global $left_url;
$left_url = 'app.php#!catalog-shop-';
//http://devspringfield.localorb.it/app.php#!catalog-view_product--prod_id-2351

#$start = microtime();
 	# if the buyer is reaching this page after logging in, show the news
 	
 	
	if($core->data['show_news'] == 'yes')
	{
		# we don't want to show the news if we have to show the dd_id selector
		if(intval($core->session['dd_id']) != 0)
			core::process_command('dashboard/release_news');
		$left_url .= '-show_news-yes';
	}
	
	if($core->data['cart'] == 'yes')
	{
		$left_url .= '-cart-yes';
	}


	#core::ensure_navstate(array('left'=>'left_shop'));
	core::head('Buy Local Food','Buy local food on Local Orbit');
	lo3::require_permission();

	# retrieve all necessary data
	global $prods,$sellers,$prices,$delivs;

	# get the full list of products
	$catalog = core::model('products')->get_final_catalog();
	
	
	if(count($catalog['products']) == 0)
	{
		$this->no_valid_products();
	}
	else
	{	
		# handle the cart
		$cart = core::model('lo_order')->get_cart();
		$cart->load_items();

		# write out necessary javascript, including the complete product/pricing/delivery listing
		core::js('core.categories ='.json_encode($catalog['categories']->by_parent).';');
		core::js('core.products ='.json_encode($catalog['products']).';');
		core::js('core.sellers ='.json_encode($catalog['sellers']).';');
		core::js('core.prices ='.json_encode($catalog['prices']).';');
		core::js('core.delivs ='.json_encode($catalog['deliveries']).';');
		core::js('core.cart = '.$cart->write_js(true).';');
		core::js('core.dds = '.json_encode($catalog['days']) . ';');
		core::js('core.addresses = '.json_encode($catalog['addresses']).';');

		# reorganize the cart into a hash by prod_id, so we can look up quantities easier
		# while rendering the catalog
		$item_hash = $cart->items->to_hash('prod_id');
		
		# render the filters on the left side
		core::ensure_navstate(array('left'=>'left_blank'), 'catalog-shop');
		core::write_navstate();
		$this->left_filters($catalog['categories'],$catalog['sellers'],$catalog['days'],$catalog['addresses'],$left_url);
		core::hide_dashboard();
		
		# figure out if we need to show the dd_id selector
		$deliv_keys = array_keys($catalog['deliveries']);
		#print_r($deliv_keys);
		# check to see if the user's dd_id in their session is valid on 
		# this market
		if(intval($core->session['dd_id']) != 0 && !in_array($core->session['dd_id'],$deliv_keys))
		{
			$core->session['dd_id'] = 0;
		}
		
		if(count($deliv_keys) == 1)
		{
			$core->session['dd_id'] = 0;
		}
		else if(intval($core->session['dd_id']) == 0)
		{
			$this->delivery_day_selector($catalog['days'],$left_url,$catalog['addresses']);
		}

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
			$catalog['products'],
			$catalog['prices'],
			$catalog['sellers'],
			$catalog['deliveries'],
			$item_hash,
			$catalog['days'],
			$catalog['addresses']
		);
		//$this->render_total_line(1);
		$this->render_no_products_line();
		$this->render_cart_empty_line();

		foreach($catalog['products'] as $prod)
		{
			# only render products with prices
			if(count($catalog['prices'][$prod['prod_id']]) > 0)
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
						$this->render_cat2_end($rendering_cats[1],$catalog['categories']->by_id[$rendering_cats[1]][0]['cat_name'],$rendering_cats[2],$catalog['categories']->by_id[$rendering_cats[2]][0]['cat_name'],$styles[0]);
					}

					# if we started rendering 1st level cats, close them
					if($rendering_cats[0] > 0)
					{
						$this->render_cat1_end($rendering_cats[0],$catalog['categories']->by_id[$rendering_cats[0]][0]['cat_name']);
					}

					# reset 2nd/3rd level cat taht we're rendering
					$rendering_cats[1] = 0;
					$rendering_cats[2] = 0;
					$rendering_cats[0] = $prod['cats'][1];

					# reset the 1st level style
					$styles[0] = ($styles[0]==1)?2:1;
					$this->render_cat1_start($rendering_cats[0],$catalog['categories']->by_id[$rendering_cats[0]][0]['cat_name'],$styles[0]);
				}

				# if this is a new 2nd or 3rd level cat
				if($rendering_cats[1] != $prod['cats'][2])
				{
					# if we started rendering 2nd/3rd level cats, close them.
					if($rendering_cats[1] > 0)
					{
						# reset teh 2nd level style
						$styles[1] = 1;
						$this->render_cat2_end($rendering_cats[1],$catalog['categories']->by_id[$rendering_cats[1]][0]['cat_name'],$rendering_cats[2],$catalog['categories']->by_id[$rendering_cats[2]][0]['cat_name'],$styles[0]);
					}
					$rendering_cats[1] = $prod['cats'][2];
					$rendering_cats[2] = $prod['cats'][3];
					$this->render_cat2_start($rendering_cats[1],$catalog['categories']->by_id[$rendering_cats[1]][0]['cat_name'],$rendering_cats[2],$catalog['categories']->by_id[$rendering_cats[2]][0]['cat_name'],$styles[0]);
				}
				# actually render the product
				$this->render_product(
					$prod,
					$catalog['categories']->by_id,
					$catalog['sellers'][$prod['org_id']][0],
					$catalog['prices'][$prod['prod_id']],
					$catalog['deliveries'],
					$styles[0],
					$styles[1],
					$item_hash[$prod['prod_id']][0]['qty_ordered'],
					$item_hash[$prod['prod_id']][0]['row_total'],
					$catalog['days'],
					$item_hash[$prod['prod_id']][0]['dd_id'],
					$catalog['addresses']
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

	#print_r($core->data);
	$js = '';
	##if($core->data['cart'] == 'yes')
	#$js .= 'core.afterCatalogInitCartFilter=\'cart\';';
	#if(is_numeric(trim($core->data['cat1'])))
	#	$js .= 'core.afterCatalogInitCat1Filter='.intval(trim($core->data['cat1']));
		
	#	$js .= 'core.catalog.setFilter(\'cat1\','.intval(trim($core->data['cat1'])).');';
		
	$js .= "core.catalog.initCatalog(".(($core->data['cart'] == 'yes')?1:0).",".(intval($core->session['dd_id'])).");";
		
	core::js("window.setTimeout('".$js."',400);");
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

