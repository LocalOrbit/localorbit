<?php

/*------------------------------------------*/
/* WPZOOM: Recent Comments (with gravatar)	*/
/*------------------------------------------*/
 
class Wpzoom_Recent_Comments extends WP_Widget {
	
	function Wpzoom_Recent_Comments() {
		/* Widget settings. */
		$widget_ops = array( 'classname' => 'recent-comments', 'description' => 'A list of recent comments from all posts' );

		/* Widget control settings. */
		$control_ops = array( 'id_base' => 'wpzoom-recent-comments' );

		/* Create the widget. */
		$this->WP_Widget( 'wpzoom-recent-comments', 'WPZOOM: Recent Comments', $widget_ops, $control_ops );
	}
	
 	function widget( $args, $instance ) {
		extract( $args );

		/* User-selected settings. */
		$title = apply_filters('widget_title', $instance['title'] );
		$show_count = $instance['show_count'];
		$show_avatar = isset( $instance['show_avatar'] ) ? $instance['show_avatar'] : false;
		$avatar_size = $instance['avatar_size'];
		$excerpt_length = $instance['excerpt_length'];

		/* Before widget (defined by themes). */
		echo $before_widget;

		/* Title of widget (before and after defined by themes). */
		if ( $title )
			echo $before_title . $title . $after_title;
				
			$comments = get_comments(array(
				'number' => $show_count,
				'status' => 'approve',
				'type' => 'comment'
			));
			
			echo '<ul class="recent-comments-list">';
			
			foreach($comments as $comment) :
				
				$comm_title = get_the_title($comment->comment_post_ID);
				$comm_link = get_comment_link($comment->comment_ID);
			?>
		
		<li>
			<?php
				if ( $show_avatar ) {
					echo '<a href="' . $comm_link . '">' . get_avatar($comment,$size=$avatar_size) . '</a>';
				}
			?>
			<a href="<?php echo($comm_link)?>"><?php echo($comment->comment_author)?>:</a> <?php echo substr(get_comment_excerpt( $comment->comment_ID ), 0, $excerpt_length); ?>&hellip;<div class="clear"></div>
		</li> 
		
			<?php 
			endforeach;
			
			echo '</ul>';
		

		/* After widget (defined by themes). */
		echo $after_widget;
	}
	
 	function update( $new_instance, $old_instance ) {
		$instance = $old_instance;

		/* Strip tags (if needed) and update the widget settings. */
		$instance['title'] = strip_tags( $new_instance['title'] );
		$instance['show_count'] = $new_instance['show_count'];
		$instance['show_avatar'] = $new_instance['show_avatar'];
		$instance['avatar_size'] = $new_instance['avatar_size'];
		$instance['excerpt_length'] = $new_instance['excerpt_length'];

		return $instance;
	}
	
 	function form( $instance ) {

		/* Set up some default widget settings. */
		$defaults = array( 'title' => 'Recent Comments', 'show_count' => 3, 'show_avatar' => false, 'avatar_size' => 40, 'excerpt_length' => 60 );
		$instance = wp_parse_args( (array) $instance, $defaults ); ?>
		
		<p>
			<label for="<?php echo $this->get_field_id( 'title' ); ?>">Title:</label><br />
			<input id="<?php echo $this->get_field_id( 'title' ); ?>" name="<?php echo $this->get_field_name( 'title' ); ?>" value="<?php echo $instance['title']; ?>" type="text" size="25"/>
		</p>

		<p>
			<label for="<?php echo $this->get_field_id( 'show_count' ); ?>">Show:</label>
			<select id="<?php echo $this->get_field_id( 'show_count' ); ?>" name="<?php echo $this->get_field_name( 'show_count' ); ?>">
				<?php
				for ( $i = 1; $i < 11; $i++ ) {
					echo '<option' . ( $i == $instance['show_count'] ? ' selected="selected"' : '' ) . '>' . $i . '</option>';
				}
				?>
			</select> comments
		</p>
		
		<p>
			<input class="checkbox" type="checkbox" <?php checked( $instance['show_avatar'], 'on' ); ?> id="<?php echo $this->get_field_id( 'show_avatar' ); ?>" name="<?php echo $this->get_field_name( 'show_avatar' ); ?>" />
			<label for="<?php echo $this->get_field_id( 'show_avatar' ); ?>">Show avatar?</label>
		</p>
		
		<p>
			<label for="<?php echo $this->get_field_id( 'avatar_size' ); ?>">Avatar size:</label>
			<input id="<?php echo $this->get_field_id( 'avatar_size' ); ?>" name="<?php echo $this->get_field_name( 'avatar_size' ); ?>" value="<?php echo $instance['avatar_size']; ?>" type="text" size="4" /> px
		</p>
		
		<p>
			<label for="<?php echo $this->get_field_id( 'excerpt_length' ); ?>">Comment excerpt:</label>
			<input id="<?php echo $this->get_field_id( 'excerpt_length' ); ?>" name="<?php echo $this->get_field_name( 'excerpt_length' ); ?>" value="<?php echo $instance['excerpt_length']; ?>" type="text" size="4" /> characters
		</p>
		
		<?php
	}
}

function wpzoom_register_rc_widget() {
	register_widget('Wpzoom_Recent_Comments');
}
add_action('widgets_init', 'wpzoom_register_rc_widget');