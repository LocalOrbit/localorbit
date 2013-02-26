<?

class core_test_request
{
	public static function do_request($url,$data=array(),$referrer='app.php',$override_path=false)
	{
		global $core;
		
		if($override_path)
		{
			$final_url = $core->config['curl_base_url'].$url;
		}
		else
		{
			$final_url = $core->config['curl_base_url'].$core->config['app_path'].$url;
		}
		#echo('url: '.$core->config['curl_base_url'].$url."\n");
		$core->config['curl'] = curl_init();
		curl_setopt($core->config['curl'], CURLOPT_URL, $final_url);
		curl_setopt($core->config['curl'], CURLOPT_RETURNTRANSFER, true);
		curl_setopt($core->config['curl'], CURLOPT_COOKIEJAR,$core->config['cookie_jar']);
		curl_setopt($core->config['curl'], CURLOPT_COOKIEFILE,$core->config['cookie_file']);
		curl_setopt($core->config['curl'], CURLOPT_POST, true);
		curl_setopt($core->config['curl'], CURLOPT_POSTFIELDS, $data);
		curl_setopt($core->config['curl'], CURLOPT_FOLLOWLOCATION, true);
		curl_setopt($core->config['curl'], CURLOPT_REFERER,$referrer);
		curl_setopt($core->config['curl'], CURLOPT_HEADER,true);
		$response = new core_test_response(curl_exec($core->config['curl']));
		curl_close($core->config['curl']);
		$core->config['request_count']++;
		return $response;
	}
	
}
?>