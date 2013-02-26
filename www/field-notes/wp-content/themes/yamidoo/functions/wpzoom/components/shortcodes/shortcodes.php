<?php
 
/*-----------------------------------------------------------------------------------*/
/* WPZOOM Shortcodes  */
/*-----------------------------------------------------------------------------------*/

// Add stylesheet for shortcodes to HEAD (added to HEAD in admin-setup.php)
if ( !function_exists( 'wpz_shortcode_stylesheet' ) ) {
    function wpz_shortcode_stylesheet() {
        echo '<link href="'. get_template_directory_uri() .'/functions/wpzoom/assets/css/shortcodes.css" rel="stylesheet" type="text/css" />'."\n";    
    }
}

// Replace WP autop formatting
if (!function_exists( "wpz_remove_wpautop")) {
    function wpz_remove_wpautop($content) { 
        $content = do_shortcode( shortcode_unautop( $content ) ); 
        $content = preg_replace( '#^<\/p>|^<br \/>|<p>$#', '', $content);
        return $content;
    }
}

/*-----------------------------------------------------------------------------------*/
/* Output shortcode JS in footer */
/*-----------------------------------------------------------------------------------*/

// Enqueue shortcode JS file.

add_action( 'init', 'wpz_enqueue_shortcode_js' );
add_action( 'wp_enqueue_scripts' , 'wpz_enqueue_shortcode_css');

/**
 * Include shortcodes .css file
 */
function wpz_enqueue_shortcode_css() {
   wp_enqueue_style('wpz-shortcodes', get_template_directory_uri() . '/functions/wpzoom/assets/css/shortcodes.css');
}

function wpz_enqueue_shortcode_js () {

    if ( !is_admin() ) {
        wp_enqueue_script( 'wpz-shortcodes', get_template_directory_uri() . '/functions/wpzoom/assets/js/shortcodes.js', array( 'jquery', 'jquery-ui-tabs' ), true );
    } // End IF Statement

} // End wpz_enqueue_shortcode_js()

// Check if option to output shortcode JS is active
if (!function_exists( "wpz_check_shortcode_js")) {
    function wpz_check_shortcode_js($shortcode) {
           $js = get_option( "wpz_sc_js" );
           if ( !$js ) 
               wpz_add_shortcode_js($shortcode);
           else {
               if ( !in_array($shortcode, $js) ) {
                   $js[] = $shortcode;
                   update_option( "wpz_sc_js", $js);
               }
           }
    }
}

// Add option to handle JS output
if (!function_exists( "wpz_add_shortcode_js")) {
    function wpz_add_shortcode_js($shortcode) {
        $update = array();
        $update[] = $shortcode;
        update_option( "wpz_sc_js", $update);
    }
}

// Output queued shortcode JS in footer
if (!function_exists( "wpz_output_shortcode_js")) {
    function wpz_output_shortcode_js() {
        $option = get_option( 'wpz_sc_js' );
        if ( $option ) {
        
            // Toggle JS output
            if ( in_array( 'toggle', $option) ) {
                   
                   $output = '
<script type="text/javascript">
    jQuery(document).ready(function() {
        jQuery( ".wpz-sc-toggle-box").hide();
        jQuery( ".wpz-sc-toggle-trigger").click(function() {
            jQuery(this).next( ".wpz-sc-toggle-box").slideToggle(400);
        });
    });
</script>
';
                echo $output;
            }
            
            // Reset option
            delete_option( 'wpz_sc_js' );
        }
    }
}
add_action( 'wp_footer', 'wpz_output_shortcode_js' );

/*-----------------------------------------------------------------------------------*/
/* Boxes - box
/*-----------------------------------------------------------------------------------*/

function wpz_shortcode_box($atts, $content = null) {
   extract(shortcode_atts(array(    'type' => 'normal',
                                       'size' => '',
                                       'style' => '',
                                       'border' => '',
                                       'icon' => ''), $atts)); 
       
       $custom = '';                                
       if ( $icon == "none" )  
           $custom = ' style="padding-left:15px;background-image:none;"';
       elseif ( $icon )  
           $custom = ' style="padding-left:50px;background-image:url( '.$icon.' ); background-repeat:no-repeat; background-position:20px 45%;"';
           
                                           
       return '<div class="wpz-sc-box '.$type.' '.$size.' '.$style.' '.$border.'"'.$custom.'>' . do_shortcode( wpz_remove_wpautop($content) ) . '</div>';
}
add_shortcode( 'box', 'wpz_shortcode_box' );

/*-----------------------------------------------------------------------------------*/
/* Buttons - button
/*-----------------------------------------------------------------------------------*/

function wpz_shortcode_button($atts, $content = null) {
       extract(shortcode_atts(array(    'size' => '',
                                       'style' => '',
                                       'bg_color' => '',
                                       'color' => '',                                       
                                       'border' => '',                                       
                                       'text' => '',                                       
                                       'class' => '',
                                       'link' => '#',
                                       'window' => ''), $atts));

       
       // Set custom background and border color
       $color_output = '';
       if ( $color ) {
       
           if (     $color == "red" OR 
                    $color == "orange" OR
                    $color == "green" OR
                    $color == "aqua" OR
                    $color == "teal" OR
                    $color == "purple" OR
                    $color == "pink" OR
                    $color == "silver"
                     ) {
               $class .= " ".$color;
           
           } else {
               if ( $border ) 
                   $border_out = $border;
               else
                   $border_out = $color;
                   
               $color_output = 'style="background:'.$color.';border-color:'.$border_out.'"';
               
               // add custom class
               $class .= " custom";
           }

       } else {
       
           if ( $border ) 
                   $border_out = $border;
               else
                   $border_out = $bg_color;
                   
               $color_output = 'style="background:'.$bg_color.';border-color:'.$border_out.'"';
               
               // add custom class
               $class .= " custom";
       
       } // End IF Statement

    $class_output = '';

    // Set text color
    if ( $text )
        $class_output .= ' dark';

    // Set class
    if ( $class )
        $class_output .= ' '.$class;

    // Set Size
    if ( $size )
        $class_output .= ' '.$size;
        
    if ( $window )
        $window = 'target="_blank" ';
    
       
       $output = '<a '.$window.'href="'.$link.'"class="wpz-sc-button'.$class_output.'" '.$color_output.'><span class="wpz-'.$style.'">' . wpz_remove_wpautop($content) . '</span></a>';
       return $output;
}
add_shortcode( 'button', 'wpz_shortcode_button' );


/*-----------------------------------------------------------------------------------*/
/* Twitter button - twitter
/*-----------------------------------------------------------------------------------*/

function wpz_shortcode_twitter($atts, $content = null) {
       extract(shortcode_atts(array(    'url' => '',
                                       'style' => 'vertical',
                                       'source' => '',
                                       'text' => '',
                                       'related' => '',
                                       'lang' => '',
                                       'float' => 'left'), $atts));
    $output = '';

    if ( $url )
        $output .= ' data-url="'.$url.'"';
        
    if ( $source )
        $output .= ' data-via="'.$source.'"';
    
    if ( $text ) 
        $output .= ' data-text="'.$text.'"';

    if ( $related )             
        $output .= ' data-related="'.$related.'"';

    if ( $lang )             
        $output .= ' data-lang="'.$lang.'"';
    
    $output = '<div class="wpz-sc-twitter '.$float.'"><a href="http://twitter.com/share" class="twitter-share-button"'.$output.' data-count="'.$style.'">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div>';    
    return $output;

}
add_shortcode( 'twitter', 'wpz_shortcode_twitter' );

/*-----------------------------------------------------------------------------------*/
/* Digg Button - digg
/*-----------------------------------------------------------------------------------*/

function wpz_shortcode_digg($atts, $content = null) {
       extract(shortcode_atts(array(    'link' => '',
                                       'title' => '',
                                       'style' => 'medium',
                                       'float' => 'left'), $atts));
    $output = "        
    <script type=\"text/javascript\">
    (function() {
    var s = document.createElement( 'SCRIPT'), s1 = document.getElementsByTagName( 'SCRIPT')[0];
    s.type = 'text/javascript';
    s.async = true;
    s.src = 'http://widgets.digg.com/buttons.js';
    s1.parentNode.insertBefore(s, s1);
    })();
    </script>        
    ";
    
    // Add custom URL
    if ( $link ) {
        // Add custom title
        if ( $title ) 
            $title = '&amp;title='.urlencode( $title );
            
        $link = ' href="http://digg.com/submit?url='.urlencode( $link ).$title.'"';
    }
    
    if ( $style == "large" )
        $style = "Large";
    elseif ( $style == "compact" )
        $style = "Compact";
    elseif ( $style == "icon" )
        $style = "Icon";
    else
        $style = "Medium";        
        
    $output .= '<div class="wpz-digg '.$float.'"><a class="DiggThisButton Digg'.$style.'"'.$link.'></a></div>';
    return $output;

}
add_shortcode( 'digg', 'wpz_shortcode_digg' );


/*-----------------------------------------------------------------------------------*/
/* Facebook Like Button - fblike
/*-----------------------------------------------------------------------------------*/

function wpz_shortcode_fblike($atts, $content = null) {
       extract(shortcode_atts(array(    'float' => 'none',
                                       'url' => '',
                                       'style' => 'standard',
                                       'showfaces' => 'false',
                                       'width' => '450',
                                       'verb' => 'like',
                                       'colorscheme' => 'light',
                                       'font' => 'arial'), $atts));
        
    global $post;
    
    if ( ! $post ) {
        
        $post = new stdClass();
        $post->ID = 0;
        
    } // End IF Statement
    
    $allowed_styles = array( 'standard', 'button_count', 'box_count' );
    
    if ( ! in_array( $style, $allowed_styles ) ) { $style = 'standard'; } // End IF Statement        
    
    if ( !$url )
        $url = get_permalink($post->ID);
    
    $height = '60';    
    if ( $showfaces == 'true')
        $height = '100';
    
    if ( ! $width || ! is_numeric( $width ) ) { $width = 450; } // End IF Statement
        
    switch ( $float ) {
    
        case 'left':
        
            $float = 'fl';
        
        break;
        
        case 'right':
        
            $float = 'fr';
        
        break;
        
        default:
        break;
    
    } // End SWITCH Statement
        
    $output = '
<div class="wpz-fblike '.$float.'">        
<iframe src="http://www.facebook.com/plugins/like.php?href='.$url.'&amp;layout='.$style.'&amp;show_faces='.$showfaces.'&amp;width='.$width.'&amp;action='.$verb.'&amp;colorscheme='.$colorscheme.'&amp;font=' . $font . '" scrolling="no" frameborder="0" allowTransparency="true" style="border:none; overflow:hidden; width:'.$width.'px; height:'.$height.'px"></iframe>
</div>
    ';
    return $output;

}
add_shortcode( 'fblike', 'wpz_shortcode_fblike' );


/*-----------------------------------------------------------------------------------*/
/* Columns
/*-----------------------------------------------------------------------------------*/

/* ============= Two Columns ============= */

function wpz_shortcode_twocol_one($atts, $content = null) {
   return '<div class="twocol-one">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'twocol_one', 'wpz_shortcode_twocol_one' );

function wpz_shortcode_twocol_one_last($atts, $content = null) {
   return '<div class="twocol-one last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'twocol_one_last', 'wpz_shortcode_twocol_one_last' );


/* ============= Three Columns ============= */

function wpz_shortcode_threecol_one($atts, $content = null) {
   return '<div class="threecol-one">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'threecol_one', 'wpz_shortcode_threecol_one' );

function wpz_shortcode_threecol_one_last($atts, $content = null) {
   return '<div class="threecol-one last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'threecol_one_last', 'wpz_shortcode_threecol_one_last' );

function wpz_shortcode_threecol_two($atts, $content = null) {
   return '<div class="threecol-two">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'threecol_two', 'wpz_shortcode_threecol_two' );

function wpz_shortcode_threecol_two_last($atts, $content = null) {
   return '<div class="threecol-two last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'threecol_two_last', 'wpz_shortcode_threecol_two_last' );

/* ============= Four Columns ============= */

function wpz_shortcode_fourcol_one($atts, $content = null) {
   return '<div class="fourcol-one">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fourcol_one', 'wpz_shortcode_fourcol_one' );

function wpz_shortcode_fourcol_one_last($atts, $content = null) {
   return '<div class="fourcol-one last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fourcol_one_last', 'wpz_shortcode_fourcol_one_last' );

function wpz_shortcode_fourcol_two($atts, $content = null) {
   return '<div class="fourcol-two">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fourcol_two', 'wpz_shortcode_fourcol_two' );

function wpz_shortcode_fourcol_two_last($atts, $content = null) {
   return '<div class="fourcol-two last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fourcol_two_last', 'wpz_shortcode_fourcol_two_last' );

function wpz_shortcode_fourcol_three($atts, $content = null) {
   return '<div class="fourcol-three">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fourcol_three', 'wpz_shortcode_fourcol_three' );

function wpz_shortcode_fourcol_three_last($atts, $content = null) {
   return '<div class="fourcol-three last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fourcol_three_last', 'wpz_shortcode_fourcol_three_last' );

/* ============= Five Columns ============= */

function wpz_shortcode_fivecol_one($atts, $content = null) {
   return '<div class="fivecol-one">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fivecol_one', 'wpz_shortcode_fivecol_one' );

function wpz_shortcode_fivecol_one_last($atts, $content = null) {
   return '<div class="fivecol-one last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fivecol_one_last', 'wpz_shortcode_fivecol_one_last' );

function wpz_shortcode_fivecol_two($atts, $content = null) {
   return '<div class="fivecol-two">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fivecol_two', 'wpz_shortcode_fivecol_two' );

function wpz_shortcode_fivecol_two_last($atts, $content = null) {
   return '<div class="fivecol-two last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fivecol_two_last', 'wpz_shortcode_fivecol_two_last' );

function wpz_shortcode_fivecol_three($atts, $content = null) {
   return '<div class="fivecol-three">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fivecol_three', 'wpz_shortcode_fivecol_three' );

function wpz_shortcode_fivecol_three_last($atts, $content = null) {
   return '<div class="fivecol-three last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fivecol_three_last', 'wpz_shortcode_fivecol_three_last' );

function wpz_shortcode_fivecol_four($atts, $content = null) {
   return '<div class="fivecol-four">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fivecol_four', 'wpz_shortcode_fivecol_four' );

function wpz_shortcode_fivecol_four_last($atts, $content = null) {
   return '<div class="fivecol-four last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'fivecol_four_last', 'wpz_shortcode_fivecol_four_last' );


/* ============= Six Columns ============= */

function wpz_shortcode_sixcol_one($atts, $content = null) {
   return '<div class="sixcol-one">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_one', 'wpz_shortcode_sixcol_one' );

function wpz_shortcode_sixcol_one_last($atts, $content = null) {
   return '<div class="sixcol-one last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_one_last', 'wpz_shortcode_sixcol_one_last' );

function wpz_shortcode_sixcol_two($atts, $content = null) {
   return '<div class="sixcol-two">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_two', 'wpz_shortcode_sixcol_two' );

function wpz_shortcode_sixcol_two_last($atts, $content = null) {
   return '<div class="sixcol-two last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_two_last', 'wpz_shortcode_sixcol_two_last' );

function wpz_shortcode_sixcol_three($atts, $content = null) {
   return '<div class="sixcol-three">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_three', 'wpz_shortcode_sixcol_three' );

function wpz_shortcode_sixcol_three_last($atts, $content = null) {
   return '<div class="sixcol-three last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_three_last', 'wpz_shortcode_sixcol_three_last' );

function wpz_shortcode_sixcol_four($atts, $content = null) {
   return '<div class="sixcol-four">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_four', 'wpz_shortcode_sixcol_four' );

function wpz_shortcode_sixcol_four_last($atts, $content = null) {
   return '<div class="sixcol-four last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_four_last', 'wpz_shortcode_sixcol_four_last' );

function wpz_shortcode_sixcol_five($atts, $content = null) {
   return '<div class="sixcol-five">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_five', 'wpz_shortcode_sixcol_five' );

function wpz_shortcode_sixcol_five_last($atts, $content = null) {
   return '<div class="sixcol-five last">' . wpz_remove_wpautop($content) . '</div>';
}
add_shortcode( 'sixcol_five_last', 'wpz_shortcode_sixcol_five_last' );


/*-----------------------------------------------------------------------------------*/
/* Icon links - ilink
/*-----------------------------------------------------------------------------------*/

function wpz_shortcode_ilink($atts, $content = null) {
       extract(shortcode_atts(array( 'style' => 'info', 'url' => '', 'icon' => ''), $atts));  
       
       $custom_icon = '';
       if ( $icon )
           $custom_icon = 'style="background:url( '.$icon.') no-repeat left 40%;"'; 

   return '<span class="wpz-sc-ilink"><a class="'.$style.'" href="'.$url.'" '.$custom_icon.'>' . wpz_remove_wpautop($content) . '</a></span>';
}
add_shortcode( 'ilink', 'wpz_shortcode_ilink' );


/*-----------------------------------------------------------------------------------*/
/* List Styles - Unordered List - [unordered_list style=""][/unordered_list]
/*-----------------------------------------------------------------------------------*/

function wpz_shortcode_unorderedlist ( $atts, $content = null ) {

    $defaults = array( 'style' => 'default' );

    extract( shortcode_atts( $defaults, $atts ) );
    
    return '<div class="shortcode-unorderedlist ' . $style . '">' . do_shortcode( $content ) . '</div>' . "\n";

} // End wpz_shortcode_unorderedlist()

add_shortcode( 'unordered_list', 'wpz_shortcode_unorderedlist' );

/*-----------------------------------------------------------------------------------*/
/* List Styles - Ordered List - [ordered_list style=""][/ordered_list]
/*-----------------------------------------------------------------------------------*/

function wpz_shortcode_orderedlist ( $atts, $content = null ) {

    $defaults = array( 'style' => 'default' );

    extract( shortcode_atts( $defaults, $atts ) );
    
    return '<div class="shortcode-orderedlist ' . $style . '">' . do_shortcode( $content ) . '</div>' . "\n";

} // End wpz_shortcode_orderedlist()

add_shortcode( 'ordered_list', 'wpz_shortcode_orderedlist' );

/*-----------------------------------------------------------------------------------*/
/* Social Icon - [social_icon url="" float="" icon_url="" title="" profile_type="" window=""]
/*-----------------------------------------------------------------------------------*/

function wpz_shortcode_socialicon ( $atts, $content = null ) {

    $defaults = array( 'url' => '', 'float' => 'none', 'icon_url' => '', 'title' => '', 'profile_type' => '', 'window' => 'no' );

    extract( shortcode_atts( $defaults, $atts ) );
    
    if ( ! $url ) { return; } // End IF Statement - Don't run the shortcode if no URL has been supplied.
    
    // Attempt to determine the location of the social profile.
    // If no location is found, a default icon will be used.
    
    $_default_icon = '';
    
    $_supported_profiles = array(
                                    'facebook' => 'facebook.com', 
                                    'twitter' => 'twitter.com', 
                                    'youtube' => 'youtube.com', 
                                    'delicious' => 'delicious.com', 
                                    'flickr' => 'flickr.com', 
                                    'linkedin' => 'linkedin.com'
                                );
    
    $_profile_to_display = '';
    $_alt_text = '';
    $_classes = 'social-icon';
    
    $_profile_match = false;
    
    // If they've specified an icon, skip the automation.
    
    if ( $profile_type != '' ) {
    
        $_profile_match = true;
        $_profile_to_display = $profile_type;
        if ( $title ) { $_alt_text = $title; } else { $_alt_text = ucwords( $_profile_to_display ); $_alt_text = sprintf( __( 'My %s Profile', 'wpzoom' ), $_alt_text ); } // End IF Statement
        $_profile_class = ' social-icon-' . $_profile_to_display;
        
        if ( $icon_url ) {

            $_img_url = $icon_url;
    
        } else {
        
            $_img_url = trailingslashit( get_template_directory_uri() ) . 'functions/wpzoom/assets/images/' . $_profile_to_display . '.png';
        
        } // End IF Statement
    
    } // End IF Statement
    
    // Create a special scenario for use with the RSS feed for this website.
    
    if ( $url == 'feed' ) {
    
        $_profile_match = true;
        $_profile_to_display = 'rss';
        if ( $title ) { $_alt_text = $title; } else { $_alt_text = __( 'Subscribe to our RSS feed', 'wpzoom' ); } // End IF Statement
        $_classes .= ' social-icon-subscribe';
        $url = get_bloginfo( 'rss2_url' );
        
        if ( $icon_url ) {
        
            $_img_url = $icon_url;
        
        } else {
        
            $_img_url = trailingslashit( get_template_directory_uri() ) . 'functions/wpzoom/assets/images/ico-social-' . $_profile_to_display . '.png';
            
        } // End IF Statement        
        
    } else {
    
        foreach ( $_supported_profiles as $k => $v ) {
        
            if ( $_profile_match == true ) { break; } // End IF Statement - Break out of the loop if we already have a match.
            
            // Get host name from URL
            
            preg_match( '@^(?:http://)?([^/]+)@i', $url, $matches );
            $host = $matches[1];
            
            if ( $host == $v ) {
            
                $_profile_match = true;
                $_profile_to_display = $k;
                if ( $title ) { $_alt_text = $title; } else { $_alt_text = ucwords( $_profile_to_display ); $_alt_text = sprintf( __( 'My %s Profile', 'wpzoom' ), $_alt_text ); } // End IF Statement
                $_profile_class = ' social-icon-' . $_profile_to_display;
                
                if ( $icon_url ) {
        
                    $_img_url = $icon_url;
            
                } else {
                
                $_img_url = trailingslashit( get_template_directory_uri() ) . 'functions/wpzoom/assets/images/' . $_profile_to_display . '.png';
                
                } // End IF Statement
            
            } else {
            
                $_profile_to_display = 'default';
                if ( $title ) { $_alt_text = $title; } else { $_alt_text = ucwords( $matches[1] ); $_alt_text = sprintf( __( 'My %s Profile', 'wpzoom' ), $_alt_text ); } // End IF Statement
                
                $_host_bits = explode( '.', $matches[1] );
                $_profile_class = ' social-icon-' . $_host_bits[0];
                
                if ( $icon_url ) {
        
                    $_img_url = $icon_url;
            
                } else {
                
                    $_img_url = trailingslashit( get_template_directory_uri() ) . 'functions/wpzoom/assets/images/' . $_profile_to_display . '.png';
                    
                    // Check if an image has been added for this social icon.
                    
                    if ( file_exists( trailingslashit( get_stylesheet_directory() ) . 'images/' . $_host_bits[0] . '.png' ) ) {
                    
                        $_img_url = trailingslashit( get_stylesheet_directory_uri() ) . 'images/' . $_host_bits[0] . '.png';
                    
                    } // End IF Statement
                    
                } // End IF Statement
            
            } // End IF Statement
        
        } // End FOREACH Loop
        
        $_classes .= $_profile_class;
        
        // Determine the floating CSS class to be used.
            
        switch ( $float ) {
        
            case 'left':
            
                $_classes .= ' fl';
            
            break;
            
            case 'right':
            
                $_classes .= ' fr';
            
            break;
            
            default:
            
            break;
        
        } // End SWITCH Statement
    
    } // End IF Statement
    
    $target = '';
    if ( $window == 'yes' ) { $target = ' target="_blank"'; } // End IF Statement
    
    return '<a href="' . $url . '" title="' . $_alt_text . '"' . $target . '><img src="' . $_img_url . '" alt="' . $_alt_text . '" class="' . $_classes . '" /></a>' . "\n";

} // End wpz_shortcode_socialicon()

add_shortcode( 'social_icon', 'wpz_shortcode_socialicon' );

/*-----------------------------------------------------------------------------------*/
/* THE END */
/*-----------------------------------------------------------------------------------*/
?>
