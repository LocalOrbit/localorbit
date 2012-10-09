<?php
/*
Plugin Name: paypal widget
Plugin URI: http://www.alakhnor.com/post-thumb
Description: Adds sidebar widgets to display paypal button
Version: 1.0
Author: Alakhnor
Author URI: http://www.alakhnor.com/post-thumb
*/

function paypal_widget()
{
	if ( !function_exists('register_sidebars')) return;
/*********************************************************************************/
/* paypal widget
/*********************************************************************************/
function web_paypal($args)
{
	extract($args);

	// Each widget can store its own options. We keep strings here.
	$options = get_option('web_paypal');
	$title = $options['title'];

	// These lines generate our output.
	echo $before_widget . $before_title . $title . $after_title;
	$url_parts = parse_url(get_bloginfo('home'));
	echo '<p>'.web_paypal_code().'</p>';
	echo $after_widget;
		
}
/*********************************************************************************/
/* paypal widget control
/*********************************************************************************/
function web_paypal_control()
{
	global $wpdb;
	$options = get_option('web_paypal');

	if ( $_POST['paypal-submit'] )
        {
        	$options['title'] = strip_tags(stripslashes($_POST['paypal-title']));
		update_option('web_paypal', $options);
	}

	$title = htmlspecialchars($options['title'], ENT_QUOTES);

	// The Box content
	echo '<p style="text-align:right;"><label for="paypal-title">' . __('Title:') . ' <input style="width: 200px;" id="paypal-title" name="paypal-title" type="text" value="'.$title.'" /></label></p>';
	echo '</select></p>';
	echo '<input type="hidden" id="paypal-submit" name="paypal-submit" value="1" />';
}
/*********************************************************************************/
/* paypal widget control
/*********************************************************************************/
function web_paypal_code()
{
// Copy paypal code here ?>

<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick" />
<input type="image" src="https://www.paypal.com/en_US/i/btn/x-click-but21.gif" style="border: none" name="submit" alt="Effectuez vos paiements via PayPal : une solution rapide, gratuite et sÈcurisÈe" />
<img alt="" style="border: none" src="https://www.paypal.com/fr_FR/i/scr/pixel.gif" width="1" height="1" />
<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
" />
</form>

<?php // End of Paypal button code
}
/*********************************************************************************/
/* Register widgets and widget controls
/*********************************************************************************/
	register_sidebar_widget ( 'pt-paypal', 'web_paypal', 'wid-paypal');
	register_widget_control ( 'pt-paypal', 'web_paypal_control', 300, 180);

}

// Run our code later in case this loads prior to any required plugins.
add_action('widgets_init', 'paypal_widget');

?>
