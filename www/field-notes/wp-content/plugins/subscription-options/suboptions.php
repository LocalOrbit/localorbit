<?php
/**
 * Plugin Name: Subscription Options
 * Plugin URI: http://digitalcortex.net/plugins
 * Description: Adds subscription option icons for your RSS Feed URL; your FeedBurner Email Service URL and your Twitter Stream URL. Totally user-defined.
 * Version: 0.4.2
 * Author: freedimensional
 * Author URI: http://digitalcortex.net
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Add function to widgets_init that will load the widget.
 */
add_action( 'widgets_init', 'suboptions_load_widgets' );

/**
 * Register the widget.
 * 'SubOptions_Widget' is the widget class used below.
 */
function suboptions_load_widgets() {
	register_widget( 'SubOptions_Widget' );
}

/**
 * suboptions Widget class.
 * This class handles everything that needs to be handled with the widget:
 * the settings, form, display, and update.  Nice!
 */
class SubOptions_Widget extends WP_Widget {

	/**
	 * Widget setup.
	 */
	function SubOptions_Widget() {
		/* Widget settings. */
		$widget_ops = array( 'classname' => 'suboptions', 'description' => __('Add subscription options for your readers with related feed icons', 'suboptions') );

		/* Widget control settings. */
		$control_ops = array( 'width' => 250, 'height' => 350, 'id_base' => 'suboptions-widget' );

		/* Create the widget. */
		$this->WP_Widget( 'suboptions-widget', __('Subscription Options', 'suboptions'), $widget_ops, $control_ops );
	}

	/**
	 * Display the widget on the screen.
	 */
	function widget( $args, $instance ) {
		extract( $args );

		/* Variables from the widget settings. */
		$title = apply_filters('widget_title', $instance['title'] );
		$rss_url = $instance['rss_url'];
		$mail_url = $instance['mail_url'];
    $twitter_url = $instance['twitter_url'];
		$size = $instance['size'];

		/* Before widget (defined by themes). */
		echo $before_widget;

		/* Display the widget title if one was input (before and after defined by themes). */
		if ( $title )
			echo $before_title . $title . $after_title;

		/* If an RSS Feed URL was entered, display the RSS icon. */			
		if ( $rss_url )
			echo '<a 	target="_blank" 	title="Subscribe via RSS" 		  alt="Subscribe via RSS" 	        href="'.$rss_url.'">		        <img class="rss_icon"		        style="border: 0px none; width: '.$size.'px; height: '.$size.'px; "	src="'.get_bloginfo('wpurl').'/'.PLUGINDIR.'/subscription-options/images/feed_icon.png"/>		  </a>';
				
		/* If a FeedBurner Email Service URL was entered, display the email icon. */			
		if ( $mail_url )
			echo '<a 	target="_blank"	title="Subscribe via Email" 	 alt="Subscribe via Email" 	  href="'.$mail_url.'">		    <img class="mail_icon"		    style="border: 0px none; width: '.$size.'px; height: '.$size.'px; " src="'.get_bloginfo('wpurl').'/'.PLUGINDIR.'/subscription-options/images/mail_icon.png"/>		    </a>';
			
		/* If a Twitter Stream URL was entered, display the Twitter icon. */			
		if ( $twitter_url )
			echo '<a 	target="_blank"	title="Subscribe via Twitter" 	alt="Subscribe via Twitter"   href="'.$twitter_url.'">	<img class="twitter_icon"	  style="border: 0px none; width: '.$size.'px; height: '.$size.'px; " src="'.get_bloginfo('wpurl').'/'.PLUGINDIR.'/subscription-options/images/twitter_icon.png"/>	</a>';

		/* After widget (defined by themes). */
		echo $after_widget;
	}

	/**
	 * Update the widget settings.
	 */
	function update( $new_instance, $old_instance ) {
		$instance = $old_instance;

		/* Strip HTML tags for the following: */
		$instance['title'] = strip_tags( $new_instance['title'] );
		$instance['rss_url'] = strip_tags( $new_instance['rss_url'] );
		$instance['mail_url'] = strip_tags( $new_instance['mail_url'] );
		$instance['twitter_url'] = strip_tags( $new_instance['twitter_url'] );
		$instance['size'] = strip_tags( $new_instance['size'] );

		return $instance;
	}

	/**
	 * Displays the widget settings controls on the widget panel.
	 * Makes use of the get_field_id() and get_field_name() function
	 * when creating your form elements. This handles the confusing stuff.
	 */
	function form( $instance ) {

		/* Set up some default widget settings. */
		$defaults = array(
					'title' => 'Subscription Options:',
          'rss_url' => '',
					'mail_url' => '',
					'twitter_url' => '',
					'size' => '70',
          );
		$instance = wp_parse_args( (array) $instance, $defaults ); ?>

		<!-- Widget Title: Text Input -->
		<p>
      <label for="<?php echo $this->get_field_id( 'title' ); ?>">Title:</label>
			<input id="<?php echo $this->get_field_id( 'title' ); ?>" name="<?php echo $this->get_field_name( 'title' ); ?>" value="<?php echo $instance['title']; ?>" style="width:218px;" />
		</p>

		<!-- RSS Feed URL: Text Input -->
		<p>
			<label for="<?php echo $this->get_field_id( 'rss_url' ); ?>"><?php _e('RSS Feed URL:', 'suboptions'); ?></label>
			<input id="<?php echo $this->get_field_id( 'rss_url' ); ?>" name="<?php echo $this->get_field_name( 'rss_url' ); ?>" value="<?php echo $instance['rss_url']; ?>" style="width:218px;" />
		</p>

		<!-- FeedBurner Email Service URL: Text Input -->
		<p>
			<label for="<?php echo $this->get_field_id( 'mail_url' ); ?>"><?php _e('FeedBurner Email Service URL:', 'suboptions'); ?></label>
			<input id="<?php echo $this->get_field_id( 'mail_url' ); ?>" name="<?php echo $this->get_field_name( 'mail_url' ); ?>" value="<?php echo $instance['mail_url']; ?>" style="width:218px;" />
		</p>
		
		<!-- Twitter Stream URL: Text Input -->
		<p>
			<label for="<?php echo $this->get_field_id( 'twitter_url' ); ?>"><?php _e('Twitter Stream URL:', 'suboptions'); ?></label>
			<input id="<?php echo $this->get_field_id( 'twitter_url' ); ?>" name="<?php echo $this->get_field_name( 'twitter_url' ); ?>" value="<?php echo $instance['twitter_url']; ?>" style="width:218px;" />
		</p>
		
		<!-- Icon Size: Text Input -->
		<p>
			<label for="<?php echo $this->get_field_id( 'size' ); ?>"><?php _e('Icon Size:', 'suboptions'); ?></label>
			<input id="<?php echo $this->get_field_id( 'size' ); ?>" name="<?php echo $this->get_field_name( 'size' ); ?>" value="<?php echo $instance['size']; ?>" style="width:30px; " /><?php _e(' pixels', 'suboptions'); ?>
		</p>

	<?php
	}
}

?>