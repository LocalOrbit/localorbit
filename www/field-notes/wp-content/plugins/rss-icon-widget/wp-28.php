<?php
class RSSIconWidget extends WP_Widget {
	
	var $icon_sizes = array(
		'10' => '10 x 10',
		'12' => '12 x 12',
		'14' => '14 x 14',
		'16' => '16 x 16',
		'24' => '24 x 24',
		'32' => '32 x 32'
	);
	
    /** constructor */
    function RSSIconWidget() {
        parent::WP_Widget(false, $name = 'RSS Icon Widget', $widget_options = array('description' => 'Display a link with the standard RSS Feed Icon linked to an RSS feed of your choice.'));
    }

    /** @see WP_Widget::widget */
    function widget($args, $instance) {		
        extract( $args );
		
		echo $before_widget;
		echo '<a href="'.$instance['feed_url'].'" style="color: '.$instance['link_color'].'; padding: '.($instance['image_size']/2).'px 0px '.($instance['image_size']/2).'px '.($instance['image_size'] + 5).'px; background: url(\''.get_bloginfo('wpurl').'/'.PLUGINDIR.'/rss-icon-widget/icons/feed-icon-'.$instance['image_size'].'x'.$instance['image_size'].'.png\') no-repeat 0 50%;">';
		echo $instance['link_text'];
		echo '</a>';
		echo $after_widget;
    }

    /** @see WP_Widget::update */
    function update($new_instance, $old_instance) {				
        return $new_instance;
    }

    /** @see WP_Widget::form */
    function form($instance) {
        $image_size =!empty($instance['image_size']) ? esc_attr($instance['image_size']) : '10';
        $link_text = !empty($instance['link_text']) ? esc_attr($instance['link_text']) : 'Subscribe via RSS';
        $link_color = !empty($instance['link_color']) ? esc_attr($instance['link_color']) : '#ff0000';
        $feed_url = !empty($instance['feed_url']) ? esc_attr($instance['feed_url']) : get_bloginfo('rss_url');
        ?>


			<p><label for="<?php echo $this->get_field_id('image_size'); ?>"><?php _e('Icon Size:');?><br />
				<select id="<?php echo $this->get_field_id('image_size'); ?>" name="<?php echo $this->get_field_name('image_size'); ?>" style="width: 100%;">
					<?php
						foreach ($this->icon_sizes as $size_key => $size_name) {
							echo '  <option value="'.$size_key.'"'.($image_size == $size_key ? ' selected' : '').'>'.$size_name.'</option>';
						}
					?>
				</select>
			</label></p>
		
			<p><label for="<?php echo $this->get_field_id('link_text'); ?>"><?php _e('Link Text:'); ?><br />
				<input id="<?php echo $this->get_field_id('link_text'); ?>" name="<?php echo $this->get_field_name('link_text'); ?>" type="text" style="width: 100%;" value="<?php echo $link_text; ?>" />
			</label></p>
		
			<script type="text/javascript">
				jQuery(document).ready(function($) {
					$('#<?php echo $this->get_field_id('link_color'); ?>_colorpicker').farbtastic('#<?php
						$lc = $this->get_field_id('link_color');
						echo $lc;
					?>');
				});
			</script>
			<p><label for="rssicon_link_color"><?php _e('Link Color:'); ?><br />
				<div id="<?php echo $this->get_field_id('link_color'); ?>_colorpicker"></div>
				<input id="<?php echo $this->get_field_id('link_color'); ?>" name="<?php echo $this->get_field_name('link_color'); ?>" type="text" style="width: 100%;" value="<?php echo $link_color; ?>" />
			</label></p>
			
		
			<p><label for="<?php echo $this->get_field_id('feed_url'); ?>"><?php _e('Feed URL:'); ?><br />
				<input id="<?php echo $this->get_field_id('feed_url'); ?>" name="<?php echo $this->get_field_name('feed_url'); ?>" type="text" style="width: 100%;" value="<?php echo $feed_url; ?>" />
			</label></p>
				<?php
    }

} // class RSSIconWidget

	// register RSSIconWidget widget
	add_action('widgets_init', create_function('', 'return register_widget("RSSIconWidget");'));

	// add jquery and the color_picker
	add_action('init', 'install_jquery_scripts');
	function install_jquery_scripts() {
		
		// make sure we don't interfere with other plugins
		if (stripos($_SERVER['REQUEST_URI'],'widgets.php')!== false) {
			wp_enqueue_script('jquery');
			wp_enqueue_script('farbtastic');
			wp_enqueue_style('farbtastic');
		}
	}
	
?>