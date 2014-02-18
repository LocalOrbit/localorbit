<?
class core_controller_fresh_sheet extends core_controller
{
	
	function test_send1()
	{
		global $core;
		return new core_ruleset('tf1',array(
			array('type'=>'valid_email','name'=>'te1','msg'=>$core->i18n['error:customer:email']),
		));
	}
	function test_send2()
	{
		global $core;
		return new core_ruleset('tf2',array(
			array('type'=>'valid_email','name'=>'te2','msg'=>$core->i18n['error:customer:email']),
		));
	}
	
	function send()
	{
		global $core;
		
		if(!in_array($core->data['domain_id'],$core->session['domains_by_orgtype_id'][2]))
		{
			lo3::require_orgtype('admin');
		}

		$domain =  core::model('domains')->load($core->data['domain_id']);

		$html = $this->generate_html($core->data['domain_id']);
		$market_manager = core::model('domains')->get_domain_info($core->data['domain_id']);
		
		if($core->data['test_only'] == '1')
		{ 
			core::js("$('#tf1,#tf2').hide();$('#bs1,#bs2').show();");
      core_email::send("[TEST] See what's fresh this week!",$core->data['email'],$html,array(),$market_manager['email'],$market_manager['name']);        
			core_ui::notification('test sent');
		}
		else
		{
			# Actually send
      $customers = $this->customers($core->data['domain_id']);
      $emails = array();
      
      foreach($customers as $customer) {
        $emails[] = $customer['email'];
      }
      core_email::send("See what's fresh this week!",$emails,$html,array(),$market_manager['email'],$market_manager['name']);        
			core::log("Successfully sent real campaign.\n");
			core_ui::notification('fresh sheet sent');
		} 
	}


	function generate_html($domain_id, $show_edit_links=false)
	{
		global $core;

		# Start HTML
		$html = core_email::header($core->data['domain_id']);
		$html .= '
			<h1>See what\'s fresh at '.$domain['name'].'</h1>
			<p>
			  Hi! Welcome to this week\'s new Fresh Sheet.
			</p>';

		$domain =  core::model('domains')->load($core->data['domain_id']);
		$prods = core::model('products')->get_catalog($domain_id,0)->sort('name');
		$prods = $prods->to_array();
		
		# first, arrange the products into a hash using the 2/3 category as the key
		# we ignore the first category because it is simply the 'root' category
		# of the catalog, and isn't actually used/displayed/relevant.
		
		$prods_by_catid_hash = array();
		$cats_to_lookup      = array();
		foreach($prods as $prod)
		{
			$cat_ids = explode(',',$prod['category_ids']);
			$new_key = $cat_ids[1].'-'.$cat_ids[2];
			if(!is_array($prods_by_catid_hash[$new_key]))
				$prods_by_catid_hash[$new_key] = array();
				
			$prods_by_catid_hash[$new_key][] = $prod;
			
			$cats_to_lookup[] = intval($cat_ids[1]);
			$cats_to_lookup[] = intval($cat_ids[2]);
		}
		
		# next, lookup the names of all the categories in the list
		$cat_order_by = array();
		$cat_names = array();
		$cat_names_by_name = array();
		if(count($cats_to_lookup) > 0)
		{
			$cats = core::model('categories')->collection()->filter('cat_id','in',$cats_to_lookup)->sort('order_by');
			foreach($cats as $cat)
			{
				$cat_names[$cat['cat_id']] = $cat['cat_name'];
				$cat_order_by[$cat['cat_id']] = $cat['order_by'];
				$cat_names_by_name[$cat['cat_name']] = $cat['cat_id'];
			}
		}
		
		# next, rebuild the product hash, this time using the category names as the key
		$prods_by_catname_hash = array();
		foreach($prods_by_catid_hash as $cat_ids => $prods)
		{			
			$cat_ids = explode('-',$cat_ids);
			$new_key = $cat_order_by[$cat_ids[0]].' : '.$cat_names[$cat_ids[0]].' : '.$cat_names[$cat_ids[1]];
			$prods_by_catname_hash[$new_key] = $prods;			
		}
		
		# finally, sorry the product hash by key
		ksort($prods_by_catname_hash, SORT_NUMERIC);

		$has_prods = false;
		$last_cat = "";
		$last_sub_cat = "";
		foreach($prods_by_catname_hash as $category => $prods) {
			$cur_cat = explode(":", $category);
			
			// new cat 1
			if($last_cat != trim($cur_cat[1])) {
				$last_cat = trim($cur_cat[1]);
				$cat_url = 'https://'.$domain['hostname'].'/app.php#!catalog-shop--cat1-'.$cat_names_by_name[$last_cat];
				$html .='<h2>'.$cur_cat[1].'</h2><a href="'.$cat_url.'" class="lo_button">Shop Now</a>';
			}

			// new cat 2
			if($last_sub_cat != trim($cur_cat[2])) {
				$last_sub_cat = trim($cur_cat[2]);
				$html .= '<h3>'.$cur_cat[2].'</h3>';
			}
			
			$html .= '<table class="lo_fresh_sheet">';
			foreach($prods as $prod)
			{
				$product_url = 'https://'.$domain['hostname'].'/app.php#!catalog-view_product--prod_id-'.$prod['prod_id'];
				$html .= '
					<tr>
						<th scope="row">
							<dl>
								<dt>'.$prod['name'].'</dt>
								<dd>'.$prod['single_unit'].'</dd>
								<dd>'.$prod['org_name'].'</dd>
							</dl>
						</th>
						<td>
							<span class="lo_availability">'.intval($prod['inventory']).' Available</span><br>
							<a href="'.$product_url.'" class="lo_add_link">Add to Order</a>
						</td>
					</tr>';
				
				$has_prods = true;
			}
			$html .='</table>';
		}
		$html .= core_email::footer();
		
		if($has_prods)
		{
			return $html;
		}
		else
		{
			return '';
		}
		
	}
  
  function customers($domain_id) {
    $customers = core::model('customer_entity')
    	->autojoin(
    		'left',
    		'organizations',
    		'(customer_entity.org_id=organizations.org_id)',
    		array('organizations.name as ORG_NAME','allow_sell')
    	)
    	->autojoin(
    		'left',
    		'organizations_to_domains',
    		'(organizations.org_id=organizations_to_domains.org_id and organizations_to_domains.is_home=1)',
    		array()
    	)
    	->autojoin(
    		'left',
    		'domains',
    		'(organizations_to_domains.domain_id=domains.domain_id)',
    		array('domains.domain_id','secondary_contact_name','secondary_contact_email','secondary_contact_phone','domains.name as website_name','hostname')
    	)
    	->autojoin(
    		'left',
    		'addresses',
    		'(addresses.org_id=organizations.org_id and addresses.default_billing=1)',
    		array('address','city','postal_code')
    	)->autojoin(
    		'left',
    		'directory_country_region dcr',
    		'(addresses.region_id=dcr.region_id)',
    		array('code as state')
    	)->collection()->filter('organizations.is_deleted', '=', 0)->filter('customer_entity.is_deleted', '=', 0)
      ->filter('customer_entity.send_freshsheet', '=', 1)
      ->filter('domains.domain_id', '=', $domain_id);
    return $customers;
  }
}
?>