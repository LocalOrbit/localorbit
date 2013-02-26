<?php
// don't cache this page
header("Cache-Control: no-cache");
function geturl($url){
	if(function_exists('curl_init')) {
		$ch = curl_init();
		$timeout = 5;
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
		// make this curl_exec, no spaces
		$results = curl_exec($ch);
		curl_close($ch);
	} else {
		$ch = fopen($url, "rb");
		$results = '';
		while (!feof($ch)) {
			$results .= fread($ch, 1024);
		}
		fclose($ch);
	}
	return $results;
}
// get the specified url from the querystring
$theurl = $_GET["url"];
// decode it
$theurl = urldecode($theurl);
// decode forgets the ampersand
$theurl = str_replace( "&#038;", "&", $theurl );
// fetch the url
$v = geturl( $theurl );
// spit out the results
echo $v;
?>