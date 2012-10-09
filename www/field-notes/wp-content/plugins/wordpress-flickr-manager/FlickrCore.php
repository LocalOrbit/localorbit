<?php
class FlickrCore {
	
	var $api_key = "0d3960999475788aee64408b64563028";
	var $secret = "b1e94e2cb7e1ff41";
	
	
	
	function call($method, $params, $sign = false, $rsp_format = "php_serial") {
		if(!is_array($params)) $params = array();
		
		$call_includes = array( 'api_key'	=> $this->api_key, 
								'method'	=> $method,
								'format'	=> $rsp_format);
		
		$params = array_merge($call_includes, $params);
		
		if($sign) $params = array_merge($params, array('api_sig' => $this->getSignature($params)));
		
		$url = "http://api.flickr.com/services/rest/?" . http_build_query($params);
		
	    return $this->getRequest($url);
	}
	
	
	
	function post($method, $params, $sign = false, $rsp_format = "php_serial") {
		if(!is_array($params) || !is_string($method) || !is_string($rsp_format) || !is_bool($sign)) return false;
		
		$call_includes = array( 'api_key'	=> $this->api_key, 
								'method'	=> $method,
								'format'	=> $rsp_format);
		
		$params = array_merge($call_includes, $params);
		
		if($sign) $params = array_merge($params, array('api_sig' => $this->getSignature($params)));
		
		$url = "http://api.flickr.com/services/rest/";
		
		return $this->postRequest($url, $params);
	}
	
	
	
	function upload($params) {
		
		if(!is_array($params) || !isset($params['photo'])) return false;
		
		$photo = $params['photo'];
		unset($params['photo']);
		
		$call_includes = array( 'api_key'	=> $this->api_key);
		
		$params = array_merge($call_includes, $params);
		$params = array_merge($params, array('photo' => $photo, 'api_sig' => $this->getSignature($params)));
		
		$url = 'http://api.flickr.com/services/upload/';
		
		return $this->postRequest($url, $params);
		
	}
	
	
	
	function getRequest($url) {
		if(function_exists('curl_init')) {
			$session = curl_init($url);
			curl_setopt($session, CURLOPT_HEADER, false);
			curl_setopt($session, CURLOPT_RETURNTRANSFER, true);
			$response = curl_exec($session);
			if (curl_errno($session) == 0) {
		    	curl_close($session);
		        return unserialize($response);
		    }
			curl_close($session);
			$rsp_obj = false;
		} else {
			$handle = fopen($url, "rb");
			$contents = '';
			while (!feof($handle)) {
				$contents .= fread($handle, 8192);
			}
			fclose($handle);
			$rsp_obj = unserialize($contents);
		}
		return $rsp_obj;
	}
	
	
	
	function postRequest($url, $params) {
		if(function_exists('curl_init')) {
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, $url);
			curl_setopt($ch, CURLOPT_POST, true);
			
		    curl_setopt($ch, CURLOPT_POSTFIELDS, $params);
		    
		    curl_setopt($ch, CURLOPT_FAILONERROR, 1);
		    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 20);
		    curl_setopt($ch, CURLOPT_TIMEOUT,200);
		    
		    $result = curl_exec($ch);
		    
		    if (curl_errno($ch) == 0) {
		    	curl_close($ch);
		        return $result;
		    }
		    curl_close($ch);
			return false;
		} else {
			return $this->fUpload($url, $params);
		}
	}
	
	
	function fUpload($url, $params, $useragent = 'PHPPost/1.0') {
		$url_info = parse_url( $url );
		
		$mime_boundary = md5(date("r",time()));
		
		$out = "POST $url HTTP/1.0\r\n";
		$out .= "Host: {$url_info['host']}\r\n";
		$out .= "User-Agent: $useragent\r\n";
		$out .= "Content-Type: multipart/form-data, boundary=$mime_boundary\r\n";
		
		ob_start();
		
		foreach ($params as $k => $v):
			echo "\r\n--$mime_boundary";
			echo "\r\nContent-Disposition: form-data; name=\"$k\"";
		
			if($k != 'photo') echo "\r\n\r\n$v";
			else {
				echo '; filename="' . basename($v) . "\"\r\n";
				
				$filename = substr($v, 1);
				echo 'Content-Type: ' . mime_content_type($filename) . "\r\n";
				echo 'Content-Transfer-Encoding: binary' . "\r\n";
				echo "\r\n" . file_get_contents($filename);
			}
		endforeach; 
		
		echo "\r\n--$mime_boundary--\r\n";
		$request = ob_get_clean();
		
		$request = $out . 'Content-Length: ' . (strlen( $request )) . "\r\n$request\r\n";
		
		$fp = fsockopen( $url_info['host'], 80);
		if( !$fp ) return false;
		
		fwrite($fp, $request);
		
		$contents = '';
		while (!feof($fp)) {
            $contents .= fread($fp, 256);
        }
		
		fclose($fp);
		
		/* seperate content and headers */
	    $contents = explode( "\r\n\r\n", $contents, 2 );
	    return $contents[1];
	}
	
	
	
	function getSignature($params) {
		ksort($params);
		
		$api_sig = $this->secret;
		
		foreach ($params as $k => $v){
			$api_sig .= $k . $v;
		}
		
		return md5($api_sig);
	}
	
	
	
	function getAuthUrl($frob, $perms) {
		$params = array('api_key' => $this->api_key, 'perms' => $perms, 'frob' => $frob);
		$params = array_merge($params, array('api_sig' => $this->getSignature($params)));
		
		$url = 'http://flickr.com/services/auth/?' . http_build_query($params);
		return $url;
	}
	
	
	
	function getPhotoUrl($photo, $size) {
		$sizes = array('square' => '_s', 'thumbnail' => '_t', 'small' => '_m', 'medium' => '', 'large' => '_b', 'original' => '_o');
		if(!isset($photo['originalformat']) && strtolower($size) == "original") $size = 'medium';
		if(($size = strtolower($size)) != 'original') {
			$url = "http://farm{$photo['farm']}.static.flickr.com/{$photo['server']}/{$photo['id']}_{$photo['secret']}{$sizes[$size]}.jpg";
		} else {
			$url = "http://farm{$photo['farm']}.static.flickr.com/{$photo['server']}/{$photo['id']}_{$photo['originalsecret']}{$sizes[$size]}.{$photo['originalformat']}";
		}
		return $url;
	}
	
}

?>
