<?php

/*----------------------------------------------------------------------------------*/
/*  WPZOOM: Twitter Widget	
/*	 			
/*  Plugin URI: http://rick.jinlabs.com/code/twitter
/*  Modified by WPZOOM
/*
/*----------------------------------------------------------------------------------*/
  	function wpzoom_twitter_messages($username = '', $num = 1, $list = false, $update = true, $linked  = '#', $hyperlinks = true, $twitter_users = true, $encode_utf8 = false) {
		require_once(ABSPATH . WPINC . '/class-simplepie.php');

		$messages = get_transient('wpzoom_twitter_messages');
		if (!$messages) {
			$feed = new SimplePie();
			$feed->set_feed_url('http://api.twitter.com/1/statuses/user_timeline.rss?screen_name=' . $username . '&count=' . $num);
			$feed->enable_cache(false);
			$feed->init();

			$messages = $feed->get_items();

			set_transient('wpzoom_twitter_messages', $messages, 360);
		}
	
		if ($list) echo '<ul class="twitter-list">';
		
		if ($username == '') {
			if ($list) echo '<li>';
			echo 'RSS not configured';
			if ($list) echo '</li>';
		} else {
				if ( !$messages ) {
					if ($list) echo '<li>';
					echo 'No Twitter messages.';
					if ($list) echo '</li>';
				} else {
			$i = 0;
					foreach ( $messages as $message ) {
						$msg = " ".substr(strstr($message->get_content(),': '), 2, strlen($message->get_content()))." ";
						if($encode_utf8) $msg = utf8_encode($msg);
						$link = $message->get_permalink();
					
						if ($list) echo '<li class="twitter-item">'; elseif ($num != 1) echo '<p class="twitter-message">';
	
			  if ($hyperlinks) { $msg = hyperlinks($msg); }
			  if ($twitter_users)  { $msg = twitter_users($msg); }
								
						if ($linked != '' || $linked != false) {
				if($linked == 'all')  { 
				  $msg = '<a href="'.$link.'" class="twitter-link">'.$msg.'</a>';  // Puts a link to the status of each tweet 
				} else if ( $linked ) {
				  $msg = $msg . '<a href="'.$link.'" class="twitter-link">'.$linked.'</a>'; // Puts a link to the status of each tweet
				  
				}
			  } 
	
			  echo $msg;
			  
			  
			if($update) {				
			  $time = strtotime($message->get_date());
			  
			  if ( ( abs( time() - $time) ) < 86400 )
				$h_time = sprintf( __('%s ago', 'wpzoom'), human_time_diff( $time ) );
			  else
				$h_time = date('M j, Y', $time);
	
			  echo sprintf( __('%s', 'wpzoom'),' <em class="twitter-timestamp">' . $h_time . '</em>' );
			 }          
					  
						if ($list) echo '</li>'; elseif ($num != 1) echo '</p>';
					
						$i++;
						if ( $i >= $num ) break;
					}
				}
			}
			if ($list) echo '</ul>';
		}
	
 	function hyperlinks($text) {
		$text = preg_replace('/\b([a-zA-Z]+:\/\/[\w_.\-]+\.[a-zA-Z]{2,6}[\/\w\-~.?=&%#+$*!]*)\b/i',"<a href=\"$1\" class=\"twitter-link\">$1</a>", $text);
		$text = preg_replace('/\b(?<!:\/\/)(www\.[\w_.\-]+\.[a-zA-Z]{2,6}[\/\w\-~.?=&%#+$*!]*)\b/i',"<a href=\"http://$1\" class=\"twitter-link\">$1</a>", $text);    
		$text = preg_replace("/\b([a-zA-Z][a-zA-Z0-9\_\.\-]*[a-zA-Z]*\@[a-zA-Z][a-zA-Z0-9\_\.\-]*[a-zA-Z]{2,6})\b/i","<a href=\"mailto://$1\" class=\"twitter-link\">$1</a>", $text);
		$text = preg_replace('/([\.|\,|\:|\°|\ø|\>|\{|\(]?)#{1}(\w*)([\.|\,|\:|\!|\?|\>|\}|\)]?)\s/i', "$1<a href=\"http://twitter.com/#search?q=$2\" class=\"twitter-link\">#$2</a>$3 ", $text);
		return $text;
	}
	
 	function twitter_users($text) {
		   $text = preg_replace('/([\.|\,|\:|\°|\ø|\>|\{|\(]?)@{1}(\w*)([\.|\,|\:|\!|\?|\>|\}|\)]?)\s/i', "$1<a href=\"http://twitter.com/$2\" class=\"twitter-user\">@$2</a>$3 ", $text);
		   return $text;
	}     
	
 	class wpzoom_Twitter extends WP_Widget {
		
 		function wpzoom_Twitter() {
			/* Widget settings. */
			$widget_ops = array( 'classname' => 'twitter', 'description' => 'A list of latest tweets' );
	
			/* Widget control settings. */
			$control_ops = array( 'id_base' => 'wpzoom-twitter' );
	
			/* Create the widget. */
			$this->WP_Widget( 'wpzoom-twitter', 'WPZOOM: Twitter', $widget_ops, $control_ops );
		}
		
 		function widget( $args, $instance ) {
			extract( $args );
	
			/* User-selected settings. */
			$title = apply_filters('widget_title', $instance['title'] );
			$username = $instance['username'];
			$show_count = $instance['show_count'];
			$hide_timestamp = isset( $instance['hide_timestamp'] ) ? $instance['hide_timestamp'] : false;
			$linked = $instance['hide_url'] ? false : '#';
			$show_follow = isset( $instance['show_follow'] ) ? $instance['show_follow'] : false;
			$show_followers = isset( $instance['show_followers'] ) ? $instance['show_followers'] : false;
	
			/* Before widget (defined by themes). */
			echo $before_widget;
	
			/* Title of widget (before and after defined by themes). */
			if ( $title )
				echo $before_title . $title . $after_title;
			
			wpzoom_twitter_messages($username, $show_count, true, !$hide_timestamp, $linked);
 
 	 
			if ($show_follow) { 
				echo '<div class="follow-user"><a href="https://twitter.com/' . $username . '" class="twitter-follow-button"';

				if ($show_followers) {
					echo 'data-show-count="false"';
				}

				echo '>Follow @' . $username . '</a><script src="//platform.twitter.com/widgets.js" type="text/javascript"></script></div>'; 
			}
	
			/* After widget (defined by themes). */
			echo $after_widget;
		}
		
 		function update( $new_instance, $old_instance ) {
			$instance = $old_instance;
	
			/* Strip tags (if needed) and update the widget settings. */
			$instance['title'] = strip_tags( $new_instance['title'] );
			$instance['username'] = $new_instance['username'];
			$instance['show_count'] = $new_instance['show_count'];
			$instance['hide_timestamp'] = $new_instance['hide_timestamp'];
			$instance['hide_url'] = $new_instance['hide_url'];
			$instance['show_follow'] = $new_instance['show_follow'];
			$instance['show_followers'] = $new_instance['show_followers'];
 	
			return $instance;
		}
		
 		function form( $instance ) {
	
			/* Set up some default widget settings. */
			$defaults = array( 'title' => 'Latest Tweets', 'username' => '', 'show_count' => 3, 'hide_timestamp' => false, 'hide_url' => false, 'show_follow' => true, 'show_followers' => true );
			$instance = wp_parse_args( (array) $instance, $defaults ); ?>
			
			<p>
				<label for="<?php echo $this->get_field_id( 'title' ); ?>">Title:</label><br />
				<input type="text" class="widefat" id="<?php echo $this->get_field_id( 'title' ); ?>" name="<?php echo $this->get_field_name( 'title' ); ?>" value="<?php echo $instance['title']; ?>" />
			</p>
	
			<p>
				<label for="<?php echo $this->get_field_id( 'username' ); ?>">Twitter ID:</label>
				<input type="text" class="widefat" id="<?php echo $this->get_field_id( 'username' ); ?>" name="<?php echo $this->get_field_name( 'username' ); ?>" value="<?php echo $instance['username']; ?>"   />
			</p>
			
			<p>
				<label for="<?php echo $this->get_field_id( 'show_count' ); ?>">Show:</label>
				<input  type="text" id="<?php echo $this->get_field_id( 'show_count' ); ?>" name="<?php echo $this->get_field_name( 'show_count' ); ?>" value="<?php echo $instance['show_count']; ?>" size="3" /> tweets
			</p>
			
			<p>
				<input class="checkbox" type="checkbox" <?php checked( $instance['hide_timestamp'], 'on' ); ?> id="<?php echo $this->get_field_id( 'hide_timestamp' ); ?>" name="<?php echo $this->get_field_name( 'hide_timestamp' ); ?>" />
				<label for="<?php echo $this->get_field_id( 'hide_timestamp' ); ?>">Hide timestamp</label>
			</p>
			
			<p>
				<input class="checkbox" type="checkbox" <?php checked( $instance['hide_url'], 'on' ); ?> id="<?php echo $this->get_field_id( 'hide_url' ); ?>" name="<?php echo $this->get_field_name( 'hide_url' ); ?>" />
				<label for="<?php echo $this->get_field_id( 'hide_url' ); ?>">Hide tweet URL</label>
			</p>
			
			<p>
				<input class="checkbox" type="checkbox" <?php checked( $instance['show_follow'], 'on' ); ?> id="<?php echo $this->get_field_id( 'show_follow' ); ?>" name="<?php echo $this->get_field_name( 'show_follow' ); ?>" />
				<label for="<?php echo $this->get_field_id( 'show_follow' ); ?>">Display follow me button</label>
			</p>
			
			<p>
				<input class="checkbox" type="checkbox" <?php checked( $instance['show_followers'], 'on' ); ?> id="<?php echo $this->get_field_id( 'show_followers' ); ?>" name="<?php echo $this->get_field_name( 'show_followers' ); ?>" />
				<label for="<?php echo $this->get_field_id( 'show_followers' ); ?>">Hide follower count?</label>
			</p>
 
				
			
			<?php
		}
	}
 
 
function wpzoom_register_tw_widget() {
	register_widget('wpzoom_Twitter');
}
add_action('widgets_init', 'wpzoom_register_tw_widget');