<?php

class core_controller_newsletters extends core_controller
{
	function save_rules()
	{
		global $core;

		$rules = array();
		$rules[] = array('type'=>'min_length','name'=>'title','data1'=>2,'msg'=>'You must enter a newsletter Subject');
		$rules[] = array('type'=>'min_length','name'=>'header','data1'=>2,'msg'=>'You must enter a newsletter Header');

		if(lo3::is_admin() || (lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) > 1))
		{
			$rules[] = array('type'=>'is_int','name'=>'domain_id','msg'=>'You must select a Market');
			$rules[] = array('type'=>'not_equal_to','name'=>'domain_id','data1'=>0,'msg'=>'You must select a Market');
		}
		return new core_ruleset('nlForm',$rules);
	}

	function delete()
	{
		global $core;
		core::log('trying to delete');

		$news = core::model('newsletter_content')->load($core->data['cont_id']);
		if(!in_array($news['domain_id'],$core->session['domains_by_orgtype_id'][2]))
		{
			lo3::require_orgtype('admin');
		}
		else
		{
			lo3::require_orgtype('market');
		}
		$news->delete();

		core_datatable::js_reload('newsletters');
		core_ui::notification('newsletter deleted');
	}

	function update()
	{
		global $core;

		$core->dump_data();
		# make sure the MM is adding content to a managed hub
		if(lo3::is_market())
		{
			if(!in_array($core->data['domain_id'],$core->session['domains_by_orgtype_id'][2]))
			{
				lo3::require_orgtype('admin');
			}
		}
		else
		{
			lo3::require_orgtype('admin');
		}

		$recips = array();
		if($core->data['send_seller'] == 1)
			$recips[] = 1;
		if($core->data['send_buyer'] == 1)
			$recips[] = 2;
		$core->data['send_to_groups'] = implode(',',$recips);

		core::log(print_r($core->data,true));

		$nl = core::model('newsletter_content')->import_fields('cont_id','domain_id','title','header','body','send_buyer','send_seller','send_to_groups');
		$nl['is_draft'] = 0;
		$nl->save('nlForm');
		core::js("$('#img_upload_row').show();$('#img_msg_row').hide();");
		$core->data['cont_id'] = $nl['cont_id'];

		if($core->data['do_test'] == 1 || $core->data['do_send'] == 1)
		{
			$html = $this->generate_html($nl);
  		$market_manager = core::model('domains')->get_domain_info($nl['domain_id']);
			if($core->data['do_test'] == 1)
			{
				core_email::send("[TEST] ".$nl['title'],$core->data['test_email'],$html,array(),$market_manager['email'],$market_manager['name']);        
				core::log("Successfully sent test\n");
				core_ui::notification('test sent');
			}

			# if we're actually sending, we need to construct our segment rules
			if($core->data['do_send'] == 1)
			{
				$groups = array();
				if($core->data['send_buyer'] == 1)
					$groups[] = 0;
				if($core->data['send_seller'] == 1)
					$groups[] = 1;

				$customers = $this->customers($nl['domain_id'], $groups);
				$emails = array();
				foreach($customers as $customer) {
					$emails[] = $customer['email'];
				}
				core_email::send($emails,$html,array(),$market_manager['email'],$market_manager['name']);
				core::log("Successfully sent real campaign\n");
				core_ui::notification('newsletter sent');
			}
		}
		else
		{
			core_ui::notification($core->i18n('messages:generic_saved','newsletter'),false,($core->data['do_redirect'] != 1));
			if($core->data['do_redirect'] == 1)
				core::redirect('newsletters','list');
		}
	}

  function generate_html($newsletter)
  {
    global $core;
    $html = core_email::header($newsletter['domain_id']);
    $html .= '<h1>'.$newsletter['header'].'</h1>';

    # see if there's a header image. if there is, add it.
    list($has_image,$webpath,$filepath) = $newsletter->get_image();
    if($has_image) {
      $html .= '<div style="text-align: center;"><img src="http://'.core::model('domains')->get_value('hostname',$newsletter['domain_id']).''.$webpath.'" /></div><br />';
    }

    $html .= $newsletter['body'];
    $html .= core_email::footer("");
    return $html;
  }

	function save_image()
	{
		global $core;
		$cont_id = $core->data['cont_id'];
		core::load_library('image');

		$new = new core_image($_FILES['new_image']);
		$new->load_image();

		if (!$cont_id)
		{
			$newsletter_content = core::model('newsletter_content');
			$newsletter_content['is_draft'] = 1;
			$newsletter_content->save();
			//core::log(print_r($newsletter_content, true));
			$cont_id = $newsletter_content['cont_id'];
		}

		if($new->width > 600 || $new->height > 300)
		{
			exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">toolarge:done</body></html>');
		}

		$filepath = $core->paths['base'].'/../img/newsletters/'.$cont_id.'.' ;
		if(file_exists($filepath.'png'))
			unlink($filepath.'png');
		if(file_exists($filepath.'jpg'))
			unlink($filepath.'jpg');
		if(file_exists($filepath.'gif'))
			unlink($filepath.'gif');

		core::log('trying to move file to: '.$core->paths['base'].'/../img/newsletters/'.$cont_id.'.'.$new->extension);
		move_uploaded_file($new->path,$core->paths['base'].'/../img/newsletters/'.$cont_id.'.'.$new->extension);

		exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">'.$new->extension.':' . $cont_id . ':done</body></html>');

	}

	function remove_nlimage()
	{
		global $core;
		$imgpath = $core->paths['base'].'/../img/newsletters/'.$core->data['cont_id'];
		core::log('image path is: '.$imgpath);
		if(file_exists($imgpath.'.png'))
			unlink($imgpath.'.png');
		if(file_exists($imgpath.'.jpg'))
			unlink($imgpath.'.jpg');
		if(file_exists($imgpath.'.gif'))
			unlink($imgpath.'.gif');
		core::js("$('#newsletterImage').fadeOut('fast');");
		core::js("$('#removenlimage').fadeOut('fast');");
		core::deinit();
	}

  # Allow sell is an array of allowed values in organizations.allow_sell
  # 0 is buyer, 1 is seller
  function customers($domain_id, $allow_sell) {
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
      ->filter('customer_entity.send_newsletter', '=', 1)
      ->filter('domains.domain_id', '=', $domain_id)
      ->filter('customer_entity.allow_sell', 'IN', '['.implode(',', $allow_sell).']');
    return $customers;
  }
}


?>
