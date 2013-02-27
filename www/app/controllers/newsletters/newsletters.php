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

		# this line was used by mike to verify the mc key being used, ignore pleas
		#$nl['body'] = $core->config['mailchimp']['key'].$nl['body'];

		if($core->data['do_test'] == 1 || $core->data['do_send'] == 1)
		{
			core::load_library('mailchimp');
			$mc = new core_mailchimp();

			# get the plaintext body
			$content = new html2text($nl['body']);
			$content = $content->get_text();

			# see if there's a header image. if there is, add it.
			list($has_image,$webpath,$filepath) = $nl->get_image();
			if($has_image)
			{
				$body  = '<br /><div style="text-align: center;"><img src="http://'.core::model('domains')->get_value('hostname',$nl['domain_id']).''.$webpath.'" /></div><br />'.$nl['body'];
			}
			else
			{
				$body  = '<br />'.$nl['body'];
			}

			if($core->data['do_test'] == 1)
			{
				# create the campaign
				$domain =  core::model('domains')->load($core->data['domain_id']);
				$template_id = $mc->get_template_id('NewsletterTemplate',$core->data['domain_id']);
				$list_id     = $mc->get_list_id('Newsletter');
				$title       = 'newsletter-'.$nl['cont_id'].'-'.date('YmdHms');
				core::log('creating a newsletter with info: '.$title.':'.$template_id.':'.$list_id);

				$camp_id = $mc->api->campaignCreate(
					'regular',
					array(
						'subject'=>$nl['title'],
						'from_email'=>'service@localorb.it',
						'from_name'=>$domain['name'],
						'title'=>$title,
						'list_id'=>$list_id,
						'template_id'=>$template_id,
					),
					array(
						'html'=>$body,
						'html_MAIN'=>$body,
						'html_HEADER'=>$nl['header'],
						'html_FOOTER'=>'',
						'html_SIDECOLUMN'=>'',
						'text'=>$content,
					)
				);
				if ($mc->api->errorCode){
					core::log("Unable to Create New Campaign!");
					core::log("\n\tCode=".$mc->api->errorCode);
					core::log("\n\tMsg=".$mc->api->errorMessage."\n");
					core::deinit();
				} else {
					core::log("New Campaign ID:".$camp_id."\n");
				}

				# perform the test and delete the campaign
				$success = $mc->api->campaignSendTest($camp_id,array('mthorn@iqguys.com',$core->data['test_email']));
				core::log("success val: ".$success);
				if ($mc->api->errorCode){
					core::log("Unable to send test Campaign!");
					core::log("\n\tCode=".$mc->api->errorCode);
					core::log("\n\tMsg=".$mc->api->errorMessage."\n");
					core_ui::notification('test send failed: '.$mc->api->errorMessage);
				} else {
					core::log("Successfully sent test:".$camp_id."\n");
				}
				#	$mc->api->campaignDelete($camp_id);
				core_ui::notification('test sent');
			}

			# if we're actually sending, we need to construct our segment rules
			if($core->data['do_send'] == 1)
			{
				$groups = array();
				if($core->data['send_buyer'] == 1)
					$groups[] = 2;
				if($core->data['send_seller'] == 1)
					$groups[] = 1;


				$domain_id = intval($core->data['domain_id']);


				# always segment on domain_id
				$seg_opts = array(
					'match'=>'all',
					'conditions'=>array(
						array(
							'field'=>'DOMAIN_ID',
							'op'=>'eq',
							'value'=>$domain_id,
						),
					),
				);

				#only add a segmentation rule by account type if only one is checked
				if(count($groups) < 2)
				{
					$seg_opts['conditions'][] = array(
						'field'=>'ACC_TYPE',
						'op'=>'eq',
						'value'=>$groups[0],
					);
				}

				# create the campain now
				$camp_id = $mc->api->campaignCreate(
					'regular',
					array(
						'subject'=>$nl['title'],
						'from_email'=>'service@localorb.it',
						'from_name'=>'Local Orbit',
						'title'=>'newsletter-'.$nl['cont_id'].'-'.date('YmdHms'),
						'list_id'=>$mc->get_list_id('Newsletter'),
						'template_id'=>$mc->get_template_id('NewsletterTemplate',$domain_id),
					),
					array(
						'html'=>$body,
						'html_MAIN'=>$body,
						'html_HEADER'=>$nl['header'],
						'html_FOOTER'=>'',
						'html_SIDECOLUMN'=>'',
						'text'=>$content,
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

				#actually send now
				$mc->api->campaignSendNow($camp_id);
				if ($mc->api->errorCode){
					core::log("Unable to send real Campaign!");
					core::log("\n\tCode=".$mc->api->errorCode);
					core::log("\n\tMsg=".$mc->api->errorMessage."\n");
					core_ui::notification('newsletter send failed: '.$mc->api->errorMessage);
				} else {
					core::log("Successfully sent real campaign:".$camp_id."\n");
				}
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
}


?>
