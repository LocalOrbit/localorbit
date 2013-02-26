<?php
/*
Plugin Name: Accordion Image Menu
Plugin URI: http://web-argument.com/category/accordion-image-menu-2/
Description: Versatile Accordion Image Menu. Allows to use the post's feature images as links. You can combine and order pages, categories and recent posts.  
Version: 3.1.3
Author: Alain Gonzalez
Author URI: http://web-argument.com/
*/

 
/**
 *  Default Options 
 */

define( 'AIM_VERSION','3.1.0'); 
 
$d_aim_options = array(
						'position' => 'vertical',
						'type' => 'post',
						'post_number' => 5,
						'effect' => 'swing',
						'opened_d' => 200,
						'closed_d' => 100,
						'width' => get_option('medium_size_w'),
						'height' => get_option('medium_size_h'),						
						'duration' => 300,						
						'border' => 1,
						'border_color' => '#000000',
						'title'=>'over',
						'open' => '',
						'include_jquery' => 1,
						'version' => AIM_VERSION
 						);


function aim_options ($default = false){

	global $d_aim_options;

    $options = get_option('a_i_m');	
	if ($default) {
	update_option('a_i_m', $d_aim_options);
	return $d_aim_options;
	}
	if (isset($options)){	
		$chk_version = version_compare(AIM_VERSION,$options['version']);
		if ($chk_version == 0) return $options;
		else if ($chk_version > 0) {
			$options = $d_aim_options;
		}	
	} else {
		$options = $d_aim_options;
	}	
	update_option('a_i_m', $options);	

	return $options;
}

/**
 *  Header  
 */
function a_image_menu_head() {	

    $options = aim_options ();

    $a_image_menu_header =  "\n<!-- Accordion Image Menu ".$options['version']."-->\n";
	if ($options['include_jquery'] == "1") 
	$a_image_menu_header .= "<script type=\"text/javascript\" src=\"".get_bloginfo('wpurl')."/wp-content/plugins/accordion-image-menu/js/jquery.min.js\"></script>\n";
    $a_image_menu_header .= "<script type=\"text/javascript\" src=\"".get_bloginfo('wpurl')."/wp-content/plugins/accordion-image-menu/js/jquery-ui-1.8.10.custom.min.js\"></script>\n";
	$a_image_menu_header .= "<script type=\"text/javascript\" src=\"".get_bloginfo('wpurl')."/wp-content/plugins/accordion-image-menu/js/accordionImageMenu-0.4.js\"></script>\n";			
	$a_image_menu_header .= "\n<link href=\"".get_bloginfo('wpurl')."/wp-content/plugins/accordion-image-menu/css/accordionImageMenu.css\" rel=\"stylesheet\" type=\"text/css\" />\n";		
    $a_image_menu_header .=  "\n<!-- / Accordion Image Menu -->\n";	
            
	print($a_image_menu_header);
}

add_action('wp_head', 'a_image_menu_head');

/**
 *  The widget 
 */
 
class AccordionImageMenuWidget extends WP_Widget {
    /** constructor */
    function AccordionImageMenuWidget() {
		$widget_ops = array('classname' => 'accordion_image_menu', 'title' => __( 'Accordion Image Menu'), 'description' => __( 'Accordion Image Menu using the parameters saved on the Plugin Settings Page') );
		$this->WP_Widget('accordion_image_menu', __('Accordion Image Menu'), $widget_ops);
	}

    /** @see WP_Widget::widget */
    function widget($args, $instance) {		
        extract( $args );
        $title = apply_filters('widget_title', $instance['title']);
        ?>
              <?php echo $before_widget; ?>
                  <?php if ( $title )
                        echo $before_title . $title . $after_title; 
                  		echo do_shortcode('[a_image_menu]');
             	 		echo $after_widget; ?>
        <?php
    }

    /** @see WP_Widget::update */
    function update($new_instance, $old_instance) {				
	$instance = $old_instance;
	$instance['title'] = strip_tags($new_instance['title']);
        return $instance;
    }

    /** @see WP_Widget::form */
    function form($instance) {				
        $title = esc_attr($instance['title']);
        ?>
         <p>
          <label for="<?php echo $this->get_field_id('title'); ?>"><?php _e('Title:'); ?></label> 
          <input class="widefat" id="<?php echo $this->get_field_id('title'); ?>" name="<?php echo $this->get_field_name('title'); ?>" type="text" value="<?php echo $title; ?>" />          
        </p>
        <p> <?php _e('The Widget will use the parameters saved on the Plugin Settings Page') ?> </p>
        <?php 
    }

} // class AccordionImageMenuWidget


// register AccordionImageMenuWidget widget
add_action('widgets_init', create_function('', 'return register_widget("AccordionImageMenuWidget");'));



/**
 * Get thumbnails
 */	

function a_m_image_url($the_parent){

	if( function_exists('has_post_thumbnail') && has_post_thumbnail($the_parent)) {
	    $thumbnail_id = get_post_thumbnail_id( $the_parent );
		if(!empty($thumbnail_id))
		$img = wp_get_attachment_image_src( $thumbnail_id, 'medium' );	
	} else {
	$attachments = get_children( array(
										'post_parent' => $the_parent, 
										'post_type' => 'attachment', 
										'post_mime_type' => 'image',
										'orderby' => 'menu_order', 
										'order' => 'ASC', 
										'numberposts' => 1) );
	if($attachments == true) :
		foreach($attachments as $id => $attachment) :
			$img = wp_get_attachment_image_src($id, 'medium');			
		endforeach;		
	endif;
	}
	if (isset($img[0])) return $img[0];
}




/**
 * Get the items
 */	
function a_image_m_items($num, $cat, $type){

	$options = aim_options ();
	
	/**
	 * Recent Posts
	 */		
	if ($type == 'post'){
	
		$i = 0;	
	
		if 	(empty($cat)) $my_query = get_posts(array('numberposts'=>$num));
		else if (!is_array($cat)){				
					
					$mcat = explode (",",$cat);
					
					$my_query = get_posts(array('category__in'=>$mcat,'numberposts'=>$num));
		} else {
		
					$my_query = get_posts(array('category__in'=>$cat,'numberposts'=>$num));	
		}    
		
		foreach ($my_query  as $post) {	
			
			$the_image = a_m_image_url($post -> ID);
			$the_title = get_the_title($post -> ID);
			$the_link = get_permalink($post -> ID);
			
			$item[$i] = array("img" => $the_image,"title" => $the_title,"link" => $the_link);
			
			$i ++;		
	
		} 
	
	} else if ($type == 'page'){	

		/**
		 * Pages
		 */
		
		if(isset($options['pag_or'])){
		
			foreach ($options['pag_or'] as $m_pages => $order){			

				 if (is_numeric($order) and ($order != 0)) {
					 
					$the_image = a_m_image_url($m_pages);
					$the_title = get_the_title($m_pages);
					$the_link = get_permalink($m_pages);	
					
					$item[$order] = array("img" => $the_image,"title" => $the_title,"link" => $the_link);				
				}				
			}		
         }
		 
		/**
		 * Categories
		 */
         if(isset($options['cat_or'])){
			foreach ($options['cat_or'] as $m_cat => $order){
			 
				 if (is_numeric($order) and ($order != 0)) {
									 
						$my_query = get_posts(array('cat'=>$m_cat,'numberposts'=>1));							
							
							$the_image = "";							
										
							foreach ($my_query  as $post) {	
																	
								$the_image = a_m_image_url($post -> ID);							
								$the_title = get_cat_name($m_cat);
								$the_link = get_category_link($m_cat);	
								
								$item[$order] = array("img" => $the_image,"title" => $the_title,"link" => $the_link);					
					  
							}
				}		
			}
		}	

	} 	
	
	return $item;

}


function a_image_m_items_from_id($ids) {

	$my_query = get_posts(array('include'=>$ids,'post_type'=>'any'));
	$i = 0;
	foreach ($my_query  as $post) {	
		
			$the_image = a_m_image_url($post -> ID);
			$the_title = get_the_title($post -> ID);
			$the_link = get_permalink($post -> ID);
		
			$item[$i] = array("img" => $the_image,"title" => $the_title,"link" => $the_link);				 
			$i ++;
	}
	
	return $item; 	
}	


function a_image_m_items_from_menu($name) {	

	$item = array ();
    
	if ($menu_items = wp_get_nav_menu_items($name)) {

		$i = 0;	

		foreach ($menu_items as $post) {

			$the_image = "";
			
		
			
			if ($post -> object == "category") {
	
				$my_query = get_posts(array('cat'=>$post -> object_id,'numberposts'=>5));
				
					
					foreach ($my_query  as $cat_post) {
															
						$the_image = a_m_image_url($cat_post -> ID);							
	
						if (!empty($the_image))	break;
						
					}
			
			} else if ($post -> object == "page"){

				$the_image = a_m_image_url($post -> object_id);
			
			}
			
	
			$the_title = $post -> title;
			$the_link = $post -> url;
			$item[$post -> menu_order] = array("img" => $the_image,"title" => $the_title,"link" => $the_link);
				 
			}			
	
		} 
	
	return $item;
	
}


/**
 * The shortcode
 */

function a_image_menu_func($atts) {

	$options = aim_options ();

   //position
	$position = $options['position'];
	
	$post_number = $options['post_number'];
	
	//type of menu cat/pages
	if(isset($options['m_cat']))
	$m_cat = $options['m_cat'];	
	if(isset($options['cat_or']))	
	$cat_or = $options['cat_or'];
	if(isset($options['pag_or']))
	$pag_or = $options['pag_or'];
	
	//menu
	$width = $options['width'];
	$height = $options['height'];
	$opened_d = $options['opened_d'];
	$closed_d = $options['closed_d'];
	$border = $options['border'];
	$border_color = $options['border_color'];	
	
	//title	
	$title = $options['title'];
	
	//effects
	$open = $options['open'];	
	$effect = $options['effect'];
	$duration = $options['duration'];
	
	//menu name
	if(isset($options['name']))
	$menu_name = $options['name'];

	extract(shortcode_atts(array(
								'position' => $position,
								'cat' => $m_cat,
								'number' => $post_number,
								'effect' => $effect,
								'closed_d' => $closed_d,
								'opened_d' => $opened_d,
								'width' => $width,
								'height' => $height,
								'duration' => $duration,
								'border' => $border,
								'border_color' => $border_color,
								'open' => $open,
								'type' =>$options['type'],
								'id' => '',
								'name' =>''
								), $atts));
								
    $alert=__("Error generating the menu");
	
	// For Wordpress version above 3.0.0
	$chk_wp_version = version_compare("3.0.0",get_bloginfo("version"));
	if (!empty($id)) $the_items = a_image_m_items_from_id($id);
    else if (!empty($name)) {
		if ($chk_wp_version <= 0) $the_items = a_image_m_items_from_menu($name);
		else $alert = __("Your Wordpress Version doesn't allows menus");	
	} else if (!empty($menu_name) && $type == "menu") {
		if ($chk_wp_version <= 0) $the_items = a_image_m_items_from_menu($menu_name);
		else $alert = __("Your Wordpress Version doesn't allows menus");
	} else $the_items = a_image_m_items($number, $cat, $type);
	
	if(isset($the_items) and count($the_items)>0) {
		ksort($the_items);
		
		$random = wp_generate_password(6, false);
		
		$image_menu_div = "imageMenu_".$random;

        $image_menu =  "\n<!-- Accordion Image Menu ".$options['version']."-->\n";		
		
		$image_menu .= "<div id='".$image_menu_div."' class='aim'>\n";		
	
			foreach ($the_items as $the_item){

			  $image_menu .= "<a href='".$the_item['link']."'>\n";
				  
			//the title
			
			 if ($title != "tnever") 
			 $image_menu .= "<span>".$the_item['title']."</span>\n";
		     
			 if (!empty($the_item['img'])) 
			 $image_menu .= "<img src='".$the_item['img']."' />";

			  $image_menu .= "</a>\n";
				
			}

		$image_menu .= "</div>\n";	
			
		$image_menu .= "<script type=\"text/javascript\">\n";
		$image_menu .= "jQuery.noConflict();(function ($) {\n"; 
		$image_menu .= "jQuery(document).ready(function() {\n";
		$image_menu .= "jQuery('#".$image_menu_div."').AccordionImageMenu({\n";    

		$image_menu .= "'border':".$border.",\n";
		$image_menu .= "'color':'".$border_color."',\n";
		$image_menu .= "'duration':".$duration.",\n";
		$image_menu .= "'position':'".$position."',\n";
		$image_menu .= "'openDim':".$opened_d.",\n";
		$image_menu .= "'closeDim':".$closed_d.",\n";
		$image_menu .= "'effect':'".$effect."',\n";
		
		switch ($open) {
			case "randomly":
				$image_menu .= "'openItem':".rand(0, count($the_items)-1).",\n";
			break;
			case "":
				$image_menu .= "'openItem':null,\n";
			break;
			default:
			    if($open >= 0  &&  ($open+1) <= count($the_items)) $image_menu .= "'openItem':".$open.",\n";
				else $image_menu .= "'openItem':null,\n";
			break;				
		}		
		
		switch ($title) {
			case "always":
				$image_menu .= "'fadeInTitle':null,\n";
			break;
			case "over":
				$image_menu .= "'fadeInTitle':true,\n";
			break;
			case "out":
				$image_menu .= "'fadeInTitle':false,\n";
			break;			
			default:
				$image_menu .= "'fadeInTitle':null,\n";
			break;				
		}		
	
		$image_menu .= "'width':".$width.",\n";
		$image_menu .= "'height':".$height."\n";				
		
     	$image_menu .= "});});\n"; 
		$image_menu .= "})(jQuery);\n";								

		$image_menu .= "</script>\n";
		$image_menu .=  "<!--/ Accordion Image Menu -->\n";	

		return $image_menu;
		
		
	} else {
	
		return $alert;
	
	}
}

add_shortcode('a_image_menu', 'a_image_menu_func');

add_action('admin_menu', 'a_img_menu_set');


/**
 *   Settings  
 */
function a_img_menu_set() {
    add_options_page('Accordion Image Menu', 'Accordion Image Menu', 'administrator', 'accordion-image-menu', 'a_image_menu_page');	 
}

function a_image_menu_page() {

	$options = aim_options();	

	$categories = get_categories();
	$trans_type = array("swing","easeOutBack","easeOutBounce","easeOutCubic","easeOutElastic","easeOutExpo","easeOutQuart","easeOutQuin","easeOutSine","easeOutExpo","easeInCirc");
	
	if(isset($_POST['Reset'])){
	
		$options = aim_options(true);
	}


	if(isset($_POST['Submit'])){

        //position
		$newoptions['position'] = $_POST['position'];
		
		//type of menu recent post or cat/pages
		$newoptions['type'] = $_POST['type'];			
		$newoptions['post_number'] = $_POST['post_number'];
		
		//type of menu cat/pages
		$newoptions['m_cat'] = $_POST['m_cat'];		
		$newoptions['cat_or'] = $_POST['cat_or'];
		$newoptions['pag_or'] = $_POST['pag_or'];
		
		//dimensions
		$newoptions['width'] = $_POST['width'];
		$newoptions['height'] = $_POST['height'];
		$newoptions['opened_d'] = $_POST['opened_d'];
		$newoptions['closed_d'] = $_POST['closed_d'];
		$newoptions['border'] = $_POST['border'];	
		
		//title	
		$newoptions['title'] = $_POST['title'];
		
		//effects
		if ($_POST['open'] == 1) 
		$newoptions['open'] = $_POST['open_number'];
		else 
		$newoptions['open'] = $_POST['open'];
				
		$newoptions['effect'] = $_POST['effect'];
		$newoptions['duration'] = $_POST['duration'];
		$newoptions['border_color'] = $_POST['border_color'];
		
		//menu name
		$newoptions['name'] = $_POST['menu_name'];	
		
		//version
		$newoptions['version'] = $options['version'];
		
		//jquery
		$newoptions['include_jquery'] = $_POST['jq'];
	

		if ( $options != $newoptions ) {
			$options = $newoptions;
			update_option('a_i_m', $options);			
		}
		    
?>
<div class="updated"><p><strong><?php _e('Options saved.', 'mt_trans_domain' ); ?></strong></p></div>
         
<?php  }  


	    //position
		$position = $options['position'];
		
		//type of menu recent post or cat/pages		
		$type = $options['type'];			
		$post_number = $options['post_number'];
		
		//type of menu cat/pages
		if(isset($options['m_cat']))
		$m_cat = $options['m_cat'];
		if(isset($options['cat_or']))		
		$cat_or = $options['cat_or'];
		if(isset($options['pag_or']))
		$pag_or = $options['pag_or'];
		
		//dimensions
		$width = $options['width'];
		$height = $options['height'];
		$opened_d = $options['opened_d'];
		$closed_d = $options['closed_d'];
		$border = $options['border'];	
		
		//title	
		$title = $options['title'];
		
		//effects
		$open = $options['open'];		
		$effect = $options['effect'];
		$duration = $options['duration'];
		$border_color = $options['border_color'];
		
		//menu name
		if(isset($options['name']))
		$menu_name = $options['name'];
		
		//jquery
		$include_jquery = $options['include_jquery'];
		
?>	 	         

<div class="wrap">   

<form method="post" name="options" target="_self">

<h2><?php _e('Accordion Image Menu Default Settings') ?></h2><br />

<h3><?php _e('Position') ?></h3>


<p><input name="position" type="radio" value="vertical" <?php if ($position=="vertical") echo "checked=\"checked\"" ?>/> <b><?php _e('Vertical') ?></b></p>
<p><input name="position" type="radio" value="horizontal" <?php if ($position=="horizontal") echo "checked=\"checked\"" ?>/> <b><?php _e('Horizontal') ?></b></p>

<hr/>

<h3><?php _e('Use the Menu for') ?></h3>


<?php 

// For Wordpress version above 3.0.0
$chk_wp_version = version_compare("3.0.0",get_bloginfo("version"));
if ($chk_wp_version <= 0) {
$menus = wp_get_nav_menus();

if ( count($menus) > 0 ) {

?>
<p><input name="type" type="radio" value="menu" id="menu" <?php if ($type=="menu") echo "checked=\"checked\"" ?>/> <b><?php _e('Wordpress Menu') ?></b></p>

    <div id="a_menu_type_menu" class="m_type">
    
            <table width="100%" cellpadding="10" class="form-table">
            <tr>
            <td width="200" align="right">
			<select name="menu_name">                          
				<?php 
                $menus = wp_get_nav_menus();

                foreach ($menus as $menu){
                ?>
                <option value="<?php echo $menu->name ?>" <?php if ($menu_name == $menu->name) echo "selected=\"selected\"" ?>><?php echo $menu->name ?></option>
                <?php 
                }
                
                ?>              
            </select>
			</td>
            <td align="left" scope="row"><?php _e('Select the Menu') ?></td>
            </tr>            
            </table>
    
    </div>
<?php } else { 

_e('If you want to use a Wordpress Menu you need to create one under Appearance based on Pages and Categories.'); 

} ?>
<?php } ?>

<p><input name="type" type="radio" value="post" id="post" <?php if ($type=="post") echo "checked=\"checked\"" ?>/> <b><?php _e('Recent Posts') ?></b></p>

    <div id="a_menu_type_post" class="m_type">
    
            <table width="100%" cellpadding="10" class="form-table">
                <tr>
                <td width="200" align="right">
                <input name="post_number" value="<?php echo $post_number ?>" size="1" />
                </td>
                <td align="left"><?php _e('Number of Posts') ?></td>
                </tr>
                           
                <tr>
                <td align="left" colspan="2"><b><?php _e('In the categories') ?></b></td>
                </tr>
                <tr>
                <td width="200" align="right"><input name="m_cat_chk_all" id="m_cat_chk_all" type="checkbox" /> 
                <td align="left"><strong><?php _e('Check All') ?></strong></td>
                </tr>
                <tr>
                  <td align="left" colspan="2">           
                    <table width="100%" cellpadding="10" class="form-table" id="chk_cat">                          
                        <?php            
                        foreach ($categories as $cat) { ?>
                            <tr>
                            <td width="200" align="right"><input name="m_cat[<?php echo $cat->cat_ID ?>]" type="checkbox" value="<?php echo $cat->cat_ID ?>"
                            <?php 
                            if (isset($m_cat))	if (in_array($cat->cat_ID, $m_cat)) echo "checked=\"checked\""; ?>                                       
                            /> 
                            <td align="left" scope="row"><?php echo $cat->cat_name ?></td>
                            </tr>
                        <?php }  ?>
                    </table>

                  </td>
                </tr>                      
            </table>
    
    </div>

<p><input name="type" type="radio" value="page" id="page" <?php if($type=="page") echo "checked=\"checked\"" ?>/> <b><?php _e('Categories and Pages') ?></b></p>

    <div id="a_menu_type_page" class="m_type">
    <p><?php _e('To select a Category or a Page just fill out the "Order" field in front of the item (The Order is the vertical item position on the menu, if you use "0" or leave it "empty" the item will not be included)') ?></p>
            <table width="100%" cellpadding="5" class="form-table">
              
              <tr>
                <td width="200" align="right"><b>Order</b></td>
                <td align="left" scope="row"><b>Categories</b></td>
              </tr>
            <?php    
             foreach ($categories as $cat) { ?>
              
                <td width="200" align="right">
                <input name="cat_or[<?php echo $cat->cat_ID ?>]" type="text" id="cat_or<?php echo $cat->cat_ID ?>" size="1" value="<?php echo $cat_or[$cat->cat_ID] ?>"/></td>
                <td align="left" scope="row"><?php echo $cat->cat_name ?></td>
              </tr>
              <?php }  
              $pages = get_pages(); 
              if (count($pages)!=0){			  
			  ?>
              <tr>
                <td width="200" align="right"></td>
                <td align="left" scope="row"></td>
              </tr>
            
             <?php 
              
              foreach ($pages as $pag) { ?>
              <tr>
                <td width="200" align="right"><input name="pag_or[<?php echo $pag->ID ?>]" type="text" id="pag_or<?php echo $pag->ID ?>" size="1" value="<?php echo $pag_or[$pag->ID] ?>"/></td>
                <td align="left" scope="row"><?php echo $pag->post_title ?></td>
              </tr>
            
              <?php }  ?>
            </select>
             <?php }  ?>
            </table>
            
    </div>

<hr />

<h3><?php _e('Select the Image Menu Dimensions') ?></h3>
<p><?php _e('The menu use the Medium Size Images') ?></p>
<table width="100%" cellpadding="10" class="form-table">

  <tr>
  	<td width="200" align="right">
  	  <input name="width" id="width" value="<?php echo $width ?>" size="2"/> <?php _e('px') ?>
  	</td>
  	<td align="left" scope="row"><?php _e('Width - Apply if menu position is "vertical"') ?></td>
  </tr>
  <tr>
  	<td width="200" align="right">
  	  <input name="height" id="height" value="<?php echo $height ?>" size="2"/> <?php _e('px') ?>
  	</td>
  	<td align="left" scope="row"><?php _e('Height - Apply if menu position is "horizontal"') ?></td>
  </tr>  
  <tr>
  	<td width="200" align="right">
  	  <input name="opened_d" id="opened_d" value="<?php echo $opened_d ?>" size="2"/> <?php _e('px') ?>
  	</td>
  	<td align="left" scope="row"><?php _e('Open items dimension when mouseover') ?></td>
  </tr>  
  <tr>
  	<td width="200" align="right">
  	  <input name="closed_d" id="closed_d" value="<?php echo $closed_d ?>" size="2"/> <?php _e('px') ?>
 	</td>
  	<td align="left" scope="row"><?php _e('Closed items dimension when the menu is inactived') ?></td>
  </tr> 
  <tr>
  	<td width="200" align="right">
  	  <input name="border" id="border" value="<?php echo $border ?>" size="2"/> <?php _e('px') ?> 
    </td>
  	<td align="left" scope="row"><?php _e('Border between items') ?></td>
  </tr>     
</table>

<p class="submit">
<input type="submit" name="Submit" value="Update Options" class="button-primary"/>
</p>

<hr />
<h3> <?php _e('Menu Behaviour ') ?></h3>
<table width="100%" cellpadding="10" class="form-table">
    <tr>
        <td width="200" align="left" colspan="2">
          <strong><?php _e('Show Title:') ?></strong>
        </td>
    </tr>
    <tr>
    <td width="200" align="right">
      <input name="title" type="radio" value="tnever" <?php if ($title == "tnever") echo "checked=\"checked\"" ?>/>
    </td>
    <td align="left" scope="row"><?php _e('Never') ?></td>
    </tr>  
    <tr>
    <td width="200" align="right">
      <input name="title" type="radio" value="always" <?php if (($title == "always") || (empty($title))) echo "checked=\"checked\""; ?> />
    </td>
    <td align="left" scope="row"><?php _e('Always') ?></td>
    </tr> 
    <tr>
    <td width="200" align="right">
      <input name="title" type="radio" value="over" <?php if ($title == "over") echo "checked=\"checked\"" ?>/>
    </td>
    <td align="left" scope="row"><?php _e('With Mouseover') ?></td>
    </tr>
    <tr>
    <td width="200" align="right">
      <input name="title" type="radio" value="out" <?php if ($title == "out") echo "checked=\"checked\"" ?>/>
    </td>
    <td align="left" scope="row"><?php _e('With Mouseout') ?></td>
    </tr>    
    <tr>
        <td width="200" align="left" colspan="2">
          <strong><?php _e('Open the menu:') ?></strong>
        </td>
    </tr>
    <tr>
        <td width="200" align="right">
          <input name="open" type="radio" value="" <?php if (empty($open)) echo "checked=\"checked\"" ; ?>/>
        </td>
        <td align="left" scope="row"><?php _e('None') ?></td>
    </tr>
    <tr>
        <td width="200" align="right">
          <input name="open" type="radio" value="randomly" <?php if ( $open == "randomly") echo "checked=\"checked\"" ?>/>
        </td>
        <td align="left" scope="row"><?php _e('Randomly') ?></td>
    </tr>        
    <tr valign="center">
        <td width="200" align="right">   
          <input name="open" type="radio" id = "chk_number" value="0" <?php if (is_numeric($open) ) echo "checked=\"checked\"" ?>/>
        </td>
        <td align="left" scope="row"><?php _e('In the position ') ?><input name="open_number" id = "open_number" type="text" value="<?php if (is_numeric($open) ) echo $open ?>" size="2"/></td>
    </tr>
    <tr>
        <td width="200" align="left" colspan="2">
          <strong><?php _e('Effects:') ?></strong>
        </td>
    </tr>
  <tr>
  	<td width="200" align="right">
  	  <select name="effect">
      <?php 
	  echo $effect;
	  foreach($trans_type as $type_value){ ?>
	  <option value="<?php echo $type_value ?>" <?php if ($type_value == $effect) echo "selected" ?> ><?php echo $type_value ?></option>
	  <?php }?>
  	  </select>
  	</td>
  	<td align="left" scope="row"><?php _e('Transition Effect') ?></td>
  <tr>
  	<td width="200" align="right">
  	  <input name="duration" value="<?php echo $duration ?>" size="3"/>
  	</td>
  	<td align="left" scope="row"><?php _e('Duration (milliseconds)') ?></td>
  </tr>
  <tr>
  	<td width="200" align="right">
  	  <input name="border_color" value="<?php echo $border_color ?>" size="8"/>
  	</td>
  	<td align="left" scope="row"> <?php _e('Border Color (hex)') ?></td>
  </tr>    
</table>

<hr />
<h3>jQuery:</h3>
 <p><input name="jq" type="checkbox" value="1" id="jq" <?php if($include_jquery) echo "checked=\"checked\"" ?>/> <?php _e('Include jQuery - Uncheck if other actived plugin is already including the library') ?></p>
<hr />
<h3><?php _e('How to Use') ?></h3>
 <p><?php _e('You can use the Accordion Image Menu everywhere using the shortcode.') ?></p>
<table width="100%" cellpadding="10" class="form-table">
   
  <tr>
    <td width="98" align="right">&nbsp;</td>
    <td width="1182" align="left" scope="row"><?php _e('In your Sidebar: <strong>As a Widget</strong>') ?></td>
  </tr>
  <tr>
    <td width="98" align="right">&nbsp;</td>
    <td align="left" scope="row"><?php _e('In the content using: <strong>[a_image_menu]</strong>') ?></td>
  </tr>
  <tr>
    <td width="98" align="right">&nbsp;</td>
    <td align="left" scope="row"><?php _e('In your theme files using: <strong>&#60;&#63;php echo do_shortcode("[a_image_menu]"); &#63;&#62;') ?></strong></td>
  </tr>
</table>

<hr />

<p class="submit">
<input type="submit" class="button-primary" value="Update Options" name="Submit">
<input type="submit" value="Reset Options" name="Reset">
</p>

</form>



<div style="width:300px; background-color:#FFFEEB; border:solid 1px #ccc; padding:10px; margin:20px 200px; text-align:center" >

<strong><?php _e('Feedback') ?></strong>

<p><?php _e('For more information and suggestions visit the <a href="http://web-argument.com/accordion-image-menu-v-3-0">plugin page</a>. If everything works fine you can consider to support the plugin code by clicking on the donate button.') ?></p>


<form action="https://www.paypal.com/cgi-bin/webscr" accept-charset="UNKNOWN" enctype="application/x-www-form-urlencoded" method="post"> <input name="cmd" size="20" type="hidden" value="_s-xclick" /> <input name="encrypted" size="20" type="hidden" value="-----BEGIN PKCS7-----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-----END PKCS7-----" /> <input alt="PayPal - The safer, easier way to pay online!" name="submit" size="20" src="https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif" type="image" /> <img src="https://www.paypal.com/en_US/i/scr/pixel.gif" border="0" alt="" width="1" height="1" />
</form>

</div>


</div>

<script type="text/javascript">

(function ($) {

	 $(document).ready(function(){

		$("div.m_type").hide();
				 
		 var selChk = $("input[name=type]:checked");
		 var selId = selChk.attr("id");		 
		 $("#a_menu_type_"+selId).slideDown();
		 
		 $("input[name=type]").click(function(){
		    $("div.m_type").slideUp();
			var selId = $(this).attr("id");			 
			$("#a_menu_type_"+selId).slideDown();
			 
		});
		
		$("#open_number").click(function(){
			$("#chk_number").attr("checked","checked");
		});		
		
		$("#chk_number").click(function(){
			var open_number = $("#open_number").val();
			if (open_number == '') $("#open_number").val(0);
		});	
		
		$("#open_number").change(function(){
			$("#chk_number").val($(this).val());
		});	
		
		$("#m_cat_chk_all").click(function()
		  {
		   var checked_status = this.checked;
		   $("#chk_cat input").each(function()
		   {
			this.checked = checked_status;
		   });
		});		
	
	 });
})(jQuery);


</script>

<?php } ?>