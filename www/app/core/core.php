<?php
if(!defined('__CORE_HTML_OUTPUT__'))
{
	define('__CORE_AJAX_OUTPUT__',true);
}
if(!defined('__CORE_ERROR_OUTPUT__'))
{
	define('__CORE_ERROR_OUTPUT__','json');
}



class core
{
	function handle_error($errnbr,$error_string,$err_file,$err_line,$err_context)
	{
		#exit(__CORE_ERROR_OUTPUT__);
		if(__CORE_ERROR_OUTPUT__ == 'jsdfson')
		{
			core::clear_response();
			ob_clean();
			core_ui::popup('','','<h1>Error '.$errnbr.'</h1>:'.$error_string.'<br /><i>'.$err_file.', line '.$err_line.'</i>','close');
			core::deinit();
		}
		if(__CORE_ERROR_OUTPUT__ == 'exit')
		{
			exit($err_file.':'.$err_line.' - '.$error_string."\n");
		}
	}
	
	function __construct($base_path)
	{
		ob_start();
		date_default_timezone_set(timezone_name_from_abbr('UTC'));
		#exit('status: '.__CORE_AJAX_OUTPUT__);
		
		# setup some basic properties
		$this->data =& $_REQUEST;
		
		$this->config = array(
			'no_base64'=>$_REQUEST['no_base64'],
			'app_page'=>'index.php',
			'page'=>'default',
			'layout'=>'default',
			'stage'=>'production',
			'default_user_id'=>0,
			'default_language'=>'en-us',
			'session_time'=>1800,
			
			'log_types'=>array('default','sql','error'),
			'log_handles'=>array(),
			
			'navstate_command'=>'',
			'navstate'=>array(),
			'current_navstate'=>array(),
			
			'cookie_auth_command'=>'',
			'cookie_auth_autowrite'=>false,
			
			'title_prefix'=>'',
			'title_suffix'=>'',
			
			# datatable related stuffs
			'datatables'=>array(
				'size_default'=>10,
				'size_options'=>array(10,50,100,),
				'size_allow_all'=>true,
				'render_page_arrows'=>true,
				'render_page_select'=>true,
				'render_resizer'=>true,
				'render_exporter'=>true,
				'write_to_session'=>true,
				'render_filter_expander'=>true,
			),
			
			'hooks'=>array(
				'phpmailer_onsend'=>'',
			),

			
			# formats for various output
			'formats'=>array(
				'dates'=>array(
					'db'=>'Y-m-d H:i:s',
					'long'=>'Y-m-d H:i:s',
					'short'=>'Y-m-d',
					'jsshort'=>'Y-m-d',
					'time'=>'H:i:s',
					'us-time'=>'g:i a',
				),
			),
			
			# push into this array the path to any additional libs that should 
			# be loaded every time. The path should be relative to core.php
			'includes'=>array(),


			#  these control the strengh/algo of the misc core_crypto functions
			'hash_algo'=>'sha512',
			'hash_salt_length'=>32,
			'crypt_algo'=>'MCRYPT_RIJNDAEL_256',
			'crypt_key'=>'coreframeworkisbest',
			'password_characters'=>'0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
			
			'command-lists'=>array(
				'pre-request'=>array(),
				'main'=>array(),
				'post-request'=>array(),
				
				# these are secondary lists used to add hooks in particular situations
				# they will mostly be empty
				'session-create'=>array(),
				'session-init'=>array(),
				'session-deinit'=>array(),
				'session-destroy'=>array(),
			),
			'time'=>time(),
			'microtime'=>microtime(true),
			
			'payments'=>array(
				'paypal'=>array(),
				'authorize'=>array(),
			),
			
			'error_ui_msg'=>'An error has occured. Our technical team has been notified. We apologize for the inconvenience',
		);
		
		$this->response=array(
			'append'=>array(),
			'replace'=>array(),
			'js'=>'',
			'title'=>'',
			'description'=>'',
			'keywords'=>'',
		);
		
		# determine current command:
		if(isset($_SERVER['ORIG_PATH_INFO']))
			$command = $_SERVER['ORIG_PATH_INFO'];
		else
			$command = $_SERVER['PATH_INFO'];
		
		
		# there's two possible ways we got to here:
		#	1: google bot figurign out ajax urls
		#	2: ajax requests from a real brwose
		#	
		
		# do 1: first:
		if(isset($_REQUEST['_escaped_fragment_']))
		{
			$command_array = explode('-',$_REQUEST['_escaped_fragment_']);
			$this->config['url-controller'] = $command_array[0];
			$this->config['url-method'] = $command_array[1];
			$this->config['command-lists']['main'][$command_array[0].'/'.$command_array[1]] = true;
			#print_r($command_array);
			#exit();
		}
		else
		{
			# pick apart the path and figure out which controller
			# to run for this request.
			$command_array = explode('/',$command);
			array_shift($command_array);

			$this->config['url-controller'] = $command_array[0];
			$this->config['url-method'] = $command_array[1];
			#exit('url method is: '.$this->config['url-controller'].'/'.$this->config['url-method']);
			$this->config['command-lists']['main'][$command_array[0].'/'.$command_array[1]] = true;
		}
		
		# continue shifting the array and use all additional values
		# as $_REQUEST params
		
		# build path info
		$this->paths = array();
		$this->paths['libraries'] = dirname(__FILE__);
		$this->paths['base'] = str_replace('\core','',str_replace('/core','',$this->paths['libraries']));
		$this->paths['logs']      = $this->paths['base'].'/../../logs';
		$this->paths['web']       = str_replace('/index.php','',$_SERVER['SCRIPT_NAME']);
		$this->paths['domain']    = strtolower($_SERVER['HTTP_HOST']);	
		$core->config['session_domain'] = $this->paths['domain'];
		$core->config['session_name']   = 'core_framework';
		
		$this->positions['base']  = 'http://'.$this->paths['domain'].'/core/';
		
		$this->i18n = array();
		
		# setup some db stuff
		$this->config['db'] = array(
			'type'=>'',
			'hostname'=>'',
			'username'=>'',
			'password'=>'',
			'database'=>'',
			'aliases' =>array(),
		);	
	}

	public static function select_nav($navs)
	{
		if (lo3::is_admin()) 
		{
			$index = 0;
		} 
		else if (lo3::is_market()) 
		{
			$index = 1;
		} 
		else if (lo3::is_seller()) 
		{
			$index = 2;
		} 
		else
		{
			$index = 3;
		}

		return $navs[$index];
	}
	
	public static function ensure_navstate($states,$nav1Highlight='',$nav2Highlight='')
	{
		global $core;
		foreach($states as $pos=>$state)
		{
			$core->config['navstate'][$pos] = $state;
		}
		if (is_array($nav1Highlight))
		{
			$nav1Highlight = core::select_nav($nav1Highlight);
		}
		if (is_array($nav2Highlight))
		{
			$nav2Highlight = core::select_nav($nav2Highlight);
		}
		core::js('core.resetNavHighlight();');
		if($nav1Highlight != '')
		{
			core::js('core.navHighlight(1,\''.$nav1Highlight.'\');');
		}
		if($nav2Highlight != '')
		{
			core::js('core.navHighlight(2,\''.$nav2Highlight.'\');');
		}
	}
	
	public static function write_navstate()
	{
		global $core;
		$return = array();
		foreach($core->config['navstate'] as $position=>$state)
		#for ($i = 0; $i < count($core->config['navstate']); $i++)
		{
			core::js('core.navState[\''.$position.'\']=\''.$state.'\';');
			#$return[] = "'".$position."':'".$state."'";
		}
		
		#core::js('core.navState=['.implode($return).'];');
	}
	
	# this starts up the core framework
	public static function init($base_path=null)
	{
		global $core;
		$core = new core($base_path);
	
		# now include the app's config
		include($core->paths['libraries'].'/../config.php');
		
		# load all base libraries
		include($core->paths['libraries'].'/core_form.php');
		include($core->paths['libraries'].'/core_logger.php');
		include($core->paths['libraries'].'/core_db.php');
		include($core->paths['libraries'].'/core_controller.php');
		include($core->paths['libraries'].'/core_session.php');
		include($core->paths['libraries'].'/core_model.php');
		include($core->paths['libraries'].'/core_model_field.php');
		include($core->paths['libraries'].'/core_format.php');
		include($core->paths['libraries'].'/core_collection.php');
		include($core->paths['libraries'].'/core_ui.php');
		include($core->paths['libraries'].'/core_html.php');
		include($core->paths['libraries'].'/core_ruleset.php');
		include($core->paths['libraries'].'/core_i18n.php');
		include($core->paths['libraries'].'/core_datatable.php');
		include($core->paths['libraries'].'/core_datacolumn.php');
		include($core->paths['libraries'].'/core_datatable_filter.php');
		
		# include any additional libraries as specified in config.php
		foreach($core->config['includes'] as $file)
		{
			include($core->paths['libraries'].$file);
		}
		
		#if(!defined('__NO_OVERRIDE_ERROR__'))
		#	set_error_handler(array($core,'handle_error'),E_ALL & ~(E_STRICT|E_NOTICE));
		
		# init things
		core_logger::init();
		core_db::init();
		core_session::init();
		core_i18n::init();
		core::log('fully started up: '.$core->config['db']['database']);

		if(isset($core->session['postauth_url']))
		{
			core::log('found a postauth url in the sessioN: '. $core->session['postauth_url']);
			$core->config['postauth_url'] = $core->session['postauth_url'];
		}
	}
	
	# this can act as a frontend for loading secondary libraries. 
	public static function load_library($alias)
	{
		global $core;
		switch($alias)
		{
			case 'core_phpmailer':
				if(!class_exists('core_phpmailer'))
				{
					include($core->paths['libraries'].'/core_phpmailer.php');
					include($core->paths['libraries'].'/core_phpmailer_pop3.php');
					include($core->paths['libraries'].'/core_phpmailer_smtp.php');
				}
				break;
			case 'pdf':
				if(!class_exists('core_pdf'))
				{
					include($core->paths['libraries'].'/core_pdf.php');
				}
				break;
			case 'image':
				if(!class_exists('core_image'))
				{
					include($core->paths['libraries'].'/core_image.php');
				}
				break;
			case 'html2text':
				if(!class_exists('html2text'))
				{
					include($core->paths['libraries'].'/class.html2text.inc');
				}
				break;
			case 'payments':
				if(!class_exists('core_payments'))
				{
					include($core->paths['libraries'].'/core_payments.php');
				}
				break;
			case 'mailchimp':
				core::load_library('html2text');
				if(!class_exists('core_mailchimp'))
				{
					if($core->config['stage'] == 'production')
						include($core->paths['libraries'].'/MCAPI.class.mini.php');
					else
						include($core->paths['libraries'].'/MCAPI.class.php');
					include($core->paths['libraries'].'/core_mailchimp.php');
				}
				break;
			case 'crypto':
				if(!class_exists('core_crypto'))
				{
					include($core->paths['libraries'].'/core_crypto.php');
				}
				break;
			default:
				core_ui::notification('Unknown library: '.$alias);
				break;
		}
	}
	
	# This is the magic that does it all.
	public static function process()
	{
		global $core;
		try
		{
			core::process_command_list('pre-request');
			core::process_command_list('main');
			core::process_command_list('post-request');
			
			# this functionality is used to set/maintain/ensure the navigation state
			# between requests
			if($core->config['navstate_command'] != '')
			{
				core::process_command($core->config['navstate_command']);
				core::write_navstate();
			}
			core::deinit();
		}
		catch(Exception $e)
		{
			echo($e->getMessage());
		}
	}

	# all response data is base64_encoded to handle escaping. This does increase the size of the response, 
	# but makes things SO SO Much more reliable.
	function encode_output()
	{
		global $core;
		
		if($core->config['no_base64'] != 'true')
		{
			foreach($core->response['replace'] as $key=>$value)
				$core->response['replace'][$key] = base64_encode($value);
			foreach($core->response['append'] as $key=>$value)
				$core->response['append'][$key] = base64_encode($value);
				
			$core->response['js'] = base64_encode($core->response['js']);
			$core->response['title'] = base64_encode($core->response['title']);
			$core->response['description'] = base64_encode($core->response['description']);
			$core->response['keywords'] = base64_encode($core->response['keywords']);
		}
		
		return json_encode($core->response);
	}
	
	# shuts down the framework
	public static function deinit($do_output=true)
	{
		global $core;
		if($do_output)
		{	
			if(__CORE_AJAX_OUTPUT__)
			{
				ob_clean();
				#header('Content-type: application/json');
				#file_put_contents('/tmp/json_data.txt',$core->encode_output());
				echo($core->encode_output());
			}
			else
			{
				echo('<html><head>');
				echo('<title>'.$core->response['title'].'</title>');
				echo('<meta name="description" content="'.$core->response['description'].'" />');
				echo('<meta name="keywords" content="'.$core->response['keywords'].'" />');
				echo('</head><body>');
				foreach($core->response['replace'] as $key=>$value)
					echo('<div id="area_'.$key.'">'.$value.'</div>');
				foreach($core->response['append'] as $key=>$value)
					echo('<div id="area_'.$key.'">'.$value.'</div>');
				
				echo('</body></html>');
			}
		}

		$end = microtime(true);
		core::log('total request time: '.($end - $core->config['microtime']));
		core_session::deinit();
		core_i18n::deinit();
		core_logger::deinit();
		core_db::deinit();
		exit();
	}
	
	public static function head($title,$description,$keywords=null)
	{
		global $core;
		$core->response['title'] = $core->config['title_prefix'].$title.$core->config['title_suffix'];
		if(!is_null($description))
			$core->response['description'] = $description;
		if(!is_null($keywords))
			$core->response['keywords'] = $keywords;
		return true;
	}
	
	# used to log to a log file.
	public static function log($string,$type='default')
	{
		core_logger::write($string,$type);
	}
	
	# used to dump the submitted data to the log
	public static function log_data($src=null,$type='default')
	{
		global $core;
		if(is_null($src))
			$src = $core->data;
		core_logger::write(print_r($src,true),$type);
	}
	
	# this function is used to implement smart phrases. Smart phrases can contain embedded parameters.
	# the simple example is implementing an internationalized pager which displays both the current page,
	# and the maximum page. In some languages, the page # might come first, but in others, it might come second
	# A smart phrase will let you embed them in a particular order.
	public static function i18n($phrase)
	{
		global $core;
		if(isset($core->i18n[$phrase]))
			$phrase = $core->i18n[$phrase];
		
		$args = func_get_args();
		$num_args = count($args);
		for($i=1;$i<$num_args;$i++)
		{
			$phrase = str_replace('{'.$i.'}',$args[$i],$phrase);
		}
		return $phrase;
	}
	
	public static function process_command_list($list)
	{
		global $core;
		foreach($core->config['command-lists'][$list] as $command=>$do)
		{
			if($do)
			{
				core::process_command($command);
			}
		}
	}
	
	public static function clear_response($type='',$area='')
	{
		global $core;
		if($type == '')
		{
			ob_get_clean();
			$core->response['append'] = array();
			$core->response['replace'] = array();
			$core->response['js'] = '';
		}
		else
		{
			if($area == '')
			{
				$core->response[$type] = ($type == 'js')?'':array();
			}
			else
			{
				$core->response[$type][$area] = '';
			}
		}
	}
	
	# this takes all the content currently in the output buffer, and stores it in the response json in such a way
	# that the content will append all content currently in the html element with the id attribute equal to the 
	# value of the first parameter passed when the json is returned to the client
	public static function append($pos='center',$text=null)
	{
		global $core;
		if(!isset($core->response['append'][$pos]))
			$core->response['append'][$pos] = '';
		
		if(is_null($text))
			$core->response['append'][$pos] .= ob_get_clean();
		else
			$core->response['append'][$pos] .= $text;
		ob_start();
	}

	# this takes all the content currently in the output buffer, and stores it in the response json in such a way
	# that the content will replace all content currently in the html element with the id attribute equal to the 
	# value of the first parameter passed when the json is returned to the client
	public static function replace($pos='center',$text=null)
	{
		global $core;
		
		if(!isset($core->response['replace'][$pos]))
			$core->response['replace'][$pos] = '';
		
		if(is_null($text)){
			$core->response['replace'][$pos] .= ob_get_clean();
			ob_start();
		}
		else
			$core->response['replace'][$pos] .= $text;
	}
	
	# adds some js to the response
	public static function js($js='')
	{
		global $core;
		if($js!='')
			$core->response['js'] .= $js;
		else{
			$core->response['js'] .= ob_get_clean();
			ob_start();
		}
	}
	
	public static function getclear_position($pos,$type='replace')
	{
		global $core;
		if(isset($core->response[$type][$pos]))
		{
			$out = $core->response[$type][$pos];
			unset($core->response[$type][$pos]);
			return $out;
		}
		else
			return '';
	}
	
	public static function controller($controller)
	{
		global $core;
		
		$class_name = 'core_controller_'.$controller;
		
		$base = $core->paths['base'].'/controllers/'.$controller.'/';
		if(!class_exists($class_name))
		{
			$path = $base.$controller.'.php';
			if(file_exists($path))
			{
				include($path);
			}
		}
		
		if(class_exists($class_name))
		{
			$controller = new $class_name($base);
		}
		else
		{
			$controller = new core_controller($base);
		}
		return $controller;
	}
		
	public static function process_command($command,$return_data=false)
	{
		global $core;
		core::log('running: '.$command);
		$command = explode('/',$command);
		$controller = $command[0];
		$method     = $command[1];
		
		# handle parameters, only pass the 3rd parameter on, as one big array
		$p = func_get_args();
		array_shift($p);
		array_shift($p);
		
		$controller = core::controller($controller);
		$data = $controller->$method($p[0],$p[1],$p[2],$p[3],$p[4],$p[5],$p[6],$p[7],$p[8],$p[9],$p[10],$p[11]);
		
		if(!$return_data)
		{
			$new_content = trim(ob_get_clean());
			if($new_content != '')
			{
				if (array_key_exists('replace', $core->response) && array_key_exists('center', $core->response['replace']))
				{
					$core->response['replace']['center'] .= $new_content;
				}
				else
				{
					$core->response['replace']['center'] = $new_content;
				}
				 
			}
			ob_start();
		}
		else
		{
			return $data;
		}
		#core::position();
	}
	
	# gets the model for table, including handling the base table which defines the actual fields
	public static function model($model)
	{
		global $core;
		
		$main_class = 'core_model_'.$model;
		$base_class = 'core_model_base_'.$model;
		
		$main_file = $core->paths['base'].'/models/'.$model.'.php';
		$base_file = $core->paths['base'].'/models/base/'.$model.'.php';
		
		if(!class_exists($base_class))
		{
			if(file_exists($base_file))
			{
				include($base_file);
			}
		}
		if(!class_exists($main_class))
		{
			if(file_exists($main_file))
			{
				include($main_file);
			}
		}
		
		$model = new $main_class($model);
		return $model;
	}

	public static function hide_dashboard () {
		core::js("$('#dashboardnav').empty();");
	}
	
	# this can be used by secondary controllers to determine which page you're on
	# ex: use this in a navigation controler to determine which link to highlight
	function current($controller,$method=null,$key=null,$val=null)
	{
		global $core;
		
		if(!is_null($key))
		{
			return (
				$core->config['url-controller'] == $controller && 
				$core->config['url-method'] == $method &&
				$_REQUEST[$key] == $val
			);
		}
		else if(!is_null($method))
		{
			return (
				$core->config['url-controller'] == $controller && 
				$core->config['url-method'] == $method
			);
		}
		else
		{
			return ($core->config['url-controller'] == $controller);
		}
	}
	
	function redirect($controller,$method,$data=array())
	{
		$href= '#!'.$controller.'-'.$method.'-';
		$has_data = false;
		foreach($data as $key=>$value)
		{
			$href .= '-'.$key.'-'.$value;
			$has_data = true;
		}
		
		if(!$has_data)
		{
			$href .= '-';
		}
		
		$js = 'location.href=\''.$href.'\'';
		$js .= ';core.go(\''.$href.'\');';
		core::log($js);
		core::js($js);
		core::deinit();
	}
	
	function dump_data()
	{
		global $core;
		$out = '$'."data = array(\n";
		foreach($core->data as $key=>$value)
		{
			if($key != '')
				$out .= "\t'$key'=>'".addslashes($value)."',\n";
		}
		$out .= ");\n";
		core::log($out);
	}
}

?>
