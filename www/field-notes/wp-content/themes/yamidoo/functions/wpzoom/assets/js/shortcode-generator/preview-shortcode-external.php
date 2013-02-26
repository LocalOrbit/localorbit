<?php 
$valid_shortcodes = array(
    'box', 'button', 'twitter', 'digg', 'fblike', 'ilink', 'unordered_list', 'ordered_list', 'social_icon',
    'twocol_one', 'twocol_one_last',
    'threecol_one', 'threecol_one_last', 'threecol_two', 'threecol_two_last',
    'fourcol_one', 'fourcol_one_last', 'fourcol_two', 'fourcol_two_last', 'fourcol_three', 'fourcol_three_last',
    'fivecol_one', 'fivecol_one_last', 'fivecol_two', 'fivecol_two_last', 'fivecol_three', 'fivecol_three_last', 'fivecol_four', 'fivecol_four_last',
    'sixcol_one', 'sixcol_one_last', 'sixcol_two', 'sixcol_two_last', 'sixcol_three', 'sixcol_three_last', 'sixcol_four', 'sixcol_four_last', 'sixcol_five', 'sixcol_five_last'
);

// Get the path to the root.
$full_path = __FILE__;

$path_bits = explode( 'wp-content', $full_path );

$url = $path_bits[0];

// Require WordPress bootstrap.
require_once( $url . '/wp-load.php' );

if ( !current_user_can( 'edit_posts' ) ) return false;

$wpz_theme_css = get_template_directory_uri() . '/style.css';
$wpz_shortcode_css = get_template_directory_uri() . '/functions/wpzoom/assets/css/shortcodes.css';
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head profile="http://gmpg.org/xfn/11">

<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js" ></script>
<link rel="stylesheet" href="<?php echo $wpz_theme_css; ?>" media="all" />
<link rel="stylesheet" href="<?php echo $wpz_shortcode_css; ?>" media="all" />
<style>
    .post  { margin: -5px 0 0 0; }
    .shortcode-typography { display: block; margin-top: 20px; }    
</style>
 
</head>
<body>

<?php

$shortcode = isset($_REQUEST['shortcode']) ? $_REQUEST['shortcode'] : '';

// WordPress automatically adds slashes to quotes
// http://stackoverflow.com/questions/3812128/although-magic-quotes-are-turned-off-still-escaped-strings
$shortcode = stripslashes($shortcode);

$regex = get_shortcode_regex();
$code = trim( urldecode( $shortcode ) );
preg_match( "/$regex/s", $code, $matches );
$shortcode_name = isset( $matches[2] ) ? $matches[2] : '';
if ( empty( $shortcode_name ) || !in_array( $shortcode_name, $valid_shortcodes ) ) return false;
unset( $regex, $code, $shortcode_name );

echo do_shortcode($shortcode);

?>
<script type="text/javascript">

    jQuery( '#wpz-preview h3:first', window.parent.document).removeClass( 'wpz-loading' );

</script>
<script type="text/javascript" src="<?php echo get_template_directory_uri() . '/functions/wpzoom/assets/js/shortcodes.js'; ?>"></script>
</body>
</html>
