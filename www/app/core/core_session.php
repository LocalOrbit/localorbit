<?php

class core_session
{
	public static function init()
	{
		global $core;
		
		$do_session_create = false;
		
		core::log('starting session: '.$core->config['session_name'].'/'.$core->config['session_domain']);
		session_name($core->config['session_name']);
		session_set_cookie_params(0, '/', $core->config['session_domain']);
		session_start();
		core::log('session id: '.session_id());
		ini_set('session.gc_maxlifetime',$core->config['session_time']);
		
		if(!isset($_SESSION['core']))
		{
			$_SESSION['core'] = array();
			$do_session_create = true;
		}
		
		if(!is_array($_SESSION['core']))
		{
			$_SESSION['core'] = array();
			$do_session_create = true;
		}
		
		
		if(!isset($_SESSION['core']['datatables']) || !is_array($_SESSION['core']['datatables']))
		{
			$_SESSION['core']['datatables'] = array();
		}
		
		
		$core->session =& $_SESSION['core'];
		#core::log('data table settings: '.print_r($core->session['datatables'],true));
		
		# update some misc vars
		if(isset($core->data['_browserX']))
			$core->session['browser_x'] = $core->data['_browserX'];
		if(isset($core->data['_browserY']))
			$core->session['browser_y'] = $core->data['_browserY'];
		
		# set some defaults
		if(!isset($core->session['language']))
			$core->session['language'] = $core->config['default_language'];
		if(!isset($core->session['user_id']))
			$core->session['user_id'] = $core->config['default_user_id'];
		if(!is_numeric($core->session['user_id']))
			$core->session['user_id'] = $core->config['default_user_id'];

		# only bother to determine some vars once
		if(!isset($core->session['time_offset']))
			core_session::determine_time_offset();
		#if(!isset($core->session['browser']))
			core_session::determine_browser();
		
		# parse the nav state

		if(!isset($core->data['_navState']))
			$core->data['_navState'] = '';
		
		core::log('parsing current navState: '.$core->data['_navState']);
		if($core->data['_navState'] != '')
		{
			
			$nav_state = explode('|',$core->data['_navState']);
			for ($i = 0; $i < count($nav_state); $i++)
			{
				$nav_state[$i] = explode(':',$nav_state[$i]);
				$core->config['current_navstate'][$nav_state[$i][0]] = $nav_state[$i][1];
			}
		}
		
		# unset all passed vars to cleanup $core->data dumps
		unset($core->data['_browserX']);
		unset($core->data['_browserY']);
		unset($core->data['_os']);
		unset($core->data['_plugins']);
		unset($core->data['_reqtime']);
		unset($core->data['_navState']);
		#core::log('checking to make sure coredata is clean: '.print_r($core->data,true));
		
		if(!isset($core->session['browser_x']))
			$core->session['browser_x'] = 0;
		if(!isset($core->session['browser_y']))
			$core->session['browser_y'] = 0;

		core::log(
			'session up: '.
			$core->session['user_id'].'/'.
			$core->session['time_offset'].'/'.
			$core->session['browser'].':'.
			$core->session['platform'].'/'.
			$core->session['os'].'/'.
			$core->session['browser_x'].':'.$core->session['browser_y']
		);
		core_session::handle_id_cookie(true);
		
		core::log('current navstate: '.str_replace("\n",'',print_r($core->config['current_navstate'],true)));
		
		# only run this if this is the first time the session has been started
		if($do_session_create)
			core::process_command_list('session-create');
		
		# always run these 
		core::process_command_list('session-init');
	}
	
	public static function write_id_cookie()
	{
		global $core;
		# generate teh new cookie text. user id must be part of the hash
		$random_num	= rand(0,1000000);
		#core::log('random number is '.$random_num);
		$random_num = hash($core->config['hash_algo'],'user_id'.$random_num);
		#core::log('random number hashed is '.$random_num);
		$key = $core->session['user_id'].':';
		$key .= $random_num.':';
		$key .= hash(
			$core->config['hash_algo'],
			$core->session['user_id'].'-'.$core->config['crypt_key'].'-'.$random_num
		);
		#core::log('new cookie is '.$key);
		#core::log('cookies are currently '.print_r($_COOKIE,true));
		#core::log('all config: '.print_r($core->paths,true));
		#unset($_COOKIE['core-user-id']);
		setcookie('core-user-id',$key,$core->config['time'] * 2,'',$core->paths['domain']);
		setcookie('core-user-id',$key);
		#core::log('cookies are now '.print_r($_COOKIE,true));
	}
	
	public static function handle_id_cookie($force_set=false)
	{
		global $core;
		#core::log('id cookie handler called');
		
		# if there's already a user id cookie, examine it and use it if necessary
		if(isset($_COOKIE['core-user-id']))
		{
			core::log('id cookie: '.$_COOKIE['core-user-id']);
			$cookie = explode(':',$_COOKIE['core-user-id']);
			
			# we only need to try to auth if the cookie user id does NOT equal the current user id
			if($cookie[0] == $core->session['user_id'])
			{
				core::log('attempting to use cookie to login: '.$core->session['user_id'].'/'.$cookie[0]);
				
				# first, verify the authenticity of the cookie
				$verify = hash(
					$core->config['hash_algo'],
					$cookie[0].'-'.$core->config['crypt_key'].'-'.$cookie[1]
				);
				
				# if this is a valid cookie, then we should try to login
				if($verify == $cookie[2])
				{
					core::log('this cookie is a valid login cookie for user '.$cookie[0]);
					
					# see if there is a cookie_auth_command defined. if there is, use it
					if($core->config['cookie_auth_command'] != '')
					{
						core::process_command($core->config['cookie_auth_command'],$cookie[0]);
					}
					# otherwise just set the user_id and move on
					else
					{
						$core->session['user_id'] = $cookie[0];
					}
				}
				else
				{
					core::log('this cookie is NOT a valid login cookie for user '.$cookie[0].', reissuing');
					core_session::write_id_cookie();
				}
				
			}
		} 
		else
		{
			core_session::write_id_cookie();
		}
	}
	
	public static function deinit()
	{
		core::process_command_list('session-deinit');
	}
	
	public static function determine_time_offset()
	{
		global $core;
		core::log('req time is: '.$core->data['_reqtime']);
		core::log('servtime is: '.$core->config['time']);
		if(!isset($core->data['_reqtime']))
		{
			$core->data['_reqtime'] = time();
		}
		$diff = round(($core->data['_reqtime'] - $core->config['time']) / 3600);
		core::log('difftime is: '.$diff);
		core::log('human readable: '.date('Y-m-d H:i:s',$core->data['_reqtime']));
		$core->session['time_offset'] = $diff * 3600;
		core::log('final offset is: '.$core->session['time_offset']);
	}
	
	public static function determine_browser()
	{
		global $core;
		
		if(!isset($_SERVER['HTTP_USER_AGENT']))
			$_SERVER['HTTP_USER_AGENT'] = 'apache';
		
		if(!isset($core->data['_os']))
			$core->data['_os'] = '';
			
		#core::log('checking browser: '.$_SERVER['HTTP_USER_AGENT']);
		#core::log('os detected: '.$core->data['_os']);
		# setup defaults
		$browser = '';
		$platform = '';
		$os = '';
		$possible_plugins = array(
			'java'=>false,
			'flash'=>false,
		);
		
		# determine plugins
		if(!isset($core->data['_plugins']))
			$core->data['_plugins'] = '';
		
		$plugins = explode(',',$core->data['_plugins']);
		for($i=0;$i<count($plugins);$i++)
		{
			if(strpos($plugins[$i],'Flash') !== false)
			{
				$possible_plugins['flash'] = true;
			}
			if(strpos($plugins[$i],'Iced') !== false)
			{
				$possible_plugins['java'] = true;
			}
			if(strpos($plugins[$i],'Java') !== false)
			{
				$possible_plugins['java'] = true;
			}
		}
		
		# detect OS
		$core->data['_os'] = strtolower($core->data['_os']);
		if(strpos($core->data['_os'],'android') !== false)
		{
			$os = 'android';
		}
		else if(strpos($core->data['_os'],'linux') !== false)
		{
			$os = 'linux';
		}
		else if(strpos($core->data['_os'],'win') !== false)
		{
			$os = 'windows';
		}
		else if(strpos($core->data['_os'],'mac') !== false)
		{
			$os = 'osx';
		}
		else if($core->data['_os'] == 'ipad')
		{
			$os = 'ios';
			$platform = 'tablet';
		}
		else
		{
			$os = 'unknown';
		}

		# determine platform and rendering engine
		if(strpos($_SERVER['HTTP_USER_AGENT'],'WebKit') !== false)
		{
			$browser = 'webkit';
			if(
				strpos($_SERVER['HTTP_USER_AGENT'],'Android') !== false
				|| 
				strpos($_SERVER['HTTP_USER_AGENT'],'iPhone') !== false
				|| 
				strpos($_SERVER['HTTP_USER_AGENT'],'iPod') !== false
			)
			{
				$os = 'ios';
				$platform = 'mobile';
			}
			else if($platform == 'tablet')
			{
			}
			else
			{
				$platform = 'desktop';
			}
		}
		else if(strpos($_SERVER['HTTP_USER_AGENT'],'Gecko') !== false)
		{
			$browser = 'gecko';
			$platform = 'desktop';
		}
		else if(strpos($_SERVER['HTTP_USER_AGENT'],'Trident') !== false)
		{
			$browser = 'trident';
			if(strpos($_SERVER['HTTP_USER_AGENT'],'Windows Phone OS') !== false)
			{
				$platform = 'mobile';
			}
			else
			{
				$platform = 'desktop';
			}
		}
		else if(strpos($_SERVER['HTTP_USER_AGENT'],'Presto') !== false)
		{
			$browser = 'presto';
			if(strpos($_SERVER['HTTP_USER_AGENT'],'Opera Mobi') !== false)
			{
				$platform = 'mobile';
			}
			else
			{
				$platform = 'desktop';
			}
		}
		
		# write data to session
		$core->session['browser']  = $browser;
		$core->session['platform'] = $platform;
		$core->session['os'] = $os;
		$core->session['plugins'] = $possible_plugins;
	}
}

?>
