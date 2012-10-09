<?php
/*
Part of Plugin: Ozh' Admin Drop Down Menu
http://planetozh.com/blog/my-projects/wordpress-admin-menu-drop-down-css/
*/

/***** Mu specific ****/

function wp_ozh_adminmenu_remove_blogswitch_init() {
	remove_action( '_admin_menu', 'blogswitch_init' );
	add_action( '_admin_menu', 'wp_ozh_adminmenu_blogswitch_init' );
}

function wp_ozh_adminmenu_blogswitch_init() {
	global $current_user, $current_blog;
	$blogs = get_blogs_of_user( $current_user->ID );
	if ( !$blogs )
		return;
	add_action( 'admin_menu', 'wp_ozh_adminmenu_blogswitch_ob_start' );
	add_action( 'dashmenu', 'blogswitch_markup' );

}


function wp_ozh_adminmenu_blogswitch_ob_start() {
	ob_start( 'wp_ozh_adminmenu_blogswitch_ob_content' );
}

function wp_ozh_adminmenu_blogswitch_ob_content( $content ) {
	// Menu with blog list
	$mumenu = preg_replace( '#.*%%REAL_DASH_MENU%%(.*?)%%END_REAL_DASH_MENU%%.*#s', '\\1', $content );
	$mumenu = str_replace ('<li>', '<li class="ozhmenu_sublevel">', $mumenu);
	$mumenu = preg_replace( '#</ul>.*?<form id="all-my-blogs"#s', '<li><form id="all-my-blogs"', $mumenu);
	$mumenu = str_replace ('</form>', '</form></li></ul>', $mumenu);
	
	
	$content = preg_replace( '#%%REAL_DASH_MENU%%(.*?)%%END_REAL_DASH_MENU%%#s', '', $content );
	$content = str_replace( '<ul id="ozhmenu">', '<ul id="ozhmenu"><li class="ozhmenu_toplevel" id="ozhmumenu_head"><a href="">My blogs</a><ul id="ozhmumenu">'.$mumenu.'</li>', $content );
	
	return $content;
}





?>