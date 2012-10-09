<?php
/*
Plugin Name: flickrRSS
Plugin URI: http://eightface.com/wordpress/flickrrss/
Description: Allows you to integrate the photos from a flickr rss feed into your site.
Version: 5.1
License: GPL
Author: Dave Kellam and Stefano Verna
Author URI: http://eightface.com
*/

if (!class_exists('flickrRSS')) {
	class flickrRSS {
	
		function flickrRSS() {
			$this->version = "5.1";
		}
	
		function setupActivation() {
		
			function get_and_delete_option($setting) { $v = get_option($setting); delete_option($setting); return $v; }
		
			// check for previously installed version 4.0 or older
			if (get_option('flickrRSS_flickrid')) {
				// let's port previous settings and delete them
				$settings = $this->fixArguments(array(
					get_and_delete_option('flickrRSS_display_numitems'),
					get_and_delete_option('flickrRSS_display_type'),
					get_and_delete_option('flickrRSS_tags'),
					get_and_delete_option('flickrRSS_display_imagesize'),
					get_and_delete_option('flickrRSS_before'),
					get_and_delete_option('flickrRSS_after'),
					get_and_delete_option('flickrRSS_flickrid'),
					get_and_delete_option('flickrRSS_set'),
					get_and_delete_option('flickrRSS_use_image_cache'),
					get_and_delete_option('flickrRSS_image_cache_uri'),
					get_and_delete_option('flickrRSS_image_cache_dest')
				));
				update_option('flickrRSS_settings', $settings);
			}
		
			// update version number
			if (get_option('flickrRSS_version') != $this->version)
				update_option('flickrRSS_version', $this->version);
		}
	
		function fixArguments($args) {
			$settings = array();
		
			if (isset($args[0])) $settings['num_items'] = $args[0];
		  	if (isset($args[1])) $settings['type'] = $args[1];
		  	if (isset($args[2])) $settings['tags'] = $args[2];
		  	if (isset($args[6])) $settings['id'] = $args[6];
		  	if (isset($args[7])) $settings['set'] = $args[7];
			if (isset($args[8])) $settings['do_cache'] = $args[8];
			if (isset($args[9])) $settings['cache_uri'] = $args[9];
			if (isset($args[10])) $settings['cache_path'] = $args[10];
	
			$imagesize = $args[3]?$args[3]:"square";
			$before_image = $args[4]?$args[4]:"";
			$after_image = $args[5]?$args[5]:"";

			$settings['html'] = $before_image . '<a href="%flickr_page%" title="%title%"><img src="%image_'.$imagesize.'%" alt="%title%" /></a>' . $after_image;
		
			return $settings;
		}
	
		function getSettings() {
			
			if (!get_option('flickrRSS_settings')) $this->setupActivation();
			
			$settings = array(
				/*== Content params ==*/
				// The type of Flickr images that you want to show. Possible values: 'user', 'favorite', 'set', 'group', 'public'
				'type' => 'public',
				// Optional: To be used when type = 'user' or 'public', comma separated
				'tags' => '',
				// Optional: To be used when type = 'set' 
				'set' => '',
				// Optional: Your Group or User ID. To be used when type = 'user' or 'group'
				'id' => '',
				// Do you want caching?
				'do_cache' => false,
				// The image sizes to cache locally. Possible values: 'square', 'thumbnail', 'small', 'medium' or 'large', provided within an array
				'cache_sizes' => array('square'),
				// Where images are saved (Server path)
				'cache_path' => '',
				// The URI associated to the cache path (web address)
				'cache_uri' => '',
			
				/*== Presentational params ==*/
				 // The number of thumbnails you want
				'num_items' => 4,
				 // the HTML to print before the list of images
				'before_list' => '',
				// the code to print out for each image. Meta tags available:
				// - %flickr_page%
				// - %title%
				// - %image_small%, %image_square%, %image_thumbnail%, %image_medium%, %image_large%
				'html' => '<a href="%flickr_page%" title="%title%"><img src="%image_square%" alt="%title%"/></a>',
				// the default title
				'default_title' => "Untitled Flickr photo", 
				// the HTML to print after the list of images
				'after_list' => ''
			);
			if (get_option('flickrRSS_settings'))
				$settings = array_merge($settings, get_option('flickrRSS_settings'));
			return $settings;
		}
	
		function getRSS($settings) {
			if (!function_exists('MagpieRSS')) { 
				// Check if another plugin is using RSS, may not work
				include_once (ABSPATH . WPINC . '/rss.php');
				error_reporting(E_ERROR);
			}
			// get the feeds
			if ($settings['type'] == "user") { $rss_url = 'http://api.flickr.com/services/feeds/photos_public.gne?id=' . $settings['id'] . '&tags=' . $settings['tags'] . '&format=rss_200'; }
			elseif ($settings['type'] == "favorite") { $rss_url = 'http://api.flickr.com/services/feeds/photos_faves.gne?id=' . $settings['id'] . '&format=rss_200'; }
			elseif ($settings['type'] == "set") { $rss_url = 'http://api.flickr.com/services/feeds/photoset.gne?set=' . $settings['set'] . '&nsid=' . $settings['id'] . '&format=rss_200'; }
			elseif ($settings['type'] == "group") { $rss_url = 'http://api.flickr.com/services/feeds/groups_pool.gne?id=' . $settings['id'] . '&format=rss_200'; }
			elseif ($settings['type'] == "public" || $settings['type'] == "community") { $rss_url = 'http://api.flickr.com/services/feeds/photos_public.gne?tags=' . $settings['tags'] . '&format=rss_200'; }
			else { 
				print '<strong>No "type" parameter has been setup. Check your flickrRSS Settings page, or provide the parameter as an argument.</strong>';
				die();
			}
			# get rss file
			return @fetch_rss($rss_url);
		}
	
		function printGallery($settings = array()) {
		
			if (!is_array($settings)) {
				$settings = $this->fixArguments(func_get_args());
			}
		
			$settings = array_merge($this->getSettings(), $settings);
			if (!($rss = $this->getRSS($settings))) return;
			# specifies number of pictures
			$items = array_slice($rss->items, 0, $settings['num_items']);
			echo stripslashes($settings['before_list']);
			# builds html from array
			foreach ( $items as $item ) {
				if(!preg_match('<img src="([^"]*)" [^/]*/>', $item['description'], $imgUrlMatches)) {
					continue;
				}
				$baseurl = str_replace("_m.jpg", "", $imgUrlMatches[1]);
				$thumbnails = array(
					'small' => $baseurl . "_m.jpg",
					'square' => $baseurl . "_s.jpg",
					'thumbnail' => $baseurl . "_t.jpg",
					'medium' => $baseurl . ".jpg",
					'large' => $baseurl . "_b.jpg"
				);
				#check if there is an image title (for html validation purposes)
				if($item['title'] !== "") 
					$title = htmlspecialchars(stripslashes($item['title']));
				else 
					$title = $settings['default_title'];
				$url = $item['link'];
				$toprint = stripslashes($settings['html']);
				$toprint = str_replace("%flickr_page%", $url, $toprint);
				$toprint = str_replace("%title%", $title, $toprint);
			
				$cachePath = trailingslashit($settings['cache_uri']);
				$fullPath = trailingslashit($settings['cache_path']);
			
				foreach ($thumbnails as $size => $thumbnail) {
					if (
							is_array($settings['cache_sizes']) && 
							in_array($size, $settings['cache_sizes']) && 
							$settings['do_cache'] == "true" && 
							$cachePath && 
							$fullPath && 
							strpos($settings['html'], "%image_".$size."%")
					) {
						$img_to_cache = $thumbnail;
						preg_match('<http://farm[0-9]{0,3}\.static.flickr\.com/\d+?\/([^.]*)\.jpg>', $img_to_cache, $flickrSlugMatches);
						$flickrSlug = $flickrSlugMatches[1];
						if (!file_exists("$fullPath$flickrSlug.jpg") ) {   
							$localimage = fopen("$fullPath$flickrSlug.jpg", 'wb');
							$remoteimage = wp_remote_fopen($img_to_cache);
							$iscached = fwrite($localimage,$remoteimage);
							fclose($localimage);
						} else {
							$iscached = true;
						}
						if($iscached) $thumbnail = "$cachePath$flickrSlug.jpg";
					}
					$toprint = str_replace("%image_".$size."%", $thumbnail, $toprint);
				}
				echo $toprint;
			}
			echo stripslashes($settings['after_list']);
		}
	
		function setupWidget() {
			if (!function_exists('register_sidebar_widget')) return;
			function widget_flickrRSS($args) {
				extract($args);
				$options = get_option('widget_flickrRSS');
				$title = $options['title'];
				echo $before_widget . $before_title . $title . $after_title;
				get_flickrRSS();
				echo $after_widget;
			}
			function widget_flickrRSS_control() {
				$options = get_option('widget_flickrRSS');
				if ( $_POST['flickrRSS-submit'] ) {
					$options['title'] = strip_tags(stripslashes($_POST['flickrRSS-title']));
					update_option('widget_flickrRSS', $options);
				}
				$title = htmlspecialchars($options['title'], ENT_QUOTES);
				$settingspage = trailingslashit(get_option('siteurl')).'wp-admin/options-general.php?page='.basename(__FILE__);
				echo 
				'<p><label for="flickrRSS-title">Title:<input class="widefat" name="flickrRSS-title" type="text" value="'.$title.'" /></label></p>'.
				'<p>To control the other settings, please visit the <a href="'.$settingspage.'">flickrRSS Settings page</a>.</p>'.
				'<input type="hidden" id="flickrRSS-submit" name="flickrRSS-submit" value="1" />';
			}
			register_sidebar_widget('flickrRSS', 'widget_flickrRSS');
			register_widget_control('flickrRSS', 'widget_flickrRSS_control');
		}
	
		function setupSettingsPage() {
			if (function_exists('add_options_page')) {
				add_options_page('flickrRSS Settings', 'flickrRSS', 8, basename(__FILE__), array(&$this, 'printSettingsPage'));
			}
		}
	
		function printSettingsPage() {
			$settings = $this->getSettings();
			if (isset($_POST['save_flickrRSS_settings'])) {
				foreach ($settings as $name => $value) {
					$settings[$name] = $_POST['flickrRSS_'.$name];
				}
				$settings['cache_sizes'] = array();
				foreach (array("small", "square", "thumbnail", "medium", "large") as $size) {
					if ($_POST['flickrRSS_cache_'.$size]) $settings['cache_sizes'][] = $size;
				}
				update_option('flickrRSS_settings', $settings);
				echo '<div class="updated"><p>flickrRSS settings saved!</p></div>';
			}
			if (isset($_POST['reset_flickrRSS_settings'])) {
				delete_option('flickrRSS_settings');
				echo '<div class="updated"><p>flickrRSS settings restored to default!</p></div>';
			}
			include ("flickrrss-settingspage.php");
		}
	}
}
$flickrRSS = new flickrRSS();
add_action( 'admin_menu', array(&$flickrRSS, 'setupSettingsPage') );
add_action( 'plugins_loaded', array(&$flickrRSS, 'setupWidget') );
register_activation_hook( __FILE__, array( &$flickrRSS, 'setupActivation' ));

function get_flickrRSS($settings = array()) {
	global $flickrRSS;
	if (func_num_args() > 1 ) {
		$old_array = func_get_args();
		$flickrRSS->printGallery($flickrRSS->fixArguments($old_array));
	}
	else $flickrRSS->printGallery($settings);
}

?>