<?php
/*
Plugin Name: Custom Admin Branding
Plugin URI: http://pressingpixels.com/wordpress-custom-admin-branding
Description: Allows you to brand your wordpress install for clients.  Display custom images for the login screen, admin header and footer.
Author: Josh Byers
Version: 1.3.4
Author URI: http://www.joshbyers.com
*/ 

add_action('admin_menu', 'mt_add_pages');

function mt_add_pages() {

add_options_page('Custom Admin Branding', 'Custom Admin Branding', 8, 'brandingoptions', 'mt_options_page');
}

// mt_options_page() displays the page content for the Test Options submenu
function mt_options_page() {

    // variables for the field and option names 
    $opt_name = 'admin_branding_link';
    $hidden_field_name = 'mt_submit_hidden';
    $cab_footer_link = 'admin_branding_link';

    // Read in existing option value from database
    $opt_val = get_option( $opt_name );

    // See if the user has posted us some information
    // If they did, this hidden field will be set to 'Y'
    if( $_POST[ $hidden_field_name ] == 'Y' ) {
        // Read their posted value
        $opt_val = $_POST[ $cab_footer_link ];

        // Save the posted value in the database
        update_option( $opt_name, $opt_val );

        // Put an options updated message on the screen

?>
<div class="updated"><p><strong><?php _e('Options saved.', 'mt_trans_domain' ); ?></strong></p></div>
<?php

    }

    // Now display the options editing screen

    echo '<div class="wrap">';

    // header

    echo "<h2>" . __( 'Custom Admin Branding Options', 'mt_trans_domain' ) . "</h2>";

    // options form
    
    ?>

<form name="form1" method="post" action="<?php echo str_replace( '%7E', '~', $_SERVER['REQUEST_URI']); ?>">
<input type="hidden" name="<?php echo $hidden_field_name; ?>" value="Y">

<p><?php _e("Footer Link:&nbsp;&nbsp;&nbsp;http://", 'mt_trans_domain' ); ?> 
<input type="text" name="<?php echo $cab_footer_link; ?>" value="<?php echo $opt_val; ?>" size="20">
</p>

<p class="submit">
<input type="submit" name="Submit" value="<?php _e('Update Options', 'mt_trans_domain' ) ?>" />
</p>

</form>
</div>

<?php
 
}

/*This is the function that displays the custom login screen.  Change the images in the images folder to create your own custom login.  Credit goes to Ben Gillbanks of Binary Moon (http://www.binarymoon.co.uk/)*/
function custom_login() {
	echo '<link rel="stylesheet" type="text/css" href="' . get_settings('siteurl') . '/wp-content/plugins/custom-admin-branding/custom_branding.css" />';
}

add_action('login_head', 'custom_login');

/*This function loads the custom css style sheet that will hide the default Wordpress containers and replace them with the custom containers and styles*/
function custom_header() {
	echo '<link rel="stylesheet" type="text/css" href="' . get_settings('siteurl') . '/wp-content/plugins/custom-admin-branding/custom_branding.css" />';


/*This function places the custom header graphic at the top of every Wordpress Admin page.  Change the file in the images folder to replace.*/


echo '<div id="wphead_custom">
	  	<a href="' . get_settings('siteurl') . '"><img id="header-logo_custom" src="' . get_settings('siteurl') . '/wp-content/plugins/custom-admin-branding/images/custom_header.png"</a>
	 	<div id="wphead-info">
	 	<div id="user_info">
	 	<p>Howdy, <a href="'. get_settings('siteurl') . '/wp-admin/profile.php">'; 
	 	
	 	global $current_user;
		if (isset($current_user->user_firstname)){
		get_currentuserinfo(); echo($current_user->user_firstname);
		} else {
		get_currentuserinfo(); echo($current_user->user_login);
		} 
	 	echo '</a> | <a href="'. get_settings('siteurl') . '/wp-admin/tools.php">Turbo</a> | <a href="'. wp_logout_url().'">Log Out</a> </p></div>';
	 	
	 	echo favorite_actions();
	 	echo '</div></div>';

}



add_action('admin_head', 'custom_header', 11);

/*This function places the custom footer at the bottom of every Wordpress Admin page.  Change the file in the images folder to replace.  You will also want to change the link (in the code below) that the footer image is pointing to.*/

function custom_footer() {
   echo '<div id="footer_custom">
	
<p><a href="http://'.get_option('admin_branding_link').'" id="footer_image"><img src="' . get_settings('siteurl') . '/wp-content/plugins/custom-admin-branding/images/custom_footer.png" alt="'.get_option('admin_branding_link').'" /></a></p>
<p class="docs"> Admin Version '. get_bloginfo('version') . '</p>
	
	
	</div>';
}

add_action('admin_footer', 'custom_footer');

/*This function gives the user the option to replaces the current admin style sheet with a custom style sheet  The code was originally written by Ozh from http://planetozh.com/

add_action('admin_init','custom_admin_branding_css');

function custom_admin_branding_css() {
	$plugin_url = get_option( 'siteurl' ) . '/wp-content/plugins/' . plugin_basename(dirname(__FILE__)) ;
	wp_admin_css_color(
		'Custom',
		__('Custom'),
		$plugin_url . '/wp-admin-custom.css',
		array(
			'#2683ae',
			'#d54e21',
			'#cee1ef',
			'#464646'
	)
);
}*/

?>