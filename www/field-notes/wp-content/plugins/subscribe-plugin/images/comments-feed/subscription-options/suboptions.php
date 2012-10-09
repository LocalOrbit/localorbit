<?php
/*
Plugin Name: Subscription Options
Plugin URI: http://digitalcortex.net/plugins/
Description: Adds three subscription options for your readers with related feed icons: your FeedBurner RSS feed URL; your FeedBurner Email service URL and your Twitter feed. User-defined icon size and title text.
Author: freedimensional
Version: 0.1.5.6
Author URI: http://digitalcortex.net/
*/

/*
	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

	// Put all functions into one big function to be called at plugins_loaded.
	// It ensures that all required plugin functions are defined.
	function widget_suboptions_init() {
	
		// Check for the required plugin functions. This will prevent fatal
		// errors occurring when you deactivate the dynamic_sidebar plugin.
		if ( !function_exists('register_sidebar_widget') )
			return;
	
		// This is the function that outputs the widget settings.
		function widget_suboptions($args) {
			
			// $args is an array of strings that help widgets to conform to the active theme:
			// before_widget, before_title, after_widget, and after_title are the array keys.
			extract($args);
	
			// Each widget can store its own options. I keep strings here.
			$options = get_option('widget_suboptions');

			$rss_url = $options['rss_url'];
			$mail_url = $options['mail_url'];
			$twitter_url = $options['twitter_url'];
			$widget_title = $options['widget_title'];
			$rel = $options['rel']; // Not currently a user-defined option
			$pixels = $options['pixels'];
	
			// These lines generate the HTML output.
			echo $before_widget;
			echo '<div class="suboptions_widget">';
			echo '<h3 class="suboptions_widget">'.$widget_title.'</h3>';
			echo '<a type="application/rss+xml" rel="'.$rel.'" 	title="Subscribe via RSS" 		alt="Subscribe via RSS" 	href="'.$rss_url.'">		<img class="rss_icon"		style="border: 0px none; width: '.$pixels.'; height: '.$pixels.'; "	src="'.get_bloginfo('wpurl').'/'.PLUGINDIR.'/subscription-options/images/feed_icon.png"/>		</a>';
			echo '<a type="text/html;"			rel="'.$rel.'" 	title="Subscribe via Email" 	alt="Subscribe via Email" 	href="'.$mail_url.'">		<img class="mail_icon"		style="border: 0px none; width: '.$pixels.'; height: '.$pixels.'; " src="'.get_bloginfo('wpurl').'/'.PLUGINDIR.'/subscription-options/images/mail_icon.png"/>		</a>';
			echo '<a type="text/javascript"		rel="'.$rel.'" 	title="Subscribe via Twitter" 	alt="Subscribe via Twitter" href="'.$twitter_url.'">	<img class="twitter_icon"	style="border: 0px none; width: '.$pixels.'; height: '.$pixels.'; " src="'.get_bloginfo('wpurl').'/'.PLUGINDIR.'/subscription-options/images/twitter_icon.png"/>	</a>';
			echo '</div>';
			echo $after_widget;
		}
	
		// This is the function that outputs the form to let the users edit the widget's title.
		function widget_suboptions_control() {
			
			// Gets the default options and checks to see if we're dealing with a form submission.
			$options = get_option('widget_suboptions');
			if ( !is_array($options) ) {
				$options = array(
					'rss_url' => 'Insert FeedBurner RSS feed URL here',
					'mail_url' => 'Insert FeedBurner Email service URL here',
					'twitter_url' => 'http://twitter.com/yourusername',
					'widget_title' => 'Subscription Options:',
					'rel' => 'alternate',
					'pixels' => '30',
				);
			}
			if ( $_POST['suboptions_submit'] ) {
	
				// Ensures that we format your input appropriately.
				$options['rss_url'] = strip_tags(stripslashes($_POST['suboptions_rss_url']));
				$options['mail_url'] = strip_tags(stripslashes($_POST['suboptions_mail_url']));
				$options['twitter_url'] = strip_tags(stripslashes($_POST['suboptions_twitter_url']));
				$options['widget_title'] = strip_tags(stripslashes($_POST['suboptions_widget_title']));
				$options['rel'] = strip_tags(stripslashes($_POST['suboptions_rel']));
				$options['pixels'] = strip_tags(stripslashes($_POST['suboptions_pixels']));				
				update_option('widget_suboptions', $options);
			}
	
			// Ensures your options are valid HTML attributes.
			$rss_url = htmlspecialchars($options['rss_url'], ENT_QUOTES);
			$mail_url = htmlspecialchars($options['mail_url'], ENT_QUOTES);
			$twitter_url = htmlspecialchars($options['twitter_url'], ENT_QUOTES);
			$widget_title = htmlspecialchars($options['widget_title'], ENT_QUOTES);
			$rel = htmlspecialchars($options['rel'], ENT_QUOTES);
			$pixels = htmlspecialchars($options['pixels'], ENT_QUOTES);
			
			// Here is the widget form segment
			
			//Title
			echo '<p><label for="suboptions_widget_title">' . __('Widget Title:', 'widgets') . "<br />";
			echo ' <input id="suboptions_widget_title" name="suboptions_widget_title" type="text" style="width: 100%;" value="'.$widget_title.'" />';
			echo '</label></p>';
			
			//Feed URL
			echo '<p><label for="suboptions_rss_url">' . __('FeedBurner RSS Feed URL:', 'widgets') . "<br />";
			echo ' <input id="suboptions_rss_url" name="suboptions_rss_url" type="text" style="width: 100%;" value="'.$rss_url.'" />';
			echo '</label></p>';
			
			//Mail URL
			echo '<p><label for="suboptions_mail_url">' . __('FeedBurner Email Service URL:', 'widgets') . "<br />";
			echo ' <input id="suboptions_mail_url" name="suboptions_mail_url" type="text" style="width: 100%;" value="'.$mail_url.'" />';
			echo '</label></p>';
			
			//Twitter URL
			echo '<p><label for="suboptions_twitter_url">' . __('Twitter Stream URL:', 'widgets') . "<br />";
			echo ' <input id="suboptions_twitter_url" name="suboptions_twitter_url" type="text" style="width: 100%;" value="'.$twitter_url.'" />';
			echo '</label></p>';
			
			//Icon Size
			echo '<p><label for="suboptions_pixels">' . __('Size of Feed Icons (up to 64px):', 'widgets') . "<br />";
			echo ' <input id="suboptions_pixels" name="suboptions_pixels" type="text" style="width: 100%;" value="'.$pixels.'" />';
			echo '</label></p>';
			
			//Submit Button
			echo '<input type="hidden" id="suboptions_submit" name="suboptions_submit" value="1" />';
			
		}
		
		// This registers the widget so that it appears with the other available
		// widgets and can be dragged and dropped into any active sidebars.
		register_sidebar_widget(array('Subscription Options', 'widgets'), 'widget_suboptions');
	
		// This registers the optional widget control form.
		register_widget_control(array('Subscription Options', 'widgets'), 'widget_suboptions_control');
	}
	
	// Runs the code later in case this loads prior to any required plugins.
	add_action('widgets_init', 'widget_suboptions_init');	
	
?>