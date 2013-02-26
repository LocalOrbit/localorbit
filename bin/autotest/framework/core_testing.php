<?
global $core;
class core_testing
{
	function init($base_path,$core_path,$base_url,$app_path)
	{
		global $core;
		
		include($core_path);
		core::init($base_path);
		include(dirname(__FILE__).'/core_test.php');
		include(dirname(__FILE__).'/core_test_request.php');
		include(dirname(__FILE__).'/core_test_response.php');
		$core->config['test_path'] = $base_path . '/tests';
		$core->config['test_success_string'] = 'SUCCESS';
		$core->config['test_fail_string'] = 'FAIL   ';
		
		# curl options
		$core->config['curl_base_url'] = $base_url;
		$core->config['app_path']    = $app_path;
		$core->config['cookie_jar']  = '/tmp/cookie_jar.txt';
		$core->config['cookie_file'] = '/tmp/cookie_jar.txt';
		unlink($core->config['cookie_file']);
		ob_end_flush();
		$core->config['request_count'] = 0;
		
	}
	
	public static function get_test_list()
	{
		global $core;
		$files = array();
		if ($handle = opendir($core->config['test_path']))
		{
			while (false !== ($entry = readdir($handle)))
			{
				
				if(substr($entry,0,1) != '.')
				{
					$files[] = $entry;
				}
			}
		}
		asort($files);
		return $files;
	}
	
	public static function run()
	{
		global $core;
		$start = time();
		echo("running test list\n");
		$files = core_testing::get_test_list();
		$results = array();
		$fatal = false;
		$error = false;
		$continue = true;
		
		foreach($files  as $file)
		{
			if($continue)
			{
				echo(str_pad(str_replace('.php','',$file),50));
				
				# determine the test name, and run/instantiate it if it exists
				$test_info  = explode('-',$file);
				$class_name = 'core_test_'.$test_info[0];
				include($core->config['test_path'].'/'.$file);
				if(class_exists($class_name))
				{
					$obj = new $class_name();
					$result = $obj->run();
				}
				else
				{
					$result = array(
						'success'=>false,
						'msg'=>'Test not found',
						'fatal'=>false,
					);
				}
				
				$result = isset($result) ? $result : array('success' => true);
				# report state and store error status and results
				echo(($result['success'])?"[\033[01;33m".$core->config['test_success_string']."\033[0m]\n":"[\033[01;31m".$core->config['test_fail_string']."\033[0m]\n");
				$result['id'] = $test_info[0];
				$result['name'] = $file;
				if(!$result['success'])
					$error = true;
				$results[] = $result;
				
				# if this error is fatal, stop all processing and report
				if($result['fatal'])
				{
					$fatal = true;
					#echo("breaking due to fatal error\n");
					$continue = false;
				}
			}
		}
		
		echo("\n\n");
		$end = time();
		# ok, the test run is complete. report all results
		if($fatal)
		{
			echo("tests did NOT successfully complete. errors below:\n");
			core_testing::report_errors($results);
		}
		else if ($error)
		{
			echo("all tests ran, but errors occurred:\n");
			core_testing::report_errors($results);
		}
		else
		{
			echo("all tests completed successfully.\n");
		}
		
		exit($core->config['request_count']." requests performed in ".($end - $start)." seconds\n");
	}
	
	public static function report_errors($results)
	{
		foreach($results as $result)
		{
			if(!$result['success'])
			{
				echo(str_pad($result['id'].': ',12,' ',STR_PAD_LEFT));
				echo($result['msg']."\n");
			}
		}
	}
}

?>
