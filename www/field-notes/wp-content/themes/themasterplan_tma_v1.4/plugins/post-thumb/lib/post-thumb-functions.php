<?php
/********************************************************************************************************/
/*
/* Utility functions for Post-thumb revisited
/*
/********************************************************************************************************/


/****************************************************************/
/* Parse given attributes of an html string
/****************************************************************/
function pt_parseAtributes($html, $attrList=array ("src", "alt", "title", "align")) {

	$html = trim($html);
	$ListAttr = array();
	
	foreach ($attrList as $attr) :
		$ListAttr[$attr]= pt_parseAttribute($html, $attr);
	endforeach;
	
	return $ListAttr;
}
function pt_parseAttribute($html, $attr) {

	if (($pos=pt_stripos($html, $attr)) === false) return '';
	$html = substr($html, $pos);
	$html = str_replace($attr, '', $html);
	$html = ltrim($html);
	$html = substr($html, 2);
	if (($pos=pt_stripos($html, '"')) === false) {
		if (($pos=pt_stripos($html, "'")) === false) return '';
	}
	return substr($html, 0, $pos);
}
/***********************************************************************************/
/* extended pathinfo (for php4)
/***********************************************************************************/
function pt_pathinfo($path) {

	$tab = pathinfo($path);
	$tab['filename'] = substr($tab['basename'],0,strlen($tab['basename']) - (strlen($tab['extension']) + 1) );
	return $tab;
}
/***********************************************************************************/
/* Parse arguments
/***********************************************************************************/
function pt_parse_arg ($arg) {

	parse_str($arg, $new_args);
	return array_change_key_case($new_args, CASE_UPPER);

}
/***********************************************************************************/
/* Exclude some REGEX from a content
/***********************************************************************************/
function exclude_regex ($content) {

	$result = $content;
	$reg_coolplayer = '/\[coolplayer](.*?)\[\/coolplayer]/i';
	$reg_youtube = '/\[youtube](.*?)\[\/youtube]/i';
	$reg_dailymotion = '/\[dailymotion](.*?)\[\/dailymotion]/i';
	$reg_googlevideo = '/\[googlevideo](.*?)\[\/googlevideo]/i';
	$reg_wordtube = '/\[MEDIA=(.*?)]/i';
	$reg_extremevideo = '/\[ev(.*?)\[\/ev]/i';

	$pt_youtube = '/\[youtube=\((.*?)\]/i';
 	$pt_dailymotion = '/\[dailymotion=\((.*?)\]/i';

	$content = preg_replace($reg_coolplayer, '...', $content);
	$content = preg_replace($reg_youtube, '...', $content);
	$content = preg_replace($reg_dailymotion, '...', $content);
	$content = preg_replace($reg_googlevideo, '...', $content);
	$content = preg_replace($reg_wordtube, '...', $content);
	$content = preg_replace($reg_extremevideo, '...', $content);
	$content = preg_replace($pt_youtube, '...', $content);
	$content = preg_replace($pt_dailymotion, '...', $content);

	return $content;
}
/****************************************************************
* Test if remote image exists
* @param url to test
* @return true if file exists
****************************************************************/
function remote_file_exists ($uri) {

//	$uri = str_replace(' ', '%20', $uri);
	if (@file_exists($uri)) return true;

	$parsed_url = @parse_url($uri);
	if ( !$parsed_url || !is_array($parsed_url) )
		return false;

	if ( !isset($parsed_url['scheme']) || !in_array($parsed_url['scheme'], array('http','https')) )
		$uri = 'http://' . $uri;

	if ( ini_get('allow_url_fopen') ) {
		if (@fclose(@fopen($uri, 'r')) !== false) return true;
	}

	if ( function_exists('curl_init') ) {

		$timeout = 50;
		$handle = curl_init();
		curl_setopt ($handle, CURLOPT_MUTE, TRUE);
		curl_setopt ($handle, CURLOPT_URL, $uri);
		curl_setopt ($handle, CURLOPT_CONNECTTIMEOUT, 2);
		curl_setopt ($handle, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt ($handle, CURLOPT_TIMEOUT, $timeout);
		$buffer = curl_exec($handle);
		curl_close($handle);
		if ($buffer !== false) return true;
	}

	if ( function_exists('get_headers') ) {

		$AgetHeaders = @get_headers($uri);
		if (preg_match("|200|", $AgetHeaders[0])) return true;

	}

	return @file_exists($uri);

}
/****************************************************************/
/* retourne un chemin canonique a partir d'un chemin contenant des ../
/****************************************************************/
function canonicalize($address) {

	$address = explode('/', $address);
	$keys = array_keys($address, '..');

	foreach($keys AS $keypos => $key)
	{
		array_splice($address, $key - ($keypos * 2 + 1), 2);
	}

	$address = implode('/', $address);
	$address = str_replace('./', '', $address);
	return $address;
}
/****************************************************************/
/*
/****************************************************************/
function pt_clean_text($text, $no_semiologic=false) {

	$text = strip_tags(stripslashes($text));

	if (function_exists('jLanguage_processTitle'))
		$text = jLanguage_processTitle($text);

	$pattern = '/\[MEDIA=([^\]]*)\]/i';
        $text = preg_replace($pattern,'',$text);
	$pattern = '/\[PTPLAYLIST=([^\]]*)\]/i';
        $text = preg_replace($pattern,'',$text);
	$pattern = '/\[dailymotion=([^\]]*)\]/i';
        $text = preg_replace($pattern,'',$text);
	$pattern = '/\[youtube=([^\]]*)\]/i';
        $text = preg_replace($pattern,'',$text);
	$pattern = '/\[PTSET=([^\]]*)\]/i';
        $text = preg_replace($pattern,'',$text);
	$pattern = '/\[PTALBUM=([^\]]*)\]/i';
        $text = preg_replace($pattern,'',$text);
	$pattern = '/\[PTTAG=([^\]]*)\]/i';
        $text = preg_replace($pattern,'',$text);

	// This is for semiologic smart link plugin
	if ($no_semiologic) {

        	$pattern = '/\[([^\]]*)\-(\>|\&gt)([^\]]*)\]/i';
        	if (preg_match_all($pattern, $text, $matches, PREG_SET_ORDER)) {
        	
        		foreach ($matches as $match) :
				$text = str_replace($match[0], $match[1], $text);
                        endforeach;
		}
	}

	// Trim all unwanted/unnecessary characters
	return rtrim($text, "\s\n\t\r\0\x0B");
}
/****************************************************************/
/*
/****************************************************************/
function get_pt_excerpt($arg='') {
	global $post;

	$new_args = pt_parse_arg($arg);
	
	// Retrieves specific parameters
	if (isset($new_args['MORETEXT'])) $more_text = $new_args['MORETEXT']; else $more_text = "...";
	$link = isset($new_args['LINK']);
	if (isset($new_args['MORETAG'])) $more_tag = $new_args['MORETAG']; else $more_tag = "span";
	if (isset($new_args['SHOWDOTS'])) $showdots = '...'; else $showdots = '';

	// if there's a password, return there.
	if (!empty($post->post_password)) {

		if ($_COOKIE['wp-postpass_'.COOKIEHASH] != $post->post_password) { // and it doesn't match cookie
			// if this runs in a feed
			if(is_feed())
				$output = __('There is no excerpt because this is a protected post.');
			else
				$output = get_the_password_form();
		}
		return $output;
	}


	// Create more link or more text
	if ($link) {
		if ($more_tag == '')
			$more_link = '';
		else
			$more_link = '<' . $more_tag . ' class="more-link">';
		$more_link .= '<a href="'.get_permalink().'" title="Permanent Link to '.get_the_title().'">' . $more_text . '</a>';
                if ($more_tag != '') $more_link .= '</' . $more_tag . '>' . "\n";
	} else
		$more_link = $more_text;

	$more_link = $showdots.$more_link;

	return get_pt_excerpt_sub($text, $more_link, $arg);
}
/****************************************************************/
/*
/****************************************************************/
function get_pt_excerpt_sub($text='', $morelink='...', $arg='') {
	global $post;

	$new_args = pt_parse_arg($arg);

	// Retrieves specific parameters
	$excerpt_length = 0;
	$excerpt_words = 0;
	if (isset($new_args['WORDS'])) $excerpt_words = $new_args['WORDS']; 
	elseif (isset($new_args['LENGTH'])) $excerpt_length = $new_args['LENGTH']; 
	else $excerpt_words = 40;
	if (isset($new_args['NOMORE'])) $no_more = ($new_args['NOMORE']==1); else $no_more = false;
	if (isset($new_args['NOSEMIO'])) $no_semiologic = ($new_args['NOSEMIO']==1); else $no_semiologic = false;

	// First cleaning
	$text = pt_clean_text($post->post_content, $no_semiologic);

	// Excerpt based on number of words
	if ($excerpt_words > 0) {

		if (!$no_more && strpos($text, '<!--more-->')) {
			$text = explode('<!--more-->', $text, 2);
			$l = count($text[0]);
			$more_link = 1;
		} else {
			$words = explode(' ', $text, $excerpt_words + 1);
			if (count($words) > $excerpt_length) {
				array_pop($words);
				$output = implode(' ', $words);
				$output .= $morelink;
			} else
				$output = $text;
		}


	// Excerpt based on number of characters
	} elseif ($excerpt_length > 0) {
		if (!$no_more && strpos($text, '<!--more-->')) {
			$text = explode('<!--more-->', $text, 2);
			$l = count($text[0]);
			$more_link = 1;
		} else {
			if (strlen($text)+3 > $excerpt_length) {
				$output = substr($text,0,$excerpt_length-3).$morelink;
			} else
				$output = $text;
		}
	} else $output = $text;
	
	return $output;
}
/****************************************************************/
/*
/****************************************************************/
function get_excerpt_revisited($excerpt_length=120, $more_link_text="...", $no_more=false) {

	global $post;
	$ellipsis = 0;
	$output = '';

 	// if there's a password
 	if (!empty($post->post_password)) { 
 	
		if ($_COOKIE['wp-postpass_'.COOKIEHASH] != $post->post_password) { // and it doesn't match cookie
			// if this runs in a feed
			if(is_feed()) { 
				$output = __('There is no excerpt because this is a protected post.');
			} else {
				$output = get_the_password_form();
			}
		}
		return $output;
	}

	$text = pt_clean_text($post->post_content);

	if($excerpt_length < 0 || $text=='') {
		$output = $text;
	} else {
	
		if(!$no_more && strpos($text, '<!--more-->')) {
			$text = explode('<!--more-->', $text, 2);
			$l = count($text[0]);
			$more_link = 1;
		} else {
			$text = explode(' ', $text);
			if(count($text) > $excerpt_length) {
				$l = $excerpt_length;
				$ellipsis = 1;
			} else {
				$l = count($text);
				$more_link_text = '';
				$ellipsis = 0;
			}
		}
		for ($i=0; $i<$l; $i++)	$output .= $text[$i] . ' ';
	}

	$output = rtrim($output, "\s\n\t\r\0\x0B");
	$output .= ($ellipsis) ? '...' : '';

	return $output;
}
/****************************************************************/
/*
/****************************************************************/
function get_the_excerpt_revisited($excerpt_length=120, $more_link_text="...", $no_semiologic=false, $showdots=true, $more_tag='div', $no_more=false) {
	global $post;
	$ellipsis = 0;
	$output = '';

	// if there's a password, return there.
	if (!empty($post->post_password)) {

		if ($_COOKIE['wp-postpass_'.COOKIEHASH] != $post->post_password) { // and it doesn't match cookie
			// if this runs in a feed
			if(is_feed())
				$output = __('There is no excerpt because this is a protected post.');
			else
				$output = get_the_password_form();
		}
		return $output;
	}

	$output = excerpt_revisited($post->post_content, $excerpt_length, get_permalink($post->ID), $more_link_text, $no_semiologic, $showdots, $more_tag, $no_more);

	return $output;
}
/****************************************************************/
/*
/****************************************************************/
function excerpt_revisited($content, $excerpt_length=120, $link='#', $more_link_text="...", $no_semiologic=false, $showdots=true, $more_tag='div', $no_more=false) {
	$ellipsis = 0;
	$output = '';

	$text = pt_clean_text($content, $no_semiologic);

	if($excerpt_length < 0 || $text=='') {
		$output = $text;
	} else {
		if(!$no_more && strpos($text, '<!--more-->')){
		
			$text = explode('<!--more-->', $text, 2);
			$l = count($text[0]);
			$more_link = 1;
		} else {
			$text = explode(' ', $text);
			if(count($text) > $excerpt_length) {
				$l = $excerpt_length;
				$ellipsis = 1;
			} else {
				$l = count($text);
				$more_link_text = '';
				$ellipsis = 0;
			}
		}
		for ($i=0; $i<$l; $i++)	$output .= $text[$i] . ' ';
	}

	switch($more_tag) {
		case('div') :
			$tag = 'div';
		break;
		case('span') :
			$tag = 'span';
		break;
		case('p') :
			$tag = 'p';
		break;
		default :
			$tag = 'span';
	}

	$output = rtrim($output, "\s\n\t\r\0\x0B");
	$output .= ($showdots && $ellipsis) ? '...' : '';

	if ($more_link_text != '')
		$output .= ' <' . $tag . ' class="more-link"><a href="'. $link . '" title="' . $more_link_text . '">' . $more_link_text . '</a></' . $tag . '>' . "\n";

	return $output;
}
/****************************************************************/
/* Return a string cleaned of annoying '\'
/****************************************************************/
function str_clean ($item)
{
	return str_replace(array("\`", "\'", '\"'), array("`", "'", '"'), $item);
}
/****************************************************************/
/* Returns a formatted url for inframe display
/****************************************************************/
function pt_return_get ($url, $if=1) {

	$look_get = strpos($url,'?');
	$end_char = substr($url, -1, 1);
	if ($end_char == '/') $url_inframe = substr($url, 0, strlen($url)-1); else $url_inframe = $url;
	if ($look_get !== false) $url_inframe .= "&amp;inframe=".$if; else $url_inframe .= "?inframe=".$if;
	return $url_inframe;
}
/*******************************************************************************/
/* Change relative url to absolute
/*******************************************************************************/
function NormalizeURL($url) {
	
	// Test if url is absolute
	if ( stristr( $url, 'http://' )) return $url;
	
	$siteurlparsed = parse_url(SITEURL);
	$host = $siteurlparsed['scheme'].'://'.$siteurlparsed['host'];
	// If http not in url, assumes relative address to blog url
	return canonicalize($host.$url);
	
}
/***********************************************************************************/
/* If you specify the third optional operator argument, you can test for a particular relationship.
/* The possible operators are: <, lt, <=, le, >, gt, >=, ge, ==, =, eq, !=, <>, ne respectively.
/* Using this argument, the function will return 1 if the relationship is the one specified by the operator, 0 otherwise.
/***********************************************************************************/
function version_compare_replacement_sub($version1, $version2, $operator='') {

	// If a part contains special version strings these are handled in the following order: dev < (alpha = a) < (beta = b) < RC < pl
	static $versiontype_lookup = array();
	if (empty($versiontype_lookup))
        {
		$versiontype_lookup['dev']   = 10001;
		$versiontype_lookup['a']     = 10002;
		$versiontype_lookup['alpha'] = 10002;
		$versiontype_lookup['b']     = 10003;
		$versiontype_lookup['beta']  = 10003;
		$versiontype_lookup['RC']    = 10004;
		$versiontype_lookup['pl']    = 10005;
	}
	if (isset($versiontype_lookup[$version1]))
		$version1 = $versiontype_lookup[$version1];
	if (isset($versiontype_lookup[$version2]))
		$version2 = $versiontype_lookup[$version2];

	switch ($operator)
        {
		case '<':
		case 'lt':
			return intval($version1 < $version2);
			break;
		case '<=':
		case 'le':
			return intval($version1 <= $version2);
			break;
		case '>':
		case 'gt':
			return intval($version1 > $version2);
			break;
		case '>=':
		case 'ge':
			return intval($version1 >= $version2);
			break;
		case '==':
		case '=':
		case 'eq':
			return intval($version1 == $version2);
			break;
		case '!=':
		case '<>':
		case 'ne':
			return intval($version1 != $version2);
			break;
	}
	if ($version1 == $version2) { return 0;	}
        elseif ($version1 < $version2) { return -1; }
	return 1;
}
/***********************************************************************************/
/*
/***********************************************************************************/
function version_compare_replacement($version1, $version2, $operator='') {

	if (function_exists('version_compare'))
        {
		// built into PHP v4.1.0+
		return version_compare($version1, $version2, $operator);
	}

	// The function first replaces _, - and + with a dot . in the version strings
	$version1 = strtr($version1, '_-+', '...');
	$version2 = strtr($version2, '_-+', '...');

	// and also inserts dots . before and after any non number so that for example '4.3.2RC1' becomes '4.3.2.RC.1'.
	// Then it splits the results like if you were using explode('.',$ver). Then it compares the parts starting from left to right.
	$version1 = eregi_replace('([0-9]+)([A-Z]+)([0-9]+)', '\\1.\\2.\\3', $version1);
	$version2 = eregi_replace('([0-9]+)([A-Z]+)([0-9]+)', '\\1.\\2.\\3', $version2);

	$parts1 = explode('.', $version1);
	$parts2 = explode('.', $version1);
	$parts_count = max(count($parts1), count($parts2));
	for ($i = 0; $i < $parts_count; $i++)
        {
		$comparison = version_compare_replacement_sub($version1, $version2, $operator);
		if ($comparison != 0)
                {
			return $comparison;
		}
	}
	return 0;
}

/*##############################################################*/
/* Youtube functions
/*	- GetUserYoutubeVideo   Return user video feed
/*	- GetSingleYoutubeVideo	Return single video
/*##############################################################*/

/****************************************************************/
/* Return Youtube User video
/****************************************************************/
function GetUserYoutubeVideo($youtube_user, $num=5) {
	if ($youtube_user=='') return;
	$url = 'http://gdata.youtube.com/feeds/api/users/'.$youtube_user.'/uploads?orderby=updated&start-index=1&max-results='.$num;
	$ytb = ParseYoutubeDetails(GetYoutubePage($url), false);
	if ($num == 1) return $ytb[0];
	return $ytb;
}
/****************************************************************/
/* Return Youtube single video
/****************************************************************/
function GetSingleYoutubeVideo($youtube_media) {
	if ($youtube_media=='') return;
	$url = 'http://gdata.youtube.com/feeds/api/videos/'.$youtube_media;
	$ytb = ParseYoutubeDetails(GetYoutubePage($url));
	return $ytb[0];
}
/****************************************************************/
/* Parse xml from Youtube
/****************************************************************/
function ParseYoutubeDetails($ytVideoXML, $show=false) {

	// Create parser, fill it with xml then delete it
	$yt_xml_parser = xml_parser_create();
	xml_parse_into_struct($yt_xml_parser, $ytVideoXML, $yt_vals);
	xml_parser_free($yt_xml_parser);
	
	// Init individual entry array and list array
	$yt_video = array();
	$yt_vidlist = array();

	// is_entry tests if an entry is processing
	$is_entry = true;
	// is_author tests if an author tag is processing
	$is_author = false;
	foreach ($yt_vals as $yt_elem) :

		// If no entry is being processed and tag is not start of entry, skip tag
		if (!$is_entry && $yt_elem['tag'] != 'ENTRY') continue;

		// Processed tag
		switch ($yt_elem['tag']) :
			case 'ENTRY' :
				if ($yt_elem['type'] == 'open') {
					$is_entry = true;
                                        $yt_video = array();
				} else {
					$yt_vidlist[] = $yt_video;
					$is_entry = false;
				}
			break;
			case 'ID' :
				$yt_video['id'] = substr($yt_elem['value'],-11);
				$yt_video['link'] = $yt_elem['value'];
			break;
			case 'PUBLISHED' :
				$yt_video['published'] = substr($yt_elem['value'],0,10).' '.substr($yt_elem['value'],11,8);
			break;
			case 'UPDATED' :
				$yt_video['updated'] = substr($yt_elem['value'],0,10).' '.substr($yt_elem['value'],11,8);
			break;
			case 'MEDIA:TITLE' :
				$yt_video['title'] = $yt_elem['value'];
			break;
			case 'MEDIA:KEYWORDS' :
				$yt_video['tags'] = $yt_elem['value'];
			break;
			case 'MEDIA:DESCRIPTION' :
				$yt_video['description'] = $yt_elem['value'];
			break;
			case 'MEDIA:CATEGORY' :
				$yt_video['category'] = $yt_elem['value'];
			break;
			case 'YT:DURATION' :
				$yt_video['duration'] = $yt_elem['attributes'];
			break;
			case 'MEDIA:THUMBNAIL' :
				if ($yt_elem['attributes']['HEIGHT'] == 240) {
					$yt_video['thumbnail'] = $yt_elem['attributes'];
					$yt_video['thumbnail_url'] = $yt_elem['attributes']['URL'];
				}
			break;
			case 'YT:STATISTICS' :
				$yt_video['viewed'] = $yt_elem['attributes']['VIEWCOUNT'];
			break;
			case 'GD:RATING' :
				$yt_video['rating'] = $yt_elem['attributes'];
			break;
			case 'AUTHOR' :
				$is_author = ($yt_elem['type'] == 'open');
			break;
			case 'NAME' :
				if ($is_author) $yt_video['author_name'] = $yt_elem['value'];
			break;
			case 'URI' :
				if ($is_author) $yt_video['author_uri'] = $yt_elem['value'];
			break;
			default :
// 			print_r($yt_elem);
		endswitch;
  	endforeach;
  	unset($yt_vals);
  
	return $yt_vidlist;
}
/****************************************************************/
/* Returns content of a remote page
/* Still need to do it without curl
/****************************************************************/
function GetYoutubePage($url) {

	// Try to use curl first
	if (function_exists('curl_init')) {
	
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
		$xml = curl_exec ($ch);
		curl_close ($ch);
	}
	// If not found, try to use file_get_contents (requires php > 4.3.0 and allow_url_fopen)
	else {
		$xml = file_get_contents($url);
	}
	
	return $xml;
}
/****************************************************************/
/* Gets options. Sets minimum options to operate before first validation.
/****************************************************************/
function pt_GetStarterOptions() {

	// Init parameters
	$up = UPLOAD_PATH;
	$pa = parse_url(SITEURL);
	$path = substr($pa['path'], 1, strlen($pa['path'])-1);
	
	$dn = str_replace($pa['path'],"",SITEURL);
	$bp = str_replace($pa['path'],"",str_replace( "\\", "/",ABSPATH));
	$bp = substr($bp, 0, strlen($bp)-1);
	$def = $path.'/wp-content/plugins/'. PT_PLUGIN_BASENAME.'/images/default.png';
	
	$settings = get_option('post_thumbnail_settings');

	if ($settings['append'] == '') 		$settings['append'] = 'false';
	if ($settings['append_text'] == '') 	$settings['append_text'] = 'thumb_';
	if ($settings['base_path'] == '') 	$settings['base_path'] = $bp;
	if ($settings['default_image'] == '') 	$settings['default_image'] = $def;
	if ($settings['folder_name'] == '') 	$settings['folder_name'] = $path.'/'.$up.'/pth';
	if ($settings['full_domain_name'] == '')$settings['full_domain_name'] = str_replace( "\\", "/",$dn);

	if ($settings['tb_use'] == '') 		$settings['tb_use'] = 'false';
	if ($settings['hs_use'] == '') 		$settings['hs_use'] = 'false';

	$settings['jpg_rate'] 			= ptr_test_setting($settings['jpg_rate'], '75', 100);
	if ($settings['keep_ratio'] == '') 	$settings['keep_ratio'] = 'true';
	$settings['png_rate'] 			= ptr_test_setting($settings['png_rate'], '6', 9);

	$settings['resize_width'] 		= ptr_test_setting($settings['resize_width'], '60');
	$settings['resize_height'] 		= ptr_test_setting($settings['resize_height'], '60');

	if ($settings['rounded'] == '') 	$settings['rounded'] = 'false';
	if ($settings['stream_check'] == '') 	$settings['stream_check'] = 'false';

	if ($settings['unsharp'] == '') 	$settings['unsharp'] = 'false';

	if ($settings['use_catname'] == '') 	$settings['use_catname'] = 'false';
	if ($settings['use_meta'] == '') 	$settings['use_meta'] = 'true';
	if ($settings['use_png'] == '') 	$settings['use_png'] = 'false';

	if ($settings['video_default'] == '') 	$settings['video_default'] = $def;
	if ($settings['pt_replace'] == '') 	$settings['pt_replace'] = 'false';

	return $settings;
}
/***********************************************************************************/
/* Check for a new version of Post-thumb Revisited on server. This one is basic
/***********************************************************************************/
function ptr_test_setting($option, $default, $max = 0) {

	$option = trim($option);
	if (!is_numeric($option) || ($option > $max && $max <> 0 ))

		return $default;
	else
		return $option;
}
/***********************************************************************************/
/* Simple check of flv-ness of a file
/***********************************************************************************/
function pt_is_flv ($file) {
	return (pt_stripos($file, '.flv') !== false);
}
/***********************************************************************************/
/* stripos for php4
/***********************************************************************************/
function pt_stripos($str, $mix) {
	if (get_pt_options('phpversion') < '5.0')
		return strpos(strtolower($str), strtolower($mix));
	else
		return stripos($str, $mix);
}
/***********************************************************************************/
/* load cache file - timeout in minutes
/***********************************************************************************/
function pt_load_cache($filename, $dirname, $timeout=0) {
		
	if (!file_exists($dirname.$filename)) return false;

	// Test if cache has expired
	$diff = (time() - filemtime($dirname.$filename))/60;
	if ($diff >= $timeout && $timeout != 0) return false;
		
	// Read content from cache file.
	$content = file_get_contents($dirname.$filename);
		
	if ($content === false) return false;

	return unserialize($content);
		
}
/***********************************************************************************
	save cache file
***********************************************************************************/
function pt_save_cache($filename, $dirname, $content) {

	$content = serialize($content);

	if (!is_dir($dirname)) {
		$old_umask = umask(0);
		@mkdir($dirname, 0777);
		umask($old_umask);
		if (!is_dir($dirname)) return false;
	}

	// Writes content from cache file.
	$content = file_put_contents($dirname.$filename, $content);

}

?>