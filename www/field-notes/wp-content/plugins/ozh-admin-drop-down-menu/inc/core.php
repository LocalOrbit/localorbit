<?php
/*
Part of Plugin: Ozh' Admin Drop Down Menu
http://planetozh.com/blog/my-projects/wordpress-admin-menu-drop-down-css/
*/

// The main function that hacks the original menu and display ours instead. Triggered in the _init function by the admin_notice hook.
function wp_ozh_adminmenu () {
	global $menu, $submenu, $self, $parent_file, $submenu_file, $plugin_page, $pagenow, $wp_ozh_adminmenu;
	
	// echo "<pre>";print_r($menu);print_r($submenu);echo "</pre>";
	
	// Plugins: hack $menu & $submenu before I butcher them
	$menu = apply_filters( 'pre_ozh_adminmenu_menu', $menu );
	$submenu = apply_filters( 'pre_ozh_adminmenu_submenu', $submenu ); 
	
	$ozh_menu = '<div id="ozhmenu_wrap"><ul id="ozhmenu">';
	
	// Plugins: hack $ozh_menu before I start adding stuff to it
	$ozh_menu = apply_filters( 'pre_ozh_adminmenu_ozh_menu', $ozh_menu );
	
	if ($wp_ozh_adminmenu['minimode'])
		$ozh_menu .= '<li id="oam_bloglink" class="ozhmenu_toplevel">'.wp_ozh_adminmenu_blogtitle().'</li>';

	$first = true;
	// 0 = name, 1 = capability, 2 = file, 3 = class, 4 = id, 5 = icon src
	foreach ( $_menu = $menu as $key => $item ) {
		// Top level menu
		if (strpos($item[4],'wp-menu-separator') !== false)
			continue;
		
		$admin_is_parent = false;
		$class = array();
		if ( $first ) {
			$class[] = 'wp-first-item';
			$first = false;
		}
		if ( !empty($submenu[$item[2]]) )
			$class[] = 'wp-has-submenu';

		if ( ( $parent_file && $item[2] == $parent_file ) || strcmp($self, $item[2]) == 0 ) {
			if ( !empty($submenu[$item[2]]) )
				$class[] = 'wp-has-current-submenu current wp-menu-open';
			else
				$class[] = 'current';
		}

		if ( isset($item[4]) && ! empty($item[4]) )
			$class[] = $item[4];

		$class = $class ? ' class="' . join( ' ', $class ) . '"' : '';
		$id = isset($item[5]) && ! empty($item[5]) ? 'oam_' . $item[5] : '';
		$anchor = $item[0];
		if ($wp_ozh_adminmenu['compact']) {
			$compactstyle = 'inline';
			$fullstyle = 'none';
		} else {
			$compactstyle = 'none';
			$fullstyle = 'inline';
		}

		if ( isset( $submenu_as_parent ) && !empty( $submenu[$item[2]] ) ) {
			$submenu[$item[2]] = array_values($submenu[$item[2]]);  // Re-index.
			$menu_hook = get_plugin_page_hook($submenu[$item[2]][0][2], $item[2]);
			if ( ( ('index.php' != $submenu[$item[2]][0][2]) && file_exists(WP_PLUGIN_DIR . "/{$submenu[$item[2]][0][2]}") ) || !empty($menu_hook)) {

				$admin_is_parent = true;
				$href = "admin.php?page={$submenu[$item[2]][0][2]}";
			} else {
				$href = $submenu[$item[2]][0][2];
			}
		} else if ( current_user_can($item[1]) ) {
			$menu_hook = get_plugin_page_hook($item[2], 'admin.php');
			if ( ('index.php' != $item[2]) && file_exists(WP_PLUGIN_DIR . "/{$item[2]}") || !empty($menu_hook) ) {
				$admin_is_parent = true;
				$href = "admin.php?page={$item[2]}";
			} else {
				$href = $item[2];
			}
		}
		
		$imgstyle = ($wp_ozh_adminmenu['wpicons']) ? '' : 'style="display:none"';
		$img = '';
		if ( isset($item[6]) && ! empty($item[6]) ) {
			if ( 'none' === $item[6] )
				$img = '<div '.$imgstyle.' class="wp-menu-image"><br /></div>';
			else
				$img = '<img '.$imgstyle.' class="wp-menu-image" src="' . $item[6] . '" alt="" />';
		}

		
		if ($wp_ozh_adminmenu['toplinks']) {
			$href = "href='$href'";
		} else {
			$href =  ( !empty($submenu[$item[2]]) )? '' : "href='$href'" ;
		}
		
		
		$ozh_menu .= "\t<li class='ozhmenu_toplevel' id='$id'><a $href $class>{$img}<span class='compact' style='display:$compactstyle'>&nbsp;</span><span class='full' style='display:$fullstyle'>$anchor</span></a>";

		// Sub level menus
		if ( !empty($submenu[$item[2]]) ) {
			if( !isset( $ulclass ) )
				$ulclass = '';
			$ozh_menu .= "\n\t\t<ul$ulclass><li class='toplevel_label'>$anchor</li>\n";
			$first = true;
			foreach ( $submenu[$item[2]] as $sub_key => $sub_item ) {
				if ( !current_user_can($sub_item[1]) )
					continue;

				$class = array();
				if ( $first ) {
					$class[] = 'wp-first-item';
					$first = false;
				}
				if ( isset($submenu_file) ) {
					if ( $submenu_file == $sub_item[2] )
						$class[] = 'current';
				// If plugin_page is set the parent must either match the current page or not physically exist.
				// This allows plugin pages with the same hook to exist under different parents.
				} else if ( (isset($plugin_page) && $plugin_page == $sub_item[2] && (!file_exists($item[2]) || ($item[2] == $self))) || (!isset($plugin_page) && $self == $sub_item[2]) ) {
					$class[] = 'current';
				}

				$subclass = $class ? ' class="' . join( ' ', $class ) . '"' : '';

				$menu_hook = get_plugin_page_hook($sub_item[2], $item[2]);
				
				if ( ( ('index.php' != $sub_item[2]) && file_exists(WP_PLUGIN_DIR . "/{$sub_item[2]}") ) || ! empty($menu_hook) ) {
					// If admin.php is the current page or if the parent exists as a file in the plugins or admin dir
					$parent_exists = (!$admin_is_parent && file_exists(WP_PLUGIN_DIR . "/{$item[2]}") && !is_dir(WP_PLUGIN_DIR . "/{$item[2]}") ) || file_exists($item[2]);
					if ( $parent_exists )
						$suburl = "{$item[2]}?page={$sub_item[2]}";
					elseif ( 'admin.php' == $pagenow || !$parent_exists )
						$suburl = "admin.php?page={$sub_item[2]}";
					else
						$suburl = "{$item[2]}?page={$sub_item[2]}";
						
					// Get icons?
					if ($wp_ozh_adminmenu['icons']) {
						$plugin_icon = apply_filters('ozh_adminmenu_icon', $sub_item[2]);
						$plugin_icon = apply_filters('ozh_adminmenu_icon_'.$sub_item[2], $sub_item[2]);
						if ($plugin_icon != $sub_item[2]) {
							// we have an icon: no default plugin class & we store the icon location
							$plugin_icons[wp_ozh_adminmenu_sanitize_id($sub_item[2])] = $plugin_icon;
							$icon = '';
						} else {
							// no icon: default plugin class
							$icon = 'oam_plugin';
						}
					}
				} else {
					$suburl = $sub_item[2];
				}

				// Custom logout menu?
				if ($sub_item[2] == 'ozh_admin_menu_logout')
					$suburl = wp_logout_url();				
				
				$subid = 'oamsub_'.wp_ozh_adminmenu_sanitize_id($sub_item[2]);
				$subanchor = strip_tags($sub_item[0]);
				
				if( !isset( $icon ) )
					$icon = '';

				$ozh_menu .= "\t\t\t<li class='ozhmenu_sublevel $icon' id='$subid'><a href='$suburl'$subclass>$subanchor</a></li>\n";
			}			
			
			$ozh_menu .=  "</ul>";
		}
		$ozh_menu .=  "</li>";
	}
	
	$ozh_menu .= "</ul></div>";
	
	// Plugins: hack $ozh_menu now it's complete
	$ozh_menu = apply_filters( 'post_ozh_adminmenu_ozh_menu', $ozh_menu );

	if ( isset( $plugin_icons ) ) {
		global $text_direction;
		$align = ($text_direction == 'rtl' ? 'right' : 'left');
		echo "\n".'<style type="text/css">'."\n";
		foreach( $plugin_icons as $hook=>$icon ) {
			$hook = plugin_basename($hook);
			//echo "#oamsub_$hook a {background-image:url($icon);}\n";
			echo "#oamsub_$hook a {background:url($icon) center $align no-repeat;}\n";
		}
		echo "</style>\n";
	}
	
	echo $ozh_menu;
}

function wp_ozh_adminmenu_blogtitle() {
	$blogname = get_bloginfo('name', 'display');
	if ( '' == $blogname )
		$blogname = '&nbsp;';
	$title_class = '';
	if ( function_exists('mb_strlen') ) {
		if ( mb_strlen($blogname, 'UTF-8') > 30 )
			$title_class = 'class="long-title"';
	} else {
		if ( strlen($blogname) > 30 )
			$title_class = 'class="long-title"';
	}
	$url = trailingslashit( get_bloginfo('url') );
	
	return "<a $title_class href='$url' title='".__('Visit site')."'>$blogname &raquo;</a>";
}


function wp_ozh_adminmenu_sanitize_id($url) {
	$url = preg_replace('/(&|&amp;|&#038;)?_wpnonce=([^&]+)/', '', $url);
	return str_replace(array('.php','.','/','?','='),array('','_','_','_','_'),$url);
}

 
function wp_ozh_adminmenu_js() {
	global $wp_ozh_adminmenu;
	
	$toomanyplugins = $wp_ozh_adminmenu['too_many_plugins'];
	if( empty($toomanyplugins) ) {
		$defaults = wp_ozh_adminmenu_defaults();
		$toomanyplugins = $defaults['too_many_plugins'];
		unset( $defaults );
	}
	$plugin_url = wp_ozh_adminmenu_pluginurl();
	$insert_main_js = '<script src="'.$plugin_url.'inc/js/adminmenu.js?v='. OZH_MENU_VER .'" type="text/javascript"></script>';

	echo <<<JS
<script type="text/javascript"><!--//--><![CDATA[//><!--
var oam_toomanypluygins = $toomanyplugins;
var oam_adminmenu = false;
jQuery(document).ready(function() {
	// Do we need to init everything ?
	var ozhmenu_uselesslinks = jQuery('#user_info p').html();
	if (ozhmenu_uselesslinks) {
		oam_adminmenu = true;
	}
})
//--><!]]></script>
$insert_main_js
JS;

}


function wp_ozh_adminmenu_css() {
	global $wp_ozh_adminmenu, $pagenow, $text_direction;
		
	// $submenu = ($wp_ozh_adminmenu['display_submenu'] or ($pagenow == "media-upload.php") ) ? 1 : 0;
	// Making links relative so they're more readable and shorter in the query string (also made relative in the .css.php)
	$plugin = wp_ozh_adminmenu_pluginurl().'inc/';
	// query vars
	$query = array(
		'v' => OZH_MENU_VER,
		'p' => wp_make_link_relative( $plugin ),
		'a' => wp_make_link_relative( trailingslashit( get_admin_url() ) ),
		'i' => $wp_ozh_adminmenu['icons'],
		'w' => $wp_ozh_adminmenu['wpicons'],
		'm' => $wp_ozh_adminmenu['minimode'],
		'c' => $wp_ozh_adminmenu['compact'],
		'h' => $wp_ozh_adminmenu['hidebubble'],
		'f' => $wp_ozh_adminmenu['displayfav'],
		'g' => $wp_ozh_adminmenu['grad'], // menu color
		'n' => $wp_ozh_adminmenu['nograd'], // disable gradient bg
		'd' => ($text_direction == 'rtl' ? 'right' : 'left'), // right-to-left locale?
	);
	$query = http_build_query($query);

	echo "<link rel='stylesheet' href='{$plugin}adminmenu.css.php?$query' type='text/css' media='all' />\n";
}


function wp_ozh_adminmenu_head() {
	wp_ozh_adminmenu_css();
	wp_ozh_adminmenu_js();
}

// Set defaults
function wp_ozh_adminmenu_defaults() {
	return array(
		'grad' => '#676768',
		'nograd' => 0,
		'compact' => 0,
		'minimode' => 0,
		'hidebubble' => 0,
		'too_many_plugins' => 30,
		'toplinks' => 1,
		'icons' => 1,
		'wpicons' => 1,
	);
}


// Read plugin options or set default values
function wp_ozh_adminmenu_init() {
	global $wp_ozh_adminmenu, $plugin_page;
	
	if ($plugin_page == 'ozh_admin_menu')
		wp_ozh_adminmenu_load_page();

	if (isset($_POST['ozh_adminmenu']) && ($_POST['ozh_adminmenu'] == 1) )
		wp_ozh_adminmenu_processform();
	
	$defaults = wp_ozh_adminmenu_defaults();
	
	if (!count($wp_ozh_adminmenu)) {
		$wp_ozh_adminmenu = (array)get_option('ozh_adminmenu');
		unset($wp_ozh_adminmenu[0]);
	}
	
	// Allow plugins to modify the config
	$wp_ozh_adminmenu = apply_filters( 'ozh_adminmenu_init_config', array_merge( $defaults, $wp_ozh_adminmenu ) );
	
	// Cannot have wpicons == 0 && compact == 1
	if ($wp_ozh_adminmenu['compact'] == 1)
		$wp_ozh_adminmenu['wpicons'] = 1;
	// upon Fluency activation+deactivation, too_many_plugins can be 0, let's fix this
	if (!$wp_ozh_adminmenu['too_many_plugins']) $wp_ozh_adminmenu['too_many_plugins'] = 30;

	// On minimode, add a Logout link to the Users menu
	if ($wp_ozh_adminmenu['minimode'])
		add_users_page(__('Log Out'), __('Log Out'), 'read', 'ozh_admin_menu_logout');
}

// Stuff to do when loading the admin plugin page
function wp_ozh_adminmenu_load_page() {
	wp_ozh_adminmenu_load_text_domain();
}


// Hooked into 'ozh_adminmenu_icon', this function give this plugin its own icon
function wp_ozh_adminmenu_customicon($in) {
	return wp_ozh_adminmenu_pluginurl().'inc/images/ozh.png';
}


// Add option page, hook Farbtastic in
function wp_ozh_adminmenu_add_page() {
	$page = add_options_page('Admin Drop Down Menu', 'Admin Menu', 'manage_options', 'ozh_admin_menu', 'wp_ozh_adminmenu_options_page_includes');
	add_action('admin_print_scripts-' . $page, 'wp_ozh_adminmenu_add_farbtastic');
	add_action('admin_print_styles-'  . $page, 'wp_ozh_adminmenu_add_farbtastic');
}

// Actually add Farbtastic
function wp_ozh_adminmenu_add_farbtastic() {
	wp_enqueue_script('farbtastic');
	wp_enqueue_style('farbtastic');
}


function wp_ozh_adminmenu_options_page_includes() {
	require_once(dirname(__FILE__).'/options.php');
	wp_ozh_adminmenu_options_page();
}

// Return plugin URL (SSL pref compliant) (trailing slash)
function wp_ozh_adminmenu_pluginurl() {
	return plugin_dir_url( dirname(__FILE__) );
}


// Add the 'Settings' link to the plugin page
function wp_ozh_adminmenu_plugin_actions($links) {
	$links[] = "<a href='options-general.php?page=ozh_admin_menu'><b>Settings</b></a>";
	return $links;
}


// Translation wrapper
function wp_ozh_adminmenu__($string) {
	// return "<span style='color:red;background:yellow'>$string</span>"; // The debugging stuff so I'm sure I didnt miss any of the translatable string
	return __($string, 'adminmenu');
}


// Load translation file if any
function wp_ozh_adminmenu_load_text_domain() {
	$locale = get_locale();
	$mofile = WP_PLUGIN_DIR.'/'.plugin_basename(dirname(__FILE__)).'/translations/adminmenu' . '-' . $locale . '.mo';
	load_textdomain('adminmenu', $mofile);
}


function wp_ozh_adminmenu_footer() {
	echo <<<HTML
<p id="footer-ozh-oam">Thank you for using <a href="http://planetozh.com/blog/my-projects/wordpress-admin-menu-drop-down-css/">Admin Drop Down Menu</a>, a wonderful plugin by <a href="http://planetozh.com/blog/">Ozh</a></p>
HTML;
}


// Process $_POST
function wp_ozh_adminmenu_processform() {

	global $wp_ozh_adminmenu;
	
	check_admin_referer('ozh-adminmenu');
	
	// Debug:
	// echo "<pre>";echo htmlentities(print_r($_POST,true));echo "</pre>";	
	
	switch ($_POST['action']) {
	case 'update_options':
	
		$defaults = wp_ozh_adminmenu_defaults();
		
		foreach ($_POST as $k=>$v) {
			$k = str_replace('oam_','',$k);
			if (array_key_exists($k, $defaults)) {
				$options[$k] = esc_attr( $v );
			}
		}
		
		if (!update_option('ozh_adminmenu', $options))
			add_option('ozh_adminmenu', $options);
			
		$wp_ozh_adminmenu = array_merge( (array)$wp_ozh_adminmenu, $options );
		
		$msg = wp_ozh_adminmenu__("updated");
		break;

	case 'reset_options':
		delete_option('ozh_adminmenu');
		$msg = wp_ozh_adminmenu__("deleted");
		break;
	}

	$message  = '<div id="message" class="updated fade">';
	$message .= '<p>'.sprintf(wp_ozh_adminmenu__('Admin Drop Down Menu settings <strong>%s</strong>'), $msg)."</p>\n";
	$message .= "</div>\n";

	add_action('admin_notices', create_function( '', "echo '$message';" ) );
}





?>