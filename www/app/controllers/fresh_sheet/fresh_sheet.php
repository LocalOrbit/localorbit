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

//$core->data['domain_id'] = 26;
		$domain =  core::model('domains')->load($core->data['domain_id']);
		
		core::load_library('mailchimp');
		$mc = new core_mailchimp();

		
		
		$html = $this->generate_html($core->data['domain_id']);
		// dont let anyone override template with doamin_id 
		$template_id = $mc->get_template_id('Weekly Fresh Sheet',0);
		
		$list_id     = $mc->get_list_id('Weekly Fresh Sheet');
		$logo = "http://".$domain['hostname'].image('logo-email',$domain['domain_id']);
		$logo_image = '<img style="margin: 0px 0px 5px 0px" alt="logo" src="'.$logo.'" />';
		$shop_now_button = '<a href=""https://'.$domain['hostname'].'/app.php#!catalog-shop" target="_blank"><img src="https://www.localorb.it/img/mailchimp/ShopNow_Button.jpg" alt="Button" border="0"></a>';
		

		$seg_opts = array(
			'match'=>'all',
			'conditions'=>array(
				array(
					'field'=>'DOMAIN_ID',
					'op'=>'eq',
					'value'=>$core->data['domain_id'],
				),
			),
		);
		
		$camp_id = $mc->api->campaignCreate(
			'regular',
			array(
				'subject'=>'see what\'s fresh this week!',
				'from_email'=>'service@localorb.it',
				'from_name'=>$domain['name'],
				'title'=>'Fresh Sheet',
				'list_id'=>$list_id,
				'template_id'=>$template_id,
			),
			array(
				'HTML'=>$html,
				'HTML_MAIN'=>$html,
				'HTML_FOOTER'=>'',
				'HTML_SIDECOLUMN'=>'',
					
				'HTML_SHOP_NOW_BUTTON'=>$shop_now_button,
				'HTML_FRESH_ITEMS'=>$html,
				'HTML_FROM_NAME1'=>$domain['name'],
				'HTML_FROM_NAME2'=>$domain['name'],
				'HTML_FROM_NAME3'=>$domain['name'],
				'HTML_LOGO_IMAGE1'=>$logo_image,
				'HTML_LOGO_IMAGE2'=>$logo_image,
				'HTML_ABOUT_US'=>$domain['market_profile'],
				'HTML_CUSTOM_TAGLINE'=>$domain['custom_tagline'],
				'HTML_CUSTOM_TAGLINE2'=>$domain['custom_tagline'],
			),
			$seg_opts
		);
		
		
		if ($mc->api->errorCode){
			core::log("Unable to Create New Campaign!");
			core::log("\n\tCode=".$mc->api->errorCode);
			core::log("\n\tMsg=".$mc->api->errorMessage."\n");
			core::deinit();
		} else {
			core::log("New Campaign ID:".$camp_id."\n");
		}
		
		if($core->data['test_only'] == '1')
		{ 
			core::js("$('#tf1,#tf2').hide();$('#bs1,#bs2').show();");
			$mc->campaignSendTest($camp_id,array('jvavul@gmail.com',$core->data['email']));

			/* echo 'test sent ' . $mc->api->errorMessage. '<br>';
			echo "list_id" . $list_id . " template_id" . $template_id .
				"domain['hostname'] " . $domain['hostname'].
				"domain['market_profile'] " . $domain['market_profile'];
			echo '<br><br><br><br>';
			print_r($core->data['email']);
			echo '<br><br>logo = '.$logo;
			echo '<br><br>logo_image = '.$logo_image;
			echo '<br><br>shop_now_button = '.$shop_now_button;
			print_r($camp_id);
			echo $html;
			die();  */
			core_ui::notification('test sent ' . $mc->api->errorMessage);
		}
		else
		{

			$mc->campaignSendNow($camp_id);
			if ($mc->api->errorCode){
				core::log("Unable to send real Campaign!");
				core::log("\n\tCode=".$mc->api->errorCode);
				core::log("\n\tMsg=".$mc->api->errorMessage."\n");
				core_ui::notification('fresh sheet send failed: '.$mc->api->errorMessage);
			} else {
				core::log("Successfully sent real campaign:".$camp_id."\n");
			}
			core_ui::notification('fresh sheet sent');
		} 
	}


	function generate_html($domain_id, $show_edit_links=false)
	{
		global $core;
		$domain =  core::model('domains')->load($core->data['domain_id']);
		
		$html = '<table class="table table-hover" style="font-family:Helvectica, Trebuchet MS, Arial" width="100%">';
		$prods = core::model('products')->get_catalog($domain_id,0)->sort('name');
		
		$prods = $prods->to_array();
		
		#echo('<pre>');
		#print_r($prods);
		#return;
		
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
				//echo "adding new key ".$new_key."<br>";
							
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
			//echo('found a new_key: '.$new_key.' === '.$cat_ids[0].' ======== '. $cat_order_by[$cat_ids[0]].' ======== '. $cat_order_by[$cat_ids[1]].'<br />');
			$prods_by_catname_hash[$new_key] = $prods;			
		}
		
		# finally, sorry the product hash by key
		ksort($prods_by_catname_hash, SORT_NUMERIC);
		/* foreach($prods_by_catname_hash as $category => $prods) {
			echo('found a new_key: '.$category.'<br />');
		} */
		
		
		#echo('<pre>');
		#print_r($prods);

		
		
		

		$has_prods = false;
		$drew_hr = false;
		$last_cat = "";
		$last_sub_cat = "";
		foreach($prods_by_catname_hash as $category => $prods) {
			$cur_cat = explode(":", $category);
			
			
			// new cat 1
			if($last_cat != trim($cur_cat[1])) {
				// single row
				if (!$drew_hr) {
					$html .= '<tr>';
						$html .= '<td'.(($show_edit_links)?' colspan="3"':' colspan="2"').'><hr style="color: #fef7f1; height: 1px;"></td>';
					$html .= '</tr>';
					$drew_hr = true;
				}
				
				$last_cat = trim($cur_cat[1]);
				$cat_url = 'https://'.$domain['hostname'].'/app.php#!catalog-shop--cat1-'.$cat_names_by_name[$last_cat];
				$html .= '<tr style="color:#839a0e; text-align:left; font-size:16px; font-weight:bold;">';
					$html .= '<th style="text-align:left;"'.(($show_edit_links)?' colspan="3"':' colspan="2"').'>'.$cur_cat[1].' | <a href="'.$cat_url.'" style="color:#5d5d5d; font-size:16px;">Shop Now</a></th>';
				$html .= '</tr>';
			}

			// new cat 2
			if($last_sub_cat != trim($cur_cat[2])) {
				// single row
				if (!$drew_hr) {
					$html .= '<tr>';
						$html .= '<td'.(($show_edit_links)?' colspan="3"':' colspan="2"').'><hr style="color: #fef7f1; height: 1px;"></td>';
					$html .= '</tr>';
				}				
				
				$last_sub_cat = trim($cur_cat[2]);
				$html .= '<tr style="color:#5d5d5d; text-align:left; font-size:14px; font-weight:bold;">';
					$html .= '<th'.(($show_edit_links)?' colspan="3"':' colspan="2"').'>'.$cur_cat[2].'</th>';
				$html .= '</tr>';
				$drew_hr = true;
			}
				
			$drew_hr = false;
			
			// double row
			/* $html .= '<tr>';
				$html .= '<td'.(($show_edit_links)?' colspan="3"':' colspan="2"').'><hr style="border: 1px solid #e5dbd1; height:5px;"></td>';
			$html .= '</tr>'; */
			
			foreach($prods as $prod)
			{
				// item remaining
				$html .= '<tr class="dt">';			
					$html .= '<td class="dt" style="color:#5d5d5d; font-size:11px;">';
						$html .= $prod['name'].' ('.$prod['single_unit'].') | ';
						$html .= '<span style="color:#5d5d5d; font-size:11px; font-style:italic;">'.$prod['org_name'].'</span>';
					$html .= '</td>';
					$html .= '<td class="dt" style="color:#5d5d5d; font-weight:bold; font-size:11px; text-align:right;">'.intval($prod['inventory']).' remaining</td>';
					
					if($show_edit_links)
					{
						$html .= '<td class="dt"><a class="btn" href="#!products-edit--prod_id-'.$prod['prod_id'].'"><i class="icon-edit" />Edit Product</a></td>';
					}
				$html .= '</tr>';
				
				
				// farm buynow
				$html .= '<tr style="color:#839a0e; text-align:left; font-family:Helvectica, Trebuchet MS, Arial">';
					$html .= '<td style="color:#5d5d5d; font-size:11px; font-style:italic;"></td>';
					$html .= '<td style="color:#5d5d5d; font-weight:bold; font-size:12px; text-align:right;"><a href="https://'.$domain['hostname'].'/app.php#!catalog-view_product--prod_id-'.$prod['prod_id'].'" style="color:#5d5d5d; font-weight:bold; text-decoration:underline;">Buy Now</a></td>';
				$html .= '</tr>';
				
				
				$has_prods = true;
			}
		}
		$html .='</table>';
		
		if($has_prods)
		{
			return $html;
		}
		else
		{
			return '';
		}
		
	}
}
?>