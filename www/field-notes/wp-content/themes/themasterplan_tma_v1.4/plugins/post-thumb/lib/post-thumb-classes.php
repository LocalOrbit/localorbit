<?php
/**********************************************************************
	Class: pt_thumbnail
	Generate a thumbnail from an image url
	Returns:
		$this->thumb_url	: thumbnail url
		$this->thumb_path	: thumbnail path on server
**********************************************************************/
class pt_thumbnail {

	var $settings;
	var $arg;

	var $the_image;
	var $extension;

	var $thumb_url;
	var $thumb_path;

	var $sub_folder;
	var $alt_append;
	var $alt_append2;
	var $append;
	var $resize_width=0;
	var $resize_height=0;
	var $crop_x=0;
	var $crop_y=0;
	var $keep_ratio=false;
	var $max=false;
	var $rounded=false;
	var $base_name=false;
	var $textBox;
	var $text;
	var $dirname = false;

	var $width = 0;
	var $height = 0;
	var $use_png = false;
	var $use_jpg = false;

	var $error = false;
	var $defaultimg;

	var $exttype = array('jpg', 'png', 'jpeg', 'gif', 'JPG', 'JPEG', 'PNG', 'GIF');
	var $speChar = array( ' ' => '%20');

	/****************************************************************/
	/* Constructor
	/****************************************************************/
	function pt_thumbnail ($settings, $img_url='', $arg='', $default = false) {

		$this->the_image	= NormalizeURL(clean_url($img_url));
		$this->settings 	= $settings;
		$this->arg 		= $arg;
		$this->defaultimg	= $default;

		$this->parse_arg();
		$this->get_thumbnail();
		unset($settings);
	}

	/****************************************************************/
	/* Retrieve all parameters
	/****************************************************************/
        function parse_arg () {
        
		$new_args = pt_parse_arg($this->arg);

		if (isset($new_args['SUBFOLDER']))
			$this->sub_folder = '/'.$new_args['SUBFOLDER'];
		else $this->sub_folder ='';
		$this->sub_folder = $this->test_folder($this->sub_folder);

		if (isset($new_args['DIRNAME'])) $this->dirname = (int) $new_args['DIRNAME'];

		if (isset($new_args['ALTAPPEND']))
			$this->alt_append = $new_args['ALTAPPEND'];
		else
			$this->alt_append = $this->settings['append_text'];

		if (isset($new_args['APPEND']))
			$this->append = ($new_args['APPEND']==1);
		else
                	$this->append = ($this->settings['append'] == 'true');

		if (isset($new_args['ADDAPPEND']))
			$this->alt_append2 = $new_args['ADDAPPEND'];
		else
			$this->alt_append2 = '';

		if (isset($new_args['WIDTH']))
			$this->resize_width = $new_args['WIDTH'];
                else 
			$this->resize_width = (int) $this->settings['resize_width'];

		if (isset($new_args['HEIGHT']))
			$this->resize_height = $new_args['HEIGHT'];
                else
			$this->resize_height = (int) $this->settings['resize_height'];

		if (isset($new_args['HCROP']))
			$this->crop_x = $new_args['HCROP'];
		else
			$this->crop_x = 0;

		if (isset($new_args['VCROP']))     
			$this->crop_y = $new_args['VCROP'];
		else
			$this->crop_y = 0;

		if (isset($new_args['KEEPRATIO']))
			$this->keep_ratio = ($new_args['KEEPRATIO']==1);
		else
                	$this->keep_ratio = ($this->settings['keep_ratio'] == 'true');

		if (isset($new_args['MAX']))
			$this->max = ($new_args['MAX']==1);
		else
                	$this->max = ($this->settings['max'] == 'true');

		if (isset($new_args['MIME'])) {
			$this->use_png = ($new_args['MIME']=='png');
			$this->use_jpg = ($new_args['MIME']=='jpg');
		}
                else
                	$this->use_png = ($this->settings['use_png'] == 'true');

		if (isset($new_args['ROUNDED']))
			$this->rounded = ($new_args['ROUNDED']==1);
		else
                	$this->rounded = ($this->settings['rounded'] == 'true');

		if ($this->rounded) $this->use_png = true;

		if (isset($new_args['BASENAME']))
			$this->base_name = ($new_args['BASENAME']==1);
		else 
			$this->base_name = false;

		if (isset($new_args['TEXTBOX']))
			$this->textBox = ($new_args['TEXTBOX']==1);
                else 
                	$this->textBox = false;

		if (isset($new_args['TEXT']))
			$this->text = $new_args['TEXT'];
                else 
                	$this->text = '';
	}
	/****************************************************************/
	/* Creates and returns thumbnail
	/*
	/* Fix for Dreamhost: Dreamhost cannot deal with imagecreatefromstring
	/****************************************************************/
	function get_thumbnail() {
	
		// Save image info
                $the_image_server = $this->the_image;
                $the_image_server = str_replace($this->settings['full_domain_name'], $this->settings['base_path'], $this->the_image);   // Fix for Dreamhost
		$the_image_server = $this->imageFilter();                
                $is_remote  = ($this->image == $the_image_server);                                                                      // Fix for Dreamhost
		$dest_path = pt_pathinfo($the_image_server);

		// Build dir to save thumbnail to
		$save_dir = $this->settings['base_path'].'/'.$this->settings['folder_name'].$this->sub_folder;
		$save_url = $this->settings['full_domain_name'].'/'.$this->settings['folder_name'].$this->sub_folder;

		// If file extension is not known, assume it's a redirect url
		if ($dest_path['extension']== '' || !in_array($dest_path['extension'], $this->exttype)) {
			$dest_path = $this->urlFilter($save_dir, $save_url);
		}
				
		// Set directory name if it needs to be included in thumbnail's name
		if ($this->dirname > 0) {
			$dirname = $this->dirDecode($dest_path['dirname']);
		} else $dirname='';

		// Find extension to use for thumbnail
		if ($this->use_png) 	$this->extension = 'png';
                elseif ($this->use_jpg)	$this->extension = 'jpg';
                else			$this->extension = strtolower($dest_path['extension']);
                if ($this->extension == '') $this->extension = 'jpg';

		// Builds thumbnail file name
		$filename = $dirname.$this->nameFilter($dest_path['filename']);
		if ($this->defaultimg)
			$filename = $filename.$this->resize_width.'x'.$this->resize_height;
		if ($this->base_name)
			$rename_to = $this->alt_append.$this->alt_append2.'.'.$this->extension;
		elseif ($this->append == 'true')
			$rename_to = $filename.$this->alt_append.$this->alt_append2.'.'.$this->extension;
		else
			$rename_to = $this->alt_append.$filename.$this->alt_append2.'.'.$this->extension;
		$rename_to = sanitize_file_name($rename_to);

		// checks if file already exists - returns location if it does
		// If basename, force thumbnail generation
		if (file_exists($save_dir.'/'.$rename_to) && (!$this->base_name)) {
                        $this->thumb_url 	= $this->settings['full_domain_name'].'/'.$this->settings['folder_name'].$this->sub_folder.'/'.$rename_to;
			$this->thumb_path   	= $save_dir.'/'.$rename_to;
		}

		// check if image exists. If doesn't exist, can't do anything so return default image
                elseif (false === remote_file_exists($this->the_image)) {
			$this->thumb_url 	= $this->settings['full_domain_name'].$this->sub_folder."/".$this->settings['default_image'];
			$this->thumb_path   	= $this->settings['base_path']."/".$this->settings['default_image'];
		}

		// if file has to be generated, generates thumbnails
		else {
			$this->thumb_url 	= $this->settings['full_domain_name']."/".$this->settings['folder_name'].$this->sub_folder."/".$rename_to;
			$this->thumb_path   	= $save_dir.'/'.$rename_to;

			// Create the image
//			$thumb = new ImageEditor($this->the_image,'', '', $this->settings);
			$thumb = new ImageEditor($the_image_server,'', '', $this->settings, $is_remote);          // Fix for Dreamhost
                        if ($thumb->img_error || $thumb->error) {
				unset($thumb);
				$this->error = true;
				return false;
			}

			// Set output type if different from image
			$thumb->setImageType($this->extension);

	                // Resize image
			$thumb->resize($this->resize_width, $this->resize_height, $this->crop_x, $this->crop_y, $this->keep_ratio, $this->max);
			
			// Round corner if option is checked
			if ($this->rounded) {
				$thumb->setImageType('png');
				$thumb->rounded($this->settings['corner_ratio']);
			}

			// Adds text box if option is checked
			if ($this->textBox && $this->text<>'') $thumb->AddBox (true, 0, 0, 0, 15, $this->text, 255, 255, 255, 15);

	                if (!$thumb->error) {
		                // If no error so far, saves thumbnail on server
				$thumb->outputFile($save_dir."/".$rename_to, "", $this->settings['jpg_rate'], $this->settings['png_rate']);

	        	        // Get thumbnail size (may be different from resize size)
				$this->width = $thumb->getWidth();
				$this->height = $thumb->getHeight();
			}
			else
				$this->error = true;

			unset($thumb);
                }
	}
	/****************************************************************/
	/* Change the url if url is a redirect. Sets up for gallery2.
	/****************************************************************/
	function dirDecode($url) {
		$url_dec = explode('/', str_replace('\\', '/', $url));
		$dir1 = end($url_dec);
		if ($this->dirname > 1) {
			$i=1;
			while ($i<$this->dirname) {
				$tmp = prev($url_dec);
				if (strpos($tmp, ':') !== false || strpos($tmp, '.') !== false) break;
				$dir1 = $tmp.$dir1;
				$i++;
			}
		}
		return sanitize_file_name($dir1);
	}
	/****************************************************************/
	/* Check url. Set up for ngg & Dreamhost.
	/****************************************************************/
	function ImageFilter() {
		global $wpdb;

		$url = str_replace ('&amp;','&', $this->the_image);

		// Filters ngg singlepic
		if (pt_stripos($url, "nggshow.php")) {
			$pos = strpos($url, 'pid=')+4;
			$ngg_pid = explode('&', substr($url, $pos));
			$ngg_pic = $wpdb->get_row("SELECT filename, galleryid FROM $wpdb->nggpictures WHERE pid = '$ngg_pid[0]' ");
			if ($ngg_pic) {
				$gallery_path = $wpdb->get_var("SELECT path FROM $wpdb->nggallery WHERE gid = '$ngg_pic->galleryid' ");
				$this->the_image = SITEURL.'/'.$gallery_path.'/'.$ngg_pic->filename;;
			}
		}

                $the_image_server = str_replace($this->settings['full_domain_name'], $this->settings['base_path'], $this->the_image);   // Fix for Dreamhost

		return $the_image_server;                
	}
	/****************************************************************/
	/* Change the url if url is a redirect. Sets up for gallery2.
	/****************************************************************/
	function urlFilter($save_dir, $save_url) {
		global $wpdb;

		$url = str_replace ('&amp;','&', $this->the_image);

		// Filters gallery2 names
		if (pt_stripos($url, "g2_itemId=")) {
			$g2_image = explode("g2_itemId=", $url);
			$g2_id = explode('&', $g2_image[1]);
			$uri = 'wpg2-'.$g2_id[0].'.jpg';
			$save_dir .= '/'.$uri;
			$save_url .= '/'.$uri;
			if ($file = @file_get_contents($save_url)) {
				if ($handle = @fopen($save_dir, 'a')) {
					fwrite ($handle, $file);
					fclose($handle);
				}
			}
			$this->the_image = $save_url;
		}
	
		return pt_pathinfo($save_url);
	}
	/****************************************************************/
	/* Tests and creates sufolder. If cannot, return blank.
	/****************************************************************/
	function nameFilter($rename_to) {

		$rename_to = str_replace ('%20', '_', $rename_to);
		$rename_to = str_replace ('%', '_', $rename_to);
		$rename_to = str_replace (' ', '_', $rename_to);
		
		// Filters gallery2 names
		if (pt_stripos($rename_to, "g2_itemId=")) {
			$rename_to = str_replace ('&amp;', '&', $rename_to);
			$g2_image = explode("g2_itemId=", $rename_to);
			$g2_id = explode('&', $g2_image[1]);
			$rename_to = 'wpg2-'.$g2_id[0];
		}
		
		return $rename_to;
	}
	/****************************************************************/
	/* Tests and creates sufolder. If cannot, return blank.
	/****************************************************************/
	function test_folder($sub_folder) {
	
		if ($sub_folder == '/' || $this->settings['safe_mode']=='true') return '';
		
 		$tempdir = $this->settings['base_path'].'/'.$this->settings['folder_name'].$sub_folder;
 		if (wp_mkdir_p($tempdir)) return $sub_folder; else return '';
 		
		return '';
	}
	/****************************************************************/
	/* Creates and returns thumbnail
	/****************************************************************/
	function sanitize_url($url) {
		foreach ($this->speChar as $key => $value) :
			$url = str_replace($key, $value, $url);
		endforeach;
		return $url;
	}

}  // End of pt_thumbnail class

/**********************************************************************
	Class: pt_post_thumbnail
	Generate a html linked to a post. This html:
		- can contain a thumbnail from an image of the post
		- can show several informations from the post
	Returns:
        	$this->html
		$this->thumb_url	: thumbnail url
		$this->thumb_path	: thumbnail path on server
		$this->the_image	: url of the linked image
**********************************************************************/
class pt_post_thumbnail {

	var $post;
	var $settings;
	var $arg;
	var $the_default_image;       // Image to use first
	var $permalink;
	var $default_title;
	var $default_date;
	var $default_author;
	var $default_link;
	var $search;
	
	var $post_url;
	var $media_url;
	var $media_title;

	var $meta_content = false;

	var $the_image;
	var $extension;
	var $has_image = true;
	var $has_media = false;
	var $has_youtube = false;
	var $has_caption;

	var $thumb_url;
	var $thumb_path;

	var $html;
	var $title;

	var $alt_text;
	var $use_catname;
	var $show_title = '';
	var $img_title;
	var $myclasshref = '';
	var $myclassimg = '';
	var $LB_effect = false;
	var $showpost = false;
	var $showlink = false;
	var $link = 'i';
	var $align = '';
	var $ajax = false;

	var $nodef;
	var $def_image = false;		// True if no image or media in post
	var $def_url;
	var $width;
	var $height;
	var $resize_width;
	
	var $n = "\n";
	var $nt = "\n\t";

	/****************************************************************/
	/* Constructor
	/****************************************************************/
	function pt_post_thumbnail ($settings, $post='', $arg='', $default_image='', $default_media='', $permalink='', $title='', $date='', $author='', $link='', $search=true) {

		// Get all parameters
		$this->post 	= $post;
		$this->settings = $settings;
		$this->arg 	= $arg;
		$this->the_default_image = $default_image;
		$this->the_default_media = $default_media;
		$this->permalink = $permalink;
		$this->default_title = $title;
		$this->default_date = $date;
		$this->default_author = $author;
		$this->default_link = $link;
		$this->search 	= $search;
		unset($settings);
		unset($post);
		
		// Init local parameters
		$path = pathinfo($this->the_default_media);
		$this->has_media = ($this->the_default_media != '' && $path['extension']!='');
		$this->has_youtube = ($this->the_default_media != '' && $path['extension']=='');
		$this->def_url  = $this->settings['full_domain_name']."/".$this->settings['default_image'];
		$this->use_hs	= ($this->settings['hs_use'] == 'true');
		$this->use_tb	= ($this->settings['tb_use'] == 'true');
		$this->use_sb	= ($this->settings['sb_use'] == 'true');
		if ($this->has_youtube) $this->arg .='&ADDAPPEND='.$this->the_default_media;

		// Sets title && use jLanguage if present
		if ($this->default_title != '')
			$this->title = $this->default_title;
		else 
			$this->title = $this->post->post_title;

		if (function_exists('jLanguage_processTitle'))
			$this->title = jLanguage_processTitle($this->title);

		// Init permalink
		if ($permalink == '')
			$this->post_url = get_permalink($this->post->ID);
		else
			$this->post_url = $permalink;

		// Set all the parameter options
		$this->parse_arg();
		
		// Check if image should be retrieved first from meta data
        	if ($this->settings['use_meta'] == 'true' && $this->search)
			$this->meta_content = get_post_meta($this->post->ID, 'pt_meta_thumb', true);

                // Get the image to thumbnailed
                if ($this->search)
			$this->search_the_image();
		else
                	$this->get_the_image();
		// Generate thumbnail
		$t = new pt_thumbnail ($this->settings, $this->the_image, $this->arg, $this->def_image);
		if ($t->error) {
			unset($t);
			$t = new pt_thumbnail ($this->settings, $this->def_url, $this->arg, true);
		}

		$this->thumb_url 	= $t->thumb_url;
		$this->thumb_path	= $t->thumb_path;
		$this->width 		= $t->width;
		$this->height 		= $t->height;

		unset($t);

		// Use $this->GetImgHTML(); to get output string

	}

	/****************************************************************/
	/****************************************************************/
        function parse_arg () {

		$new_args = pt_parse_arg($this->arg);

		if (isset($new_args['NOFORM'])) {
			$this->n = "";
			$this->nt = "";
		}

		if (isset($new_args['WIDTH']))
			$this->resize_width = $new_args['WIDTH'];
                else
			$this->resize_width = (int) $this->settings['resize_width'];

		$this->nodef = isset($new_args['NODEF']);
		$this->ajax = isset($new_args['AJAX']);

		if (isset($new_args['ALTTEXT']))
			$this->alt_text = str_clean ($new_args['ALTTEXT']);
                else {
			if ($this->post->post_title == '')
				$this->alt_text = $this->default_title;
			else
				$this->alt_text = $this->post->post_title;
		}

		if (isset($new_args['USECATNAME'])) 
			$this->use_catname = ($new_args['USECATNAME']==1);
		else
			$this->use_catname = ($this->settings['use_catname']=='true');

		if (isset($new_args['SHOWTITLE']) && $new_args['SHOWTITLE'] != '')
			$this->show_title = $this->Return_Title($new_args['SHOWTITLE']);

		if (isset($new_args['CAPTION']))
			$this->has_caption = ($new_args['CAPTION'] == 1);
		else 
			$this->has_caption = ($this->settings['caption']=='true');

		if (isset($new_args['TITLE']))
			$this->img_title = $this->Get_Title($new_args['TITLE']);
                else
			$this->img_title = $this->title;

		if (isset($new_args['MYCLASSHREF']))
			$this->myclasshref = $new_args['MYCLASSHREF'];

		if (isset($new_args['ALIGN']))
			$this->align = ' align="'.$new_args['ALIGN'].'"';

		if (isset($new_args['MYCLASSIMG']))
			$this->myclassimg = ' class="'.$new_args['MYCLASSIMG'].'"';

		if (isset($new_args['LB_EFFECT']))
			$this->LB_effect = ($new_args['LB_EFFECT']==1);

		if (isset($new_args['SHOWPOST']))
			$this->showpost = ($new_args['SHOWPOST']==1);

		if (isset($new_args['LINK'])) {
			$this->link = $new_args['LINK'];
			if ($this->link == 'p') $this->showpost=true;
			if ($this->link == 'u' && $this->default_link != '') $this->showlink=true;
		}
	}
	/****************************************************************/
	/****************************************************************/
	function get_the_image() {

 	        // if image is already given
		if ($this->the_default_image != '') {
			$this->the_image = $this->the_default_image;
		}

		// If no image, return default image
		else {
			$this->the_image = $this->def_url;
			$this->has_image = false;
			$this->def_image = true;
		}
	}
	/****************************************************************/
	/****************************************************************/
	function search_the_image() {


	        // if image is already given
		if ($this->the_default_image != '') {

			$this->the_image = $this->the_default_image;
		}

        	// finds an attachement to the post
        	elseif ($this->meta_content !== false && $this->meta_content != '') {
			// put matches into recognizable vars
			$this->the_image = $this->meta_content;
	        }

	        // finds an image from the post content
		elseif (preg_match('/<img(.*?)src=["'."']".'(.*?)["'."']".'(.*?)\/\>/i', $this->post->post_content, $matches)) {
			// put matches into recognizable vars
			$this->the_image = $matches[2];

			// detects if the image is already linked to a thumbnail
			$img_src = str_replace('/', '\/', $matches[2]);
			$pattern = '/<a(.*?)href=["'."']".'(.*?).(bmp|jpg|jpeg|gif|png)["'."']".'(.*?)>(.*?)<img(.*?)src=["'."']".$img_src.'["'."']".'(.*?)>/i';
			if (preg_match($pattern,$this->post->post_content,$matches))
				$this->the_image = $matches[2].'.'.$matches[3];
		}

                // If no image found in the post content - checks for video
	        elseif ($this->use_catname) {
	        	$this->Get_DefaultCategory();
	        	$this->the_image = $this->def_url;
			$this->has_image = false;
		}

                // If no image found in the post content - checks for video
	        elseif (!empty($this->settings['video_regex']) && $this->content_check_video()) {
			$this->the_image = $this->settings['full_domain_name']."/".$this->settings['video_default'];
			$this->has_image = false;
		}

                // If no image found yet - checks for videostream
	        elseif ($this->settings['stream_check']=='true' && $this->content_check_stream()) {
			$this->the_image = $this->check_stream();
			$this->has_image = false;
		}

                // If really no image, return default image
		else {
			$this->the_image = $this->def_url;
			$this->has_image = false;
			$this->def_image = true;
		}
	}
	/****************************************************************/
	/* Returns html string with link and thumbnail
	/****************************************************************/
	function GetImgHTML() {

		if ($this->def_image && $this->nodef) return '';
		
		// Starts Highslide output
		if ($this->LB_effect && $this->use_hs) {

			// If showpost true, or post doesn't has picture, and post doesn't have media
			if ($this->showpost || $this->showlink || (!$this->has_image && !$this->has_media && !$this->has_youtube)) {

				if ($this->showlink) $link = $this->default_link; else $link = $this->post_url;
				$h = new pt_highslide($link, $this->thumb_url, $this->title);
				$h->set_wrapClass('highslide-wrapper');
				$h->set_borders($this->settings['hsframe']);
				$h->set_href_text($this->img_title, $this->myclassimg.$this->align);
				$h->set_myclassimg($this->myclassimg);
				$h->set_myclasshref($this->myclasshref);
				$h->set_bottom(__('Direct link to: ', 'post-thumb').$this->title, $link);
				$h->set_size($this->settings['hs_width'], $this->settings['hs_height'], $this->settings['hsmargin']);
				if ($this->ajax)
					$this->html = $h->highslide_link('ajax');
				else
					$this->html = $h->highslide_link('iframe');
				unset($h);
			}

	                // If a media is given, links to the media
			elseif ($this->has_media) {

				$this->html = $this->GetVideo ($this->title, $this->the_default_media, $this->thumb_url, $this->settings['wordtube_pwidth'], $this->settings['wordtube_pheight']);

			}

	                // If a media is given, links to the media
			elseif ($this->has_youtube) {

				$this->html = SetYoutubeVideo ($this->the_default_media, $this->title, $this->thumb_url, $this->settings, $this->myclassimg.$this->align);

			}

			// Otherwise, links to picture
	                else {

				$h = new pt_highslide($this->the_image, $this->thumb_url, $this->title);
				$h->set_borders ($this->settings['ovframe']);
				$h->set_myclassimg($this->myclassimg);
				$h->set_myclasshref($this->myclasshref);
				$h->set_href_text('', $this->align);
				if ($this->has_caption) $h->set_caption(htmlspecialchars(str_replace("'", "\'", $this->title), ENT_QUOTES));
				$this->html = $h->highslide_link('overlay');
				unset($h);
			}
		}

		// Starts Thickbox output
		elseif ($this->LB_effect && ($this->use_tb || $this->use_sb)) {

			// If an image and showpost false
			if ($this->showpost || $this->showlink || (!$this->has_image && !$this->has_media && !$this->has_youtube)) {

				if ($this->showlink) $link = $this->default_link; else $link = $this->post_url;
				$this->html = $this->n.'<a href="'.$link.'"';
		                $this->html .= ' title="'.$this->title.'"';
				if ($this->myclasshref !='') $this->html .= ' class="'.$this->myclasshref.'"';
				$this->html .= '>';

				$this->html .= $this->nt.'<img src="'.$this->thumb_url.'" alt="'.$this->alt_text.'"';
			        if ($this->myclassimg != '') $this->html .= $this->myclassimg;
		                $this->html .= ' />'.$this->n.'</a>';
				unset($h);

			}

	                // If a media is given, links to the media
			elseif ($this->has_media) {

				$this->html = $this->GetVideo ($this->title, $this->the_default_media, $this->thumb_url, $this->settings['wordtube_pwidth'], $this->settings['wordtube_pheight']);

			}

	                // If a media is given, links to the media
			elseif ($this->has_youtube) {

				$this->html = SetYoutubeVideo ($this->the_default_media, $this->title, $this->thumb_url, $this->settings, $this->myclassimg.$this->align);

			}

			else {
				$h = new pt_thickbox ($this->the_image, $this->thumb_url, $this->title);
				$h->set_myclasshref($this->myclasshref);
				$this->html = $h->thickbox_link('overlay');
				unset($h);
		        }
		}

		// Starts output using no javascript library
		else {
			if ($this->showpost || !$this->has_image)
				$this->html = $this->n.'<a href="'.$this->post_url.'"';
			elseif ($this->showlink)
				$this->html = $this->n.'<a href="'.$this->default_link.'"';
	                else
				$this->html = $this->n.'<a href="'.$this->the_image.'"';

	                $this->html .= ' title="'.htmlspecialchars($this->title).'"';
			if ($this->myclasshref !='') $this->html .= ' class="'.$this->myclasshref.'"';
			$this->html .= '>';

			$this->html .= $this->nt.'<img src="'.$this->thumb_url.'" alt="'.htmlspecialchars($this->alt_text).'"';
		        $this->html .= $this->myclassimg;
		        $this->html .= $this->align;
	                $this->html .= ' />'.$this->n.'</a>';
		}

		if ($this->show_title != '') $this->get_add_html();
		
		return $this->html;

	}
	/****************************************************************/
	/* Set additionnal html string with link and thumbnail
	/****************************************************************/
	function get_add_html() {

		$this->html .= $this->show_title;
	}
	/****************************************************************/
	/* Check if there is a video in content using REGEX
	/****************************************************************/
	function content_check_video() {

		return (preg_match('/'.$this->settings['video_regex'].'/i',$this->post->post_content,$matches));
	}
	/****************************************************************/
	/* Returns adhoc thumbnail for videostream
	/****************************************************************/
	function check_stream() {

		$the_image = '';
               // Tag for Youtube
		if (
			(pt_stripos($this->post->post_content, 'http://youtube.com/watch') !== false) ||
			(pt_stripos($this->post->post_content, 'http://www.youtube.com/v/') !== false) ||
			(pt_stripos($this->post->post_content, '[youtube') !== false)) 
		{
			$the_image = PT_URLPATH.'images/youtube.png';
		}


                // Tag for Dailymotion
		elseif (
			(pt_stripos($this->post->post_content, 'http://www.dailymotion.com/swf') !== false) || 
			(pt_stripos($this->post->post_content, 'http://www.dailymotion.com/video') !== false) ||
			(pt_stripos($this->post->post_content, '[dailymotion') !== false))
		{
			$the_image = PT_URLPATH.'/images/dailymotion.png';
		}

		// Tag for googlevideo
		elseif (
			(pt_stripos($this->post->post_content, 'http://video.google.fr/videoplay') !== false) || 
			(pt_stripos($this->post->post_content, 'http://video.google.com/videoplay') !== false) || 
			(pt_stripos($this->post->post_content, '[googlevideo') !== false))
		
		{
			$the_image = PT_URLPATH.'/images/gvideo.png';
		} 

		return $the_image;
	}
	/****************************************************************/
	/* Returns adhoc thumbnail for videostream
	/****************************************************************/
	function content_check_stream() {

		$test = $this->check_stream();
		return ($test != '');
	}
	/***********************************************************************************/
	/* Test if image in content
	/* $img_only = true  : return true if an image is found in the current post
	/* $img_only = false : return true if an image or a video is found in the current post
	/***********************************************************************************/
	function post_content_test($img_only=false) {

		// find an image from the post content
		if (preg_match('/<img(.*?)src=["'."']".'(.*?)["'."']".'/i',$this->post->post_content,$matches))
			return true;
	        else
	        {
			if (!empty($this->settings['video_regex']) && (!$img_only) && $this->content_check_video())
				return true;
			if (($this->settings['stream_check']) && (!$img_only) && ($this->content_check_stream()))
				return true;
			return false;
		}
	}
	/****************************************************************/
	/* Add post-thumb option SHOWTITLE
	/****************************************************************/
	function Return_Title ($showtitle='') {

		$arg = strtoupper($showtitle);
		$ret = $this->n.'<ul style = "width:'.$this->resize_width.'px;">';
		$sep = ', ';
		while ($arg <>'') :

			if (strlen($arg)==1) $sep = '';
			$option = substr($arg, 0, 1);
			$ret .= $this->Return_TitleOption ($option, $sep);
			$arg = substr($arg, 1);

	        endwhile;

		$ret .= $this->n.'</ul>';
		
		return $ret;

	}
	/****************************************************************/
	/* Add post-thumb option TITLE
	/****************************************************************/
	function Return_TitleOption ($option, $sep) {

		switch ($option) :
			case 'A':
				if ($this->default_author == '')
					$ret = $this->nt.'<li>'.get_author_name($this->post->post_author).$sep.'</li>';
				else
					$ret = $this->nt.'<li>'.$this->default_author.$sep.'</li>';
				break;
					
			case 'D':
				if ($this->default_date == '')
					$ret = $this->nt.'<li>'.substr($this->post->post_date, 0, 10).$sep.'</li>';
				else
					$ret = $this->nt.'<li>'.substr($this->default_date, 0, 10).$sep.'</li>';
				break;
					
			case 'E':
				$ret = $this->nt.'<li>'.excerpt_revisited($this->post->post_content, 40, $this->post_url).$sep.'</li>';
				break;

			case 'T':
				$ret = $this->nt.'<li><a href="'.$this->post_url.'">'.$this->title.'</a>'.$sep.'</li>';
				break;
					
		endswitch;

		return $ret;
	}
	/****************************************************************/
	/* Add post-thumb option TITLE
	/****************************************************************/
	function Get_Title ($title='') {
          
		$arg = strtoupper($title);
		switch ($arg) :
			case 'C':
				$ret = htmlspecialchars(excerpt_revisited($this->post->post_content, -1));
				break;
			case 'E':
				$ret = htmlspecialchars(excerpt_revisited($this->post->post_content, 40));
				break;
			case 'T':
                      		$ret = htmlspecialchars($this->post->post_title);
				break;
		endswitch;

		return $ret;
	}

	/****************************************************************/
	/* Get category image
	/****************************************************************/
	function Get_DefaultCategory () {

		if (get_bloginfo('version')>='2.1')
			$myposts = wp_get_post_categories($this->post->ID);
		else
			$myposts = wp_get_post_cats('1', $this->post->ID);
	
		$array_def = pt_pathinfo($this->def_url);
		$filename = $array_def['filename'];

		foreach ($myposts as $mypost) :

			$new_def = $array_def['dirname'].'/'.$filename.'cat-'.$mypost.'.'.$array_def['extension'];
			if (remote_file_exists($new_def)) {
                        	$this->def_url = $new_def;
                        	break;
			}
		endforeach;

	}
	/****************************************************************/
	/* Get category image
	/****************************************************************/
	function GetVideo ($name, $file, $image, $play_width, $play_height) {

		// Init parameters
		$settings = '';
		$path = pathinfo($file);
		$extension = strtoupper($path['extension']);
		$hs_width = $play_width;
		$ID = 'v'.rand();

		// Prepare the script string
		if ($extension == "FLV")
			$text = $this->settings['wordtube_vtext'];
		elseif ($extension == "MP3") 
			$text = $this->settings['wordtube_mtext'];
				

		// Prepare highslide html
		if (class_exists('pt_highslide')) {

	                $replace = SetWordTubeMedia ($file, $image, $play_width, $play_height, $ID, $extension, get_wt_playertype(), get_wt_options_all());
			$h = new pt_highslide('#', $this->thumb_url, $name);
			$h->set_wrapClass('highslide-wrapper-wtb');
			$h->set_borders($this->settings['hsframe']);
			$h->set_size($play_width, $play_height, $this->settings['hsmargin']);
			$h->set_href_text($name, $this->myclassimg.$this->align);
			$h->set_myclassimg($this->myclassimg);
			$h->set_myclasshref($this->myclasshref);
			$highslide = $h->highslide_link('swfObject', 'so'.$ID);
			unset($h);
	
			$replace .= $highslide;
		}
		elseif (class_exists('pt_thickbox')) {

       	                $replace = SetWordTubeMedia ($file, $image, $play_width, $play_height, $ID, $extension, get_wt_playertype(), get_wt_options_all(), true);
			$h = new pt_thickbox('', $this->thumb_url, $name);
			$h->set_size($play_width+5, $play_height+10);
			$h->set_href_text($name);
			$h->set_body($replace);
			$replace = $h->thickbox_link('swfObject', $ID);

		}
		
		return $replace;

	}

}  // End of pt_post_thumbnail class


?>
