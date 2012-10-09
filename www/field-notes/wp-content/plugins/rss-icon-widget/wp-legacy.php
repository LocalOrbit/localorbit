<?php

	// Put functions into one big function we'll call at the plugins_loaded
	// action. This ensures that all required plugin functions are defined.
	function widget_rssicon_init() {
	
		// Check for the required plugin functions. This will prevent fatal
		// errors occurring when you deactivate the dynamic_sidebar plugin.
		if ( !function_exists('register_sidebar_widget') )
			return;
	
		// This is the function that outputs our little RSS Icon form.
		function widget_rssicon($args) {
			
			// $args is an array of strings that help widgets to conform to
			// the active theme: before_widget, before_title, after_widget,
			// and after_title are the array keys. Default tags: li and h2.
			extract($args);
	
			// Each widget can store its own options. We keep strings here.
			$options = get_option('widget_rssicon');
			// $image_color = $options['image_color'];
			$image_size = $options['image_size'];
			$link_text = $options['link_text'];
			$link_color = $options['link_color'];
			$feed_url = $options['feed_url'];
	
			// These lines generate our output. Widgets can be very complex
			// but as you can see here, they can also be very, very simple.
			echo $before_widget;
			echo '<a href="'.$feed_url.'" style="color: '.$link_color.'; padding: '.($image_size/2).'px 0px '.($image_size/2).'px '.($image_size + 5).'px; background: url(\''.get_bloginfo('wpurl').'/'.PLUGINDIR.'/rss-icon-widget/icons/feed-icon-'.$image_size.'x'.$image_size.'.png\') no-repeat 0 50%;">';
			echo $link_text;
			echo '</a>';
			echo $after_widget;
		}
	
		// This is the function that outputs the form to let the users edit
		// the widget's title. It's an optional feature that users cry for.
		function widget_rssicon_control() {
			
			/*$icon_colors = array(
				'orange' => 'Orange'
			);*/
			
			$icon_sizes = array(
				'10' => '10 x 10',
				'12' => '12 x 12',
				'14' => '14 x 14',
				'16' => '16 x 16',
				'24' => '24 x 24',
				'32' => '32 x 32'
			);
			
			// Get our options and see if we're handling a form submission.
			$options = get_option('widget_rssicon');
			if ( !is_array($options) ) {
				$options = array(
					// 'image_color' => 'orange',
					'image_size' => '10',
					'link_text' => 'Subscribe via RSS',
					'link_color' => '#ff0000',
					'feed_url' => get_bloginfo('rss_url')
				);
			}
			if ( $_POST['rssicon_submit'] ) {
	
				// Remember to sanitize and format use input appropriately.
				// $options['image_color'] = strip_tags(stripslashes($_POST['rssicon_image_color']));
				$options['image_size'] = strip_tags(stripslashes($_POST['rssicon_image_size']));
				$options['link_text'] = strip_tags(stripslashes($_POST['rssicon_link_text']));
				$options['link_color'] = strip_tags(stripslashes($_POST['rssicon_link_color']));
				$options['feed_url'] = strip_tags(stripslashes($_POST['rssicon_feed_url']));
				update_option('widget_rssicon', $options);
			}
	
			// Be sure you format your options to be valid HTML attributes.
			// $image_color = htmlspecialchars($options['image_color'], ENT_QUOTES);
			$image_size = htmlspecialchars($options['image_size'], ENT_QUOTES);
			$link_text = htmlspecialchars($options['link_text'], ENT_QUOTES);
			$link_color = htmlspecialchars($options['link_color'], ENT_QUOTES);
			$feed_url = htmlspecialchars($options['feed_url'], ENT_QUOTES);
			
			// Here is our little form segment. Notice that we don't need a
			// complete form. This will be embedded into the existing form.
			/*echo '<p><label for="rssicon_image_color">' . __('Color:') . "<br />";
			echo ' <select id="rssicon_image_color" name="rssicon_image_color" style="width: 100%;">';
			echo '  <option value="orange">-- Choose a Color --</option>';
			foreach ($icon_colors as $color_key => $color_name) {
				echo '  <option value="'.$color_key.'"'.($image_color == $color_key ? ' selected' : '').'>'.$color_name.'</option>';
			}
			echo ' </select>';
			echo '</label></p>';*/
			
			echo '<p><label for="rssicon_image_size">' . __('Size:') . "<br />";
			echo ' <select id="rssicon_image_size" name="rssicon_image_size" style="width: 100%;">';
			echo '  <option value="10">-- Choose a Size --</option>';
			foreach ($icon_sizes as $size_key => $size_name) {
				echo '  <option value="'.$size_key.'"'.($image_size == $size_key ? ' selected' : '').'>'.$size_name.'</option>';
			}
			echo ' </select>';
			echo '</label></p>';
			
			echo '<p><label for="rssicon_link_text">' . __('Link Text:', 'widgets') . "<br />";
			echo ' <input id="rssicon_link_text" name="rssicon_link_text" type="text" style="width: 100%;" value="'.$link_text.'" />';
			echo '</label></p>';
			
			echo '<script type="text/javascript">';
  			echo ' $(document).ready(function() {';
			echo "  $('#rssicon_link_color_colorpicker').farbtastic('#rssicon_link_color');";
			echo ' });';
			echo '</script>';
			echo '<p><label for="rssicon_link_color">' . __('Link Color:', 'widgets') . "<br />";
			echo ' <div id="rssicon_link_color_colorpicker"></div>';
			echo ' <input id="rssicon_link_color" name="rssicon_link_color" type="text" style="width: 100%;" value="'.$link_color.'" />';
			echo '</label></p>';
			
			echo '<p><label for="rssicon_feed_url">' . __('Feed URL:', 'widgets') . "<br />";
			echo ' <input id="rssicon_feed_url" name="rssicon_feed_url" type="text" style="width: 100%;" value="'.$feed_url.'" />';
			echo '</label></p>';
			echo '<input type="hidden" id="rssicon_submit" name="rssicon_submit" value="1" />';
		}
		
		// This registers our widget so it appears with the other available
		// widgets and can be dragged and dropped into any active sidebars.
		register_sidebar_widget(array('RSS Icon', 'widgets'), 'widget_rssicon');
	
		// This registers our optional widget control form. Because of this
		// our widget will have a button that reveals a 300x100 pixel form.
		register_widget_control(array('RSS Icon', 'widgets'), 'widget_rssicon_control');
	}
	
	// Run our code later in case this loads prior to any required plugins.
	add_action('widgets_init', 'widget_rssicon_init');
	
	// add jquery and the color_picker
	add_action('init', 'install_jquery_scripts');
	function install_jquery_scripts() {
		
		// make sure we don't interfere with other plugins
		if (stripos($_SERVER['REQUEST_URI'],'widgets.php')!== false) {
			// fix broken jquery
			wp_deregister_script('jquery');
			wp_register_script('jquery', get_bloginfo('wpurl').'/'.PLUGINDIR.'/rss-icon-widget/js/jquery-1.3.2.min.js', array(), '1.3.2');
		
			// add color picker js
			wp_enqueue_script('farbtastic', get_bloginfo('wpurl').'/'.PLUGINDIR.'/rss-icon-widget/js/farbtastic/farbtastic.js', array('jquery'));
			// add color picker js
			wp_enqueue_style('farbtastic', get_bloginfo('wpurl').'/'.PLUGINDIR.'/rss-icon-widget/js/farbtastic/farbtastic.css', array('jquery'));
		}
	}	
?>