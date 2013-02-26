<?php
/*------------------------------------------*/
/* WPZOOM: Social widget					*/
/*------------------------------------------*/

$socialProfiles = array('Facebook','Twitter', 'Google Plus', 'RSS', 'Email', 'Youtube', 'Vimeo', 'LinkedIn', 'Flickr', 'Skype','Delicious', 'Digg', 'StumbleUpon');
class wpzoom_widget_socialize extends WP_Widget {

/* Widget setup. */
function wpzoom_widget_socialize() {
	/* Widget settings. */
	$widget_ops = array( 'classname' => 'wpzoom_social', 'description' => __('Custom WPZOOM Widget that displays links to social sharing websites.', 'wpzoom') );
	
	/* Widget control settings. */
	$control_ops = array( 'width' => 250, 'height' => 350, 'id_base' => 'wpzoom-widget-social' );
	
	/* Create the widget. */
	$this->WP_Widget( 'wpzoom-widget-social', __('WPZOOM: Social Widget', 'wpzoom'), $widget_ops, $control_ops );
	
}

/* How to display the widget on the screen. */
function widget( $args, $instance ) {

	extract( $args );
	global $socialProfiles;
	
	/* Our variables from the widget settings. */
	$title = apply_filters('widget_title', $instance['title'] );

	echo $before_widget;
	echo $before_title . $title . $after_title;
	?>
		<ul class="social">
			<?php
			foreach ($socialProfiles as $item)
			{
				$id = strtolower($item);
				$iditem = $id . "_title";
				$iddesc = $id . "_desc";
				if ($instance[$id] && $instance[$id] != '') {
				    if (simple_email_check($instance[$id])) { $instance[$id] = 'mailto:' . $instance[$id]; }
				    
				    echo '<li><a class="'.$id.'" href="'.$instance[$id].'" rel="external,nofollow" title="'.$instance[$iditem].'"><img src="'. get_template_directory_uri() .'/images/icons/social/'.strtolower($item).'.png" alt="'.$instance[$iddesc]. '" />'.$instance[$iditem].'<span>'.$instance[$iddesc].'</span></a></li>'; 
				}
			} 
			?>
  		</ul>
		<div class="cleaner">&nbsp;</div>
	
	<?php
	echo $after_widget; 
	
	wp_reset_query(); 
	}

	/* Update the widget settings.*/
	function update( $new_instance, $old_instance ) {
		$instance = $old_instance;

		/* Strip tags for title and name to remove HTML (important for text inputs). */
		$instance['title'] = strip_tags( $new_instance['title'] );
		$instance['desc'] = strip_tags( $new_instance['desc'] );
		global $socialProfiles;
		
		foreach ($socialProfiles as $item)
		{
			$id = strtolower($item);
			$idtitle = $id . "_title";
			$iddesc = $id . "_desc";
			$instance[$id] = strip_tags( $new_instance[$id] );
			$instance[$idtitle] = strip_tags( $new_instance[$idtitle] );
			$instance[$iddesc] = strip_tags( $new_instance[$iddesc] );
		}
		
		return $instance;
	}

	/** Displays the widget settings controls on the widget panel.
	 * Make use of the get_field_id() and get_field_name() function when creating your form elements. This handles the confusing stuff. */
	function form( $instance ) {
	
		global $socialProfiles;

		/* Set up some default widget settings. */
		$defaults = array( 'title' => 'Widget Title');
		$instance = wp_parse_args( (array) $instance, $defaults );
    ?>

 		<p>
			<label for="<?php echo $this->get_field_id( 'title' ); ?>"><?php _e('Widget Title:', 'wpzoom'); ?></label>
			<input type="text" size="25" id="<?php echo $this->get_field_id( 'title' ); ?>" name="<?php echo $this->get_field_name( 'title' ); ?>" value="<?php echo $instance['title']; ?>"  />
		</p>
		<br/>
		<?php
		
		foreach ($socialProfiles as $item)
		{
			$id = strtolower($item);
			$idtitle = $id . "_title";
			$iddesc = $id . "_desc";

			?>
 	 		<p>
				<img style="float: left; margin:0 8px 0 0;" src="<?php echo get_template_directory_uri(); ?>/images/icons/social/<?php echo $id; ?>.png" />
 				<label for="<?php echo $this->get_field_id( $id ); ?>"><strong><?php echo $item; ?> URL</strong></label> 
				<input type="text" style="margin-left:31px;" id="<?php echo $this->get_field_id( $id ); ?>" name="<?php echo $this->get_field_name( $id ); ?>" value="<?php echo $instance[$id]; ?>" size="22"/> 

			</p> 
			<p style="margin-left:33px;"> 

 				<label for="<?php echo $this->get_field_id( $idtitle ); ?>">Label</label>
				<input type="text"  id="<?php echo $this->get_field_id( $idtitle ); ?>" name="<?php echo $this->get_field_name( $idtitle ); ?>" value="<?php echo $instance[$idtitle]; ?>" size="22" /><br/>

 				<label for="<?php echo $this->get_field_id( $iddesc ); ?>">Description</label>
				<input type="text"  id="<?php echo $this->get_field_id( $iddesc ); ?>" name="<?php echo $this->get_field_name( $iddesc ); ?>" value="<?php echo $instance[$iddesc]; ?>" size="22" /><br/>
			</p> 

 			<br/>
			<?php
		}
		
		?>
	
	<?php
	}
}

function wpzoom_register_sw_widget() {
	register_widget('wpzoom_widget_socialize');
}
add_action('widgets_init', 'wpzoom_register_sw_widget');