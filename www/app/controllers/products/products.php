<?php

class core_controller_products extends core_controller
{
	function testing($test)
	{
	}

	function cat_request_rules()
	{
		global $core;
		return new core_ruleset('catRequest',array(
			array('type'=>'is_int','name'=>'parent_category','msg'=>'Please enter a Parent Category Number'),
			array('type'=>'min_length','name'=>'new_category','data1'=>1,'msg'=>'Please enter a longer Category name'),
		));
	}

	function request_rules()
	{
		global $core;
		return new core_ruleset('catform',array(
			array('type'=>'min_length','name'=>'product_request','data1'=>4,'msg'=>'Please enter a longer product name'),
		));
	}

	function info_rules()
	{
		global $core;
		return new core_ruleset('prodForm_prodinfo',array(
			array('type'=>'min_length','name'=>'product_name','data1'=>4,'msg'=>'Please enter a longer name'),
			array('type'=>'selected',  'name'=>'unit_id','msg'=>'Please select a unit'),
			array('type'=>'min_length','name'=>'description','data1'=>4,'msg'=>'Please enter a longer description'),
		));
	}

	function pricing_basic_rules()
	{
		global $core;
		return new core_ruleset('pricing_basic_rules',array(
			array('type'=>'is_valid_price','name'=>'retail','msg'=>'Please enter a retail price'),
			array('type'=>'is_valid_price','name'=>'wholesale','msg'=>'Please enter a wholesale price'),
			array('type'=>'is_int','name'=>'qty','msg'=>'Please enter a wholesale minimum'),
		));
	}

	function inventory_basic_rules()
	{
		global $core;
		return new core_ruleset('inventory_basic_rules',array(
			array('type'=>'is_int','name'=>'qty','allow_blank'=>true,'msg'=>'Please enter a minimum quantity'),
		));
	}

	function pricing_advanced_rules()
	{
		global $core;
		return new core_ruleset('pricing_advanced_rules',array(
			array('type'=>'is_valid_price','name'=>'price','msg'=>'Please enter a price'),
			array('type'=>'is_int','name'=>'min_qty','msg'=>'Please enter a minimum qty'),
		));
	}

	function inventory_advanced_rules()
	{
		global $core;
		return new core_ruleset('inventory_advanced_rules',array(
		));
	}

	function request_new()
	{
		global $core;
		# $recips = core::model('customer_entity')->collection()->filter('org_id',1);
		# foreach($recips as $recip)
		# {
		$core->dump_data();
		core::log(print_r($core->data['product_request'], true));
		$recip='service@localorb.it';
			core::process_command(
				'emails/product_request',
				false,
				$recip,
				$core->session['first_name'].' '.$core->session['last_name'],
				$core->data['product_request'],
				$core->session['email'],
				$core->session['first_name'].' '.$core->session['last_name']
			);
		# }
		#core::js("$('#newProdRequestLink,#newProdRequest,#picker_button,#picker_cols').toggle();");
		core_ui::notification('request sent');
	}

	function request_new_cat()
	{
		global $core;
		#Mike - this is where we need to "insert into categories (parent_id, cat_name) values (# , 'name of product');"
		lo3::require_orgtype('admin');
		$new_cat =  core::model('categories');
		$new_cat['parent_id'] = $core->data['parent_category'];
		$new_cat['cat_name'] = $core->data['new_category'];
		$new_cat->save();

		core_ui::notification('category added. you must reload to use it.');
	}

	function create_new()
	{
		global $core;


		$prod = core::model('products');

		if(lo3::is_customer())
			$prod['org_id'] = $core->session['org_id'];
		else
			$prod['org_id'] = $core->data['org_id'];
		
		
		$org = core::model('organizations')->load($prod['org_id']);
		$prod['how'] = $org['product_how'];
		$prod['who'] = $org['profile'];

		$prod['category_ids'] = explode(',',$core->data['category_ids']);
		$cat = core::model('categories')->load(array_pop($prod['category_ids']));
		$prod['category_ids'][] = $cat['cat_id'];
		$prod['name'] = $cat['cat_name'];
		$prod['category_ids'] = join(',',$prod['category_ids']);
		$prod['last_modified'] = date("Y-m-d H:i:s");

		$prod->save();

		# add inventory
		$inv = core::model('product_inventory');
		$inv['prod_id'] = $prod['prod_id'];
		$inv['qty'] = 0;
		$inv->save();

		# add delivery days
		$sql = '
			select dd.dd_id
			from delivery_days dd

			where dd.domain_id ='.core_db::col('select domain_id from organizations_to_domains where  is_home=1 and org_id='.$prod['org_id'],'domain_id').'
			or dd.dd_id in (
				select odcs.dd_id
				from organization_delivery_cross_sells odcs
				where odcs.org_id ='.$prod['org_id'].'
			);
		';

		$days = new core_collection($sql);
		foreach($days as $day)
		{
			$new_deliv = core::model('product_delivery_cross_sells');
			$new_deliv['prod_id'] = $prod['prod_id'];
			$new_deliv['dd_id']   = $day['dd_id'];
			$new_deliv->save();
		}

		core::redirect('products','edit',array('prod_id'=>$prod['prod_id']));
	}

	function get_final_cats()
	{
		global $core;
		$cats = core::model('categories')->collection()->sort('cat_name')->to_array();
		$final_cats = array();
		$cat_idx = array();

		# first build an index of all categories, and create a 'has children' flag
		for ($i = 0; $i < count($cats); $i++)
		{
			$cat_idx[$cats[$i]['cat_id']] = $i;
			$cats[$i]['has_children'] = false;
		}

		# loop through all the cats and set the has children flag appropriately
		for ($i = 0; $i < count($cats); $i++)
		{
			if(is_numeric($cats[$i]['parent_id']))
				$cats[$cat_idx[$cats[$i]['parent_id']]]['has_children'] = true;
		}


		# figure out the complete name of teh category, but only if it has no children
		for ($i = 0; $i < count($cats); $i++)
		{
			# we only look for categories without sub categories to be actual products
			if(!$cats[$i]['has_children'])
			{
				# setup a hash to hold all the info about this category
				$final = array(
					'cat_id'=>$cats[$i]['cat_id'],
					'category_ids'=>$cats[$i]['cat_id'],
					'name'=>' / '.$cats[$i]['cat_name'],
				);

				# setup a loop to get the complete path to this category
				$has_parent = true;
				$parent_id = $cats[$i]['parent_id'];
				while($has_parent)
				{
					# find the parent using the index
					$parent = $cats[$cat_idx[$parent_id]];

					# don't bother with 'default category' as part of the label
					if($parent['cat_id'] != 2)
						$final['name'] = ' / '.$parent['cat_name'].$final['name'];

					# but we do want that # as part of the id list
					$final['category_ids'] = $parent['cat_id'].','.$final['category_ids'];

					# break the loop if the current parent has no parent
					if(!is_numeric($parent['parent_id']) || $parent['parent_id'] == 1)
						$has_parent = false;

					# set the next parent up
					$parent_id = $parent['parent_id'];
				}
				$final['search'] = strtolower($final['name']);
				$final['displayed'] = 0;
				$final_cats[] = $final;
			}
		}
		return $final_cats;
	}

	function update()
	{
		global $core;

		$prod = core::model('products')->load();

		# the seller of this product is NOT the same as the organization of
		# the current user
		if($prod['org_id'] != $core->session['org_id'])
		{
			core::log("here");
			list(
				$home_domain_id,
				$all_domains,
				$domains_by_orgtype_id
			) = core::model('customer_entity')->get_domain_permissions($prod['org_id']);

			# check to see if the current user manages a domain
			# that the seller is on. If not, then we must require
			# the current user to be an admin
			if(count(array_intersect($core->session['domains_by_orgtype_id'][2],$all_domains)) == 0)
			{
				lo3::require_orgtype('admin');
			}
		}


		$prod->import_fields('prod_id','name','short_description','description','who','how','unit_id','addr_id');
		 date("Y-m-d H:i:s");
		$prod->set('last_modified',date("Y-m-d H:i:s"));
		$prod->set('name',$core->data['product_name']);
		$prod->save();

		# save the delivery options
		$dds = explode(',',$core->data['dd_list']);
		core_db::query('delete from product_delivery_cross_sells where prod_id='.$prod['prod_id']);
		#core::log('data: '.print_r($core->data,true));
		for ($i = 0; $i < count($dds); $i++)
		{
			#core::log('checking '.$dds[$i]);
			if($core->data['dd_'.$dds[$i]] == 1)
			{
				core_db::query('insert into product_delivery_cross_sells (prod_id,dd_id) values ('.$prod['prod_id'].','.$dds[$i].')');
			}
		}

		# save the pricing
		if($core->data['pricing_mode'] == 'basic')
		{
			core_format::parse_prices('retail','wholesale');


			# if there was no retail price before:
			$retail = core::model('product_prices');
			if($core->data['retail_price_id'] > 0)
			{
				$retail->load($core->data['retail_price_id']);
			}
			core::log('retail values: '.floatval($core->data['retail']).' / '.intval($core->data['retail_price_id']));
			if(floatval($core->data['retail']) == 0)
			{
				if(intval($core->data['retail_price_id'])!=0)
				{
					$retail->delete($core->data['retail_price_id']);
					core::js("$('#retail_price_id').val(0);");
				}
			}
			else
			{
				# save the retail price
				$retail->set('price',$core->data['retail']);
				$retail->set('prod_id',$core->data['prod_id']);
				$retail->set('last_modified', date("Y-m-d H:i:s"));
				$retail->save();
				core::js("$('#retail_price_id').val(".$retail['price_id'].");");
			}

			$wholesale = core::model('product_prices');
			if($core->data['wholesale_price_id'] > 0)
			{
				$wholesale->load($core->data['wholesale_price_id']);
			}
			if(floatval($core->data['basic_wholesale_qty']) == 0 && floatval($core->data['wholesale']) == 0)
			{
				if(intval($core->data['wholesale_price_id'])!=0)
				{
					$wholesale->delete($core->data['wholesale_price_id']);
					core::js("$('#wholesale_price_id').val(0);");
				}
			}
			else
			{
				$wholesale->set('price',$core->data['wholesale']);
				$wholesale->set('min_qty',floatval($core->data['basic_wholesale_qty']));
				$wholesale->set('last_modified', date("Y-m-d H:i:s"));
				$wholesale->set('prod_id',$core->data['prod_id']);
				$wholesale->save();
				core::js("$('#wholesale_price_id').val(".$wholesale['price_id'].");");
			}

			core_datatable::js_reload('pricing');
		}

		# save the inventory
		if($core->data['inventory_mode'] == 'basic')
		{
			$inv = core::model('product_inventory');
			$inv->set('inv_id',$core->data['basic_inv_id']);
			$inv->set('qty',$core->data['qty']);
			$inv->set('good_from',null);
			$inv->set('expires_on',null);
			$inv->save();
			core_datatable::js_reload('inventory');
		}

		core_ui::notification($core->i18n('messages:generic_saved','product'),false,($core->data['do_redirect'] != 1));
		if($core->data['do_redirect'] == 1)
			core::redirect('products','list');
	}

	function save_lot()
	{
		global $core;

		parse_dates('good_from','expires_on');

		#core::log('saving lot: '.print_r($core->data,true));
		$inv = core::model('product_inventory')->import_fields('inv_id','prod_id','lot_id','good_from','expires_on','qty');

		if (strpos($inv['good_from'], '--00') === 0) {
			$inv['good_from'] = null;
		}

		if (strpos($inv['expires_on'], '--00') === 0) {
			$inv['expires_on'] = null;

		}

		$inv->save();


		#core::log('ok: '.unparse_date($core->data['good_from']));
		core_datatable::js_reload('inventory');
		core_ui::notification('lot saved');
	}

	function save_price()
	{
		global $core;
		core_format::parse_prices('price');

		$price = core::model('product_prices')->import_fields('price_id','prod_id','domain_id','org_id','price','min_qty');
		$price->set('last_modified', date("Y-m-d H:i:s"));

		core::log('price data: '.print_r($price, true));
		if($price->verify_unique())
		{
			$price->set('prod_id',$core->data['prod_id']);
			$price->save();

			if($core->data['call_method'] == 'popup')
			{
				core_datatable::js_reload('market_products');
				core_datatable::js_reload('products');
				core_datatable::js_reload('seller_products');
				core::js("$('#edit_popup').fadeOut('fast');");
			}
			else
			{
				core_datatable::js_reload('pricing');
				core::js('product.cancelPriceChanges();');
			}
			core_ui::notification('price saved');
		}
		else
		{
			core_ui::validate_error($core->i18n['error:products:nonunique_price_combination'],($core->data['call_method'] == 'popup')?'pricing_advanced_rules':'prodForm','min_qty');
		}
	}

	function save_inventory()
	{
		global $core;

		$inv = core::model('product_inventory')->load();
		$inv['qty'] = min(intval($core->data['qty']), '99999999');
		$inv->save();

		core_datatable::js_reload('market_products');
		core_datatable::js_reload('products');
		core_datatable::js_reload('seller_products');
		core::js("$('#edit_popup').fadeOut('fast');");
		core_ui::notification('inventory saved');
	}

	function delete_lots()
	{
		global $core;
		core_db::query('delete from product_inventory where inv_id in ('.$core->data['inv_ids'].');');
		core_datatable::js_reload('inventory');
		core_ui::notification('lots deleted');
	}

	function delete_prices()
	{
		global $core;

		# update product_price version end_date
		core_db::query('update versions_product_prices set end_date = "' . date("Y-m-d H:i:s") . '" where price_id in ('.$core->data['price_ids'].');');

		core_db::query('delete from product_prices where price_id in ('.$core->data['price_ids'].');');
		core_datatable::js_reload('pricing');
		core_ui::notification('pricing deleted');
	}

	function save_image()
	{
		global $core;
		core::load_library('image');

		if($_FILES['new_image'])
		{

			$image = core::model('product_images');
			if($core->data['old_pimg_id'] > 0)
			{
				$image->delete($core->data['old_pimg_id']);
				unlink($new->path,$core->paths['base'].'/../img/products/raws/'.$core->data['old_pimg_id'].'.dat');
				shell_exec('rm '.$core->paths['base'].'/../img/products/cache/'.intval($core->data['old_pimg_id']).'.*.jpg');
			}


			#echo('prod_id: '.$core->data['prod_id'].'<br />');
			$new = new core_image($_FILES['new_image']);
			$new->load_image();

			$image['prod_id'] = $core->data['prod_id'];
			$image['width'] = $new->width;
			$image['height'] = $new->height;
			$image['extension'] = $new->extension;
			$image->save();

			move_uploaded_file($new->path,$core->paths['base'].'/../img/products/raws/'.$image['pimg_id'].'.dat');

			exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">'.$image['pimg_id'].':'.$new->width.':'.$new->height.':'.$new->extension.':done</body></html>');
		}
		else
		{
			exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">noimage:done</body></html>');
		}
	}

	function remove_image()
	{
		global $core;
		$image = core::model('product_images');
		if($core->data['pimg_id'] > 0)
		{
			$image->delete($core->data['pimg_id']);
			unlink($core->paths['base'].'/../img/products/raws/'.$core->data['pimg_id'].'.dat');
			shell_exec('rm '.$core->paths['base'].'/../img/products/cache/'.intval($core->data['pimg_id']).'.*.jpg');
		}

		core::js("$('#prod_image').fadeOut();");
	}

	function delete_product()
	{
		global $core;
		$prod = core::model('products')->load(intval($core->data['prod_id']));
		if($prod['org_id'] != $core->session['org_id'])
		{
			lo3::require_orgtype('market');
		}
		$prod['is_deleted'] = 1;
		$prod->save();

		core_db::query('delete from weekly_specials where product_id='.intval($core->data['prod_id']).' and product_id>0;');
		core_db::query('delete from discount_codes where restrict_to_product_id='.intval($core->data['prod_id']).' and restrict_to_product_id>0;');

		core_datatable::js_reload('products');
		core_ui::notification('product deleted');
	}
}

?>