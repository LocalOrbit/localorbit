<?php
/*
Author: Janek Niefeldt
Author URI: http://www.janek-niefeldt.de/
Description: Configuration of My Custom Widgets Plugin.
*/
include_once('my_custom_widget_functions.php');
include_once('my_custom_widget_meta.php');
?><?php
class MCW_my_donation extends WP_Widget
{
	function MCW_my_donation(){
		$widget_ops = array('classname' => 'MCW_my_donation', 'description' => 'CustomWidget generated with MCW &raquo;' );
		$control_ops = array('width' => 345);
		$this->WP_Widget('MCW_my_donation', 'MCW: my_donation', $widget_ops, $control_ops);
	}
	function widget($args, $instance){
		$args['name'] = 'my_donation';
		MCW_eval_code($args);
	}
	function update($new_instance, $old_instance){
	  $new_instance['title'] = MCW_get_widget_info('my_donation', 'title');
		return $new_instance;
	}
	function form($instance){
    MCW_get_official_form('my_donation');	  
  }
}
	function MCW_my_donationInit() {
	  register_widget('MCW_my_donation');
	}
	add_action('widgets_init', 'MCW_my_donationInit');
?><?php
class MCW_my_most_popular extends WP_Widget
{
	function MCW_my_most_popular(){
		$widget_ops = array('classname' => 'MCW_my_most_popular', 'description' => 'CustomWidget generated with MCW &raquo;' );
		$control_ops = array('width' => 345);
		$this->WP_Widget('MCW_my_most_popular', 'MCW: my_most_popular', $widget_ops, $control_ops);
	}
	function widget($args, $instance){
		$args['name'] = 'my_most_popular';
		MCW_eval_code($args);
	}
	function update($new_instance, $old_instance){
	  $new_instance['title'] = MCW_get_widget_info('my_most_popular', 'title');
		return $new_instance;
	}
	function form($instance){
    MCW_get_official_form('my_most_popular');	  
  }
}
	function MCW_my_most_popularInit() {
	  register_widget('MCW_my_most_popular');
	}
	add_action('widgets_init', 'MCW_my_most_popularInit');
?><?php
class MCW_my_special_links extends WP_Widget
{
	function MCW_my_special_links(){
		$widget_ops = array('classname' => 'MCW_my_special_links', 'description' => 'CustomWidget generated with MCW &raquo;' );
		$control_ops = array('width' => 345);
		$this->WP_Widget('MCW_my_special_links', 'MCW: my_special_links', $widget_ops, $control_ops);
	}
	function widget($args, $instance){
		$args['name'] = 'my_special_links';
		MCW_eval_code($args);
	}
	function update($new_instance, $old_instance){
	  $new_instance['title'] = MCW_get_widget_info('my_special_links', 'title');
		return $new_instance;
	}
	function form($instance){
    MCW_get_official_form('my_special_links');	  
  }
}
	function MCW_my_special_linksInit() {
	  register_widget('MCW_my_special_links');
	}
	add_action('widgets_init', 'MCW_my_special_linksInit');
?>