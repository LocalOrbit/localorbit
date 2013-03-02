<?
	#core::log('show it: '.(print_r($_COOKIE['cookie'],true)));
	#echo('<h2>hereeeee: '.$core->session['login_note_viewed'].'/'.$core->session['org_id'].'</h2>');
	
	// reset to test  devannarbor-mi.localorb.it/release_news.php?has_seen_release_news=0
	if($core->config['stage'] == 'production')
	{
		
		if ($core->data["has_seen_release_news"] == 'yes') 
		{
			$user = core::model('customer_entity')->load($core->session['user_id']);
			$user['login_note_viewed'] = 1;
			$user->save();
			$core->session['login_note_viewed'] = 1;
				
			core::js('$("#releaseNewsModal").modal("hide");');
			core::deinit();
		}	
		else if ($core->data["news_remind_later"] == 'yes')
		{
			$core->session['login_note_viewed'] = 1;
				
			core::js('$("#releaseNewsModal").modal("hide");');
			core::deinit();
		}
		else if ($core->session['login_note_viewed']  != 1 && $core->session['org_id'] < 1286)
		{
			
			if(lo3::is_market())
			{
				$this->release_news__market();
			}
			else
			{
				$this->release_news__buyerseller();
			}
			core::js('$("#releaseNewsModal").modal();');
		}
	}
?>
	
