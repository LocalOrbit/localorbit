<?php

################################################################################
########## Administration class
################################################################################
class PostThumbAdmin {

	// Version and path to check version
	var $PTRVERSION = '2.2';
	var $PTRURL = 'http://www.alakhnor.com/post-thumb/ptrversion.htm';

	var $settings;
	var $table_pt_post;
	var $tablestruct = " (post_id int(10) unsigned NOT NULL, body longtext NOT NULL ) ";
	var $tablequery = " post_id, body ";
	var $update_error = false;
	var $error_msg = '';

	var $BooleanList = array('safe_mode', 'rounded' , 'append', 'use_meta','use_png' ,'keep_ratio', 'max',
				'unsharp', 'use_catname', 'stream_check', 'hs_wordtube', 'wt_append', 'hs_youtube',
				'hs_use', 'caption', 'tb_use', 'sb_use', 'hs_post', 'p_keep_ratio', 'p_max', 'p_rounded', 'p_use_png',
				'pt_replace', 'p_caption', 'wt_media', 'wt_playlist', 'ytb_media', 'p_rel', 'p_lightbox');

	var $OptionList = array('updslice', 'append_text', 'resize_width', 'resize_height', 'wordtube_width', 'wordtube_height',
				'wordtube_pwidth', 'wordtube_pheight', 'wordtube_text', 'wordtube_vtext', 'wordtube_mtext', 
				'ovframe', 'hsframe', 'hs_width', 'hs_height', 'ovtopframe', 'unsharp_amount', 'unsharp_radius',
				'unsharp_threshold', 'corner_ratio', 'youtube_width', 'youtube_height',	'youtube_pwidth',
				'youtube_pheight', 'jpg_rate', 'png_rate', 'video_regex', 'bgcolor', 'hdcolor', 'ftcolor',
				'hsmargin', 'p_append_text', 'p_resize_width', 'p_resize_height', 'p_dirname', 'p_subfolder');
	
	/****************************************************************/
	/* Constructor
	/****************************************************************/
	function PostThumbAdmin() {
		global $wpdb;
			
		$this->settings = pt_GetStarterOptions();
		$this->table_pt_post = $wpdb->prefix . "pt_post";
		
		// add WP actions - not limited to is_admin() to be applied also in case of xmlrpc posts by external blogging application
		add_action('publish_post',		array(&$this, 'savePostImage'));
		add_action('edit_post',			array(&$this, 'savePostImage'));
		add_action('save_post',			array(&$this, 'savePostImage'));
		add_action('wp_insert_post',		array(&$this, 'savePostImage'));
		add_action('wp_insert_post',		array(&$this, 'savePostImage'));
		add_action('private_to_published',	array(&$this, 'savePostImage'));
		add_action('delete_post', 		array(&$this, 'deletePostImage'));

		// Header
		if ('deactivate' != $_GET['action']) {
			add_action('admin_head', 'pt_admin_include_header');
		}

		// Plugin activation
		add_action('activate_post-thumb/post-thumb.php', array(&$this, 'activate'));

		// add option screen menu
		add_action('admin_menu', array(&$this, 'options'));
		
		// check if we need to upgrade
		if ( $this->settings['version'] < $this->PTRVERSION  ) {
			// Execute installation
			$this->install();
				
			// Update version number in the options
			$this->settings['version'] = $this->PTRVERSION;
		}

	}
	/****************************************************************/
	/* Plugin activation
	/****************************************************************/
	function activate() {
		$this->install(false);
	}
	/****************************************************************/
	/* Add post-thumb option
	/****************************************************************/
	function options() {

		if (function_exists('add_options_page'))
			add_options_page('Post Thumb Revisited', 'Post Thumb', 8, basename(__FILE__), array(&$this, 'MenuOptions'));

	}
	/****************************************************************/
	/* Installation routine
	/****************************************************************/
	function install($show_results=true) {

		global $wpdb;

		// add charset & collate like wp core
		$charset_collate = '';
	
		if ( version_compare(mysql_get_server_info(), '4.1.0', '>=') ) {
			if ( ! empty($wpdb->charset) )
				$charset_collate = "DEFAULT CHARACTER SET $wpdb->charset";
			if ( ! empty($wpdb->collate) )
				$charset_collate .= " COLLATE $wpdb->collate";
		}
		
		// create post table if it doesn't exist
		$tablename = $this->table_pt_post;
        	$found = false;
        	foreach ($wpdb->get_results("SHOW TABLES;", ARRAY_N) as $row) {
        	
            		if ($row[0] == $tablename) {
                	$found = true;
                	break;
            		}
            		
        	}
        	
		// Drop table if previous version is older than 2.1.4 (format has changed)
		if ($found && $this->settings['version'] < '2.2') {
       				$res = $wpdb->query(" DROP TABLE ".$tablename);
       				$found = false;
		}
		
		if (!$found) {
		
            		$res = $wpdb->get_results("CREATE TABLE $tablename " . $this->tablestruct . $charset_collate);
	                $ptr2_options = pt_get_default_options();
			$ptr2_options['version'] = $this->PTRVERSION;
			update_option('post_thumbnail_settings', $ptr2_options);

			$count_posts = $wpdb->get_var("SELECT COUNT(*) FROM ".$wpdb->posts." WHERE post_type <> 'attachment'");
			$this->UpdatePostDB(0, $count_posts, $show_results);

		}
    	}

	/****************************************************************/
	/* Creates all record in DB
	/****************************************************************/
	function UpdatePostDB($llimit, $hlimit, $show_results=true) {

		global $wpdb;
		if ($show_results) echo '<p class="updated">'.__('Posts: ', 'post-thumb-admin').$llimit.' - '.$hlimit.' '.__('updated', 'post-thumb-admin').'</p>';
		$lines = $hlimit-$llimit;

		$dbresults = $wpdb->get_results(" SELECT * FROM ".$wpdb->posts." WHERE post_type <> 'attachment' LIMIT ".$llimit.",".$lines);
		foreach ($dbresults as $dbresult) :

			// Saves post data
			$this->StorePostData($dbresult);
 	
		endforeach;
		unset($dbresults);

	}
	/****************************************************************/
	/* save new list of post tags to database
	/****************************************************************/
	function savePostImage($id) {
	
		
		// authorization
		if ( !current_user_can('edit_post', $id) )
			return $id;

        	// clear old values first
		$this->deletePostImage($id);

		// Retrieve post content as list
		$post = &get_post($id);

		// skip drafts
		if ( !($post->post_status == 'publish' OR $post->post_status == 'static' OR $post->post_status == 'future'))
			return $id;

		// Saves post data
		$this->StorePostData($post);
		
	}

	/*******************************************************************************/
	/* Deletes a post record
	/*******************************************************************************/
	function GetMetacontent($id) {
	
		// finds an attachement to the post
       		if ($this->settings['use_meta'] == 'true') 
       			$metaContent = get_post_meta($id, 'pt_meta_thumb', true);
		else 
			$metaContent = '';
			
		return $metaContent;

	}
	/*******************************************************************************/
	/* Deletes a post record
	/*******************************************************************************/
	function StorePostData($post) {

        	global $wpdb;

 		$p = new postThumb($post);
		$metaContent = $this->GetMetacontent($p->post_id);
		$post->post_content = $this->apply_filters($post->post_content);

		// Check metacontent
		if ($metaContent != '') {

			$pattern1 = '/youtube=\((.*?)\)(.*?)/i';
			$pattern2 = '/MEDIA=([0-9]+%?)/i';
			if (preg_match($pattern1, $metaContent, $match)) {

				$p->image = 'http://img.youtube.com/vi/'.$match[1].'/0.jpg';
                                $p->media = $match[1];
	
			} elseif (preg_match($pattern2, $metaContent, $match)) {

					$media = $wpdb->get_row("SELECT * FROM $wpdb->wordtube WHERE vid = $match[1] ");
					if ($media) {
						$p->image = htmlspecialchars(addslashes($media->image));
						$p->media = htmlspecialchars(addslashes($media->file));
						if (pt_is_flv($media->file)) {
							$p->vwidth = $media->width;
							$p->vheight = $media->height;
						}
					}

			} else
				$p->image = $metaContent;
		}

		// If no meta content detected
		if ($p->image == '') {

	        	// finds an image from the post content
			if (preg_match('@<img([^>]*)\/>@si', $post->post_content, $matches)) {

				// put matches into recognizable vars
				$la = pt_parseAtributes($matches[0], array('src'));
				$p->image = $la['src'];

				// Prepare for RegEx
				$img_src = str_replace(array("%", "|", "@", ")", "("), array("\%", "\|", "\@", "\)", "\("), $p->image);

				// detects if the image is already linked to a thumbnail
				$pattern = '%<a([^>]*).(jpg|jpeg|png|gif)([^>]*)\>([^>]*)'.$img_src.'([^\<]*)\<\/a>%si';
				if (preg_match($pattern,$post->post_content,$matches)) {
					$la = pt_parseAtributes($matches[0], array('href'));
					$p->image = $la['href'];
				} 

				// detects if the image is linked to an url
				$pattern = '%<a([^>]*)>([^>]*)'.$img_src.'([^<]*)\<\/a>%i';
				if (preg_match($pattern,$post->post_content,$matches)) {
					$la = pt_parseAtributes($matches[0], array('href'));
					$p->image = $la['href'];
				}
			}

			// Search for wordTube MEDIA. Hope it won't change after that. Needs to be refreshed if it does.
			if ($this->settings['hs_wordtube'] == 'true') {
				$pattern = '/\[MEDIA=([0-9]+%?)\]/i';
				if (preg_match($pattern, $post->post_content, $match)) {
					
					$media = $wpdb->get_row("SELECT * FROM $wpdb->wordtube WHERE vid = $match[1] ");
					if ($media) {
						$p->image = htmlspecialchars(addslashes($media->image));
						$p->media = htmlspecialchars(addslashes($media->file));
						if (pt_is_flv($media->file)) {
							$p->vwidth = $media->width;
							$p->vheight = $media->height;
						}
					}
					
				}
			}
		 
			// Search for Youtube video.
			if ($this->settings['hs_youtube'] == 'true') {
	
				$pattern1 = '/\[youtube=\((.*?)\)(.*?)\]/i';
				$pattern2 = '/\<a(.*?)href="http:\/\/www\.youtube\.com\/watch\?v\=(.*?)"(.*?)\<\/a>/i';
				$pattern3 = '/\<object([^>]*)>([^>]*)\<param([^>]*)value=[\'|"]http:\/\/www.youtube.com\/v\/(.*?)[\'|"]\>\<\/param>([^>]*)\<param(.*?)\<\/object>/is';
				if (preg_match($pattern1, $post->post_content, $match)) {
	
					$p->image = 'http://img.youtube.com/vi/'.$match[1].'/0.jpg';
	                                $p->media = $match[1];
	
				} elseif (preg_match($pattern2, $post->post_content, $match)) {
	
					$p->image = 'http://img.youtube.com/vi/'.$match[2].'/0.jpg';
	                                $p->media = $match[2];
	
				} elseif (preg_match($pattern3, $post->post_content, $match)) {
	
					$ytbID = explode('&', $match[4]);
					$p->image = 'http://img.youtube.com/vi/'.$ytbID[0].'/0.jpg';
	                                $p->media = $ytbID[0];
				}
			}
		}

		if ($p->image != '') {
			// Retrieve categories. Again, this needs to be refreshed if categories change.
			$p->categories = $this->retrieveCategories($p->post_id);
			$this->savePost($p);
		}
		
		unset ($p);
		
	}
	/*******************************************************************************/
	/* Applies filters from other plugins
	/*******************************************************************************/
	function apply_filters($content) {

		if (function_exists('ngg_addjs')) {
			include_once (NGGALLERY_ABSPATH."nggfunctions.php");
			$content = searchnggallerytags($content);
		}
		if (function_exists('pta_replace_tag')) $content = pta_replace_tag($content);
		if (function_exists('g2_imagebyidinpost')) $content = g2_imagebyidinpost($content);
		if (function_exists('g2_imagebypathinpost')) $content = g2_imagebypathinpost($content);

		return $content;

	}
	/*******************************************************************************/
	/* Deletes a post record
	/*******************************************************************************/
	function deletePostImage($postid) {
		
		global $wpdb;

		if ( is_numeric($postid) || $postid > 0 ) { 
			$wpdb->query("DELETE FROM {$this->table_pt_post} WHERE post_id='$postid'");
			return true;
		} else {
			return false;
		}

	}
	/*******************************************************************************/
	/* Saves a post with its image
	/*******************************************************************************/
	function retrieveCategories($postid) {
	
		$catList = array();
		$categories = get_the_category($postid);
		foreach ($categories as $cat) :
			$catList[] = $cat->cat_ID;
		endforeach;
		$SerCatList = serialize($catList);
		
		return $SerCatList;
		
	}
	/*******************************************************************************/
	/* Saves a post with its image
	/*******************************************************************************/
	function savePost($p) {
	
		global $wpdb;
		
		$p_array = Array();
		$p_array['id'] 		= $p->post_id;
		$p_array['image_url'] 	= $p->image;
		$p_array['media_url'] 	= $p->media;
		$p_array['categories'] 	= $p->categories;
		$p_array['title'] 	= $p->title;
		$p_array['date'] 	= $p->date;
		$p_array['permalink'] 	= $p->permalink;
		$p_array['author'] 	= $p->author;
		$p_array['link'] 	= $p->link;
		$p_array['vwidth'] 	= $p->vwidth;
		$p_array['vheight'] 	= $p->vheight;
		
		$pObject = addslashes(serialize($p_array));
		
		$wpdb->query(" INSERT IGNORE INTO {$this->table_pt_post} ($this->tablequery) 
				VALUES ( '$p->post_id', '$pObject' )");

	}
	/*******************************************************************************/
	/* Option panel
	/*******************************************************************************/
	function MenuOptions() {
	
		global $wpdb;

		// Init parameters
		$count_posts = $wpdb->get_var("SELECT COUNT(*) FROM ".$wpdb->posts." WHERE post_type <> 'attachment'");
		
		if ($this->settings['updslice'] <= 0) $this->settings['updslice']=20;
		if ($count_posts < $this->settings['updslice']) 
			$post_slice = $this->settings['updslice']; 
		else 
			$post_slice = $this->settings['updslice'];
		$max_count = ceil($count_posts/$post_slice);
	
		$pa = parse_url(SITEURL);
		$dn = str_replace($pa['path'],"",SITEURL);
		$bp = str_replace($pa['path'],"",str_replace( "\\", "/",ABSPATH));
		$bp = substr($bp, 0, strlen($bp)-1);
		$pa['path'] = substr($pa['path'], 1, strlen($pa['path'])-1);

		// Detects wordTube
		$se = get_wordTubePath();
		if ($se == '') {
	        	$re='';
	                $wdet='';
		} else {
			$re = "MEDIA=";
	                $wdet='Wordtube detected. Path: ';
		}

		if (isset($_POST['info_update'])) {
		
			$this->RetrievePostOptions();
			
			// Update pt_posts table if some checked
			for ($i=1;$i<=$max_count;$i++) :
			
			  	$_POST['db_refresh'.$i]	= pt_GetBooleanOption ($_POST['db_refresh'.$i]);
				$llimit = ($i-1)*$post_slice;
				if ($i==$max_count) $hlimit = $count_posts; else $hlimit = $i*$post_slice;
				if ($_POST['db_refresh'.$i] == 'true') {
					$lines = $hlimit-$llimit;
					$array_posts = $wpdb->get_col(" SELECT ID FROM ".$wpdb->posts." WHERE post_type <> 'attachment' LIMIT ".$llimit.",".$lines);
					$array_posts = '( '.implode(',', $array_posts).' )';
					$wpdb->query(" DELETE FROM ".$this->table_pt_post." WHERE post_id IN ".$array_posts);
					$this->UpdatePostDB($llimit, $hlimit);
				}
			endfor;

		  	if (get_magic_quotes_gpc()) $_POST['video_regex'] = stripslashes($_POST['video_regex']);
		}

		// Validates options & displays error message
		$this->ValidateOptions();
		if ($this->update_error || isset($_POST['info_update'])) {
			?>
	        	<div class="updated">
	    			<?php if ($this->update_error) : ?>
	    				<strong><?php _e('Update error:', 'post-thumb-admin'); ?></strong> <?php echo $this->error_msg; ?>
	    			<?php else : ?>
					<?php if (isset($_POST['info_update'])) { ?>
	    					<strong><?php _e('Settings saved', 'post-thumb-admin'); ?></strong>
	    				<?php } ?>
	    			<?php endif; ?>
	    		</div>
			<?php
		}
		
		// Init parameters
		$count_posts = $wpdb->get_var("SELECT COUNT(*) FROM ".$wpdb->posts." WHERE post_type <> 'attachment'");
		
		if ($this->settings['updslice'] <= 0) $this->settings['updslice']=20;
		if ($count_posts < $this->settings['updslice']) 
			$post_slice = $this->settings['updslice']; 
		else 
			$post_slice = $this->settings['updslice'];
		$max_count = ceil($count_posts/$post_slice);

		// script for sliders
		?>
		<script type="text/javascript">
			jQuery(document).ready(function() {
				jQuery("#jpg_rate").attr("value", <?php echo $this->settings['jpg_rate']; ?> );
				jQuery("#png_rate").attr("value", <?php echo $this->settings['png_rate']; ?> );
			jQuery("#slider1").slider({
				minValue: 0,
				maxValue: 100,
				steps: 20,
				startValue: <?php echo $this->settings['jpg_rate']; ?>,
				slide: function(e,ui) {
					jQuery("#jpg_rate").attr("value", ui.value );
				}
			});
			jQuery("#slider2").slider({
				minValue: 0,
				maxValue: 9,
				startValue: <?php echo $this->settings['png_rate']; ?>,
				slide: function(e,ui) {
					jQuery("#png_rate").attr("value", ui.value );
				}
			});
		});
		</script>
		<?php

		$count_pt = $wpdb->get_var("SELECT COUNT(*) FROM ".$this->table_pt_post);
		$post_thumbnail_settings = pt_get_default_options();
		update_option('post_thumbnail_settings',$post_thumbnail_settings);

		?>
		<div class="wrap">
		<form method="post">

			<h2><?php _e('Post Thumb Revisited Options', 'post-thumb-admin'); ?></h2>
			<fieldset name="options">
        	
				<?php if ($this->version_check()) { ?>
					<p class="info"><?php _e('New Version available: ', 'post-thumb-admin'); ?>
					<?php _e('The server reports that a new Post-Thumb Revisited Version is now available. Please visit the plugin homepage for more information.', 'post-thumb-admin'); ?></p>
	                        <?php } else ?><?php _e('Version number: ', 'post-thumb-admin');echo $this->PTRVERSION; ?>
				<br /><br />
        			
			</fieldset>

			<ul id="submenu">
				<li><a href="#" id="aptover" onclick="showmenu('ptover'); return false;"><?php _e('Overview', 'post-thumb-admin'); ?></a></li>
				<li><a href="#" id="aptbasic" onclick="showmenu('ptbasic'); return false;"><?php _e('Basic options', 'post-thumb-admin'); ?></a></li>
				<li><a href="#" id="aptthumbnail" onclick="showmenu('ptthumbnail'); return false;"><?php _e('Thumbnail options', 'post-thumb-admin'); ?></a></li>
				<li><a href="#" id="aptadditional" onclick="showmenu('ptadditional'); return false;"><?php _e('Additional options', 'post-thumb-admin'); ?></a></li>
				<li><a href="#" id="aptjavascript" onclick="showmenu('ptjavascript'); return false;"><?php _e('Javascript options', 'post-thumb-admin'); ?></a></li>
				<li><a href="#" id="aptpost" onclick="showmenu('ptpost'); return false;"><?php _e('Post options', 'post-thumb-admin'); ?></a></li>
				<li><a href="#" id="apthelp" onclick="showmenu('pthelp'); return false;"><?php _e('Help', 'post-thumb-admin'); ?></a></li>
			</ul>

			<div id="ptover">
        			<input type="hidden" name="screen" value="over">
        			<h3><?php _e('Overview', 'post-thumb-admin'); ?></h3>
         	
        			<p class="title showhide"><?php _e('Post Table settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">

					<p class="tabs"><?php _e('Posts viewed by Post-Thumb: ', 'post-thumb-admin');echo $count_pt; ?></p><br />
					<p class="tabs"><?php _e('Posts in database: ', 'post-thumb-admin');echo $count_posts; ?></p>


					<?php           
					for ($i=1;$i<=$max_count;$i++) :
						$llimit = ($i-1)*$post_slice;
						if ($i==$max_count) $hlimit = $count_posts; else $hlimit = $i*$post_slice;
						echo '<input type="checkbox" name="db_refresh'.$i.'" />&nbsp;'.$llimit.'-'.$hlimit.'&nbsp;';
					endfor;
					?>		
					<br />

					<p class="tabs"><?php _e('Posts per update batch: ', 'post-thumb-admin'); ?></p>
					<input type="text" name="updslice" value="<?php echo $post_thumbnail_settings['updslice']; ?>" size="3" /><br />
					<br />

					<p class="info"><?php _e('Check this to refresh Post database. Cases when you need to refresh it: ', 'post-thumb-admin'); ?>
						<ul>
							<li><?php _e("You've changed one of the following options: 'Use metadata', 'Detect wordTube media', 'Detect Youtube'.", 'post-thumb-admin'); ?></li>
							<li><?php _e("You've deleted a category.", 'post-thumb-admin'); ?></li>
							<li><?php _e("You have a large post base and activation process was not completed.", 'post-thumb-admin'); ?></li>
							<li><?php _e("You've changed the permalinks.", 'post-thumb-admin'); ?></li>
							<li><?php _e("You have the feeling that recent_thumbs and random_thumb do not work properly.", 'post-thumb-admin'); ?></li>							
						</ul>
					</p>

				</fieldset>
        	
				<p class="title showhide"><?php _e('System check', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">
        	
					<p class="tabs"><?php _e('PHP version', 'post-thumb-admin'); ?></p>
					<?php echo $post_thumbnail_settings['phpversion']; ?><br />
        	
					<p class="tabs"><?php _e('Remote files', 'post-thumb-admin'); ?></p>
					<?php if (ini_get('allow_url_fopen')) _e('Retrieve remote file is OK', 'post-thumb-admin'); elseif (function_exists('curl_init'))_e('Retrieve remote file is OK using cURL', 'post-thumb-admin'); else _e('Retrieve remote file not allowed on this server.', 'post-thumb-admin'); ?><br />
					<p class="info"><?php _e('Dealing with remote file also requires php 4.3.0 or later', 'post-thumb-admin'); ?></p><br />
        	
					<p class="tabs"><?php _e('GD version', 'post-thumb-admin'); ?></p>
					<?php echo $post_thumbnail_settings['gdversion']; ?><br />
			
					<p class="tabs"><?php _e('Safe mode', 'post-thumb-admin'); ?></p>
					<?php if ($post_thumbnail_settings['safe_mode']=='true') _e('Safe mode on', 'post-thumb-admin'); else _e('Safe mode off', 'post-thumb-admin'); ?><br />
			
					<p class="tabs"><?php _e('Memory limit', 'post-thumb-admin'); ?></p>
					<?php if ($ml = ini_get('memory_limit')) echo $ml; else _e('Cannot Retrieve memory limit', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('Memory usage', 'post-thumb-admin'); ?></p>
					<?php if (function_exists('memory_get_usage')) _e('Function memory_get_usage available', 'post-thumb-admin'); else _e('Function memory_get_usage not available', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('Set Memory limit', 'post-thumb-admin'); ?></p>
					<?php $ms = ini_set('memory_limit', $ml); if (empty($ms)) _e('Memory cannot be set', 'post-thumb-admin'); else _e('Memory can be set', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('wordTube', 'post-thumb-admin'); ?></p>
					<?php _e($wdet, 'post-thumb-admin');echo $se; ?><br />
        	
				</fieldset>

	         		<div class="submit"><input type="submit" name="info_update" value="<?php _e('Update', 'post-thumb-admin'); ?>" /></div>

			</div>

			<div id="ptbasic">
        			<input type="hidden" name="screen" value="base">
				<h3><?php _e('Basic options', 'post-thumb-admin'); ?></h3>
        	
				<p class="info"><?php _e("Leave default settings if you're unsure of what to set.", 'post-thumb-admin'); ?></p>
				<br />
				
                		<p class="title showhide"><?php _e('Location settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">
        	

					<p class="tabs"><?php _e('Base path', 'post-thumb-admin'); ?></p>
					<input type="text" name="base_path" value="<?php echo $post_thumbnail_settings['base_path']; ?>" size="60" /><br />
 					<p class="tabsi"><?php _e('Initial default value: ', 'post-thumb-admin'); ?></p><?php echo $bp; ?><br />
					<p class="info"><?php _e("Absolute path to website. For example, /httpdocs or /yourdomain.com. Used to find location of thumbnails on server. http://yourdomain.com/images/pth/thumb_picture.jpg would actually be /httpdocs/images/pth/thumb_picture.jpg.", 'post-thumb-admin');echo ' ';_e("No trailing '/'", 'post-thumb-admin'); ?>
        	                        <br />
        	                        
					<p class="tabs"><?php _e('Full domain name', 'post-thumb-admin'); ?></p>
					<input type="text" name="full_domain_name" value="<?php echo $post_thumbnail_settings['full_domain_name']; ?>" size="60" /><br />
					<p class="tabsi"><?php _e('Initial default value: ', 'post-thumb-admin'); ?></p><?php echo str_replace( "\\", "/",$dn); ?><br />
					<p class="info"><?php _e("Full domain name. Includes the http://.", 'post-thumb-admin');echo ' ';_e("No trailing '/'", 'post-thumb-admin'); ?><br />
        	                        <br />
        	                        
					<p class="tabs"><?php _e('Folder name', 'post-thumb-admin'); ?></p>
					<input type="text" name="folder_name" value="<?php echo $post_thumbnail_settings['folder_name']; ?>" size="60" /><br />
					<p class="info"><?php _e('Set the relative path to thumbs. Make sure directory exists and is writable.', 'post-thumb-admin');echo ' ';_e("No trailing '/'", 'post-thumb-admin'); ?><br />
        	                        <br />
        	                        
					<p class="tabs"><?php _e('Default image', 'post-thumb-admin'); ?></p>
					<input type="text" name="default_image" value="<?php echo $post_thumbnail_settings['default_image']; ?>" size="60" /><br />
					<p class="info"><?php _e('The location of the default image to use if no picture can be found. Enter in the relative url, eg. images/default.jpg', 'post-thumb-admin'); ?><br />
					<p class="info"><?php _e('If category names are used, this will override Default Image and Default Image for Videos', 'post-thumb-admin'); ?><br />
        	                        <br />
        	                        
					<p class="tabs"><?php _e('Use meta data', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="use_meta" <?php if ($post_thumbnail_settings['use_meta'] == 'true') echo 'checked'; ?> /><br />
        	                        
					<p class="tabs"><?php _e('Use Category Names', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="use_catname" <?php if ($post_thumbnail_settings['use_catname'] == 'true') echo 'checked'; ?> /><br />
        	
				</fieldset>

				<p class="title showhide"><?php _e('Filename settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">
		
					<p class="tabs"><?php _e('Append / Prepend text', 'post-thumb-admin'); ?></p>
					<input type="text" name="append_text" value="<?php echo $post_thumbnail_settings['append_text']; ?>" size="60" /><br />
					<p class="info"><?php _e('Choose text to append or prepend image with.', 'post-thumb-admin'); ?>

					<p class="tabs"><?php _e('Append', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="append" <?php if ($post_thumbnail_settings['append'] == 'true') echo 'checked'; ?> /><br />
					<p class="info"><?php _e('Choose to put text before image name or after. Uncheck will put text before.', 'post-thumb-admin'); ?></p>
        	
					<?php _e(' Example: ', 'post-thumb-admin');if ($post_thumbnail_settings['append']=='true') echo 'yourimage'.$post_thumbnail_settings['append_text'].'.jpg'; else echo $post_thumbnail_settings['append_text'].'yourimage'.'.jpg';?></p>
        	
				</fieldset>
		
				<p class="title showhide"><?php _e('Video image settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">
				
					<p class="tabs"><?php _e('Video regex:', 'post-thumb-admin'); ?></p>
					<input type="text" name="video_regex" value="<?php echo htmlentities($post_thumbnail_settings['video_regex']); ?>" size="60" /><br />
 					<p class="info"><?php _e('If you want to scan a post for a video and use a default image. Uses regex to scan for video.', 'post-thumb-admin'); ?></p>
        	
					<p class="tabs"><?php _e('Video default image:', 'post-thumb-admin'); ?></p>
					<input type="text" name="video_default" value="<?php echo $post_thumbnail_settings['video_default']; ?>" size="60" /><br />
        	
				</fieldset>
		
				<p class="title showhide"><?php _e('Stream Video image settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">
        	
					<p class="tabs"><?php _e('Stream Check:', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="stream_check" <?php if ($post_thumbnail_settings['stream_check'] == 'true') echo 'checked'; ?> /><br />
        	
					<p class="info"><?php _e('If you want to scan a post for a stream video. Supports Youtube, Gvideo and Dailymotion. Will display a thumb for each specific source.', 'post-thumb-admin'); ?></p>
		
				</fieldset>
		
	         		<div class="submit"><input type="submit" name="info_update" value="<?php _e('Update', 'post-thumb-admin'); ?>" /></div>

			</div>

			<div id="ptthumbnail">
        			<input type="hidden" name="screen" value="base">
				<h3><?php _e('Thumbnail options', 'post-thumb-admin'); ?></h3>
        	
				<fieldset class="options ptswitch">
        	
					<p class="tabs"><?php _e('Resize width x height', 'post-thumb-admin'); ?></p>
					<input type="text" name="resize_width" value="<?php echo $post_thumbnail_settings['resize_width']; ?>" size="10" />
					x
					<input type="text" name="resize_height" value="<?php echo $post_thumbnail_settings['resize_height']; ?>" size="10" /><br />
					
					<p class="tabs"><?php _e('Quality for jpeg', 'post-thumb-admin'); ?></p>
					<input type="text" name="jpg_rate" id="jpg_rate" value="<?php echo $post_thumbnail_settings['jpg_rate']; ?>" size="3" />
					<?php _e('From 0 to 100 (best quality, highest size). Default: 75', 'post-thumb-admin'); ?>
					<div id='slider1' class='ui-slider-1' style="margin:10px;">
						<div class='ui-slider-handle'></div>	
					</div>		
					<br />
		
					<?php if (version_compare_replacement(phpversion(), '5.1.2', '>=')) { ?>
        	
						<p class="tabs"><?php _e('Compression for png', 'post-thumb-admin'); ?></p>
						<input type="text" name="png_rate" id="png_rate" value="<?php echo $post_thumbnail_settings['png_rate']; ?>" size="3" />
						<?php _e('From 0 (no compression, best quality) to 9. Default: 6', 'post-thumb-admin'); ?>
						<div id='slider2' class='ui-slider-1' style="margin:10px;">
							<div class='ui-slider-handle'></div>	
						</div>		
        	
					<?php } ?>

					<p class="tabs"><?php _e('Keep ratio', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="keep_ratio" <?php if ($post_thumbnail_settings['keep_ratio'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to apply original picture ratio to thumbnails.', 'post-thumb-admin'); ?><br />
					<p class="info"><?php _e('Choose your resize width and height. Will resize in proportion to original width and height. If you do not care about proportions, uncheck keep ratio.', 'post-thumb-admin'); ?></p>
					<br />
        	
					<p class="tabs"><?php _e('Max size', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="max" <?php if ($post_thumbnail_settings['max'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want resize to apply only if original image is smaller than target size.', 'post-thumb-admin'); ?><br />
					<br />
        	
					<p class="tabs"><?php echo __('Use rounded corner', 'post-thumb-admin').' '; ?></p>
					<input type="checkbox" name="rounded" <?php if ($post_thumbnail_settings['rounded'] == 'true') echo 'checked'; ?> />
					&nbsp;&nbsp;&nbsp;
					<?php _e('Corner ratio', 'post-thumb-admin'); ?>
					<input type="text" name="corner_ratio" value="<?php echo $post_thumbnail_settings['corner_ratio']; ?>" size="10" />&nbsp;<?php _e('From 0 to 1. Typical: 0.15', 'post-thumb-admin'); ?><br />
					<p class="info"><?php _e('Check this option will apply rounded corner to thumbnail. It will also force use of png format for thumbnails.', 'post-thumb-admin'); ?></p>
					<br />
        	
					<p class="tabs"><?php _e('Use png', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="use_png" <?php if ($post_thumbnail_settings['use_png'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to save thumbnails in .png format.', 'post-thumb-admin'); ?><br />
					<p class="info"><?php _e('Check this option will increase thumbnail size (used with rounded corner checked).', 'post-thumb-admin'); ?></p>
					<br />
        	
					<p class="tabs"><?php _e('Use unsharp mask', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="unsharp" <?php if ($post_thumbnail_settings['unsharp'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to apply a sharpness mask to thumbnails.', 'post-thumb-admin'); ?><br />
					<p class="info"><?php _e('WARNING: check this option slows down the thumbnail creation.', 'post-thumb-admin'); ?></p>
					<br />
        	
					<p class="tabs"><?php _e('Unsharp amount', 'post-thumb-admin'); ?></p>
					<input type="text" name="unsharp_amount" value="<?php echo $post_thumbnail_settings['unsharp_amount']; ?>" size="3" />
					<?php _e('From 0 to 100. Typical: 80', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('Unsharp radius', 'post-thumb-admin'); ?></p>
					<input type="text" name="unsharp_radius" value="<?php echo $post_thumbnail_settings['unsharp_radius']; ?>" size="3" />
					<?php _e('From 0 to 1. Typical: 0.5', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('Unsharp threshold', 'post-thumb-admin'); ?></p>
					<input type="text" name="unsharp_threshold" value="<?php echo $post_thumbnail_settings['unsharp_threshold']; ?>" size="3" />
					<?php _e('From 0 to 5. Typical: 3', 'post-thumb-admin'); ?><br />
        	
				</fieldset>
		
	         		<div class="submit"><input type="submit" name="info_update" value="<?php _e('Update', 'post-thumb-admin'); ?>" /></div>
			</div>

			<div id="ptadditional">
        			<input type="hidden" name="screen" value="add">
				<h3><?php _e('Additional options', 'post-thumb-admin'); ?></h3>
        	
				<fieldset class="options ptswitch">

					<p class="tabs"><?php _e('Detect wordTube medias', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="hs_wordtube" <?php if ($post_thumbnail_settings['hs_wordtube'] == 'true') echo 'checked'; ?> />
					<?php _e('Scan post content for wordTube media and use them to generate thumbnails.', 'post-thumb-admin'); ?><br />

					<p class="tabs"><?php _e('Detect Youtube video', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="hs_youtube" <?php if ($post_thumbnail_settings['hs_youtube'] == 'true') echo 'checked'; ?> />
					<?php _e('Scan post content for Youtube video and use them to generate thumbnails.', 'post-thumb-admin'); ?><br />

				</fieldset>

				<p class="title showhide"><?php _e('WordTube settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">

					<p class="tabs"><?php _e('wordTube display size', 'post-thumb-admin'); ?></p>
					<input type="text" name="wordtube_width" value="<?php echo $post_thumbnail_settings['wordtube_width']; ?>" size="10" />
					x
					<input type="text" name="wordtube_height" value="<?php echo $post_thumbnail_settings['wordtube_height']; ?>" size="10" />
					<?php _e('Wordtube thumbnail size.', 'post-thumb-admin'); ?>
					<?php _e(' (width x height)', 'post-thumb-admin'); ?>
					<br />
        	
					<p class="tabs"><?php _e('wordTube play size', 'post-thumb-admin'); ?></p>
					<input type="text" name="wordtube_pwidth" value="<?php echo $post_thumbnail_settings['wordtube_pwidth']; ?>" size="10" />
					x
					<input type="text" name="wordtube_pheight" value="<?php echo $post_thumbnail_settings['wordtube_pheight']; ?>" size="10" />
					<?php _e('Size of the frame to play wordTube video.', 'post-thumb-admin'); ?>
					<?php _e(' (width x height)', 'post-thumb-admin'); ?>
					<br />
        	
					<p class="tabs"><?php _e('video display text', 'post-thumb-admin'); ?></p>
					<input type="text" name="wordtube_vtext" value="<?php echo $post_thumbnail_settings['wordtube_vtext']; ?>" size="20" />
					<?php _e('Text shown in wordTube video thumbnails.', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('mp3 display text', 'post-thumb-admin'); ?></p>
					<input type="text" name="wordtube_mtext" value="<?php echo $post_thumbnail_settings['wordtube_mtext']; ?>" size="20" />
					<?php _e('Text shown in wordTube mp3 thumbnails.', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('wordTube thumbnail text', 'post-thumb-admin'); ?></p>
					<input type="text" name="wordtube_text" value="<?php echo $post_thumbnail_settings['wordtube_text']; ?>" size="20" />
					<?php _e('Text to append/prepend to wordtube thumbnail name.', 'post-thumb-admin'); ?><br />

					<p class="tabs"><?php _e('Append', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="wt_append" <?php if ($post_thumbnail_settings['wt_append'] == 'true') echo 'checked'; ?> /><br />
					<p class="info"><?php _e('Choose to put text before image name or after. Uncheck will put text before.', 'post-thumb-admin'); ?></p>
        	
				</fieldset>
		
				<p class="title showhide"><?php _e('Youtube settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">
        	
					<p class="tabs"><?php _e('Youtube display size', 'post-thumb-admin'); ?></p>
					<input type="text" name="youtube_width" value="<?php echo $post_thumbnail_settings['youtube_width']; ?>" size="10" />
					x
					<input type="text" name="youtube_height" value="<?php echo $post_thumbnail_settings['youtube_height']; ?>" size="10" />
					<?php _e('Youtube thumbnail size.', 'post-thumb-admin'); ?>
					<?php _e(' (width x height)', 'post-thumb-admin'); ?>
					<br />
        	
					<p class="tabs"><?php _e('Youtube play size', 'post-thumb-admin'); ?></p>
					<input type="text" name="youtube_pwidth" value="<?php echo $post_thumbnail_settings['youtube_pwidth']; ?>" size="10" />
					x
					<input type="text" name="youtube_pheight" value="<?php echo $post_thumbnail_settings['youtube_pheight']; ?>" size="10" />
					<?php _e('Size of the frame to play Youtube video.', 'post-thumb-admin'); ?>
					<?php _e(' (width x height)', 'post-thumb-admin'); ?>
					<br />
        	
				</fieldset>
		
	         		<div class="submit"><input type="submit" name="info_update" value="<?php _e('Update', 'post-thumb-admin'); ?>" /></div>
			</div>

			<div id="ptjavascript">
        			<input type="hidden" name="screen" value="JS">
				<h3><?php _e('Javascript options', 'post-thumb-admin'); ?></h3>
        	
				<p class="title showhide"><?php _e('Library settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">

 					<p class="tabs"><?php _e('Use Highslide', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="hs_use" <?php if ($post_thumbnail_settings['hs_use'] == 'true') echo 'checked'; ?> />
					<?php _e('Uncheck this will disable all Highslide effects', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('Use Thickbox', 'post-thumb-admin'); ?></p>
					<?php if (false) { ?>
						<input type="checkbox" name="tb_use" <?php if ($post_thumbnail_settings['tb_use'] == 'true') echo 'checked'; ?> />
					<?php } ?>
					<?php _e('Uncheck this will disable all Thickbox effects', 'post-thumb-admin'); ?><br />

					<p class="tabs"><?php _e('Use Smoothbox', 'post-thumb-admin'); ?></p>
					<?php if (false) { ?>
						<input type="checkbox" name="sb_use" <?php if ($post_thumbnail_settings['sb_use'] == 'true') echo 'checked'; ?> />
					<?php } ?>
					<?php _e('Uncheck this will disable all Smoothbox effects', 'post-thumb-admin'); ?><br />
        	
				</fieldset>

				<p class="title showhide"><?php _e('Highslide settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">

					<p class="tabs"><?php _e('Add caption to images', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="caption" <?php if ($post_thumbnail_settings['caption'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to add a caption to each image (available with Highslide).', 'post-thumb-admin'); ?><br />
					<br />
        	
					<p class="info"><?php _e('WARNING: it is not recommanded to use more than one library at a time.', 'post-thumb-admin'); ?></p>

					<p class="tabs"><?php _e('Picture frame border style', 'post-thumb-admin'); ?></p>
		        		<select size="1" name="ovframe" style="width:140px">
						<option value="rounded-black" <?php if ($post_thumbnail_settings['ovframe'] == 'rounded-black') echo 'selected="selected"'?>>rounded-black</option>
						<option value="rounded-white" <?php if ($post_thumbnail_settings['ovframe'] == 'rounded-white') echo 'selected="selected"'?>>rounded-white</option>
						<option value="outer-glow" <?php if ($post_thumbnail_settings['ovframe'] == 'outer-glow') echo 'selected="selected"'?>>outer-glow</option>
						<option value="drop-shadow" <?php if ($post_thumbnail_settings['ovframe'] == 'drop-shadow') echo 'selected="selected"'?>>drop-shadow</option>
						<option value="beveled" <?php if ($post_thumbnail_settings['ovframe'] == 'beveled') echo 'selected="selected"'?>>beveled</option>
						<option value="windows" <?php if ($post_thumbnail_settings['ovframe'] == 'windows') echo 'selected="selected"'?>>windows</option>
						<option value="none" <?php if ($post_thumbnail_settings['ovframe'] == 'none') echo 'selected="selected"'?>>none</option>
					</select>
					<br />
        	                                        
					<p class="tabs"><?php _e('Other frame border style', 'post-thumb-admin'); ?></p>
       					<select size="1" name="hsframe" style="width:140px">
						<option value="rounded-black" <?php if ($post_thumbnail_settings['ovframe'] == 'rounded-black') echo 'selected="selected"'?>>rounded-black</option>
						<option value="rounded-white" <?php if ($post_thumbnail_settings['hsframe'] == 'rounded-white') echo 'selected="selected"'?>>rounded-white</option>
						<option value="outer-glow" <?php if ($post_thumbnail_settings['hsframe'] == 'outer-glow') echo 'selected="selected"'?>>outer-glow</option>
						<option value="drop-shadow" <?php if ($post_thumbnail_settings['hsframe'] == 'drop-shadow') echo 'selected="selected"'?>>drop-shadow</option>
						<option value="beveled" <?php if ($post_thumbnail_settings['hsframe'] == 'beveled') echo 'selected="selected"'?>>beveled</option>
						<option value="windows" <?php if ($post_thumbnail_settings['hsframe'] == 'windows') echo 'selected="selected"'?>>windows</option>
						<option value="none" <?php if ($post_thumbnail_settings['hsframe'] == 'none') echo 'selected="selected"'?>>none</option>
					</select>
					<br />
        	
					<p class="tabs"><?php _e('Frame top style', 'post-thumb-admin'); ?></p>
		        		<select size="1" name="ovtopframe" style="width:140px">
						<option value="default" <?php if ($post_thumbnail_settings['ovtopframe'] == 'default') echo 'selected="selected"'?>>default</option>
						<option value="windows" <?php if ($post_thumbnail_settings['ovtopframe'] == 'windows') echo 'selected="selected"'?>>windows</option>
					</select>
					<br />
        	                                        
					<p class="tabs"><?php _e('Frames width x height', 'post-thumb-admin'); ?></p>
					<input type="text" name="hs_width" value="<?php echo $post_thumbnail_settings['hs_width']; ?>" size="10" />
					x
					<input type="text" name="hs_height" value="<?php echo $post_thumbnail_settings['hs_height']; ?>" size="10" /><br />
					
					<p class="tabs"><?php _e('Inside margin', 'post-thumb-admin'); ?></p>
					<input type="text" name="hsmargin" value="<?php echo $post_thumbnail_settings['hsmargin']; ?>" size="5" />
					<?php _e('Inside margin for frames (in pixels).', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('Frame content color', 'post-thumb-admin'); ?></p>
					<input type="text" name="bgcolor" value="<?php echo $post_thumbnail_settings['bgcolor']; ?>" size="10" />
					<?php _e('Use html hex color numbers, or transparent, or none (no style).', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('Frame top color', 'post-thumb-admin'); ?></p>
					<input type="text" name="hdcolor" value="<?php echo $post_thumbnail_settings['hdcolor']; ?>" size="10" />
					<?php _e('Use html hex color numbers, or transparent, or none (no style).', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('Frame footer color', 'post-thumb-admin'); ?></p>
					<input type="text" name="ftcolor" value="<?php echo $post_thumbnail_settings['ftcolor']; ?>" size="10" />
					<?php _e('Use html hex color numbers, or transparent, or none (no style).', 'post-thumb-admin'); ?><br />
        	
				</fieldset>
		
	         		<div class="submit"><input type="submit" name="info_update" value="<?php _e('Update', 'post-thumb-admin'); ?>" /></div>
			</div>

			<div id="ptpost">
        			<input type="hidden" name="screen" value="post">
				<h3><?php _e('Post options', 'post-thumb-admin'); ?></h3>
				
				<fieldset name="options">

					<p class="tabs"><?php _e('Activate formatting inside posts', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="hs_post" <?php if ($post_thumbnail_settings['hs_post'] == 'true') echo 'checked'; ?> />
	       				<?php _e('If checked, Post-Thumb will thumbnail images inside posts.', 'post-thumb-admin'); ?>
					<br />
        	
				</fieldset>

				<p class="title showhide"><?php _e('Thumbnail settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">

					<p class="tabs">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Resize width x height', 'post-thumb-admin'); ?></p>
					<input type="text" name="p_width" value="<?php echo $post_thumbnail_settings['p_resize_width']; ?>" size="10" />
					x
					<input type="text" name="p_height" value="<?php echo $post_thumbnail_settings['p_resize_height']; ?>" size="10" />
					<br />
		
					<p class="tabs">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Append / Prepend text', 'post-thumb-admin'); ?></p>
					<input type="text" name="p_append_text" value="<?php echo $post_thumbnail_settings['p_append_text']; ?>" size="60" />
					<br />
		
					<p class="info">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Choose text to append or prepend image with.', 'post-thumb-admin'); ?>
					<?php _e(' Example: ', 'post-thumb-admin');if ($post_thumbnail_settings['p_append']=='true') echo 'yourimage'.$post_thumbnail_settings['p_append_text'].'.jpg'; else echo $post_thumbnail_settings['p_append_text'].'yourimage'.'.jpg';?></p>
					<br />
        	
					<p class="tabs">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Save sub-directory', 'post-thumb-admin'); ?></p>
					<input type="text" name="p_subfolder" value="<?php echo $post_thumbnail_settings['p_subfolder']; ?>" size="60" />
					<br />
		
					<p class="info">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Choose sub-directory to save generated thumbnails to.', 'post-thumb-admin'); ?>
					<br />
        	
					<p class="tabs">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Level of directory to include in names', 'post-thumb-admin'); ?></p>
					<input type="text" name="p_dirname" value="<?php echo $post_thumbnail_settings['p_dirname']; ?>" size="5" />
					<br />
        	
					<p class="tabs">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Keep ratio', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="p_keep_ratio" <?php if ($post_thumbnail_settings['p_keep_ratio'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to apply original picture ratio to thumbnails.', 'post-thumb-admin'); ?>
					<br />
        	
					<p class="tabs">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Max size', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="p_max" <?php if ($post_thumbnail_settings['p_max'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want resize to apply only if original image is larger than target size.', 'post-thumb-admin'); ?><br />
					<br />
        	
					<p class="tabs">&nbsp;&nbsp;&nbsp;&nbsp;<?php echo __('Use rounded corner', 'post-thumb-admin').' '; ?></p>
					<input type="checkbox" name="p_rounded" <?php if ($post_thumbnail_settings['p_rounded'] == 'true') echo 'checked'; ?> />
					<br />
        	
					<p class="tabs">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Use png', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="p_use_png" <?php if ($post_thumbnail_settings['p_use_png'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to save thumbnails in .png format.', 'post-thumb-admin'); ?>
					<br />

					<p class="tabs">&nbsp;&nbsp;&nbsp;&nbsp;<?php _e('Auto replace', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="p_rel" <?php if ($post_thumbnail_settings['p_rel'] == 'true') echo 'checked'; ?> />
					<?php _e('If option is checked, use rel="nothumb" to not thumbnail an image. If it is not checked, use rel="thumb" to thumbnail images.', 'post-thumb-admin'); ?>
					<br />
        	                               
				</fieldset>
        	
				<p class="title showhide"><?php _e('Javascript settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">

					<p class="tabs"><?php _e('Lightbox compatibility', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="p_lightbox" <?php if ($post_thumbnail_settings['p_lightbox'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want Post-Thumb to add rel="lightbox" to every generated thumbnail.', 'post-thumb-admin'); ?>
					<br />
        	
					<p class="tabs"><?php _e('Add Highslide effect to existing thumbnails in posts', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="pt_replace" <?php if ($post_thumbnail_settings['pt_replace'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want Post-Thumb to add Highslide expand effect to existing thumbnails in posts.', 'post-thumb-admin'); ?>
					<br />
        	
				</fieldset>
        	
				<p class="title showhide"><?php _e('Highslide settings', 'post-thumb-admin'); ?></p>
				<fieldset class="options ptswitch">

					<p class="tabs"><?php _e('Add caption to images', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="p_caption" <?php if ($post_thumbnail_settings['p_caption'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to add a caption to each image.', 'post-thumb-admin'); ?><br />
					<br />
        	
					<p class="tabs"><?php _e('Replace wordTube media in posts', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="wt_media" <?php if ($post_thumbnail_settings['wt_media'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to replace wordTube media by thumbnail and popup frame.', 'post-thumb-admin'); ?><br />

					<p class="tabs"><?php _e('Use PTPLAYLIST', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="wt_playlist" <?php if ($post_thumbnail_settings['wt_playlist'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to use PTPLAYLIST tag.', 'post-thumb-admin'); ?><br />
        	
					<p class="tabs"><?php _e('Replace Youtube in posts', 'post-thumb-admin'); ?></p>
					<input type="checkbox" name="ytb_media" <?php if ($post_thumbnail_settings['ytb_media'] == 'true') echo 'checked'; ?> />
					<?php _e('Check this option if you want to replace Youtube by thumbnail and popup frame.', 'post-thumb-admin'); ?><br />

				</fieldset>
		
	         		<div class="submit"><input type="submit" name="info_update" value="<?php _e('Update', 'post-thumb-admin'); ?>" /></div>
			</div>

			<div id="pthelp">
				<?php $this->Help(); ?>
			</div>

		</form>
		</div>

		<?php
	}
	/****************************************************************/
	/* Help screen
	/****************************************************************/
	function Help() {
		?>

		<ul id="subsubmenu">
			<li><a href="#" id="ahelpover" onclick="showsubmenu('helpover'); return false;"><?php _e('Overview', 'post-thumb-admin'); ?></a></li>
			<li><a href="#" id="ahelpintegration" onclick="showsubmenu('helpintegration'); return false;"><?php _e('Theme integration', 'post-thumb-admin'); ?></a></li>
			<li><a href="#" id="ahelpsettings" onclick="showsubmenu('helpsettings'); return false;"><?php _e('Settings', 'post-thumb-admin'); ?></a></li>
			<li><a href="#" id="ahelpparameters" onclick="showsubmenu('helpparameters'); return false;"><?php _e('Parameters', 'post-thumb-admin'); ?></a></li>
			<li><a href="#" id="ahelpfeatures" onclick="showsubmenu('helpfeatures'); return false;"><?php _e('Additional features', 'post-thumb-admin'); ?></a></li>
			<li><a href="#" id="ahelpformat" onclick="showsubmenu('helpformat'); return false;"><?php _e('Formatting', 'post-thumb-admin'); ?></a></li>
		</ul>

		<div id="helpover">
			<h3><?php _e('How Post-Thumb works', 'post-thumb-admin'); ?></h3>
			<p class="htabs"><?php _e('Post scan', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('When a post is edited, Post-Thumb will scan through and look for a picture. If it finds one, it saves it and some post informations in a special table: pt_posts.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e("The scan will retrieve only one element per post. If 'Use metadata' options is checked, it will retrieve it and stop the scan. If 'youtube' or 'wordTube' are used, it will stick to this order: metadata, youtube video, wordtube media, image.", 'post-thumb-admin'); ?></p><br />
			<p class="htabs"><?php _e('Using metadata', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('If an image (http://....) or any valid reference to a youtube video (youtube=<youtubeor id>) a wordtube media (media=<mediais id>) input in metadata, it will be used to display the thumbnail.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('Metadata name to use is: <i>pt_meta_thumb</i>.', 'post-thumb-admin'); ?></p><br />
		</div>

		<div id="helpintegration">
			<h3><?php _e('Theme integration', 'post-thumb-admin'); ?></h3>
		
			<p class="htabs"><?php _e('Display thumbnails in the Loop', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('To display thumbnail in your loops, you need to insert the following line in your template file:', 'post-thumb-admin'); ?></p><br />
			<p class="hcode"><?php _e('&lt;?php the_thumb(); ?&gt;', 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('Display thumbnails in Sidebar', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('To display most recent posts with their thumbnail in the sidebar, you need to insert the following line in your template file:', 'post-thumb-admin'); ?></p><br />
			<p class="hcode"><?php _e('&lt;?php the_recent_thumbs(); ?&gt;', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('To display most random posts with their thumbnail in the sidebar, you need to insert the following line in your template file:', 'post-thumb-admin'); ?></p><br />
			<p class="hcode"><?php _e('&lt;?php the_random_thumb(); ?&gt;', 'post-thumb-admin'); ?></p><br />
	
			<p class="htabs"><?php _e('Manage thumbnail aspect, name and more', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('In option panels, many informations about aspect, save name, save directory and template link can be set.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('These are default values which will be used all through the site.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e("However, it's often convenient to be able to display the same image with different formats. For this, Post-Thumb can pass almost any option as a parameter to set up a new value.", 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('Using functions parameters', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('Each function can be used with numerous parameters to manage display or how or where thumbnails are saved. You do not have to use them unless you want different settings from the default options you have choosen in the option screen.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e("Each parameter should be input with its value separated with '=' and separated from the other parameters with '&'.", 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('Example:', 'post-thumb-admin'); ?></p><br />
			<p class="hcode"><?php _e("&lt;?php get_recent_thumbs('WIDTH=100&HEIGHT=80&ROUNDED=1&LIMIT=12'); ?&gt;", 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><a href="#" id="ahelpparameters" onclick="showsubmenu('helpparameters'); return false;"><?php _e('See the list of available parameters', 'post-thumb-admin'); ?></a></p><br /> 
		</div>

		<div id="helpsettings">
			<h3><?php _e('Settings', 'post-thumb-admin'); ?></h3>

			<p class="htabs"><?php _e('Overview', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('There is an important feature there: the post-thumb table.', 'post-thumb-admin'); ?></p><br />
	
			<p class="htabs"><?php _e('Basic options', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('These options need to be set properly in order for Post-Thumb to work. Most of the time, default values will be ok.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e("<u>Base path</u>: Absolute path to website. For example, /httpdocs or /yourdomain.com. Used to find location of thumbnails on server. http://yourdomain.com/images/pth/thumb_picture.jpg would actually be /httpdocs/images/pth/thumb_picture.jpg. No trailing '/'", 'post-thumb-admin'); ?></p><br />
       	                <p class="hdocs"><?php _e("<u>Full domain name</u>: This is the actual domain that contains your blog. Includes the http://. No trailing '/'", 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e("<u>Initial default value</u>: These are values of 'Base path' and 'Domain name' calculated by Post-Thumb from informations retrieved from your blog installation.", 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e("<u>Folder name</u>: Set the relative path to thumbs. Make sure directory exists and is writable. No trailing '/'", 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('<u>Default image</u>: The location of the default image to use if no picture can be found. Enter in the relative url, eg. images/default.jpg', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('<u>Use meta data</u>: Will tell Post-thumb to use metadata or not in its post scan.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e("<u>Use Category Names</u>: if category names are used, this will override 'Default Image' and 'Default Image for Videos' and use a category specific image instead.", 'post-thumb-admin'); ?></p><br />
	
			<p class="htabs"><?php _e('Thumbnail options', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('These options set the size, aspect and quality of the thumbnails.', 'post-thumb-admin'); ?></p><br />
	
			<p class="htabs"><?php _e('Additional options', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('There, you can include wordTube media and Youtube video in the thumbnail scan.', 'post-thumb-admin'); ?></p><br />
	
			<p class="htabs"><?php _e('Javascript options', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('Highslide javascript library can be activated.', 'post-thumb-admin'); ?></p><br />
	
			<p class="htabs"><?php _e('Post options', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('With these options, Post-Thumb can also work on post content.', 'post-thumb-admin'); ?></p><br />
		</div>

		<div id="helpparameters">
			<h3><?php _e('Available parameters', 'post-thumb-admin'); ?></h3>

			<p class="htabs"><?php _e('Display parameters', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('WIDTH: resize width. Overrides default if greater than 0.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('HEIGHT: resize height. Overrides default if greater than 0.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('HCROP: horizontal crop. Crops if greater than 0.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('VCROP: vertical crop. Crops if greater than 0.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('KEEPRATIO (0/1): if set to 1, image ratio is kept. Overrides default if it exists.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('ROUNDED (0/1): creates thumbnails with rounded corners. Overrides default if it exists.', 'post-thumb-admin'); ?></p><br />
 			<p class="hdocs" style="color: blue"><?php _e('OBJECT (0/1): return an object or an array of objects instead of a display string.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('MAX (0/1): will not resize if image is smaller than target size. Does not work with keepratio set to true. Overrides default if it exists.', 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('Addtitional display parameters', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('TEXTBOX (0/1):  write a text in the bottom. Default is 0 (no text).', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('TEXT: text to write if TEXTBOX is set to 1.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('SHOWTITLE: display title, author or date below the thumbnail. Parameters: T, A, D.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('TITLE (C/E/D): choose wether content (C), excerpt (E) or title (T) is used in title tag of the thumbnail. Default is T.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('MYCLASSHREF: output class name in html &lt;a class="myclasshref" href=...>', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('MYCLASSIMG: output class name in html &lt;img class="myclassimg" href=...>', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('LB_EFFECT (0/1): use highslide to display image or link. This parameter must be set to add the effect and is only available if highslide is activated in option panel.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('CAPTION (0/1): display or not the caption for pictures.', 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('Saving parameters', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('ALTAPPEND: text to append to create thumbnail name. Override default if exists.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('APPEND (0/1): forces append or prepend of thumbnail prefix.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('MIME (jpg/png): force type of thumbnail.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('BASENAME (0/1): force generation of thumbnail and use generic name. Default is 0. Used in the random function.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e("SUBFOLDER: name of the subfolder to save thumbnails in. Only one level, no wrapping '/'.", 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('DIRNAME (integer): includes image directories in thumbnail name (convenient for digital camera images). Specify the level of subdirectory to include.', 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('Template parameters', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('USECATNAME (0/1): choose if category default image should be used or not. Override default if exists.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('SHOWPOST (0/1): force Highslide to expand on post if set to 1. Default is 0 (expand on image or post)', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('LINK (i/p/u): force Highslide to expand on post if set to p, on url if set to u. Default is i, image (expand on image or post)', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e("NODEF (no value or 1): doesn't display thumbnail if not image in post.", 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('get_recent_thumbs specific parameters', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('LIMIT: number of posts to display.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('OFFSET: skip posts by the given number. Default is 0.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('CATEGORY: categories to get posts from, or categories to exclude from search.', 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('get_random_thumb specific parameters', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('LIMIT: number of posts to display.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs" style="color: blue"><?php _e('CATEGORY: categories to get random posts from.', 'post-thumb-admin'); ?></p><br />
			
	                <br />
			<p class="hdocs"><small><?php _e('Parameters in blue do not have equivalency in option panel.', 'post-thumb-admin'); ?></small></p><br />
		</div>

		<div id="helpfeatures">

			<h3><?php _e('Additional features', 'post-thumb-admin'); ?></h3>
			<p class="htabs"><?php _e('Using Highslide', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('Highslide can be used to add a popup effect to the thumbnails.', 'post-thumb-admin'); ?></p><br />
			
			<p class="htabs"><?php _e('wordTube', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('If option is selected, Post-Thumb will parse the posts and look for wordTube media (format: [MEDIA=xx]).', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('When a media is found, its image will be used to create the thumbnail.', 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('Youtube', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('If option is selected, Post-Thumb will parse the posts and look for Youtube video (format: [YOUTUBE=xxxxxxxx], or the link to the video page, or the Youtube object code.).', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('When a video is found, its image will be used to create the thumbnail.', 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('Post formatting', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('As an additional feature, Post-Thumb can parse the whole post content and thumbnail all the images in it.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('This is espacially convenient if you want to format all your content with a fixed size.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('If highslide is activated, wordTube media and Youtube video can also be thumbnailed. They will then play in a popup windows.', 'post-thumb-admin'); ?></p><br />
	
		</div>

		<div id="helpformat">

			<h3><?php _e('Formatting', 'post-thumb-admin'); ?></h3>
			<p class="htabs"><?php _e('Formatting thumbnails', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('As Post-Thumb returns pure html strings, you can use your style.css to format thumbnails.', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e('There are several parameters which impact thumbnail formatting: MYCLASSIMG, MYCLASSHREF and ALIGN.', 'post-thumb-admin'); ?></p><br />

			<p class="htabs"><?php _e('Formatting Highslide popup windows', 'post-thumb-admin'); ?></p><br />
			<p class="hdocs"><?php _e("Frame aspect can be customized at two levels: options and css. Sizes, color, frame border, top bar and inside margin can be choosen in option. There is also a css file which can give more control over frame aspect: 'js/style_hs.css'", 'post-thumb-admin'); ?></p><br />

		</div>
		<?php
	}
	/*******************************************************************************/
	/* Retrieve posted options
	/*******************************************************************************/
	function RetrievePostOptions() {
	
	  	if (ini_get('safe_mode')) $safe_mode = 'true'; else $safe_mode = 'false';

		$new_options = pt_get_default_options();

		$new_options['safe_mode'] = $safe_mode;
		$new_options['version']	= $this->PTRVERSION;
		$new_options['phpversion'] = phpversion();
		$new_options['wt_path'] = get_wordTubePath();

		if (isset($_POST['default_image']))
			$new_options['default_image'] = $this->noLeadSlash($this->noTrailSlash($_POST['default_image']));
		if (isset($_POST['full_domain_name']))
			$new_options['full_domain_name'] = $this->noTrailSlash($_POST['full_domain_name']);
		if (isset($_POST['base_path']))
			$new_options['base_path'] = $this->noTrailSlash($_POST['base_path']);
		if (isset($_POST['folder_name']))
			$new_options['folder_name'] = $this->noLeadSlash($this->noTrailSlash($_POST['folder_name']));
		if (isset($_POST['video_default']))
			$new_options['video_default'] = $this->noLeadSlash($this->noTrailSlash($_POST['video_default']));

		// Retrieve Boolean options
		if (isset($_POST['screen'])) {

			$blist = $this->BooleanList;
			
			foreach ($blist as $option) :
				$new_options[$option] = pt_GetBooleanOption ($_POST[$option]);
			endforeach;
		}

		// Retrieve other options
		foreach ($this->OptionList as $option) :
		  	if (isset($_POST[$option]))
				$new_options[$option] = $_POST[$option];
		endforeach;
		
		$this->settings = $new_options;
		update_option('post_thumbnail_settings',$new_options);

	}
	/****************************************************************/
	/* Validates update options
	/****************************************************************/
	function ValidateOptions() {

	        // Test resize values
		if (!is_numeric($this->settings['resize_width'])) {
	
			$this->isError(__("Resize width must be a number"));
			$this->settings['resize_width'] = '60';
		}
		elseif (!is_numeric($this->settings['resize_height'])) {
			
			$this->isError(__("Resize width must be a number"));
			$this->settings['resize_height'] = '60';
		}

	        // Test default image
		$video_exists = file_exists($this->settings['base_path'].'/'.$this->settings['video_default']);
		if (!$video_exists) $this->isError(__('Video default image not found on server.', 'post-thumb-admin'));

	        // Test default image
		$default_exists = file_exists($this->settings['base_path'].'/'.$this->settings['default_image']);
		if (!$default_exists) $this->isError(__('Default image not found on server.', 'post-thumb-admin'));

	        // Test folder name
		$this->TestFolder($this->settings['base_path'].'/'.$this->settings['folder_name']);
	
	}
	/****************************************************************/
	/* Delete leading slash
	/****************************************************************/
	function noLeadSlash ($text) {
		
		if (substr($text, 0, 1) == '/') return substr($text, 1);
		return $text;
	}
	/****************************************************************/
	/* Delete trailing slash
	/****************************************************************/
	function noTrailSlash ($text) {
		
		if (substr($text, -1) == '/') return substr($text, 0, strlen($text)-1);
		return $text;
	}
	/****************************************************************/
	/* Test if a path is writable
	/****************************************************************/
	function isError ($text) {
		
		$this->update_error = true;
		$this->error_msg = $text;
	}
	/****************************************************************/
	/* Test if a path is writable
	/****************************************************************/
	function TestFolder ($is_writable_dir) {

		$rs = PT_ABSPATH . 'lib/index.htm';
		$rt = $is_writable_dir . '/index.htm';

		if (is_dir($is_writable_dir)) {
		
			if (@copy($rs, $rt)===false)

				$this->isError(__('Directory: ', 'post-thumb-admin').$is_writable_dir.' '.__('may not be writeable.', 'post-thumb-admin'));
			else
	                        unlink($rt);
		}
		else 
			$this->isError(__('Directory: ', 'post-thumb-admin').$is_writable_dir.' '.__('does not exist!', 'post-thumb-admin'));

	}
	/***********************************************************************************/
	/* Check for a new version of Post-thumb Revisited on server. This one is basic
	/***********************************************************************************/
	function version_check() {

		require_once(ABSPATH . WPINC . '/class-snoopy.php');
	
		// check for a new version
		$check_intervall = get_option( "ptr_next_update" );
	
		if ( ($check_intervall < time() ) or (empty($check_intervall)) ) {
			if (class_exists(snoopy)) {

				$client = new Snoopy();
				$client->_fp_timeout = 10;

				if (@$client->fetch($this->PTRURL) === false)
					return false;

			   	$remote = $client->results;
				$server_version = $remote;

				if ( version_compare($server_version, $this->PTRVERSION, '>'))
			 		return true;

				// come back in 24 hours :-)
				$check_intervall = time() + 86400;
				update_option( "ptr_next_update", $check_intervall );
				return false;
			}
		}

		return false;
	}
} // End of admin class

################################################################################
########## Record class
################################################################################
class postThumb {

	var $post_id;
	var $image_url='';
	var $media_url='';
	var $categories='';
	var $title='';
	var $date='';
	var $permalink='';
	var $author='';
	var $link='';
	var $vwidth=0;
	var $vheight=0;
	
	function postThumb($post='') {
		if ($post != '')
			$this->post_id = $post->ID;
			$this->title = $post->post_title;
			$this->date = $post->post_date_gmt;
			$this->permalink = get_permalink($this->post_id);
			$author = get_author_name($post->post_author);
			$this->author= '<a href="'.get_author_posts_url($post->post_author).'" title="'.
					__('Posts from: ', 'post-thumb-admin').$author.'">'.$author.'</a>';
	}
}

/****************************************************************/
/* Set checkbox result to boolean
/****************************************************************/
function pt_GetBooleanOption($boolean) {

  	if ($boolean == 'on') 
		$boolean = 'true';
  	else 
	  	$boolean = 'false';
	  	
	return $boolean;
}
/****************************************************************/
/* Validates update options
/****************************************************************/
function pt_get_default_options() {

	// Init parameters
	$up = get_settings('upload_path');
	$pa = parse_url(SITEURL);
	$dn = str_replace($pa['path'],"",SITEURL);
	$bp = str_replace($pa['path'],"",str_replace( "\\", "/",ABSPATH));
	$bp = substr($bp, 0, strlen($bp)-1);
	$pa['path'] = substr($pa['path'], 1, strlen($pa['path'])-1);
	$def = $pa['path'].'/wp-content/plugins/'. PT_PLUGIN_BASENAME.'/images/default.png';
	$defvid = $pa['path'].'/wp-content/plugins/'. PT_PLUGIN_BASENAME.'/images/defaultvideo.png';
	$se = get_wordTubePath();
	if ($se=='') {
		$re='';
	} else {
		$re = "MEDIA="; 
	}

	$settings = get_option('post_thumbnail_settings');

	if ($settings['append'] == '') 		$settings['append'] = 'false';
	if ($settings['append_text'] == '') 	$settings['append_text'] = 'thumb_';
	if ($settings['base_path'] == '') 	$settings['base_path'] = $bp;
	if ($settings['bgcolor'] == '') 	$settings['bgcolor'] = '#000000';
	if ($settings['hdcolor'] == '') 	$settings['hdcolor'] = '#000000';
	if ($settings['ftcolor'] == '') 	$settings['ftcolor'] = '#000000';
	
	$settings['corner_ratio'] 		= ptr_test_setting($settings['corner_ratio'], '0.150', 1);
	if ($settings['default_image'] == '') 	$settings['default_image'] = $def;
	if ($settings['folder_name'] == '') 	$settings['folder_name'] = $pa['path'].'/'.UPLOAD_PATH.'/pth';
	if ($settings['full_domain_name'] == '')$settings['full_domain_name'] = str_replace( "\\", "/",$dn);
	if ($settings['gdversion'] == '') 	$settings['gdversion'] = gd_version(true);

	if ($settings['sb_use'] == '') 		$settings['sb_use'] = 'false';
	if ($settings['tb_use'] == '') 		$settings['tb_use'] = 'false';
	if ($settings['hs_use'] == '') 		$settings['hs_use'] = 'false';
	if ($settings['caption'] == '') 	$settings['caption'] = 'false';
	if ($settings['hsframe'] == '') 	$settings['hsframe'] = 'drop-shadow';
	if ($settings['hs_post'] == '') 	$settings['hs_post'] = 'false';
	if ($settings['hs_wordtube'] == '') 	$settings['hs_wordtube'] = 'false';
	if ($settings['hs_youtube'] == '') 	$settings['hs_youtube'] = 'false';

	if ($settings['info_update'] == '') 	$settings['info_update'] = 'Create';
	$settings['jpg_rate'] 			= ptr_test_setting($settings['jpg_rate'], '75', 100);
	if ($settings['keep_ratio'] == '') 	$settings['keep_ratio'] = 'true';
	if ($settings['ovframe'] == '') 	$settings['ovframe'] = 'drop-shadow';
	if ($settings['ovtopframe'] == '') 	$settings['ovtopframe'] = 'default';
	if ($settings['phpversion'] == '') 	$settings['phpversion'] = phpversion();
	$settings['png_rate'] 			= ptr_test_setting($settings['png_rate'], '6', 9);

	$settings['resize_width'] 		= ptr_test_setting($settings['resize_width'], '60');
	$settings['resize_height'] 		= ptr_test_setting($settings['resize_height'], '60');

	if ($settings['rounded'] == '') 	$settings['rounded'] = 'false';
	if ($settings['stream_check'] == '') 	$settings['stream_check'] = 'true';

	if ($settings['unsharp'] == '') 	$settings['unsharp'] = 'false';
	$settings['unsharp_amount'] 		= ptr_test_setting($settings['unsharp_amount'], '80', 100);
	$settings['unsharp_radius'] 		= ptr_test_setting($settings['unsharp_radius'], '0.5', 1);
	$settings['unsharp_threshold'] 		= ptr_test_setting($settings['unsharp_threshold'], '3', 5);

	if ($settings['use_catname'] == '') 	$settings['use_catname'] = 'false';
	if ($settings['use_meta'] == '') 	$settings['use_meta'] = 'true';
	if ($settings['use_png'] == '') 	$settings['use_png'] = 'false';

	if ($settings['video_regex'] == '') 	$settings['video_regex'] = $re;
	if ($settings['video_default'] == '') 	$settings['video_default'] = $defvid;

	$settings['hs_width'] 			= ptr_test_setting($settings['hs_width'], '550');
	$settings['hs_height'] 			= ptr_test_setting($settings['hs_height'], '900');
	$settings['hsmargin'] 			= ptr_test_setting($settings['hsmargin'], '5');
	if ($settings['wordtube_text'] == '') 	$settings['wordtube_text'] = 'wtthumb_';
	$settings['wordtube_width'] 		= ptr_test_setting($settings['wordtube_width'], '160');
	$settings['wordtube_height'] 		= ptr_test_setting($settings['wordtube_height'], '120');
	$settings['wordtube_pwidth'] 		= ptr_test_setting($settings['wordtube_pwidth'], '425');
	$settings['wordtube_pheight'] 		= ptr_test_setting($settings['wordtube_pheight'], '350');

	$settings['youtube_width'] 		= ptr_test_setting($settings['youtube_width'], '160');
	$settings['youtube_height'] 		= ptr_test_setting($settings['youtube_height'], '120');
	$settings['youtube_pwidth'] 		= ptr_test_setting($settings['youtube_pwidth'], '425');
	$settings['youtube_pheight'] 		= ptr_test_setting($settings['youtube_pheight'], '350');


	if ($settings['pt_replace'] == '') 	$settings['pt_replace'] = 'false';
	if ($settings['p_append_text'] == '') 	$settings['p_append_text'] = 'pthumb_';
	if ($settings['p_keep_ratio'] == '') 	$settings['p_keep_ratio'] = 'true';
	$settings['p_resize_width'] 		= ptr_test_setting($settings['p_resize_width'], '120');
	$settings['p_resize_height'] 		= ptr_test_setting($settings['p_resize_height'], '120');
	if ($settings['p_rounded'] == '') 	$settings['p_rounded'] = 'false';
	if ($settings['p_use_png'] == '') 	$settings['p_use_png'] = 'false';
	if ($settings['p_caption'] == '') 	$settings['p_caption'] = 'false';
	if ($settings['p_rel'] == '') 		$settings['p_rel'] = 'false';
	if ($settings['p_dirname'] == '') 	$settings['p_dirname'] = '0';

	if ($settings['wt_media'] == '') 	$settings['wt_media'] = 'false';
	if ($settings['wt_playlist'] == '') 	$settings['wt_playlist'] = 'false';
	if ($settings['p_caption'] == '') 	$settings['p_caption'] = 'false';
	if ($settings['wt_path'] == '') 	$settings['wt_path'] = $se;

	if ($settings['updslice'] == '') 	$settings['updslice'] = 20;

	return $settings;
}
/****************************************************************/
/* Includes features in header for admin panel
/****************************************************************/
function pt_admin_include_header() {

	/* js includes ============================== */
	echo "\n".'<!-- Start Of Script Generated By Post-Thumb Revisited Admin -->'."\n";
	wp_enqueue_script('jquery', PT_URLPATH.'js/jquery.js', false);
	wp_enqueue_script('dimensions', PT_URLPATH.'js/jquery.dimensions.js', array('jquery'));
	wp_enqueue_script('mouse', PT_URLPATH.'js/ui.mouse.js', array('jquery'));
	wp_enqueue_script('slider', PT_URLPATH.'js/ui.slider.js', array('jquery'));
	wp_print_scripts(array('jquery', 'dimensions', 'mouse', 'slider'));

	$echo = __('Click to hide and show', 'post-thumb-admin');

        ?>
	<link rel="stylesheet" href="<?php echo PT_URLPATH; ?>js/flora.slider.css" type="text/css" media="screen" />
	<link rel="stylesheet" href="<?php echo PT_URLPATH; ?>lib/ptr_admin.css" type="text/css" media="screen" />

	<script type="text/javascript">
		jQuery(document).ready(function() {

			jQuery('.ptadvanced').css({ display: 'none' });
				jQuery('.showhide').click(function() {jQuery(this).next(".ptswitch").slideToggle();});
				jQuery('.showhide').attr({ title: "<?php echo $echo; ?>" });

			showsubmenu('helpover');
			showmenu('ptover');
		});
		
		function showmenu (thisclass) {
			hidemenu();
			jQuery("#"+thisclass).fadeIn('slow');			
			jQuery("#a"+thisclass).addClass('selected');			
		}
		function hidemenu () {
			var listM = new Array ('ptover', 'ptbasic', 'ptthumbnail', 'ptadditional', 'ptjavascript', 'ptpost', 'pthelp');
			var c = listM.length;
			for (j=0;j<c;j++) {
				jQuery("#"+listM[j]).fadeOut('slow');
				jQuery("#a"+listM[j]).removeClass('selected');
			}
		}
		function hidesubmenu () {
			var listM = new Array ('helpover', 'helpintegration', 'helpsettings', 'helpparameters', 'helpfeatures', 'helpformat');
			var c = listM.length;
			for (j=0;j<c;j++) {
				jQuery("#"+listM[j]).fadeOut('slow');
				jQuery("#a"+listM[j]).removeClass('selected');
			}
		}
		function showsubmenu (thisclass) {
			hidesubmenu();
			jQuery("#"+thisclass).fadeIn('slow');			
			jQuery("#a"+thisclass).addClass('selected');			
		}
	</script>

	<?php
	echo '<!-- End Of Script Generated By Post-Thumb Revisited Admin -->'."\n";
}
/****************************************************************/
/* Retrieve wordTube path
/****************************************************************/
function get_wordTubePath() {
	$allplugins = get_option('active_plugins');
	$path = '';
	foreach ($allplugins as $plugin):
		if (strpos($plugin, '/wordtube.php'))
			$path = str_replace('/wordtube.php', '', $plugin);
	endforeach;
	if ($path == '') $path = 'wordtube';
	return $path;
}
/****************************************************************/
/* Loads language file at init
/****************************************************************/
function post_thumb_admin_init () {

	// Load language file
	$locale = get_locale();
	if ( !empty($locale) )
		load_textdomain('post-thumb-admin', PT_ABSPATH.'languages/' . 'post-thumb-admin'.$locale.'.mo');
}
add_action('init', 'post_thumb_admin_init');

?>
