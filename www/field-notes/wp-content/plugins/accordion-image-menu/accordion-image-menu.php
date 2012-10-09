<?php
/*
Plugin Name: Accordion Image Menu
Plugin URI: http://web-argument.com/accordion-image-menu-v-20/
Description: Versatile Accordion Image Menu. Allows to use your medium size attached images as links. You can combine and order pages, categories and recent posts.  
Version: 2.0
Author: Alain Gonzalez
Author URI: http://web-argument.com/
*/

// Default Values

$d_aim_options = array(
						'position' => 'vertical',
						'type' => 'rp',
						'post_number' => 5,
						'effect' => 'Sine',
						'open' => 200,
						'closed' => 100,
						'fixed_d' => get_option('medium_size_w'),						
						'dur' => 300,						
						'border' => 2,
						'open_type' => 'open_num',
						'element_open' => 1
 						);


/**
 *  Header  
 */
function a_image_menu_head() {	

    $a_image_menu_header =  "\n<!-- Accordion Image Menu -->\n";		
    $a_image_menu_header .= "<script type=\"text/javascript\" src=\"".get_bloginfo('url')."/wp-content/plugins/accordion-image-menu/js/mootools.js\"></script>\n";
	$a_image_menu_header .= "<script type=\"text/javascript\" src=\"".get_bloginfo('url')."/wp-content/plugins/accordion-image-menu/js/accordion-image-menu.js\"></script>\n";			
	$a_image_menu_header .= "\t<link href=\"".get_bloginfo('url')."/wp-content/plugins/accordion-image-menu/css/imageMenu.css\" rel=\"stylesheet\" type=\"text/css\" />\n";	
	
    $a_image_menu_header .=  "\n<!-- / Accordion Image Menu -->\n";	
            
print($a_image_menu_header);
}

add_action('wp_head', 'a_image_menu_head');
wp_enqueue_script('jquery'); 




/**
 *  The widget 
 */
 
function a_image_menu_w_register() {

	function a_image_menu_w_op() {
	
	$options = get_option('a_i_m'); 
	
	if ($_POST) {
	$options['im_title'] = htmlspecialchars($_POST['im_title']);
	update_option('a_i_m', $options);
	}
	
		
	_e('Title'); ?>	
	 <input name="im_title" type="text" value="<?php echo $options['im_title']; ?>" /><br /><br /> 	
	 <p> You can edit the Image Menu Widget under Settings/ Accordion Image Menu </p>
	<?php
	
	}
	
	function a_image_menu_widget() {

				$options = get_option('a_i_m');

				 echo $before_widget; 
              
              		if (!empty($options['im_title'])) echo $before_title."<h2 class='widgettitle'>".$options['im_title']."</h2>". $after_title;
					
					echo do_shortcode('[a_image_menu]');
					
                 echo $after_widget;
		
	}
	register_sidebar_widget('Accordion Image Menu', 'a_image_menu_widget');
	register_widget_control('Accordion Image Menu', 'a_image_menu_w_op','250','300');	  

}
add_action('init', 'a_image_menu_w_register');




/**
 * Get thumbnails
 */	

function a_m_image_url($the_parent){

$attachments = get_children( array(
						'post_parent' => $the_parent, 
						'post_type' => 'attachment', 
						'post_mime_type' => 'image', 
						'order' => 'DESC', 
						'numberposts' => 1) );
				
				if($attachments == true) :
					foreach($attachments as $id => $attachment) :
						$img = wp_get_attachment_image_src($id, 'medium');
					endforeach;		
				endif;
								
				return $img[0]; 

}




/**
 * Get the items
 */	
function a_image_m_items($num, $cat, $type){

global $d_aim_options;
$options = get_option('a_i_m');

if  ((empty($options)) ||  (empty($options['position']))) $options = $d_aim_options;
	
	/**
	 * Recent Posts
	 */		
	if ($type == 'rp'){
	
			$i = 0;	

if 	(empty($cat)) $my_query = get_posts(array('numberposts'=>-1));
else if (!is_array($cat)){				
			
			$mcat = split (",",$cat);
			
			$my_query = get_posts(array('category__in'=>$mcat,'numberposts'=>-1));
} else {

			$my_query = get_posts(array('category__in'=>$cat,'numberposts'=>-1));

}

	
			foreach ($my_query  as $post) {	
				
				if ($i == $num) break;
				
				$the_image = a_m_image_url($post -> ID);
				$the_title = $post -> post_title;
				$the_link = $post -> guid;
				
				if (isset($the_image))	{
				
					$item[$i] = array("img" => $the_image,"title" => $the_title,"link" => $the_link);
					 
					$i ++;

				}			
	  
			} 
	
	
	} 
	
	else if ($type == 'cp'){	

		/**
		 * Pages
		 */
		if(isset($options['pag_or'])){
			foreach ($options['pag_or'] as $m_pages => $order){
			 
				 if (is_numeric($order) and ($order != 0)) {
					 
					$the_image = a_m_image_url($m_pages);
					$the_title = get_the_title($m_pages);
					$the_link = get_permalink($m_pages);	
					
					if (isset($the_image))	$item[$order] = array("img" => $the_image,"title" => $the_title,"link" => $the_link);			
				
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
								
								if (isset($the_image))	$item[$order] = array("img" => $the_image,"title" => $the_title,"link" => $the_link);					
					  
							}
				}		
			}
		}	

	}		
	
	return $item;

}



/**
 * The shortcode
 */

function a_image_menu_func($atts) {

	global $d_aim_options;

	$options = get_option('a_i_m');

if  ((empty($options)) ||  (empty($options['position']))) $options = $d_aim_options;

   //position
	$position = $options['position'];
	
	//type of menu recent post or cat/pages
	$type = $options['type'];			
	$post_number = $options['post_number'];
	
	//type of menu cat/pages
	$m_cat = $options['m_cat'];		
	$cat_or = $options['cat_or'];
	$pag_or = $options['pag_or'];
	
	//dimensions
	$fixed_d = $options['fixed_d'];
	$open = $options['open'];
	$closed = $options['closed'];
	$border = $options['border'];	
	
	//title	
	$inc_title = $options['inc_title'];
	$title_bg = $options['title_bg'];
	
	//effects
	$open_type = $options['open_type'];		
	$element_open = $options['element_open'];		
	$effect = $options['effect'];
	$dur = $options['dur'];
	

	extract(shortcode_atts(array(
								'position' => $position,
								'cat' => $m_cat,
								'number' => '',
								'effect' => $effect,
								'closed_d' => $closed,
								'open_d' => $open,
								'fixed_d' => $fixed_d,
								'duration' => $dur,
								'border' => $border,
								'element_open' => '',
								'title_bg' => $title_bg
								), $atts));		


	if (empty($number))  $the_items = a_image_m_items($post_number, $cat, $type);
	else $the_items = a_image_m_items($number, $cat, 'rp');	
	
	if(isset($the_items)) {
		ksort($the_items);



		
		$random = wp_generate_password(4, false);
		
		$image_menu_div = "imageMenu_".$random;

        $image_menu =  "\n<!-- Accordion Image Menu -->\n";		
		
		$total_dim =  ($closed_d + $border) * count($the_items);
		
		// horizontal
		if ($position == 'horizontal') {
		
			$div_height = $fixed_d;
			$div_width = $total_dim+10;
			$a_height = $fixed_d;
			$a_width = $closed_d;
			$border_style = "border-right:".$border."px solid #FFFFFF;";			
		
        // vertical		
		} else {
		
			$div_height = $total_dim;
			$div_width = $fixed_d;
			$a_height = $closed_d;
			$a_width = $fixed_d;
			$border_style = "border-bottom:".$border."px solid #FFFFFF;";
				
        }
		
		$image_menu .= "<div id='".$image_menu_div."' style='height:".$div_height."px; width:".$div_width."px;' class='imageMenu' >\n";		
	
			foreach ($the_items as $the_item){

			  $image_menu .= "<a href='".$the_item['link']."' style='background-image:url(".$the_item['img']."); height:".$a_height."px; width:".$a_width."px; ".$border_style."' >\n";
				  
			  if ($inc_title != 'itnev') {
			  
			  $image_menu .= "<span class='vai_title_shadow' >".$the_item['title']."</span><span class='vai_title ";
			  
			  if (isset($title_bg)) $image_menu .= "imageMenu_bg";
			  
			  $image_menu .= "'>".$the_item['title']."</span>\n";
			  
			  }
			  
			  $image_menu .= " &nbsp;</a>\n";
				
			}

		$image_menu .= "</div>\n";		

			
		$image_menu .= "<script type=\"text/javascript\">\n";
		$image_menu .= "jQuery(function($){\n"; 
		$image_menu .= "$(document).ready(function () {\n"; 
					   
		switch ($inc_title) {
			case "itmo":
				$image_menu .= "$('#".$image_menu_div." a').children().hide();\n";			
				$image_menu .= "$('#".$image_menu_div." a').hover( function () { $(this).children().fadeIn(); }, function () { $(this).children().fadeOut(); }); \n";
			break;
			case "itnev":
				$image_menu .= "$('#".$image_menu_div." a').children().hide();\n";
			break;
			default:
				$image_menu .= "$('#".$image_menu_div." a').hover(  function () {    $(this).children().fadeOut();  },  function () {   $(this).children().fadeIn(); });\n";
			break;				
		}
	
		$image_menu .= "var myMenu_".$random." = new ImageMenu($$('#".$image_menu_div." a'),{openDim:".$open_d.", transition: Fx.Transitions.".$effect.".easeOut,";

		switch ($open_type) {
			case "randomly":
			    if($atts['element_open']>0) $image_menu .= "open:".($atts['element_open']-1).",";
				else if($atts['element_open']== 'randomly') $image_menu .= "open:".rand(0, count($the_items)-1).",";
				else $image_menu .= "open:".rand(0, count($the_items)-1).",";
			break;
			case "open_num":
			    if($atts['element_open']>0) $value = $atts['element_open']-1;
			    if ( $element_open <= 0) $value = 0;
				else $value = $element_open -1;
				
				$image_menu .= "open:".$value.",";
			break;
			default:
			    if($atts['element_open']>0) $image_menu .= "open:".$atts['element_open'].",";
				if($atts['element_open']== 'randomly') $image_menu .= "open:".rand(0, count($the_items)-1).",";
			break;				
		}		
		
		$image_menu .= "duration:".$duration.", pos:'".$position."'});\n";
		$image_menu .= "});\n";
		$image_menu .="});\n";
		$image_menu .= "</script>\n";
		$image_menu .=  "\n<!-- Accordion Image Menu -->\n";		

		return $image_menu;
	}
}

add_shortcode('a_image_menu', 'a_image_menu_func');

add_action('admin_menu', 'a_img_menu_set');




/**
 *   Settings  
 */
function a_img_menu_set() {
    add_options_page('Accordion Image Menu', 'Accordion Image Menu', 10, 'accordion-image-menu', 'a_image_menu_page');	 
}

function a_image_menu_page() {

global $d_aim_options;

$categories = get_categories();
$trans_type = array("Back","Bounce","Cubic","Elastic","Expo","Pow","Quad","Quart","Quint","Sine");

$options = get_option('a_i_m');


if  ((empty($options)) ||  (empty($options['position']))) $options = $d_aim_options;


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
		$newoptions['fixed_d'] = $_POST['fixed_d'];
		$newoptions['open'] = $_POST['open'];
		$newoptions['closed'] = $_POST['closed'];
		$newoptions['border'] = $_POST['border'];	
		
		//title	
		$newoptions['inc_title'] = $_POST['inc_title'];
		$newoptions['title_bg'] = $_POST['title_bg'];
		
		//effects
		$newoptions['open_type'] = $_POST['open_type'];		
		$newoptions['element_open'] = $_POST['element_open'];		
		$newoptions['effect'] = $_POST['effect'];
		$newoptions['dur'] = $_POST['dur'];

						

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
		$m_cat = $options['m_cat'];		
		$cat_or = $options['cat_or'];
		$pag_or = $options['pag_or'];
		
		//dimensions
		$fixed_d = $options['fixed_d'];
		$open = $options['open'];
		$closed = $options['closed'];
		$border = $options['border'];	
		
		//title	
		$inc_title = $options['inc_title'];
		$title_bg = $options['title_bg'];
		
		//effects
		$open_type = $options['open_type'];		
		$element_open = $options['element_open'];		
		$effect = $options['effect'];
		$dur = $options['dur'];

		
?>	 	         

<script type="text/javascript">

jQuery(function($){

	 $(document).ready(function(){
		 if ($("input[name=type]:checked").val() == 'cp')
			$("#a_menu_type_rp").hide();
		 else  if ($("input[name=type]:checked").val() == 'rp')   
			$("#a_menu_type_cp").hide();
		 else	{
			$("#a_menu_type_cp").hide();
			$("#a_menu_type_rp").hide();
		}		
		 
		 $("input[name=type]").click(function(){ 
			if ($("input[name=type]:checked").val() == 'cp'){
				$("#a_menu_type_rp").slideUp();
				$("#a_menu_type_cp").slideDown();
			}else if ($("input[name=type]:checked").val() == 'rp'){
				$("#a_menu_type_cp").slideUp();
				$("#a_menu_type_rp").slideDown();
			}  
		});
	
	 });
});
 
</script>

<div class="wrap">   

<form method="post" name="options" target="_self">

<h2>Accordion Image Menu Default Settings</h2><br />

<h3>Position</h3>

<p><input name="position" type="radio" value="vertical" <?php if ($position=="vertical") echo "checked=\"checked\"" ?>/> <b>Vertical</b></p>
<p><input name="position" type="radio" value="horizontal" <?php if ($position=="horizontal") echo "checked=\"checked\"" ?>/> <b>Horizontal</b></p>

<hr/>
<h3>Use the Menu for</h3>

<p><input name="type" type="radio" value="rp" <?php if ($type=="rp") echo "checked=\"checked\"" ?>/> <b>Recent Posts</b></p>

    <div id="a_menu_type_rp">
    
            <table width="100%" cellpadding="10" class="form-table">
            <tr>
            <td width="200" align="right">
			<input name="post_number" value="<?php echo $post_number ?>" size="1" />
			</td>
            <td align="left" scope="row">Number of Posts</td>
            </tr>
                       
            <tr>
            <td width="200" align="right"></td>
            <td align="left" scope="row"><b>On the categories</b></td>
            </tr>
            <?php
            
              foreach ($categories as $cat) { ?>
              <tr valign="top">
                <td width="200" align="right"><input name="m_cat[<?php echo $cat->cat_ID ?>]" type="checkbox" value="<?php echo $cat->cat_ID ?>"
                <?php 
				if (isset($m_cat))	if (in_array($cat->cat_ID, $m_cat)) echo "checked=\"checked\""; ?>                                       
                /> 
                <td align="left" scope="row"><?php echo $cat->cat_name ?></td>
              </tr>
              <?php }  ?>
            
            </table>
    
    </div>

<p><input name="type" type="radio" value="cp" <?php if($type=="cp") echo "checked=\"checked\"" ?>/> <b>Categories and Pages</b></p>

    <div id="a_menu_type_cp">
    <p>To select a Category or a Page just fill out the "Order" field in front of the item (The Order is the vertical item position on the menu, if you use "0" or leave it "empty" the item will not be included)</p>
            <table width="100%" cellpadding="5" class="form-table">
              
              <tr valign="top">
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
              <tr valign="top">
                <td width="200" align="right"></td>
                <td align="left" scope="row"><b>Pages</b></td>
              </tr>
            
             <?php 
              
              foreach ($pages as $pag) { ?>
              <tr valign="top">
                <td width="200" align="right"><input name="pag_or[<?php echo $pag->ID ?>]" type="text" id="pag_or<?php echo $pag->ID ?>" size="1" value="<?php echo $pag_or[$pag->ID] ?>"/></td>
                <td align="left" scope="row"><?php echo $pag->post_title ?></td>
              </tr>
            
              <?php }  ?>
            </select>
             <?php }  ?>
            </table>
            
    </div>

<hr />

<h3>Select the Image Menu Dimensions</h3>
<p>The menu use the Medium Size Images</p>
<table width="100%" cellpadding="10" class="form-table">

  <tr valign="top">
  	<td width="200" align="right">
  	  <input name="fixed_d" id="fixed_d" value="<?php echo $fixed_d ?>" size="2"/> 
  	  px
  	</td>
  	<td align="left" scope="row"><b>Fixed Dimension</b> of the Menu (<strong>width</strong> for
  			vertical position, <strong>height</strong> for horizontal position)</td>
  </tr>
 <tr valign="top">
  	<td width="200" align="right">
  	  <input name="open" id="open" value="<?php echo $open?>" size="2"/> 
  	  px
  	</td>
  	<td align="left" scope="row"><b>Open Dimension</b> (Is the dimension of the images when the mouse is over them)</td>
  </tr>  
  <tr valign="top">
  	<td width="200" align="right">
  	  <input name="closed" id="closed" value="<?php echo $closed ?>" size="2"/>
px </td>
  	<td align="left" scope="row"><b>Closed </b> <b>Dimension</b> (Is the dimension of the images when the menu is not activated)</td>
  </tr> 
  <tr valign="top">
  	<td width="200" align="right">
  	  <input name="border" id="border" value="<?php echo $border ?>" size="2"/>
px </td>
  	<td align="left" scope="row">Border between elements</td>
  </tr>     
</table>

<p class="submit">
<input type="submit" name="Submit" value="Update Options" class="button-primary"/>
</p>

<hr />
<h3> Menu Behaviour </h3>
<table width="100%" cellpadding="10" class="form-table">
    <tr valign="top">
        <td width="200" align="left" colspan="2">
          <strong>Titles:</strong>
        </td>
    </tr>
  <tr valign="top">
  	<td width="200" align="right">
  	  <input name="inc_title" type="radio" value="itnev" <?php if ($inc_title == "itnev") echo "checked=\"checked\"" ?>/>
  	</td>
  	<td align="left" scope="row">Never shows the titles</td>
  </tr>  
  <tr valign="top">
  	<td width="200" align="right">
  	  <input name="inc_title" type="radio" value="it" <?php if (($inc_title == "it") || (empty($inc_title))) echo "checked=\"checked\""; ?> />
  	</td>
  	<td align="left" scope="row">Always shows the titles</td>
  </tr> 
  <tr valign="top">
  	<td width="200" align="right">
  	  <input name="inc_title" type="radio" value="itmo" <?php if ($inc_title == "itmo") echo "checked=\"checked\"" ?>/>
  	</td>
  	<td align="left" scope="row">Shows the titles only with the mouseover event</td>
  </tr>
  <tr valign="top">
  	<td width="200" align="right">
  	  <input name="title_bg" type="checkbox" value="true" <?php if ($title_bg) echo "checked=\"checked\"" ?>/>
  	</td>
  	<td align="left" scope="row">Use  Background</td>
  </tr>  
    <tr valign="top">
        <td width="200" align="left" colspan="2">
          <strong>Open the menu:</strong>
        </td>
    </tr>
    <tr valign="top">
        <td width="200" align="right">
          <input name="open_type" type="radio" value="none" <?php if (( $open_type == "none") || (empty($open_type))) echo "checked=\"checked\"" ; ?>/>
        </td>
        <td align="left" scope="row">None</td>
    </tr>
    <tr valign="top">
        <td width="200" align="right">
          <input name="open_type" type="radio" value="randomly" <?php if ( $open_type == "randomly") echo "checked=\"checked\"" ?>/>
        </td>
        <td align="left" scope="row">Randomly</td>
    </tr>        
    <tr valign="top">
        <td width="200" align="right">
          <input name="open_type" type="radio" value="open_num" <?php if ( $open_type == "open_num") echo "checked=\"checked\"" ?>/>
        </td>
        <td align="left" scope="row">In the position <input name="element_open" type="text" value="<?php echo $element_open ?>" size="2"/></td>
    </tr>
    <tr valign="top">
        <td width="200" align="left" colspan="2">
          <strong>Effects:</strong>
        </td>
    </tr>
  <tr valign="top">
  	<td width="200" align="right">
  	  <select name="effect">
      <?php 
	  foreach($trans_type as $type_value){ ?>
	  <option value="<?php echo $type_value ?>" <?php if ($type_value == $effect) echo "selected" ?> ><?php echo $type_value ?></option>
	  <?php }?>
  	  </select>
  	</td>
  	<td align="left" scope="row">Transition Effect</td>
  <tr valign="top">
  	<td width="200" align="right">
  	  <input name="dur" value="<?php echo $dur ?>" size="3"/>
  	</td>
  	<td align="left" scope="row">Duration (milliseconds)</td>
  </tr>   
</table>

<hr />
<h3>Use</h3>
 <p>You can use the Accordion Image Menu everywhere using the shortcode.</p>
<table width="100%" cellpadding="10" class="form-table">
   
  <tr valign="top">
    <td width="98" align="right">&nbsp;</td>
    <td width="1182" align="left" scope="row">On your Sidebar: <strong>As a Widget</strong></td>
  </tr>
  <tr valign="top">
    <td width="98" align="right">&nbsp;</td>
    <td align="left" scope="row">On the content using: <strong>[a_image_menu]</strong></td>
  </tr>
  <tr valign="top">
    <td width="98" align="right">&nbsp;</td>
    <td align="left" scope="row">On your theme files using: <strong>echo do_shortcode('[a_image_menu]');</strong></td>
  </tr>
</table>

<hr />
<div style="width:300px; background-color:#FFFEEB; border:solid 1px #ccc; padding:10px; margin:20px 200px; text-align:center" >

<strong>Feedback</strong>

<p>If you find this plugin useful or have a suggestion please visit the <a href="http://web-argument.com/accordion-image-menu-plugin">plugin page</a> or make today a special day.</p>


<form action="https://www.paypal.com/cgi-bin/webscr" accept-charset="UNKNOWN" enctype="application/x-www-form-urlencoded" method="post"> <input name="cmd" size="20" type="hidden" value="_s-xclick" /> <input name="encrypted" size="20" type="hidden" value="-----BEGIN PKCS7-----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-----END PKCS7-----" /> <input alt="PayPal - The safer, easier way to pay online!" name="submit" size="20" src="https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif" type="image" /> <img src="https://www.paypal.com/en_US/i/scr/pixel.gif" border="0" alt="" width="1" height="1" />
</form>

</div>

<p class="submit">
<input type="submit" name="Submit" value="Update Options" class="button-primary" />
</p>

</form>
</div>

<?php } ?>