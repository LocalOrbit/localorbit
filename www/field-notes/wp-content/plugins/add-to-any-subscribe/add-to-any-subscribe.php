<?php
/*
Plugin Name: Add to Any: Subscribe Button
Plugin URI: http://www.addtoany.com/buttons/
Description: Helps readers subscribe to your blog using any feed reader.  [<a href="widgets.php">Enable Widget</a> | <a href="options-general.php?page=add-to-any-subscribe.php">Settings</a>]
Version: .9.7
Author: Add to Any
Author URI: http://www.addtoany.com/contact/
*/


if( !isset($A2A_javascript) )
	$A2A_javascript = '';
if( !isset($A2A_locale) )
	$A2A_locale = '';

// WordPress MU?
if ( basename(dirname(__FILE__)) == "mu-plugins" )
	$A2A_wpmu = TRUE;
else
	$A2A_wpmu = FALSE;

// Pre-2.6 compatibility
if ( !defined('WP_CONTENT_URL') )
    define( 'WP_CONTENT_URL', get_option('siteurl') . '/wp-content');
if ( ! defined( 'WP_PLUGIN_URL' ) )
      define( 'WP_PLUGIN_URL', WP_CONTENT_URL. '/plugins' );

$A2A_SUBSCRIBE_plugin_basename = plugin_basename(dirname(__FILE__));

if ( $A2A_wpmu )
	$A2A_SUBSCRIBE_plugin_url_path = WPMU_PLUGIN_URL.'/add-to-any-subscribe';
else
	$A2A_SUBSCRIBE_plugin_url_path = WP_PLUGIN_URL.'/'.$A2A_SUBSCRIBE_plugin_basename; // /wp-content/plugins/add-to-any-subscribe

function A2A_SUBSCRIBE_textdomain() {
	global $A2A_SUBSCRIBE_plugin_url_path, $A2A_SUBSCRIBE_plugin_basename;
	load_plugin_textdomain('add-to-any-subscribe',
		$A2A_SUBSCRIBE_plugin_url_path.'/languages',
		$A2A_SUBSCRIBE_plugin_basename.'/languages');
}
add_action('init', 'A2A_SUBSCRIBE_textdomain');

		
class Add_to_Any_Subscribe_Widget {

  	// static init callback
	function init() {
		// Check for the required plugin functions. This will prevent fatal
		// errors occurring when you deactivate the dynamic-sidebar plugin.
		if ( !function_exists('register_sidebar_widget') )
		  return;
		
		$widget = new Add_to_Any_Subscribe_Widget();
		
		// This registers our widget so it appears with the other available
		// widgets and can be dragged and dropped into any active sidebars.
		register_sidebar_widget('Add to Any Subscribe', array($widget,'display'));
		
		//Registering the control form.
		register_widget_control('Add to Any Subscribe', 'A2A_SUBSCRIBE_options_widget', 450);
	}


	function display( $args = false ) {
	
		global $A2A_SUBSCRIBE_plugin_url_path;
		
		if( $args )
			extract( $args );
		
		$feedname		= ($feedname) ? $feedname : get_bloginfo('name');
		$feedname		= ($feedname=='') ? 'Blog' : $feedname ; // Blog name cannot be blank for A2A
		$feedname_enc	= rawurlencode( $feedname );
		$feedurl		= ($feedurl) ? $feedurl : get_bloginfo('rss2_url');
		$feedurl_enc 	= rawurlencode( $feedurl );
		
		$button_target	= (get_option('A2A_SUBSCRIBE_button_opens_new_window')=='1' && (get_option('A2A_SUBSCRIBE_onclick')!='1')) ? ' target="_blank"' : '';
		
		if( !get_option('A2A_SUBSCRIBE_button') ) {
			$button_fname	= 'subscribe_120_16.png';
			$button_width	= ' width="120"';
			$button_height	= ' height="16"';
			$button_src		= $A2A_SUBSCRIBE_plugin_url_path.'/'.$button_fname;
		} else if( get_option('A2A_SUBSCRIBE_button') == 'CUSTOM' ) {
			$button_src		= get_option('A2A_SUBSCRIBE_button_custom');
			$button_width	= '';
			$button_height	= '';
		} else if( get_option('A2A_SUBSCRIBE_button') == 'TEXT' ) {
			$button_text	= stripslashes(get_option('A2A_SUBSCRIBE_button_text'));
		} else {
			$button_attrs	= explode( '|', get_option('A2A_SUBSCRIBE_button') );
			$button_fname	= $button_attrs[0];
			$button_width	= ' width="'.$button_attrs[1].'"';
			$button_height	= ' height="'.$button_attrs[2].'"';
			$button_src		= $A2A_SUBSCRIBE_plugin_url_path.'/'.$button_fname;
			$button_text	= stripslashes(get_option('A2A_SUBSCRIBE_button_text'));
		}
		
		if( $button_fname == 'subscribe_16_16.png' ) {
			if( !is_feed() ) {
				$style_bg	= 'background:url('.$A2A_SUBSCRIBE_plugin_url_path.'/'.$button_fname.') no-repeat scroll 9px 0px'; // padding-left:9 (9=other icons padding)
				$style_bg	= ';' . $style_bg . ' !important;';
				$style		= ' style="'.$style_bg.'padding:0 0 0 30px;display:inline-block;height:16px;line-height:16px;vertical-align:middle;"'; // padding-left:30+9 (9=other icons padding)
			}
		}
		
		if( $button_text && (!$button_fname || $button_fname == 'subscribe_16_16.png') ) {
			$button			= $button_text;
		} else {
			$style = '';
			$button			= '<img src="'.$button_src.'"'.$button_width.$button_height.' alt="Subscribe"/>';
		}
		
		echo $before_widget;
		
		if( trim(get_option('A2A_SUBSCRIBE_widget_title')) != "" ) {
		
			echo $before_title
				. stripslashes(get_option('A2A_SUBSCRIBE_widget_title'))
				. $after_title;
		} ?>

        <a class="a2a_dd addtoany_subscribe" href="http://www.addtoany.com/subscribe?linkname=<?php echo $feedname_enc; ?>&amp;linkurl=<?php echo $feedurl_enc; ?>"<?php echo $style . $button_target; ?>><?php echo $button; ?></a>
        <?php echo $after_widget;
		
		global $A2A_javascript, $A2A_SUBSCRIBE_external_script_called;
		if( $A2A_javascript == '' || !$A2A_SUBSCRIBE_external_script_called ) {
			$external_script_call = '</script><script type="text/javascript" src="http://static.addtoany.com/menu/feed.js"></script>';
			$A2A_SUBSCRIBE_external_script_called = true;
		}
		else
			$external_script_call = 'a2a_init("feed");</script>';
		$A2A_javascript .= '<script type="text/javascript">' . "\n"
			. A2A_menu_locale()
			. 'a2a_linkname="' . js_escape($feedname) . '";' . "\n"
			. 'a2a_linkurl="' . $feedurl . '";' . "\n"
			. ((get_option('A2A_SUBSCRIBE_onclick')=='1') ? 'a2a_onclick=1;' . "\n" : '')
			. ((get_option('A2A_SUBSCRIBE_hide_embeds')=='-1') ? 'a2a_hide_embeds=0;' . "\n" : '')
			. ((get_option('A2A_SUBSCRIBE_show_title')=='1') ? 'a2a_show_title=1;' . "\n" : '')
			. (($A2A_javascript == '' || !$A2A_SUBSCRIBE_external_script_called) ? stripslashes(get_option('A2A_SUBSCRIBE_additional_js_variables')) . "\n" : '')
			. $external_script_call . "\n\n";
		
		remove_action('wp_footer', 'A2A_menu_javascript');
		add_action('wp_footer', 'A2A_menu_javascript');
		
	}
	
}

// Run our code later in case this loads prior to any required plugins.
add_action('widgets_init', array('Add_to_Any_Subscribe_Widget','init'), 99);


if (!function_exists('A2A_menu_javascript')) {
	function A2A_menu_javascript() {
		global $A2A_javascript;
		echo $A2A_javascript;
	}
}

if (!function_exists('A2A_menu_locale')) {
	function A2A_menu_locale() {
		global $A2A_locale;
		if( $A2A_locale != '' ) return false;
		$A2A_locale = 'a2a_localize = {
	Share: "' . __("Share", "add-to-any") . '",
	Save: "' . __("Save", "add-to-any") . '",
	Subscribe: "' . __("Subscribe", "add-to-any") . '",
	Email: "' . __("E-mail") . '",
    Bookmark: "' . __("Bookmark") . '",
	ShowAll: "' . __("Show all", "add-to-any") . '",
	ShowLess: "' . __("Show less", "add-to-any") . '",
	FindServices: "' . __("Find service(s)", "add-to-any") . '",
	FindAnyServiceToAddTo: "' . __("Instantly find any service to add to", "add-to-any") . '",
	PoweredBy: "' . __("Powered by", "add-to-any") . '",
	ShareViaEmail: "' . __("Share via e-mail", "add-to-any") . '",
	SubscribeViaEmail: "' . __("Subscribe via e-mail", "add-to-any") . '",
	BookmarkInYourBrowser: "' . __("Bookmark in your browser", "add-to-any") . '",
	BookmarkInstructions: "' . __("Press Ctrl+D or Cmd+D to bookmark this page", "add-to-any") . '",
	AddToYourFavorites: "' . __("Add to your favorites", "add-to-any") . '",
	SendFromWebOrProgram: "' . __("Send from any e-mail address or e-mail program") . '",
    EmailProgram: "' . __("E-mail program") . '"
};
';
		return $A2A_locale;
	}
}

if (!function_exists('A2A_wp_footer_check')) {
	function A2A_wp_footer_check()
	{
		// If footer.php exists in the current theme, scan for "wp_footer"
		$file = get_template_directory() . '/footer.php';
		if( is_file($file) ) {
			$search_string = "wp_footer";
			$file_lines = @file($file);
			
			foreach($file_lines as $line) {
				$searchCount = substr_count($line, $search_string);
				if($searchCount > 0) {
					return true;
					break;
				}
			}
			
			// wp_footer() not found:
			echo "<div class=\"plugin-update\">" . __("Your theme needs to be fixed. To fix your theme, use the <a href=\"theme-editor.php\">Theme Editor</a> to insert <code>&lt;?php wp_footer(); ?&gt;</code> just before the <code>&lt;/body&gt;</code> line of your theme's <code>footer.php</code> file.") . "</div>";
		}
	}  
}


function A2A_SUBSCRIBE_button_css() {
	?><style type="text/css">.addtoany_subscribe img{border:0;}</style>
<?php
}
add_action('wp_head', 'A2A_SUBSCRIBE_button_css');




/*************************************************
		OPTIONS  ( Appearance > Widgets )
*************************************************/


// This function outputs the options control panel under the admin screen.
function A2A_SUBSCRIBE_options_widget() {

	global $A2A_SUBSCRIBE_plugin_url_path;
	
	if( $_POST[ 'A2A_SUBSCRIBE_submit_hidden' ] == 'Y' ) {

		update_option( 'A2A_SUBSCRIBE_button', $_POST['A2A_SUBSCRIBE_button'] );
		update_option( 'A2A_SUBSCRIBE_button_custom', $_POST['A2A_SUBSCRIBE_button_custom'] );
		update_option( 'A2A_SUBSCRIBE_widget_title', $_POST['A2A_SUBSCRIBE_widget_title'] );
		
		// Store desired text if 16 x 16px button or text-only is chosen:
		if( get_option('A2A_SUBSCRIBE_button') == 'subscribe_16_16.png|16|16' )
			update_option( 'A2A_SUBSCRIBE_button_text', $_POST['A2A_SUBSCRIBE_button_subscribe_16_16_text'] );
		else
			update_option( 'A2A_SUBSCRIBE_button_text', ( trim($_POST['A2A_SUBSCRIBE_button_text']) != '' ) ? $_POST['A2A_SUBSCRIBE_button_text'] : "Subscribe" );
		
    }

	
	// Which is checked
	$subscribe_16_16 		= ( get_option('A2A_SUBSCRIBE_button')=='subscribe_16_16.png|16|16' ) ? ' checked="checked" ' : ' ';
	$subscribe_120_16 		= ( !get_option('A2A_SUBSCRIBE_button') || get_option('A2A_SUBSCRIBE_button')=='subscribe_120_16.png|120|16' ) ? ' checked="checked" ' : ' ';
	$subscribe_171_16 		= ( get_option('A2A_SUBSCRIBE_button')=='subscribe_171_16.png|171|16' ) ? ' checked="checked" ' : ' ';
	$subscribe_256_24 		= ( get_option('A2A_SUBSCRIBE_button')=='subscribe_256_24.png|256|24' ) ? ' checked="checked" ' : ' ';
	$subscribe_custom 		= ( get_option('A2A_SUBSCRIBE_button')=='CUSTOM' ) ? ' checked="checked" ' : ' ';
	$subscribe_text 		= ( get_option('A2A_SUBSCRIBE_button')=='TEXT' ) ? ' checked="checked" ' : ' ';
	
	?>
    <input type="hidden" id="A2A_SUBSCRIBE_submit_hidden" name="A2A_SUBSCRIBE_submit_hidden" value="Y" />
    <p>
    	<label>
        	<?php _e("Title (optional)"); ?>:
			<input class="widefat" type="text" name="A2A_SUBSCRIBE_widget_title" value="<?php echo stripslashes(get_option('A2A_SUBSCRIBE_widget_title')); ?>" />
		</label>
	</p>
    <p>
    	<label>
        	<input class="radio" type="radio"<?php echo $subscribe_16_16; ?> name="A2A_SUBSCRIBE_button" value="subscribe_16_16.png|16|16" style="vertical-align:middle" />
    		<img src="<?php echo $A2A_SUBSCRIBE_plugin_url_path.'/subscribe_16_16.png'; ?>" width="16" height="16" border="0" style="vertical-align:middle" />
		</label>
		<input name="A2A_SUBSCRIBE_button_subscribe_16_16_text" type="text" size="50" onclick="e=document.getElementsByName('A2A_SUBSCRIBE_button');e[e.length-6].checked=true" style="vertical-align:middle;width:150px" 
			value="<?php echo (get_option('A2A_SUBSCRIBE_button_text') !== FALSE) ? stripslashes(get_option('A2A_SUBSCRIBE_button_text')) : "Subscribe"; ?>" />
	</p>
    <p>
    	<label>
        	<input class="radio" type="radio"<?php echo $subscribe_120_16; ?> name="A2A_SUBSCRIBE_button" value="subscribe_120_16.png|120|16" style="vertical-align:middle" />
    		<img src="<?php echo $A2A_SUBSCRIBE_plugin_url_path.'/subscribe_120_16.png'; ?>" width="120" height="16" border="0" style="vertical-align:middle" />
		</label>
	</p>
    <p>
    	<label>
        	<input class="radio" type="radio"<?php echo $subscribe_171_16; ?> name="A2A_SUBSCRIBE_button" value="subscribe_171_16.png|171|16" style="vertical-align:middle" />
    		<img src="<?php echo $A2A_SUBSCRIBE_plugin_url_path.'/subscribe_171_16.png'; ?>" width="171" height="16" border="0" style="vertical-align:middle" />
		</label>
	</p>
    <p>
    	<label>
        	<input class="radio" type="radio"<?php echo $subscribe_256_24; ?> name="A2A_SUBSCRIBE_button" value="subscribe_256_24.png|256|24" style="vertical-align:middle" />
    		<img src="<?php echo $A2A_SUBSCRIBE_plugin_url_path.'/subscribe_256_24.png'; ?>" width="256" height="24" border="0" style="vertical-align:middle" />
		</label>
	</p>
    <p>
    	<label>
        	<input class="radio" type="radio"<?php echo $subscribe_custom; ?> name="A2A_SUBSCRIBE_button" value="CUSTOM" style="vertical-align:middle" />
			<?php _e("Image URL"); ?>:
        </label>
        <input class="widefat" name="A2A_SUBSCRIBE_button_custom" type="text" onclick="e=document.getElementsByName('A2A_SUBSCRIBE_button');e[e.length-2].checked=true" style="vertical-align:middle;width:256px"
        	value="<?php echo get_option('A2A_SUBSCRIBE_button_custom'); ?>" /> 
	</p>
    <p>
    	<label>
        	<input class="radio" type="radio"<?php echo $subscribe_text; ?> name="A2A_SUBSCRIBE_button" value="TEXT" style="vertical-align:middle" />
			<?php _e("Text only"); ?>:
        </label>
        <input class="widefat" name="A2A_SUBSCRIBE_button_text" type="text" onclick="e=document.getElementsByName('A2A_SUBSCRIBE_button');e[e.length-1].checked=true" style="vertical-align:middle;width:256px"
        	value="<?php echo stripslashes(get_option('A2A_SUBSCRIBE_button_text')); ?>" /> 
	</p>
    <p>
    	<a href="options-general.php?page=add-to-any-subscribe.php"><?php _e("More Settings", "add-to-any-subscribe"); ?>...</a>
	</p>
	<?php
	
}




/************************************************
		OPTIONS  ( Settings > Subscribe Button )
*************************************************/


function A2A_SUBSCRIBE_options_page() {

	global $A2A_SUBSCRIBE_plugin_url_path;

    if( $_POST[ 'A2A_SUBSCRIBE_submit_hidden' ] == 'Y' ) {

		update_option( 'A2A_SUBSCRIBE_hide_embeds', ($_POST['A2A_SUBSCRIBE_hide_embeds']=='1') ? '1':'-1' );
		update_option( 'A2A_SUBSCRIBE_show_title', ($_POST['A2A_SUBSCRIBE_show_title']=='1') ? '1':'-1' );
		update_option( 'A2A_SUBSCRIBE_onclick', ($_POST['A2A_SUBSCRIBE_onclick']=='1') ? '1':'-1' );
		update_option( 'A2A_SUBSCRIBE_button_opens_new_window', ($_POST['A2A_SUBSCRIBE_button_opens_new_window']=='1') ? '1':'-1' );
		update_option( 'A2A_SUBSCRIBE_button', $_POST['A2A_SUBSCRIBE_button'] );
		update_option( 'A2A_SUBSCRIBE_button_custom', $_POST['A2A_SUBSCRIBE_button_custom'] );
		update_option( 'A2A_SUBSCRIBE_additional_js_variables', trim($_POST['A2A_SUBSCRIBE_additional_js_variables']) );
		
		// Store desired text if 16 x 16px button or text-only is chosen:
		if( get_option('A2A_SUBSCRIBE_button') == 'subscribe_16_16.png|16|16' )
			update_option( 'A2A_SUBSCRIBE_button_text', $_POST['A2A_SUBSCRIBE_button_subscribe_16_16_text'] );
		else
			update_option( 'A2A_SUBSCRIBE_button_text', ( trim($_POST['A2A_SUBSCRIBE_button_text']) != '' ) ? $_POST['A2A_SUBSCRIBE_button_text'] : "Subscribe" );
		
		?>
    	<div class="updated fade"><p><strong><?php _e('Settings saved.'); ?></strong></p></div>
		<?php
		
    }

    ?>
    
    <?php A2A_wp_footer_check(); ?>
    
    <div class="wrap">

	<h2><?php _e( 'Add to Any: Subscribe ', 'add-to-any-subscribe' ) . _e( 'Settings' ); ?></h2>

    <form method="post" action="">
    
	<?php wp_nonce_field('update-options'); ?>
    
    	<input type="hidden" name="A2A_SUBSCRIBE_submit_hidden" value="Y">
    
        <table class="form-table">
        	<tr valign="top">
            <th scope="row"><?php _e("Button", "add-to-any-subscribe"); ?></th>
            <td><fieldset>
            	<label>
                	<input name="A2A_SUBSCRIBE_button" value="subscribe_16_16.png|16|16" type="radio"<?php if(get_option('A2A_SUBSCRIBE_button')=='subscribe_16_16.png|16|16') echo ' checked="checked"'; ?>
                    	 style="margin:9px 0;vertical-align:middle">
                    <img src="<?php echo $A2A_SUBSCRIBE_plugin_url_path.'/subscribe_16_16.png'; ?>" width="16" height="16" border="0" style="padding:9px;vertical-align:middle" alt="+ Subscribe" title="+ Subscribe"
                    	onclick="this.parentNode.firstChild.checked=true"/>
                </label>
				<input name="A2A_SUBSCRIBE_button_subscribe_16_16_text" class="code" type="text" size="50" onclick="e=document.getElementsByName('A2A_SUBSCRIBE_button');e[e.length-6].checked=true" style="vertical-align:middle;width:150px" 
			value="<?php echo (get_option('A2A_SUBSCRIBE_button_text') !== FALSE) ? stripslashes(get_option('A2A_SUBSCRIBE_button_text')) : "Subscribe"; ?>" /><br>
                <label>
                	<input name="A2A_SUBSCRIBE_button" value="subscribe_120_16.png|120|16" type="radio"<?php if( !get_option('A2A_SUBSCRIBE_button') || get_option('A2A_SUBSCRIBE_button' )=='subscribe_120_16.png|120|16' ) echo ' checked="checked"'; ?>
                    	style="margin:9px 0;vertical-align:middle">
                    <img src="<?php echo $A2A_SUBSCRIBE_plugin_url_path.'/subscribe_120_16.png'; ?>" width="120" height="16" border="0" style="padding:9px;vertical-align:middle"
                    	onclick="this.parentNode.firstChild.checked=true"/>
                </label><br>
                <label>
                	<input name="A2A_SUBSCRIBE_button" value="subscribe_171_16.png|171|16" type="radio"<?php if(get_option('A2A_SUBSCRIBE_button')=='subscribe_171_16.png|171|16') echo ' checked="checked"'; ?>
                    	style="margin:9px 0;vertical-align:middle">
                    <img src="<?php echo $A2A_SUBSCRIBE_plugin_url_path.'/subscribe_171_16.png'; ?>" width="171" height="16" border="0" style="padding:9px;vertical-align:middle"
                    	onclick="this.parentNode.firstChild.checked=true"/>
                </label><br>
                <label>
                	<input name="A2A_SUBSCRIBE_button" value="subscribe_256_24.png|256|24" type="radio"<?php if(get_option('A2A_SUBSCRIBE_button')=='subscribe_256_24.png|256|24') echo ' checked="checked"'; ?>
                    	style="margin:9px 0;vertical-align:middle">
                    <img src="<?php echo $A2A_SUBSCRIBE_plugin_url_path.'/subscribe_256_24.png'; ?>" width="256" height="24" border="0" style="padding:9px;vertical-align:middle"
                    	onclick="this.parentNode.firstChild.checked=true"/>
				</label><br>
                <label>
                	<input name="A2A_SUBSCRIBE_button" value="CUSTOM" type="radio"<?php if( get_option('A2A_SUBSCRIBE_button') == 'CUSTOM' ) echo ' checked="checked"'; ?>
                    	style="margin:9px 0;vertical-align:middle">
					<span style="margin:0 9px;vertical-align:middle"><?php _e("Image URL"); ?>:</span>
				</label>
  				<input name="A2A_SUBSCRIBE_button_custom" type="text" class="code" size="50" onclick="e=document.getElementsByName('A2A_SUBSCRIBE_button');e[e.length-2].checked=true" style="vertical-align:middle"
                	value="<?php echo get_option('A2A_SUBSCRIBE_button_custom'); ?>" /><br>
				<label>
                	<input name="A2A_SUBSCRIBE_button" value="TEXT" type="radio"<?php if( get_option('A2A_SUBSCRIBE_button') == 'TEXT' ) echo ' checked="checked"'; ?>
                    	style="margin:9px 0;vertical-align:middle">
					<span style="margin:0 9px;vertical-align:middle"><?php _e("Text only"); ?>:</span>
				</label>
                <input name="A2A_SUBSCRIBE_button_text" type="text" class="code" size="50" onclick="e=document.getElementsByName('A2A_SUBSCRIBE_button');e[e.length-1].checked=true" style="vertical-align:middle"
                	value="<?php echo ( trim(get_option('A2A_SUBSCRIBE_button_text')) != '' ) ? stripslashes(get_option('A2A_SUBSCRIBE_button_text')) : "Subscribe"; ?>" />
            </fieldset></td>
            </tr>
            <tr valign="top">
            <th scope="row"><?php _e("Button Placement", "add-to-any-subscribe"); ?></th>
            <td><fieldset>
            	<p><?php _e("If you are using a widget-ready theme, you can use the <a href=\"widgets.php\">widgets page</a> to place the button where you want in your sidebar.", "add-to-any-subscribe"); ?></p>
                <p><a href="widgets.php" class="button-secondary"><?php _e("Open Widgets Panel", "add-to-any-subscribe"); ?></a></p>
                <p><?php _e("Alternatively, you can place the following code in <a href=\"theme-editor.php\">your template pages</a> (within <code>sidebar.php</code>, <code>index.php</code>, <code>single.php</code>, and/or <code>page.php</code>)", "add-to-any-subscribe"); ?>:<br/>
                <code>&lt;?php if( class_exists('Add_to_Any_Subscribe_Widget') ) { Add_to_Any_Subscribe_Widget::display(); } ?&gt;</code></p>
            </fieldset></td>
            </tr>
            <tr valign="top">
            <th scope="row"><?php _e("Menu Style", "add-to-any-subscribe"); ?></th>
            <td><fieldset>
					<p><?php _e("Using Add to Any's Menu Styler, you can customize the colors of your Subscribe menu! When you're done, be sure to paste the generated code in the <a href=\"#\" onclick=\"document.getElementById('A2A_SUBSCRIBE_additional_js_variables').focus();return false\">Additional Options</a> box below.", "add-to-any-subscribe"); ?></p>
                    <p>
                		<a href="http://www.addtoany.com/buttons/subscribe/menu_style/wordpress" class="button-secondary" title="<?php _e("Open the Add to Any Menu Styler in a new window", "add-to-any-subscribe"); ?>" target="_blank"
                        	onclick="document.getElementById('A2A_SUBSCRIBE_additional_js_variables').focus();
                            	document.getElementById('A2A_SUBSCRIBE_menu_styler_note').style.display='';"><?php _e("Open Menu Styler", "add-to-any-subscribe"); ?></a>
					</p>
            </fieldset></td>
            </tr>
            <tr valign="top">
            <th scope="row"><?php _e("Menu Options", "add-to-any-subscribe"); ?></th>
            <td><fieldset>
            	<label>
                	<input name="A2A_SUBSCRIBE_hide_embeds" 
                        type="checkbox"<?php if(get_option('A2A_SUBSCRIBE_hide_embeds')!='-1') echo ' checked="checked"'; ?> value="1"/>
                	<?php _e("Hide embedded objects (Flash, video, etc.) that intersect with the menu when displayed", "add-to-any-subscribe"); ?>
                </label><br />
                <label>
                	<input name="A2A_SUBSCRIBE_show_title" 
                        type="checkbox"<?php if(get_option('A2A_SUBSCRIBE_show_title')=='1') echo ' checked="checked"'; ?> value="1"/>
                	<?php _e("Show the title of this blog within the menu", "add-to-any-subscribe"); ?>
                </label><br />
				<label>
                	<input name="A2A_SUBSCRIBE_onclick" 
                        type="checkbox"<?php if(get_option('A2A_SUBSCRIBE_onclick')=='1') echo ' checked="checked"'; ?> value="1"
                        onclick="e=getElementsByName('A2A_SUBSCRIBE_button_opens_new_window')[0];if(this.checked){e.checked=false;e.disabled=true}else{e.disabled=false}"
						onchange="e=getElementsByName('A2A_SUBSCRIBE_button_opens_new_window')[0];if(this.checked){e.checked=false;e.disabled=true}else{e.disabled=false}"/>
                	<?php _e("Only show the menu when the user clicks the Subscribe button", "add-to-any-subscribe"); ?>
                </label><br />
				<label>
                	<input name="A2A_SUBSCRIBE_button_opens_new_window" 
                        type="checkbox"<?php if(get_option('A2A_SUBSCRIBE_button_opens_new_window')=='1') echo ' checked="checked"'; ?> value="1"
						<?php if(get_option('A2A_SUBSCRIBE_onclick')=='1') echo ' disabled="disabled"'; ?>/>
                	<?php _e('Open the addtoany.com menu page in a new tab or window if the user clicks the Subscribe button', 'add-to-any-subscribe'); ?>
                </label>
            </fieldset></td>
            </tr>
            <tr valign="top">
            <th scope="row"><?php _e("Additional Options", "add-to-any-subscribe"); ?></th>
            <td><fieldset>
            		<p id="A2A_SUBSCRIBE_menu_styler_note" style="display:none">
                        <label for="A2A_SUBSCRIBE_additional_js_variables" class="updated">
                            <strong><?php _e("Paste the code from Add to Any's Menu Styler in the box below!", "add-to-any-subscribe"); ?></strong>
                        </label>
                    </p>
                    <label for="A2A_SUBSCRIBE_additional_js_variables">
                    	<p><?php _e("Below you can set special JavaScript variables to apply to your Subscribe menu.", "add-to-any-subscribe"); ?>
                    	<?php _e("Advanced users might want to explore Add to Any's <a href=\"http://www.addtoany.com/buttons/api/\" target=\"_blank\">JavaScript API</a>.", "add-to-any-subscribe"); ?></p>
					</label>
                    <p>
                		<textarea name="A2A_SUBSCRIBE_additional_js_variables" id="A2A_SUBSCRIBE_additional_js_variables" class="code" style="width: 98%; font-size: 12px;" rows="5" cols="50"><?php echo stripslashes(get_option('A2A_SUBSCRIBE_additional_js_variables')); ?></textarea>
					</p>
                    <?php if( get_option('A2A_SUBSCRIBE_additional_js_variables')!='' ) { ?>
                    <label for="A2A_SUBSCRIBE_additional_js_variables" class="setting-description"><?php _e("<strong>Note</strong>: If you're adding new code, be careful not to accidentally overwrite any previous code.", "add-to-any-subscribe"); ?></label>
                    <?php } ?>
            </fieldset></td>
            </tr>
        </table>
        
        <p class="submit">
            <input class="button-primary" type="submit" name="Submit" value="<?php _e('Save Changes', 'add-to-any-subscribe' ) ?>" />
        </p>
    
    </form>
    </div>

<?php
 
}

function A2A_SUBSCRIBE_add_menu_link() {
	if( current_user_can('manage_options') ) {
		add_options_page(
			'Add to Any: '. __("Subscribe", "add-to-any-subscribe") . " " . __("Settings")
			, __("Subscribe Buttons", "add-to-any-subscribe")
			, 8 
			, basename(__FILE__)
			, 'A2A_SUBSCRIBE_options_page'
		);
	}
}

add_action('admin_menu', 'A2A_SUBSCRIBE_add_menu_link');

// Place in Settings Option List
function A2A_SUBSCRIBE_actlinks( $links, $file ){
	//Static so we don't call plugin_basename on every plugin row.
	static $this_plugin;
	if ( ! $this_plugin ) $this_plugin = plugin_basename(__FILE__);
	
	if ( $file == $this_plugin ){
		$settings_link = '<a href="options-general.php?page=add-to-any-subscribe.php">' . __('Settings') . '</a>';
		$widgets_link = '<a href="widgets.php">' . __('Widgets') . '</a>';
		array_unshift( $links, $settings_link, $widgets_link ); // before other links
	}
	return $links;
}

add_filter("plugin_action_links", 'A2A_SUBSCRIBE_actlinks', 10, 2);

?>
