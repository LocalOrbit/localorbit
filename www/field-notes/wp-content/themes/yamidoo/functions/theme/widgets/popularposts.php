<?php

/*------------------------------------------*/
/* WPZOOM: Popular Posts										*/
/*------------------------------------------*/

class Wpzoom_Popular_Posts extends WP_Widget {

	function Wpzoom_Popular_Posts() {
		/* Widget settings. */
		$widget_ops = array( 'classname' => 'wpzoom-popular-posts', 'description' => 'A list of the most popular posts' );

		/* Widget control settings. */
		$control_ops = array( 'id_base' => 'wpzoom-popular-posts' );

		/* Create the widget. */
		$this->WP_Widget( 'wpzoom-popular-posts', 'WPZOOM: Popular Posts', $widget_ops, $control_ops );
	}

	function widget( $args, $instance ) {
		extract( $args );

		/* User-selected settings. */
		$title = apply_filters('widget_title', $instance['title'] );
		$maxposts = $instance['maxposts'];
		$timeline = $instance['sincewhen'];

		/* Before widget (defined by themes). */
		echo $before_widget;

		/* Title of widget (before and after defined by themes). */
		if ( $title )
			echo $before_title . $title . $after_title;

		// Generate output
		echo "<ul class='popular'>\n";

		// Since we're passing a SQL statement, globalise the $wpdb var
		global $wpdb;
		$sql = "SELECT ID, post_title, comment_count, post_date FROM $wpdb->posts WHERE post_status = 'publish' AND post_type = 'post' ";
		// What's the chosen timeline?
		switch ($timeline) {
			case "thismonth":
				$sql .= "AND MONTH(post_date) = MONTH(NOW()) AND YEAR(post_date) = YEAR(NOW()) ";
				break;
			case "thisyear":
				$sql .= "AND YEAR(post_date) = YEAR(NOW()) ";
				break;
			default:
				$sql .= "";
		}

		// Make sure only integers are entered
		if (!ctype_digit($maxposts)) {
			$maxposts = 10;
		} else {
			// Reformat the submitted text value into an integer
			$maxposts = $maxposts + 0;
			// Only accept sane values
			if ($maxposts <= 0 or $maxposts > 10) {
				$maxposts = 10;
			}
		}

		// Complete the SQL statement
		$sql .= "AND comment_count > 0 ORDER BY comment_count DESC LIMIT ". $maxposts;

		$res = $wpdb->get_results($sql);

		if($res) {
			$mcpcounter = 1;
			foreach ($res as $r) {

				$cats = get_the_category($r->ID);

				$wrappeddate = $r->post_date;
				$wrappeddate = str_replace(" ","-",$wrappeddate);
				$wrappeddate = str_replace(":","-",$wrappeddate);
				$datearray = explode("-", $wrappeddate);

				$wrappeddate = date("F j, Y", mktime($datearray[3], $datearray[4], $datearray[5], $datearray[1], $datearray[2], $datearray[0]));


				echo "<li>	<a href='".get_permalink($r->ID)."' rel='bookmark'>".htmlspecialchars($r->post_title, ENT_QUOTES)."</a><br/><small class='comments'>".htmlspecialchars($r->comment_count, ENT_QUOTES)." comments</small>";


				 echo"</li>\n";


				$mcpcounter++;
			}
		} else {
			echo "<li class='mcpitem mcpitem-0'>". __('No commented posts yet', 'wpzoom') . "</li>\n";
		}

		echo "</ul>\n";

		/* After widget (defined by themes). */
		echo $after_widget;
	}

 	function update( $new_instance, $old_instance ) {
		$instance = $old_instance;

		/* Strip tags (if needed) and update the widget settings. */
		$instance['title'] = strip_tags( $new_instance['title'] );
		$instance['maxposts'] = $new_instance['maxposts'];
		$instance['sincewhen'] = $new_instance['sincewhen'];

		return $instance;
	}

 	function form( $instance ) {
		/* Set up some default widget settings. */
		$defaults = array( 'title' => 'Popular Posts', 'maxposts' => 10, 'sincewhen' => 'forever' );
		$instance = wp_parse_args( (array) $instance, $defaults ); ?>
		
		<p>
			<label for="<?php echo $this->get_field_id( 'title' ); ?>"><?php _e('Title:', 'wpzoom'); ?></label><br />
			<input id="<?php echo $this->get_field_id( 'title' ); ?>" name="<?php echo $this->get_field_name( 'title' ); ?>" value="<?php echo $instance['title']; ?>" type="text" size="25"/>
		</p>
		
		<p>
			<label for="<?php echo $this->get_field_id( 'sincewhen' ); ?>"><?php _e('Since:', 'wpzoom'); ?></label><br />
			<select id="<?php echo $this->get_field_id( 'sincewhen' ); ?>" name="<?php echo $this->get_field_name( 'sincewhen' ); ?>">
				<option value="forever"<?php echo $instance['sincewhen'] != 'thismonth' && $instance['sincewhen'] != 'thisyear' ? 'selected="selected"' : ''; ?>><?php _e('Forever', 'wpzoom'); ?></option>
				<option value="thisyear"<?php echo $instance['sincewhen'] == 'thisyear' ? 'selected="selected"' : ''; ?>><?php _e('This Year', 'wpzoom'); ?></option>
				<option value="thismonth"<?php echo $instance['sincewhen'] == 'thismonth' ? 'selected="selected"' : ''; ?>><?php _e('This Month', 'wpzoom'); ?></option>
			</select>
		</p>

		<p>
			<label for="<?php echo $this->get_field_id( 'maxposts' ); ?>"><?php _e('Posts To Display:', 'wpzoom'); ?></label>
			<select id="<?php echo $this->get_field_id( 'maxposts' ); ?>" name="<?php echo $this->get_field_name( 'maxposts' ); ?>">
				<?php
				for ( $i = 1; $i < 11; $i++ ) {
					echo '<option' . ( $i == $instance['maxposts'] ? ' selected="selected"' : '' ) . '>' . $i . '</option>';
				}
				?>
			</select>
		</p>

		<?php
	}

}

function wpzoom_register_pp_widget() {
	register_widget('Wpzoom_Popular_Posts');
}
add_action('widgets_init', 'wpzoom_register_pp_widget');
?>