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
		
		core::load_library('mailchimp');
		$mc = new core_mailchimp();
		
		$html = $this->generate_html($core->data['domain_id']);
		$html = core::process_command('emails/handle_source',true,$html,array());
		
		$domain =  core::model('domains')->load($core->data['domain_id']);
		$template_id = $mc->get_template_id('Weekly Fresh Sheet',$core->data['domain_id']);
		$list_id     = $mc->get_list_id('Weekly Fresh Sheet');
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
				'html'=>$html,
				'html_MAIN'=>$html,
				'html_FOOTER'=>'',
				'html_SIDECOLUMN'=>'',
				'text'=>' ',
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
			$mc->campaignSendTest($camp_id,array('mike@localorb.it',$core->data['email']));
			core_ui::notification('test sent');
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


	function generate_html($domain_id,$show_edit_links=false)
	{
		global $core;
		$html = '<table class="table table-hover">';
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
				$prods_by_catid_hash[$new_key] = array();
				
			$prods_by_catid_hash[$new_key][] = $prod;
			
			$cats_to_lookup[] = intval($cat_ids[1]);
			$cats_to_lookup[] = intval($cat_ids[2]);
		}
		
		# next, lookup the names of all the categories in the list
		$cat_names = array();
		if(count($cats_to_lookup) > 0)
		{
			$cats = core::model('categories')->collection()->filter('cat_id','in',$cats_to_lookup);
			foreach($cats as $cat)
			{
				$cat_names[$cat['cat_id']] = $cat['cat_name'];
			}
		}
		
		# next, rebuild the product hash, this time using the category names as the key
		$prods_by_catname_hash = array();
		foreach($prods_by_catid_hash as $cat_ids => $prods)
		{
			$cat_ids = explode('-',$cat_ids);
			$new_key = $cat_names[$cat_ids[0]].' : '.$cat_names[$cat_ids[1]];
			$prods_by_catname_hash[$new_key] = $prods;
			
		}
		
		# finally, sorry the product hash by key
		ksort($prods_by_catname_hash);
		
		
		#echo('<pre>');
		#print_r($prods);
		
		
		
		
		
		$has_prods = false;
		$cur_cat = '';
		foreach($prods_by_catname_hash as $category => $prods)
		{
			$html .= '<tr class="'.$style.'">';
				$html .= '<th'.(($show_edit_links)?' colspan="2"':'').'>'.$category.'</th>';
				
			$html .= '</tr>';
			$style = false;
			foreach($prods as $prod)
			{
				$html .= '<tr class="dt'.$style.'">';
			
				$html .= '<td class="dt">'.$prod['name'].' ('.$prod['single_unit'].') from '.$prod['org_name'].' - '.intval($prod['inventory']).' remaining</td>';
				if($show_edit_links)
				{
					$html .= '<td class="dt"><a class="btn" href="#!products-edit--prod_id-'.$prod['prod_id'].'"><i class="icon-edit" />Edit Product</a></td>';
				}
				$html .= '</tr>';
				$style = (!$style);
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