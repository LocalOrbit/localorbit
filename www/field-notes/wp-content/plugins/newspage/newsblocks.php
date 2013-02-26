<?php

class newsblocks{
	function data($url, $options = null){
		$feed = new SimplePie();
		$feed->enable_cache( (bool) get_option('newspage_cache_on') );
		$feed->set_cache_location( SIMPLEPIE_CACHEDIR );
		$feed->set_cache_duration( (get_option('newspage_cache_duration') * get_option('newspage_cache_duration_units')) );
		$feed->set_feed_url($url);
		$feed->init();
		if (!is_array($url)) $hash_str = array($url);
		else $hash_str = $url;
		$classname = null;
		$copyright = $feed->get_copyright();
		$date_format = '%a, %e %b %Y, %I:%M %p';
		$description = $feed->get_description();
		$direction = 'ltr';
		$favicon = $feed->get_favicon();
		$id = 'a' . sha1(implode('', $hash_str));
		$item_classname = 'tips';
		$items = 10;
		$language = $feed->get_language();
		$length = 200;
		$more = 'More &raquo;';
		$more_move = false;
		$more_fx = true;
		$permalink = $feed->get_permalink();
		$show_title = true;
		$since = time() - (24*60*60); // 24 hours ago.
		$title = $feed->get_title();
		extract($options);
		if (!$favicon) $favicon = NB_FAVICON_DEFAULT;
		if (!$title){
			if (is_array($url)){
				$feed_title = array();
				foreach ($url as $u){
					$feed_title[] = newsblocks::name($u);
				}
				$title = implode(', ', $feed_title);
			}
		}
		return array(
			'classname' => $classname,
			'ftitle' => $ftitle,
			'copyright' => $copyright,
			'date_format' => $date_format,
			'description' => $description,
			'direction' => $direction,
			'favicon' => $favicon,
			'feed' => $feed,
			'id' => $id,
			'item_classname' => $item_classname,
			'items' => $items,
			'language' => $language,
			'length' => $length,
			'more' => $more,
			'more_move' => $more_move,
			'more_fx' => $more_fx,
			'permalink' => $permalink,
			'show_title' => $show_title,
			'since' => $since,
			'title' => $title
		);
	}
	function listing($url, $options = null){
		if (!$options) $options = array();
		$ftitle = "";
		extract(newsblocks::data($url, $options));
		if (!$classname) $classname = 'nb-list';
		$html = '<div class="feed">';
		if ($show_title){
			$html .= '<div class="feedtitle"><img src="' . $favicon . '" width="16" height="16"  style="vertical-align:middle;"/> ';
			if ($permalink) $html .= '<a href="' . $permalink . '" '.( (bool) get_option('newspage_newwindow') ? 'target=_new' : null ).'>';
			if( get_option("newspage_useFeedTitle") == 1){
				$html .= $title;
			}else{
				$html .= $ftitle;
			}
			if ($permalink) $html .= '</a>';
			$html .= '</div>' . "\n";
		}
		$html .= '<ul>' . "\n";
		$counter_start = 0;
		$counter_length = $items;
		foreach ($feed->get_items($counter_start, $counter_length) as $item){
			$class = '';
			$type = '';
			$new = '';
			extract(newsblocks::has_enclosure($item));
			if ($item->get_date('U') > $since){
				$new = NB_NEW_HTML;
			}
			$desc = "<b>" . $item->get_date() . "</b><br />" . substr(strip_tags($item->get_description(true)), 0, 500) . "...";
			$title_attr = newsblocks::get_title_attr($item, $length, $date_format);
			$html .= '<li class="feeditem">';
			$html .= '<a href="' . $item->get_permalink() . '" '.( (bool) get_option('newspage_newwindow') ? 'target=_new' : null ).'>'.$item->get_title();
			$html .= '<span>'.$desc.'</span>';
			$html .= '</a>';
			$html .= ' ' . $new . '</li>' . "\n";
		}
		$html .= '</ul>' . "\n";
		$html .= '</div>' . "\n";
		return $html;
	}
	function has_enclosure($item){
		$class = '';
		$type = '';
		if ($enclosure = $item->get_enclosure()){
			$type = $enclosure->get_real_type();
			if (stristr($type, 'video/') || stristr($type, 'x-shockwave-flash')){
				$class = 'enclosure video';
			}elseif (stristr($type, 'audio/')){
				$class = 'enclosure audio';
			}elseif (stristr($type, 'image/')){
				$class = 'enclosure image';
			}
		}
		return array('class' => $class, 'type' => $type	);
	}
	function get_title_attr($item, $length, $date_format){
		$parent = $item->get_feed();
		$title_attr = '';
		$title_attr .= $item->get_title(); // The title of the post
		$title_attr .= ' :: '; // The separator between the title and the description (required by MooTools)
		$title_attr .= newsblocks::cleanup($item->get_description(), $length); // The cleaned-up and shortened version of the description
		$title_attr .= '<span>'; // This marks the beginning of the date/domain line (and is CSS styleable)
		if ($item->get_local_date($date_format)){
			$title_attr .= $item->get_local_date($date_format); // Use the locale-friendly version for non-English languages.
			$title_attr .= ' // '; // Visual separator.
		}
		$title_attr .= newsblocks::name($parent->subscribe_url()); // The domain name that the item is coming from.
		$title_attr .= '</span>'; // Mark the end of the date/domain line.
		return $title_attr;
	}
	function cleanup($s, $length = 0){
		$s = html_entity_decode($s, ENT_QUOTES, 'UTF-8');
	    $s = strip_tags($s);
	    $s = str_replace('"', '', $s);
	    $s = preg_replace('/(\s+)/', ' ', $s);
		if ($length > 0 && strlen($s) > $length){
			$s = trim(newsblocks::substr($s, 0, $length, 'UTF-8')) . '&hellip;';
		}
	    return $s;
	}
	function name($s){
		preg_match('/http(s)?:\/\/(www.)?([^\/]*)/i', $s, $d);
		return $d[3];
	}
	function substr($str, $start, $length, $encoding = null){
		if (function_exists('mb_substr')){
			return mb_substr($str, $start, $length, $encoding);
		}else{
			return substr($str, $start, $length);
		}
	}
}
?>