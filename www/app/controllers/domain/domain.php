
<?php 

class core_controller_domain extends core_controller
{
	function init()
	{
		global $core;
		
		//~ $allowed_controllers = array(
			//~ 'whitelabel'=>true,
			//~ 'registration'=>true,
			//~ 'whitelabel'=>true,
			//~ 'whitelabel'=>true,
			//~ 
		//~ );
		
		#core::log('request: '.$core->config['url-controller'].'/'.$core->config['url-method']);
		core::log('trying to find settings for domain '.$_SERVER['HTTP_HOST']);
		$core->config['domain'] = core::model('domains')->loadrow_by_hostname(strtolower($_SERVER['HTTP_HOST']));
		if(!is_numeric($core->config['domain']['domain_id']))
		{
			# we're on the deafult hostname, load this.
			if($core->config['hostname_prefix'].$core->config['session_domain'] == $_SERVER['HTTP_HOST'])
			{
				$core->config['domain'] = core::model('domains')->load(1);
			}
			else
			{
				core::log('on an unknown domain, issue redirect');
				core::js("location.href='https://".(($core->config['stage'] == 'production')?'www':$core->config['stage']).".localorb.it';");
				$core->config['domain'] = core::model('domains')->loadrow_by_hostname((($core->config['stage'] == 'production')?'':$core->config['stage']).$core->config['default_hostname']);
			}
		}
		
		# if this is a new session, just set their session domain to the 
		# current domain
		if(!is_numeric($core->session['home_domain_id']))
		{
			core::log('session home_domain_id is empty, setting session to be current domain');
			$core->session['home_domain_id'] = $core->config['domain']['domain_id'];
		}
		
		# don't do a redirect if this is an anon shopping hub:
		if($core->config['domain']['feature_allow_anonymous_shopping'] != 1)
		{
			
			if(!is_array($core->session['all_domains']))
				$core->session['all_domains'] = array($core->config['domain']['domain_id']);
		
			# redirect if not on correct hub
			if(!in_array($core->config['domain']['domain_id'],$core->session['all_domains'])
				&& ($core->config['url-controller'] != 'market' && $core->config['url-controller'] != 'login_info') 
				&& ($core->config['url-controller'] != 'navstate' && $core->config['url-controller'] != 'left_hub_info') 
				&& ($core->config['url-controller'] != 'whitelabel' && $core->config['url-controller'] != 'auth') 
				&& ($core->config['url-controller'] != 'registration' && $core->config['url-controller'] != 'invite')
				&& ($core->config['url-controller'] != 'registration' && $core->config['url-controller'] != 'process_invite') 
				&& !lo3::is_admin()
			)
			{
				core::log('currently on '.$core->config['domain']['domain_id']);
				core::log('all domains: '.implode(',',$core->session['all_domains']));
				core::log('session domain does not match domain loaded. redirecting');
				$real_hub = core::model('domains')->load($core->session['home_domain_id']);
				core::log('request info '.print_r($_REQUEST,true));
				#core::log(print_r($_SERVER,true));
				
				$url = ''.$_REQUEST['_requestor_url'];
				if(strpos($url,'http') === false)
				{
					$url = 'https://'.$_SERVER['HTTP_HOST'].'/'.$url;
				}
				
				core::log("new host is: ".$real_hub['hostname']);
				core::log("looking for ".$_SERVER['HTTP_HOST']);
				$url = str_replace($_SERVER['HTTP_HOST'],$real_hub['hostname'],$url);
				core::log('new url: '.$url);
				#core::js("alert('need to redirect to new url: ".$url."');");
				core::js('location.href=\''.$url.'\';');
				#core::log('here');
				#exit();
				core::deinit();
			}
		}

		core::log('loaded '.$core->config['domain']['domain_id']);
		core::log('session is '.$core->session['home_domain_id']);
		
		#core::log('domain info: '.print_r($core->config['domain'],true));
		#core::replace('tagline',$core->config['stage']);
		
	}
	
}

?>