<?php 
/*
Author: Janek Niefeldt
Author URI: http://www.janek-niefeldt.de/
Description: Configuration of My Custom Widgets Plugin.
*/

/******************************************************************************/
/* Version History:	                                                          */
/******************************************************************************/
/*2.0 addon - compatible with new Widget API introduced with Wordpress 2.8     */                                         
/******************************************************************************/

include_once('my_custom_widget_meta.php');
//include_once('my_custom_widget_functions.php');
 
class MyCustomWidgetAddon extends WP_Widget
{
	/**
	* Declares the MyCustomWidget class.
	*
	*/
	
	function MyCustomWidgetAddon(){
		$widget_ops = array('classname' => 'MyCustomWidgetAddon', 'description' => 'MyCustomWidget Addon' );
		$control_ops = array('width' => 450, 'height' => 400);
		$this->WP_Widget('MyCustomWidgetAddon', 'MCW 2.0 Addon', $widget_ops, $control_ops);
		//register_shutdown_function(array(&$this, '__destruct'));
		//MCW_logfile(" Widget initilisiert: ". $this->id); //debugging only
	}

		
	function widget($args, $instance){
		extract($args);
		
		$name = empty($instance['name']) ? '' : $instance['name'];
		//$MyWidget = MCW_get_mywidget_by_name($name);
		
		$code = empty($instance['code']) ? $MyWidget['code'] : $instance['code'];
		$kind = empty($instance['kind']) ? $MyWidget['kind'] : $instance['kind'];
    $title = empty($instance['title']) ? $MyWidget['title'] : $instance['title'];
    $title = apply_filters('widget_title', $title);
    
    
    $myfilteroptions = MCW_get_option('filters');
    $max = count($myfilteroptions);
    for ( $i = 0; $i < $max; ++$i ) {
      $filter_ID = 'filter-'.$myfilteroptions[$i][0];
      $MyWidget[$filter_ID] = empty($instance[$filter_ID]) ? $MyWidget[$filter_ID] : $instance[$filter_ID];
    }		
		
    $beforecode = empty($instance['beforecode']) ? $MyWidget['beforecode'] : $instance['beforecode'];
    $foreign_id = empty($instance['foreign_id']) ? $MyWidget['foreign_id'] : $instance['foreign_id'];
		
		$MyWidget['kind'] = $kind;
		$MyWidget['name'] = $name;
		$MyWidget['code'] = $code;
		$MyWidget['beforecode'] = $beforecode;
		$MyWidget['foreign_id'] = $foreign_id;
    
    MCW_logfile("prüfung ob filter zulässig."); //debugging only
    
    $myfilteroptions = MCW_get_option('filters');
    $max = count($myfilteroptions);
    $erg = false;
    $temp = false;
    for ( $i = 0; $i < $max; ++$i ) {
      $c = 'if ('.stripslashes($myfilteroptions[$i][1]).'){$temp = true;}'; // filter würde greifen
      eval($c);    
      if (($temp) && (($instance['filter-'.$myfilteroptions[$i][0]])==1)) { // und filter wurde aktiviert
        $visible = true;
        break;
      }      
    }
    if ($visible){
    MCW_logfile("Darstellung ist zulässig."); //debugging only
		# Before the widget
		  if ( $title <> ""){
        echo $before_widget;
		  }
	    if ( trim($title) <> "") { 
        $output = $before_title . $title . $after_title; 
      }
      $output = $output.MCW_run_code($MyWidget);
    
    # apply filters                 
      if (MCW_get_option('use_wpfilter')){
        $wpfilter = MCW_get_option('wpfilter'); 
        $output = apply_filters($wpfilter, $output);
      }
		
		  echo $output;	
		
		  # After the widget
		  if ( $title <> ""){
        echo $after_widget;
      }
		}
	}
	
	/**
	* Saves the widgets settings.
	*
	*/
	function update($new_instance, $old_instance){
		$instance = $old_instance;
    //$instance['name'] = strip_tags(stripslashes($new_instance['name']));
    
    $instance['name'] = $this->id;
    
		$instance['title'] = strip_tags(stripslashes($new_instance['title']));
		$instance['filter'] = strip_tags(stripslashes($new_instance['filter']));

		$myfilteroptions = MCW_get_option('filters'); // get all filters
    $max = count($myfilteroptions);
    for ( $i = 0; $i < $max; ++$i ) {
      $instance['filter-'.$myfilteroptions[$i][0]] = strip_tags(stripslashes($new_instance['filter-'.$myfilteroptions[$i][0]]));
    }
		
		$instance['kind'] = strip_tags(stripslashes($new_instance['kind']));
		$instance['code'] = stripslashes($new_instance['code']);
		$instance['beforecode'] = stripslashes($new_instance['beforecode']);
    $instance['foreign_id'] = strip_tags(stripslashes($new_instance['foreign_id']));
		
		//save in database
		//if (!$completely_new){
		//MCW_set_mywidget($instance);
		//}
		return $instance;
	}
	
	/**
	* Creates the edit form for the widget.
	*
	*/
	function form($instance){
		global $mcw_prefix;
		global $mcw_path;
		
		//if (!empty($instance)){
      include_once(MCW_get_url('style'));
    //}
    
    //Defaults
    
    $defaults = MCW_get_default_options();
    
		$instance = wp_parse_args( (array) $instance, array('title'=>'', 'kind'=>$defaults['std_kind'], 'name'=>$this->id, 'filter-all'=>1) );
		
		$title = htmlspecialchars($instance['title']);
		
    	
    echo '<div class="mcw-row-"><label for="'.$this->get_field_name('title').'"><input type="text" id="'.$this->get_field_id('title').'" name="'.$this->get_field_name('title').'" value="'.$title.'" size="13" ></label></div>';
	  echo '<div class="mcw-row-small"><nobr><label for="'.$this->get_field_name('kind').'_php"><input type="radio" id="'.$this->get_field_id('kind').'_php" name="'.$this->get_field_name('kind').'" value="php" checked="checked"> PHP</label></nobr>';
    echo '<nobr><label for="'.$this->get_field_name('kind').'_html"><input type="radio" id="'.$this->get_field_id('kind').'_html" name="'.$this->get_field_name('kind').'" value="html"'. MCW_check($instance['kind'],"html") .'> HTML</label></nobr></div><br>';
    
    //echo '<div class="mcw-row">'.MCW_get_input_code($instance, $this).'</div>';
    echo '<div class="mcw-row"><textarea cols="60" id="'.$this->get_field_id('code').'" name="'.$this->get_field_name('code').'" style="height:'.MCW_get_option('code_height').'px; font-family:Courier, Monaco, monospace;" >'.stripslashes($instance["code"]).'</textarea><br></div>';
	  
    //echo '<div class="mcw-row-small">'.MCW_get_input_filters($instance, $this).'</div>';
    $myfilteroptions = MCW_get_option('filters'); // get all filters
    if (empty($myfilteroptions)){ $myfilteroptions = array('all'  => '1'); }
    $max = count($myfilteroptions);    
    
    echo '<div class="mcw-row-small">';
    for ( $i = 0; $i < $max; ++$i ) {     
        echo '<nobr><label for="'.$this->get_field_id('filter'.'-'.$myfilteroptions[$i][0]).'">';
        echo '<input type="checkbox" id="'.$this->get_field_id('filter'.'-'.$myfilteroptions[$i][0]).'" name="'.$this->get_field_name('filter'.'-'.$myfilteroptions[$i][0]).'" value="1" ';
        echo MCW_check($instance['filter-'.$myfilteroptions[$i][0]],"1"); //active or not
        echo '> '.$myfilteroptions[$i][0].' </label></nobr>';
    }
    echo '</div>';
    
  }
  
}// END class
	
	function MyCustomWidgetAddonInit() {
	  register_widget('MyCustomWidgetAddon');
	}


	add_action('widgets_init', 'MyCustomWidgetAddonInit');

?>