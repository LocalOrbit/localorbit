<?php
/***********************************************************************************/
/* Post Thumb Revisited Main functions
/*
/* 	function the_thumb ($arg='')
/* 	function get_thumb ($arg='')
/*		Loop function. Returns the formatted thumbnail of the current post
/*		or object (depending on parameters)
/*
/* 	function get_thumb_url ()
/*
/*	function the_recent_thumbs ($arg='', $beforeli='', $afterli='', $before='', $after='')
/*	function get_recent_thumbs ($arg='', $beforeli='', $afterli='', $before='', $after='')
/*		Anywhere function. Returns thumbnails of the most recent posts
/*
/* 	function the_random_thumb ($arg='', $beforeli='', $afterli='', $before='', $after='')
/*	function get_random_thumb ($arg='', $beforeli='', $afterli='', $before='', $after='')
/*		Anywhere function. Returns thumbnail(s) from random post(s)
/*
/*	function pt_the_excerpt($length=40, $title_after= false, $arg='')
/*		Loop function. Returns Thumbnail (+ Title) + Excerpt
/*
/*	function get_single_thumb ($post, $arg='')
/*	function get_recent_medias ($arg='', $beforeli='', $afterli='', $before='', $after='')
/*	function get_WTMedia ($vid, $arg='', $play_width=0, $play_height=0)
/*	function get_WTPlaylist ($pid, $arg='', $play_width=0, $play_height=0, $mp3=false, $flv=false)
/*	function get_wordTubeTag ($content='')
/*	function get_Youtube ($id, $title, $thumb)
/*	function RecentImages ($arg='', $slice=5, $timeout=0)
/*	function RecentImages_sub ($ListImages, $slice, $offset, $i, $limit)
/*
/***********************************************************************************/


/***********************************************************************************/
/* display thumbnail. Loop function.
/***********************************************************************************/
function the_thumb ($arg='') {

	echo get_thumb($arg);
}
/***********************************************************************************/
/* Get thumbnail. Loop function.
/***********************************************************************************/
function get_thumb ($arg='') {
	global $PTRevisited;

		return $PTRevisited->GetThumb($arg);
}
/***********************************************************************************/
/* Get post image url. Loop function.
/***********************************************************************************/
function get_thumb_url () {
	global $PTRevisited, $post;

		setup_postdata($post);
		$array =  $PTRevisited->GetPostData($post->ID);
		if ($array !='') return $array['image_url'];
		return '';
	
}
/***********************************************************************************/
/* Return recent posts display string
/***********************************************************************************/
function get_recent_thumbs ($arg='', $beforeli='', $afterli='', $before='', $after='') {
	global $PTRevisited;

		return $PTRevisited->GetTheRecentThumbs($arg, $beforeli, $afterli, $before, $after);
}
/***********************************************************************************/
/* Display recent posts
/***********************************************************************************/
function the_recent_thumbs ($arg='', $beforeli='', $afterli='', $before='', $after='') {

	echo get_recent_thumbs($arg, $beforeli, $afterli, $before, $after);

}
/***********************************************************************************/
/* Return random thumbnails.
/***********************************************************************************/
function get_random_thumb ($arg='', $beforeli='', $afterli='', $before='', $after='') {
	global $PTRevisited;

		return $PTRevisited->GetRandomThumb($arg, $beforeli, $afterli, $before, $after);

}
/***********************************************************************************/
/* Return random thumbnails.
/*
/* LIMIT: number of thumbnail to display. Default is 1.
/***********************************************************************************/
function the_random_thumb ($arg='', $beforeli='', $afterli='', $before='', $after='') {

	echo get_random_thumb($arg, $beforeli, $afterli, $before, $after);

}
/****************************************************************/
/* Returns displayable post content
/****************************************************************/
function pt_get_excerpt($earg='', $arg='', $addstr='') {

	global $PTRevisited;
		return $PTRevisited->TheExcerpt($earg, $arg, $addstr);

}
/****************************************************************/
/* Returns displayable post content
/****************************************************************/
function pt_the_excerpt($earg='', $arg='', $addstr='') {
	global $PTRevisited;
		return $PTRevisited->TheExcerpt($earg, $arg, $addstr);
}
/***********************************************************************************/
/* Display recent posts
/***********************************************************************************/
function get_recent_medias ($arg='', $beforeli='', $afterli='', $before='', $after='') {
	global $PTRevisited;
		echo $PTRevisited->GetTheRecentThumbs($arg.'&media=1', $beforeli, $afterli, $before, $after);
}
/***********************************************************************************/
/* Get thumbnail for a given post
/***********************************************************************************/
function get_single_thumb ($post, $arg='') {
	global $PTRevisited;
		return $PTRevisited->GetSingleThumb($post, $arg);
}
/****************************************************************/
/* Includes features in header
/****************************************************************/
function pt_include_header() {
	global $PTRevisited;
		return $PTRevisited->include_header();
}
/***********************************************************************************/
/* Get Post-Thumb Revisited options.
/***********************************************************************************/
function get_pt_options($option) {
	global $PTRevisited;
		return $PTRevisited->settings[$option];
}
/***********************************************************************************/
/* Get Post-Thumb Revisited options.
/***********************************************************************************/
function get_pt_options_all() {
	global $PTRevisited;
		return $PTRevisited->settings;
}
/***********************************************************************************/
/* Get wordtube options.
/***********************************************************************************/
function get_wt_options_all() {
	global $PTRevisited;
		return $PTRevisited->wordtube_options;
}
/***********************************************************************************/
/* Get wordtube options.
/***********************************************************************************/
function get_wt_options($option) {
	global $PTRevisited;
		return $PTRevisited->wordtube_options[$option];
}
/***********************************************************************************/
/* Get wordtube playertype.
/***********************************************************************************/
function get_wt_playertype() {
	global $PTRevisited;
		return $PTRevisited->playertype;
}
/***********************************************************************************/
/* Get wordtube playertype.
/***********************************************************************************/
function get_wt_playertypemp3() {
	global $PTRevisited;
		return $PTRevisited->playertypemp3;
}

/***********************************************************************************/
/* Get wordTube media.
/***********************************************************************************/
function get_WTMedia ($vid, $arg='', $play_width=0, $play_height=0) {
	global $PTRLibrary;
		if (class_exists('PostThumbLibrary'))
			return $PTRLibrary->GetWTMedia($vid, $arg, $play_width, $play_height);
		return false;
}
/***********************************************************************************/
/* Get wordTube Playlist.
/***********************************************************************************/
function get_WTPlaylist ($pid, $arg='', $play_width=0, $play_height=0, $mp3=false, $flv=false) {
	global $PTRLibrary;
		if (class_exists('PostThumbLibrary'))
		return $PTRLibrary->GetWTPlaylist($pid, $arg, $play_width, $play_height, $mp3, $flv);
		return false;
}
/***********************************************************************************/
/* Get 
/***********************************************************************************/
function get_wordTubeTag ($content='') {
	global $PTRLibrary;
		if (class_exists('PostThumbLibrary'))
		return $PTRLibrary->ReplaceWordTubeMedia($content);
		return false;
}
/***********************************************************************************/
/* Get 
/***********************************************************************************/
function get_Youtube ($id, $title, $thumb) {
	global $PTRLibrary;
		if (class_exists('PostThumbLibrary'))
		return $PTRLibrary->GetYoutube($id, $title, $thumb);
		return false;
}

/***********************************************************************************/
/* List all recent images.
/* 	$arg: 		post-thumb parameters
/*	$slice:		number of posts to load for each loop of parsing
/*	$timeout:	cache delay in minutes
/***********************************************************************************/
function RecentImages ($arg='', $slice=5, $timeout=0) {
	global $PTRevisited, $wpdb;

	// check cache
	if ($timeout > 0) {
		$filename = 'recentimages'.md5($arg);
		$dirname = get_pt_options('base_path').'/'.get_pt_options('folder_name').'/_cache/';
		$ret_str = pt_load_cache($filename, $dirname, $timeout);
		if ($ret_str !== false) return $ret_str;
	}
	
	$ListImages = array();
	$ListImages['pic'] = array();
	$ListImages['endDB'] = false;

	// Retrieves specific parameters
	$new_args = pt_parse_arg($arg);
	if (isset($new_args['LIMIT'])) { 
		$limit = (int) $new_args['LIMIT']; 
	} else 
		$limit = 10;


	$offset = 0;
	$i = 0;
	while ($i < $limit):
        	$ListImages = RecentImages_sub ($ListImages, $slice, $offset, $i, $limit);
        	$offset = $offset+$slice;
        	$i = count($ListImages['pic']);
        	if ($ListImages['endDB']) break;
        endwhile;

	// Delete image in excess
	while (count($ListImages['pic']) > $limit) :
		array_pop($ListImages['pic']);
	endwhile;
	
	$ret_str = '';
	foreach ($ListImages['pic'] as $image):

		$t = new pt_thumbnail (get_pt_options_all(), $image[0], $arg);

		// Add thumbnail & highslide expand to image
		if (POSTTHUMB_USE_HS) {
			$h = new pt_highslide ($image[0], $t->thumb_url, $image[1]);
			$h->set_borders (get_pt_options('ovframe'));
			$h->set_title ($image[1]);
			if (get_pt_options('caption') == 'true')
				$h->set_caption (addslashes($image[1]));
			$h->set_html_size();
			$h->set_href_text('', $add_tag);
			$ret_str .= $h->highslide_link ();
			unset ($h);
		}
		// Simple replacement by thumbnail linked to image
		else $ret_str .= '<a href="'.$image[0].'" title="'.$image[1].'" ><img src="'.$t->thumb_url.'" alt="'.$image[1].'" /></a>';

		unset ($t);

	endforeach;
	
	unset($ListImages);
	
	if ($timeout > 0) pt_save_cache($filename, $dirname, $ret_str);
	return $ret_str;	
}
/***********************************************************************************/
/* List all recent images.
/*	$ListImages:	input and output parameter. Contain the list of images
/*	$offset:	post to skip to start new loop
/*	$i:		current counter
/*	$limit:		number of images to return
/***********************************************************************************/
function RecentImages_sub ($ListImages, $slice, $offset, $i, $limit) {
	global $PTRevisited, $PTRLibrary;
	$attrList = array ("src");

	// Create a query object to retrieve posts
	$posts = get_posts('numberposts='.$slice.'&offset='.$offset);
	if (count($posts) < $slice) $ListImages['endDB']=true;
	
	foreach ($posts as $post) :

		if ($i>$limit) break;

		setup_postdata($post);		
		$content = apply_filters('the_content', get_the_content());

		// Parse images
		$pattern = '/<img([^>]*)\/>/si';
		if (preg_match_all($pattern, $content, $matches, PREG_SET_ORDER)) {
			
			foreach ($matches as $match) :

				// Skip wp smileys
				if (pt_stripos($match[0], 'class="wp-smiley"')) continue;
				if (pt_stripos($match[0], "class='wp-smiley'")) continue;
				
				if ($i>$limit) break;
				if (!$PTRLibrary->p_rel) {
					if (pt_stripos($match[0], 'rel="thumb"') === false && pt_stripos($match[0], "rel='thumb'") === false)
						continue;
				} else {
					if (pt_stripos($match[0], 'rel="nothumb"') !== false || pt_stripos($match[0], "rel='nothumb'") !== false)
						continue;
				}

				$m = str_replace(array("%", "|", "@", ")", "("), array("\%", "\|", "\@", "\)", "\("), $match[0]);
				
				$pat = '%<a([^>]*).(jpg|jpeg|png|gif)([^>]*)\>([^>]*)'.$m.'([^>]*)\<\/a>%si';
				if (preg_match($pat,$content,$macgee)) {

					$ListAttr = pt_parseAtributes($macgee[0], array('href', 'title'));
					$ListImages['pic'][] =  array($ListAttr['href'], $ListAttr['title']);
					$i++;
					unset($macgee);

				} else {

					$ListAttr = pt_parseAtributes($match[1], array('src', 'alt'));
					$ListImages['pic'][] =  array($ListAttr['src'], $ListAttr['alt']);
					$i++;
				}

			endforeach;
		}
		
	endforeach;
	
	return $ListImages;
	

}


?>