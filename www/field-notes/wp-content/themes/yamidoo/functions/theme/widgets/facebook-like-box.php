<?php

/*----------------------------------------------------------------------------------*/
/*  WPZOOM: Facebook Like Box	
/*	 			
/*  Author: Dumitru Brinzan @ WPZOOM
/*
/*----------------------------------------------------------------------------------*/

add_action('widgets_init', create_function('', 'return register_widget("wpzoom_facebook");'));

 	class wpzoom_facebook extends WP_Widget {
 
 		function wpzoom_facebook() {
			/* Widget settings. */
			$widget_ops = array( 'classname' => 'facebook', 'description' => 'Display the Facebook Like Box for your Facebook page' );
	
			/* Widget control settings. */
			$control_ops = array( 'id_base' => 'wpzoom-facebook' );
	
			/* Create the widget. */
			$this->WP_Widget( 'wpzoom-facebook', 'WPZOOM: Facebook Like Box', $widget_ops, $control_ops );
		}
		
 		function widget( $args, $instance ) {
			extract( $args );
	
			/* User-selected settings. */
			$title = apply_filters('widget_title', $instance['title'] );
			$pageurl = $instance['pageurl'];
			$width = $instance['width'];
			$bordercolor = $instance['bordercolor'];
			$show_faces = $instance['show_faces'];
			$show_stream = $instance['show_stream'];
			$show_header = $instance['show_header'];
			
			if ($show_faces == 'on') { $show_faces = 'true';} else { $show_faces = 'false'; }
			if ($show_stream == 'on') { $show_stream = 'true';} else { $show_stream = 'false'; }
			if ($show_header == 'on') { $show_header = 'true';} else { $show_header = 'false'; }
	
			/* Before widget (defined by themes). */
			echo $before_widget;
	
			/* Title of widget (before and after defined by themes). */
			if ( $title ) {
				echo $before_title . $title . $after_title;
			}
?>
			<div id="fb-root"></div>
			<script>(function(d, s, id) {
			  var js, fjs = d.getElementsByTagName(s)[0];
			  if (d.getElementById(id)) {return;}
			  js = d.createElement(s); js.id = id;
			  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
			  fjs.parentNode.insertBefore(js, fjs);
			}(document, 'script', 'facebook-jssdk'));</script>
			
			<div class="fb-like-box" data-href="<?php echo $pageurl ?>" data-width="<?php echo $width ?>" data-show-faces="<?php echo $show_faces ?>" data-border-color="#<?php echo $bordercolor ?>" data-stream="<?php echo $show_stream ?>" data-header="<?php echo $show_header ?>"></div>
<?php

			/* After widget (defined by themes). */
			echo $after_widget;
		}
		
        ///////////////////////////////////////////
        // Update
        ///////////////////////////////////////////
		function update( $new_instance, $old_instance ) {
			
            $instance = $old_instance;
	
			/* Strip tags (if needed) and update the widget settings. */
			$instance['title'] = strip_tags( $new_instance['title'] );
			$instance['pageurl'] = $new_instance['pageurl'];
			$instance['width'] = $new_instance['width'];
			$instance['bordercolor'] = $new_instance['bordercolor'];
			$instance['show_faces'] = $new_instance['show_faces'];
			$instance['show_stream'] = $new_instance['show_stream'];
			$instance['show_header'] = $new_instance['show_header'];
			
	
			return $instance;
		}
		
        ///////////////////////////////////////////
        // Form
        ///////////////////////////////////////////
		function form( $instance ) {
	
			/* Set up some default widget settings. */
			$defaults = array( 'title' => 'Like us on Facebook', 'pageurl' => 'http://www.facebook.com/wpzoom', 'width' => 300, 'bordercolor' => 'e6e2dc', 'show_faces' => 'on', 'show_stream' => 'off', 'show_header' => 'off' );
			$instance = wp_parse_args( (array) $instance, $defaults ); ?>
			
			<p>
				<label for="<?php echo $this->get_field_id( 'title' ); ?>">Widget Title:</label><br />
				<input type="text" id="<?php echo $this->get_field_id( 'title' ); ?>" name="<?php echo $this->get_field_name( 'title' ); ?>" value="<?php echo $instance['title']; ?>" style="width:90%;" />
			</p>
	
			<p>
				<label for="<?php echo $this->get_field_id( 'pageurl' ); ?>">Facebook page URL:</label>
				<input type="text" id="<?php echo $this->get_field_id( 'pageurl' ); ?>" name="<?php echo $this->get_field_name( 'pageurl' ); ?>" value="<?php echo $instance['pageurl']; ?>" style="width:90%;" /><br />
				<small>* Example of page URL: <br />http://www.facebook.com/wpzoom<br />You can get your page username here: <br /><a href="https://www.facebook.com/username/" target="_blank">https://www.facebook.com/username/</a></small>
			</p>
			<p>
				<label for="<?php echo $this->get_field_id( 'width' ); ?>">Box Width:</label>
				<input type="text" id="<?php echo $this->get_field_id( 'width' ); ?>" name="<?php echo $this->get_field_name( 'width' ); ?>" value="<?php echo $instance['width']; ?>" style="width:90%;" /><br />
				<small>* Default: <strong>300</strong> </small>
			</p>
			<p>
				<label for="<?php echo $this->get_field_id( 'bordercolor' ); ?>">Box Border Color:</label>
				<input type="text" id="<?php echo $this->get_field_id( 'bordercolor' ); ?>" name="<?php echo $this->get_field_name( 'bordercolor' ); ?>" value="<?php echo $instance['bordercolor']; ?>" style="width:90%;" /><br />
				<small>* Default: <strong>e6e2dc</strong> </small>
			</p>
			
			<p>
			<input class="checkbox" type="checkbox" id="<?php echo $this->get_field_id('show_faces'); ?>" name="<?php echo $this->get_field_name('show_faces'); ?>" <?php if ($instance['show_faces'] == 'on') { echo ' checked="checked"';  } ?> /> 
			<label for="<?php echo $this->get_field_id('show_faces'); ?>"><?php _e('Show Faces', 'wpzoom'); ?></label>
			<br />
			<input class="checkbox" type="checkbox" id="<?php echo $this->get_field_id('show_stream'); ?>" name="<?php echo $this->get_field_name('show_stream'); ?>" <?php if ($instance['show_stream'] == 'on') { echo ' checked="checked"';  } ?> /> 
			<label for="<?php echo $this->get_field_id('show_stream'); ?>"><?php _e('Show Stream', 'wpzoom'); ?></label>
			<br />
			<input class="checkbox" type="checkbox" id="<?php echo $this->get_field_id('show_header'); ?>" name="<?php echo $this->get_field_name('show_header'); ?>" <?php if ($instance['show_header'] == 'on') { echo ' checked="checked"';  } ?> /> 
			<label for="<?php echo $this->get_field_id('show_header'); ?>"><?php _e('Show Header', 'wpzoom'); ?></label>
			</p>
	
			<?php
		}
	}
 ?>