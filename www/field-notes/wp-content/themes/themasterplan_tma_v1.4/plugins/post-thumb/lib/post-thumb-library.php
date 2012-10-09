<?php
/**********************************************************************
	Class: PTR Library
	Description: Library for Post-Thumb Revisited.
	Version: 1.0
	Author:  Alakhnor
**********************************************************************/

$PTRLibrary = new PostThumbLibrary();

################################################################################
########## MAIN CLASS
################################################################################
class PostThumbLibrary {

	/**
	 * PostThumbRevisited
	 *
	 * Constructor for the PostThumbRevisited class.
	 */

	var $addArg = '';
	var $p_rel;
	var $p_has_caption;
	var $lightbox = '';
	
	function PostThumbLibrary () {

          	global $wpdb, $wp_query;

		// Add header data
		add_action('wp_head', array(&$this, 'include_header'));

		// Wordtube initialization
		$wpdb->wordtube	= $wpdb->prefix . 'wordtube';
		$wpdb->wordtube_med2play = $wpdb->prefix . 'wordtube_med2play';

		// Adds parameters
		if (get_pt_options('p_rounded') == 'true') 
			$this->addArg = '&rounded=1'; 
		else 
			$this->addArg = '&rounded=0';
		if (get_pt_options('p_keep_ratio') == 'true') 
			$this->addArg .= '&keepratio=1'; 
		else 
			$this->addArg .= '&keepratio=0';
		if (get_pt_options('p_max') == 'true') 
			$this->addArg .= '&max=1'; 
		else 
			$this->addArg .= '&max=0';
		if (get_pt_options('p_subfolder') != '') 
			$this->addArg .= '&subfolder='.get_pt_options('p_subfolder');
		if (get_pt_options('p_dirname') != '' && get_pt_options('p_dirname') != '0') 
			$this->addArg .= '&dirname='.get_pt_options('p_dirname');
		if (get_pt_options('p_use_png') == 'true') 
			$this->addArg .= '&mime=png'; 
		if (get_pt_options('p_lightbox') == 'true') $this->lightbox = ' rel="lightbox"';
			
		$this->p_has_caption = (get_pt_options('p_caption') == 'true');
		$this->p_rel = (get_pt_options('p_rel') == 'true');

		// ReplaceImage is activated with rel="thumb" in the img
		add_filter('the_content', array(&$this, 'ReplaceImage'));

		// Other options can only be available if highslide is activated
		if (((POSTTHUMB_USE_HS || POSTTHUMB_USE_TB))) {

			// ReplaceLinks is activated with rel="ptlink" in the img
			add_filter('the_content', array(&$this, 'ReplaceLinks'));

			// Image with thumbnails filter
			if (get_pt_options('pt_replace') == 'true') {
				add_filter('the_content', array(&$this, 'ReplaceThumbnails'));
			}

			// wordTube filter
			if (get_pt_options('wt_media') == 'true') {
				add_filter('the_content', array(&$this, 'ReplaceWTMedia'));
				if (get_pt_options('wt_playlist') == 'true') 
					add_filter('the_content', array(&$this, 'ReplaceWTPlaylist'));
			}

			// Youtube filter
			if (get_pt_options('ytb_media') == 'true') 
				add_filter('the_content', array(&$this, 'ReplaceYoutube'));
		}

		add_filter('the_content_rss', array(&$this, 'ReplaceImage'), 5);
		add_action('rss2_item', array(&$this, 'ReplaceImage'), 5);
	}
	/****************************************************************/
	/* Filter function (if Highslide is activated)
	/****************************************************************/
	function ReplaceThumbnails($content) {
		$attrList=array ("src", "alt", "title", "align", "width", "height");
		
		if (is_feed()) return $content;

		$r_ID = rand();

		// Replace thumbnail
		$pattern = '/<a([^>]*)href=[\'|"]([^>]*).(bmp|jpg|jpeg|gif|png)[\'|"]([^>]*)><img([^>]*)\/><\/a>/si';
		if (preg_match_all($pattern,$content,$matches, PREG_SET_ORDER)) {
		
			$i=1;
			foreach ($matches as $match) :

				$ID = $r_ID.$i;

				if (POSTTHUMB_USE_HS) {
					$href = '<a href="'.$match[2].'.'.$match[3].'" onclick="return hs.expand(this, {captionId: '."'caption".$r_ID."',"." outlineType: '".get_pt_options('ovframe')."'".'})" id="thumb'.$r_ID.'" class="highslide">';
					$img_src = '<img '.$match[5].'/></a>';
					$caption = '<div class="highslide-caption" id="caption'.$r_ID.'">'.$match[8].'</div>';
				}
				elseif (POSTTHUMB_USE_TB) {
					$href = '<a href="'.$match[2].'.'.$match[3].'" class="thickbox" rel="WP_ptr_gallery" '.$match[4].'>';
					$img_src = '<img '.$match[5].'/></a>';
					$caption = '';
				}
				else continue;

				$replacement = $href.$img_src.$caption;
       				$content = str_replace($match[0], $replacement, $content);
				$i++;
				
			endforeach;
		}

		return $content;

	}
	/****************************************************************/
	/* Filter function (if Highslide is activated)
	/****************************************************************/
	function ReplaceImage($content) {
		$attrList=array ("src", "alt", "title", "align", "rel");	

		if (!$this->p_rel && 
			pt_stripos($content, 'rel="thumb"') === false && pt_stripos($content, "rel='thumb'") === false)
		return $content;

		// Thumbnails image and replace
		$pattern = '/<img([^>]*)\/>/si';
		if (preg_match_all($pattern, $content, $matches, PREG_SET_ORDER)) {

			foreach ($matches as $match) :

				if (pt_stripos($match[0], 'class="wp-smiley"')) continue;
				if (pt_stripos($match[0], "class='wp-smiley'")) continue;
				
				if (!$this->p_rel){
					if (pt_stripos($match[0], 'rel="thumb"') !== false)
						$match[1] = str_replace('rel="thumb"', '', $match[1]);
					elseif (pt_stripos($match[0], "rel='thumb'") !== false)
						$match[1] = str_replace("rel='thumb'", '', $match[1]);
					else
						continue;
				} else {
					if (pt_stripos($match[0], 'rel="nothumb"') !== false || pt_stripos($match[0], "rel='nothumb'") !== false)
						continue;
				}
				
				$m = str_replace('@', '\@', $match[0]);
				$m = str_replace(')', '\)', $m);
				$m = str_replace('(', '\(', $m);
				$pat = '@<a([^>]*)\>([^>]*)'.$m.'([^>]*)\<\/a>@si';

				if (preg_match($pat, $content, $foo)) {
					continue;
				} 

				$ListAttr = pt_parseAtributes($match[1], $attrList);
				$ListAttr['ext'] = substr(strrchr($ListAttr['src'], "."), 1);
				$ListAttr['img'] = substr($ListAttr['src'],0,strlen($ListAttr['src']) - (strlen($ListAttr['ext']) + 1) );
				if ($ListAttr['title']=='' || !isset($ListAttr['title'])) $ListAttr['title'] = $ListAttr['alt'];
				$replacement = $this->MakeThumb($ListAttr);
      				$content = str_replace($match[0], $replacement, $content);

			endforeach;
		}

		return $content;
	}
	/****************************************************************/
	/* Filter function (if Highslide is activated)
	/****************************************************************/
	function MakeThumb($ListAttr) {
	
		// Initialize parameters
//		$the_image = NormalizeURL($ListAttr['img'].'.'.$ListAttr['ext']);
		$the_image = $ListAttr['img'].'.'.$ListAttr['ext'];
		$ListAttr['alt'] = htmlspecialchars($ListAttr['alt']);
		$ListAttr['title'] = htmlspecialchars($ListAttr['title']);

		if ($ListAttr['align'])	
			$align = ' align="'.$ListAttr['align'].'"';
		else 
			$align="";
			
		if ($ListAttr['rel']) {
			$rel = ' rel="'.$ListAttr['rel'].'"';
		} else {
			$rel = $this->lightbox;
		}

		// Prepare parameter for thumbnail
		$arg = 	'ALTAPPEND='.get_pt_options('p_append_text').
			'&WIDTH='.get_pt_options('p_resize_width').
			'&HEIGHT='.get_pt_options('p_resize_height').
			$this->addArg;

		// Retrieve thumbnail
		$t = new pt_thumbnail (get_pt_options_all(), $the_image, $arg);
		$add_tag = $align;

		// Add thumbnail & highslide expand to image
		if (POSTTHUMB_USE_HS) {
			$h = new pt_highslide ($the_image, $t->thumb_url, $ListAttr['alt']);
			$h->set_borders (get_pt_options('ovframe'));
			$h->set_title ($ListAttr['title']);
			if ($this->p_has_caption)
				$h->set_caption (addslashes($ListAttr['alt']));
			$h->set_html_size();
			$h->set_href_text('', $add_tag);
			$h_str = $h->highslide_link ();
			unset ($h);
		}
		// Add thumbnail & thickbox/smoothbox class to image
		elseif (POSTTHUMB_USE_TB || POSTTHUMB_USE_SB) {
			$h = new pt_thickbox ($the_image, $t->thumb_url, $ListAttr['alt']);
			$h->set_href_text('', $add_tag);
			$h_str = $h->thickbox_link ();
			unset ($h);
		}
		// Simple replacement by thumbnail linked to image
		else $h_str = '<a href="'.$the_image.'" title="'.$ListAttr['title'].'" '.$rel.' ><img src="'.$t->thumb_url.'" alt="'.$ListAttr['alt'].'"'.$align.' /></a>';

		unset ($t);

		return $h_str;
	}
	/****************************************************************/
	/* Filter function (if Highslide is activated)
	/****************************************************************/
	function ReplaceWTMedia($content) {
	
		if (pt_stripos($content, '[MEDIA=') === false) return $content;

		// Replace wordTube MEDIA with parameters
		$pattern = '@(?:<p>)*\s*\[MEDIA=([0-9]+%?)\]\s*(?:</p>)*@i';
		if (preg_match_all($pattern, $content, $matches, PREG_SET_ORDER)) {
			
			$play_width = get_pt_options('wordtube_pwidth');
			$play_height = get_pt_options('wordtube_pheight');
			
			foreach ($matches as $match) :

				$replacement = $this->GetwordTubeMedia($match[1], $play_width, $play_height);
				if ($replacement != '') $content = str_replace($match[0], $replacement, $content);
				$i++;

        		endforeach;
		}
		
		$pattern = '@(?:<p>)*\s*\[MEDIA=([0-9]+%?)(.*?)\]\s*(?:</p>)*@i';
		if (preg_match_all($pattern, $content, $matches, PREG_SET_ORDER)) {
		
			foreach ($matches as $match) :

				$str_match = strtoupper($match[0]);
				if (preg_match('/\[(.*?)WIDTH=([0-9]+%?)(.*?)\]/i', $str_match, $foo3))
					$play_width = $foo3[2];
				else 
					$play_width = get_pt_options('wordtube_pwidth');
					
				if (preg_match('/\[(.*?)HEIGHT=([0-9]+%?)(.*?)\]/i', $str_match, $foo4))
					$play_height = $foo4[2];
				else 
					$play_height = get_pt_options('wordtube_pheight');

				$replacement = $this->GetwordTubeMedia($match[1], $play_width, $play_height);
				if ($replacement != '') $content = str_replace($match[0], $replacement, $content);
				$i++;

	        	endforeach;
		}
	
		return $content;
	}
	/****************************************************************/
	/* Filter function (if Highslide is activated)
	/****************************************************************/
	function ReplaceWTPlaylist($content) {
	
		global $wpdb;
		if (is_feed()) return $content;
		if (pt_stripos($content, '[PTPLAYLIST=') === false) return $content;

		// Replace wordTube post-thumb ptplaylist
		$pattern = '@(?:<p>)*\s*\[PTPLAYLIST=\((.*?)\)(.*?)]\s*(?:</p>)*@i';
		if (preg_match_all($pattern, $content, $matches, PREG_SET_ORDER)) {

			foreach ($matches as $match) :

				$str_match = strtoupper($match[0]);
				$vid_array = explode(",",$match[1]);
				if ($match[1] != '0') $where = "WHERE vid IN ('" . implode("','", $vid_array) . "')";
				$dbresults = $wpdb->get_results("SELECT * FROM $wpdb->wordtube $where");

				if ($dbresults) {
					$replacement = '';
					$mp3 = strpos($str_match, 'MP3');
					$flv = strpos($str_match, 'FLV');
					if (preg_match('/\[(.*?)WIDTH=([0-9]+%?)(.*?)\]/i', $str_match, $foo3))
						$play_width = $foo3[2];
					else 
						$play_width = get_pt_options('wordtube_pwidth');
						
					if (preg_match('/\[(.*?)HEIGHT=([0-9]+%?)(.*?)\]/i', $str_match, $foo4))
						$play_height = $foo4[2];
					else 
						$play_height = get_pt_options('wordtube_pheight');

					foreach ($dbresults as $media) :

						$replacement .= $this->ReturnMediaFromPlaylist($media, $play_width, $play_height, $mp3, $flv);
							
	        			endforeach;
	        			$content = str_replace($match[0], $replacement, $content);
				}
				unset($dbresults);
				$i++;
			endforeach;
		}

		// Replace wordTube ptplaylist
		$pattern = '@(?:<p>)*\s*\[PTPLAYLIST=([0-9]+%?)(.*?)]\s*(?:</p>)*@i';
		if (preg_match_all($pattern, $content, $matches, PREG_SET_ORDER)) {

			foreach ($matches as $match) :

				$str_match = strtoupper($match[0]);

				$dbresults = $this->GetwordTubePlaylist($match[1]);
	
				if ($dbresults) {
				
					$replacement = '';
					$mp3 = pt_stripos($str_match, 'MP3');
					$flv = pt_stripos($str_match, 'FLV');
					if (preg_match('/\[(.*?)WIDTH=([0-9]+%?)(.*?)\]/i', $str_match, $foo3))
						$play_width = $foo3[2];
					else 
						$play_width = get_pt_options('wordtube_pwidth');
						
					if (preg_match('/\[(.*?)HEIGHT=([0-9]+%?)(.*?)\]/i', $str_match, $foo4))
						$play_height = $foo4[2];
					else 
						$play_height = get_pt_options('wordtube_pheight');

					foreach ($dbresults as $media) :

						$replacement .= $this->ReturnMediaFromPlaylist($media, $play_width, $play_height, $mp3, $flv);

	        			endforeach;
	        			$content = str_replace($match[0], $replacement, $content);
				}
				unset($dbresults);

			endforeach;
		}

		return $content;
	}
	/****************************************************************/
	/* Returns wordTube media
	/****************************************************************/
	function ReturnMediaFromPlaylist($media, $play_width, $play_height, $mp3, $flv, $arg='') {

		$replacement = '';
		if ($mp3 || $flv) {
			
			$med_url = pathinfo($media->file);
			if ($mp3) {

				if (strtoupper($med_url['extension']) == 'MP3') {
					$replacement = $this->GetVideo($media->name, $media->file, $media->image, $play_width, $play_height, $arg, $media->vid);
				}
              					}
			if ($flv) {

				if (strtoupper($med_url['extension']) == 'FLV') {
					$replacement = $this->GetVideo($media->name, $media->file, $media->image, $play_width, $play_height, $arg, $media->vid);
				}
			}
		}
		else 
			$replacement = $this->GetVideo($media->name, $media->file, $media->image, $play_width, $play_height, $arg, $media->vid);
		
		return $replacement;
	}
	/****************************************************************/
	/* Returns wordTube media
	/****************************************************************/
	function GetwordTubeMedia($vid, $play_width, $play_height, $arg='') {

        	global $wpdb;

		$select = " SELECT * FROM $wpdb->wordtube WHERE vid = ".$vid;
		$media = $wpdb->get_row($select);
		if ($media)
			return $this->GetVideo($media->name, $media->file, $media->image, $play_width, $play_height, $arg, $vid);
		else
			return '';
	}
	/****************************************************************/
	/* Returns wordTube playlist
	/****************************************************************/
	function GetwordTubePlaylist($pid) {

        	global $wpdb;

		if ($pid == '0') 
			$select = " SELECT * FROM {$wpdb->wordtube} ORDER BY vid DESC";
		else
			$select = " SELECT * FROM {$wpdb->wordtube} w
				INNER JOIN {$wpdb->wordtube_med2play} m
				WHERE (m.playlist_id = '".$pid."' AND m.media_id = w.vid)
				GROUP BY w.vid 
				ORDER BY m.rel_id DESC";
 
		return $wpdb->get_results($select);

	}
	/****************************************************************/
	/* Returns formatted wordTube playlist
	/****************************************************************/
	function GetWTMedia ($vid, $arg='', $play_width=0, $play_height=0) {
	
		if ($play_width == 0) $play_width = get_pt_options('wordtube_pwidth');
		if ($play_height == 0) $play_height = get_pt_options('wordtube_pheight');

		$replacement = $this->GetwordTubeMedia($vid, $play_width, $play_height, $arg);
		
                return $replacement;
	}	
	/****************************************************************/
	/* Returns formatted wordTube playlist
	/****************************************************************/
	function GetWTPlaylist($pid, $arg='', $play_width=0, $play_height=0, $mp3=false, $flv=false) {
	
		if ($play_width == 0) $play_width = get_pt_options('wordtube_pwidth');
		if ($play_height == 0) $play_height = get_pt_options('wordtube_pheight');

		$new_args = pt_parse_arg($arg);

		if (isset($new_args['LIMIT'])) { $limit = $new_args['LIMIT']; settype($limit,"integer"); } else $limit = 5;
		if (isset($new_args['OFFSET'])) { $offset = $new_args['OFFSET']; settype($offset,"integer"); } else $offset = 0;

		$l = $limit+$offset;

		$dbresults = $this->GetwordTubePlaylist($pid);
		if ($dbresults) {

			$replacement = '';
			$i=1;
			foreach ($dbresults as $media) :

				if ($i > $l) break;
	                	if ($i > $offset)
					$replacement .= $this->ReturnMediaFromPlaylist($media, $play_width, $play_height, $mp3, $flv, $arg);
				$i++;

       			endforeach;
		}
		unset ($dbresults);

                return $replacement;
	}	
	/****************************************************************/
	/* Filter function (if Highslide is activated)
	/****************************************************************/
	function ReplaceLinks($content) {
		$attrList=array ("src", "alt", "title", "align", "width", "height");
	
		if (is_feed()) return $content;
		if ((pt_stripos($content, 'rel="ptlink"') === false)
		and (pt_stripos($content, "rel='ptlink'") === false))
		return $content;

		$r_ID = rand();

		// Replace thumbnail
		$pattern = '/<a(.*?)href=[\'|"](.*?)[\'|"](.*?)><img([^>]*)rel\=[\'|"]ptlink[\'|"]([^>]*)\/><\/a>/i';
		if (preg_match_all($pattern,$content,$matches, PREG_SET_ORDER)) {
			$i=1;
			foreach ($matches as $match) :

				$ListAttr = pt_parseAtributes($match[4].$match[5], $attrList);
				$ListAttr['ext'] = substr(strrchr($ListAttr['src'], "."), 1);
				$ListAttr['img'] = substr($ListAttr['src'],0,strlen($ListAttr['src']) - (strlen($ListAttr['ext']) + 1) );

				$ID = $r_ID.$i;
				$main_url = $match[2];
				$thumb_url = $ListAttr['src'];
				if (POSTTHUMB_USE_HS) {

					if ($ListAttr['title'] == '') $title = $ListAttr['title'];
					else $title = $ListAttr['alt'];
					$h = new pt_highslide($main_url, $thumb_url, $title);
					$h->set_borders(get_pt_options('hsframe'));
					$h->set_href_text($match[8]);
               				$h->set_bottom(__('Direct link to: ', 'post-thumb').$title, $main_url);
					$h->set_size(get_pt_options('hs_width'), get_pt_options('hs_height'), get_pt_options('hsmargin'));

					$replacement = $h->highslide_link('iframe');
					unset($h);
				}
				elseif (POSTTHUMB_USE_TB) {
				}
				
       				$content = str_replace($match[0], $replacement, $content);
				$i++;
				
			endforeach;
		}

		return $content;

	}
	/****************************************************************/
	/* Filter function (if Highslide is activated)
	/****************************************************************/
	function ReplaceYoutube($content) {

		if (is_feed()) return $content;
		
                // Replace Youtube
		$pattern1 = '@(?:<p>)*\s*\[youtube=\((.*?)\)(.*?)\]\s*(?:</p>)*@i';
		$pattern2 = '@(?:<p>)*\s*\<a(.*?)href=[\'|"]http:\/\/youtube.com/watch\?v=(.*?)[\'|"](.*?)\</a\>\s*(?:</p>)*@i';
		$pattern3 = '@(?:<p>)*\s*\<object([^>]*)>([^>]*)\<param([^>]*)value=[\'|"]http:\/\/www.youtube.com\/v\/(.*?)[\'|"]\>\<\/param>([^>]*)\<param(.*?)\<\/object>\s*(?:</p>)*@is';
		$pat_title = '/(.*?)title=[\'|"](.*?)[\'|"]/i';

//		$pattern3 = '/\<object([^>]*)>([^>]*)\<param([^>]*)value=[\'|"]http:\/\/www.youtube.com\/v\/(.*?)[\'|"]>\<\/param>([^>]*)\<param([^>]*)>([^>]*)\<\/param>([^>]*)\<embed([^>]*)>([^>]*)\<\/embed>([^>]*)\</object>/is';

		if (pt_stripos($content, 'http://youtube.com/watch?v=') !== false) {
		if (preg_match_all($pattern2, $content, $matches, PREG_SET_ORDER)) {

			foreach ($matches as $match) :
				if (preg_match($pat_title, $match[0], $mat_title))
					$title = $mat_title[2];
				else
					$title = '';

				$thumb = 'http://img.youtube.com/vi/'.$match[2].'/0.jpg" width="'.get_pt_options('youtube_width').'" height="'.get_pt_options('youtube_height');
				$replacement = SetYoutubeVideo ($match[2], $title, $thumb, get_pt_options_all());
				$content = str_replace($match[0],$replacement, $content);

			endforeach;
		}
		}

		if (pt_stripos($content, 'http://www.youtube.com/v/') !== false) {
		if (preg_match_all($pattern3, $content, $matches, PREG_SET_ORDER)) {

			foreach ($matches as $match) :

				str_replace ('<p>'.$match[0].'</p>', $match[0], $content);
				if (preg_match($pat_title, $match[0], $mat_title))
					$title = $mat_title[2];
				else
					$title = '';
				
				$ytbID = explode('&', $match[4]);
				$thumb = 'http://img.youtube.com/vi/'.$ytbID[0].'/0.jpg" width="'.get_pt_options('youtube_width').'" height="'.get_pt_options('youtube_height');
				$replacement = SetYoutubeVideo ($ytbID[0], '', $thumb, get_pt_options_all());
				$content = str_replace($match[0],$replacement, $content);

			endforeach;
		}
		}

		if (pt_stripos($content, '[youtube=') !== false) {
		if (preg_match_all($pattern1, $content, $matches, PREG_SET_ORDER)) {

			foreach ($matches as $match) :

				str_replace ('<p>'.$match[0].'</p>', $match[0], $content);
				$thumb = 'http://img.youtube.com/vi/'.$match[1].'/0.jpg" width="'.get_pt_options('youtube_width').'" height="'.get_pt_options('youtube_height');
				if (preg_match($pat_title, $match[0], $mat_title))
					$title = $mat_title[2];
				else
					$title = '';

				$replacement = SetYoutubeVideo ($match[1], $title, $thumb, get_pt_options_all());
				$content = str_replace($match[0],$replacement, $content);

			endforeach;
		}
		}

		return $content;
	}
	/****************************************************************/
	/* Get category image
	/****************************************************************/
	function GetVideo ($name, $file, $image, $play_width, $play_height, $arg='', $vid) {

		// Init parameters
		$settings = '';
		$path = pathinfo($file);
		$extension = strtolower($path['extension']);
		$hs_width = $play_width;
		$ID = 'v'.rand();

		// Prepare the script string
		if ($extension == "flv") 
			$text = get_pt_options('wordtube_vtext');
		elseif ($extension == "mp3") { 
			$text = get_pt_options('wordtube_mtext');
			$playertype = get_wt_playertypemp3();
			if (get_wt_options('showeq')) $play_height=70; else $play_height = 20;
		}
				
		$new_args = pt_parse_arg($arg);

		if (isset($new_args['MYCLASSHREF'])) $myclasshref = $new_args['MYCLASSHREF']; else $myclasshref = '';
		if (isset($new_args['MYCLASSIMG'])) $myclassimg = ' class="'.$new_args['MYCLASSIMG'].'"'; else $myclassimg = '';

		// Get thumbnail
		if ($arg == '')
			$t = new pt_thumbnail(get_pt_options_all(), $image, 'keepratio=0&width='.get_pt_options('wordtube_width').'&height='.get_pt_options('wordtube_height').'&altappend='.get_pt_options('wordtube_text').'&textbox=1&text='.$text.$this->addArg);
		else 
			$t = new pt_thumbnail(get_pt_options_all(), $image, $arg.$this->addArg);
		$thumb_url = $t->thumb_url;
		unset($t);
		
		// returns custom message for RSS feeds
		if (is_feed()) {

			if (!empty($thumb_url)) $replace = '<br /><a href="'.$image.'"><img src="'.$thumb_url.'" alt="media"></a><br />'."\n"; 
			if (get_wt_options('activaterss')) $replace .= "[".get_wt_options('rssmessage')."]";
			return $replace;

		}
		// Prepare highslide html
		if (POSTTHUMB_USE_HS) {

	                $replace = SetWordTubeMedia ($file, $image, $play_width, $play_height, $ID, $extension, get_wt_playertype(), get_wt_options_all(), false, $vid);
			$h = new pt_highslide('#', $thumb_url, $name);
			$h->set_wrapClass('highslide-wrapper-wtb');
			$h->set_borders(get_pt_options('hsframe'));
			$h->set_size($play_width, $play_height, get_pt_options('hsmargin'));
			$h->set_href_text($name, $this->myclassimg.$this->align);
			$h->set_myclassimg($myclassimg);
			$h->set_myclasshref($myclasshref);
			$highslide = $h->highslide_link('swfObject', 'so'.$ID);
			unset($h);

			$replace .= $highslide;
		}
		elseif (POSTTHUMB_USE_TB || POSTTHUMB_USE_SB) {

       	                $replace = SetWordTubeMedia ($file, $image, $play_width, $play_height, $ID, $extension, get_wt_playertype(), get_wt_options_all(), true, $vid);
			$h = new pt_thickbox('', $thumb_url, $name);
			$h->set_size($play_width+5, $play_height+10);
			$h->set_href_text($name);
			$h->set_myclasshref($myclasshref);
			$h->set_body($replace);
			$replace = $h->thickbox_link('swfObject', $ID);

			unset($h);
		}

		return $replace;

	}
	/****************************************************************/
	/* Get category image
	/****************************************************************/
	function GetYoutube ($id, $title, $thumb) {
	
		return SetYoutubeVideo ($id, $title, $thumb, get_pt_options_all());
		
	}
	/****************************************************************/
	/* Includes features in header
	/****************************************************************/
	function include_header() {


	}
}

?>