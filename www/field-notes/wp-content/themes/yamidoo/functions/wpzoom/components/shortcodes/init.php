<?php
/*-----------------------------------------------------------------------------------
Shortcode generator.
Author: Based on the work of the Shortcode Ninja plugin by VisualShortcodes.com.

INSTANTIATE CLASS

-----------------------------------------------------------------------------------*/

class wpzoom_Shortcode_Generator {

     function wpzoom_Shortcode_Generator () {
    
        // Register the necessary actions on `admin_init`.
        add_action( 'admin_init', array( &$this, 'init' ) );
        
        // wp_ajax_... is only run for logged users.
        add_action( 'wp_ajax_wpz_check_url_action', array( &$this, 'ajax_action_check_url' ) );
        
        // Shortcode testing functionality.
        //if ( ! function_exists( 'add_shortcode' ) ) return;
        //add_shortcode( 'testing',     array( &$this, 'shortcode_testing' ) );
    
    } // End wpzoom_Shortcode_Generator()

/*-----------------------------------------------------------------------------------
  init()
-----------------------------------------------------------------------------------*/

    function init() {
     
        if ( ( current_user_can( 'edit_posts' ) || current_user_can( 'edit_pages' ) ) && get_user_option( 'rich_editing') == 'true' )  {
              
              // Add the tinyMCE buttons and plugins.
            add_filter( 'mce_buttons', array( &$this, 'filter_mce_buttons' ) );
            add_filter( 'mce_external_plugins', array( &$this, 'filter_mce_external_plugins' ) );
            
            // Register the colourpicker JavaScript.
            wp_register_script( 'wpz-colourpicker', WPZOOM::$assetsPath . '/js/colorpicker.js', array( 'jquery' ), '3.6', true ); // Loaded into the footer.
            wp_enqueue_script( 'wpz-colourpicker' );
            
            // Register the colourpicker CSS.
            wp_register_style( 'wpz-colourpicker', WPZOOM::$assetsPath . '/css/colorpicker.css' );
            wp_enqueue_style( 'wpz-colourpicker' );
            
            // Register the custom CSS styles.
            wp_register_style( 'wpz-shortcode-generator', WPZOOM::$assetsPath . '/css/shortcode-generator.css' );
            wp_enqueue_style( 'wpz-shortcode-generator' );
            
        } // End IF Statement
    
    } // End init()

/*-----------------------------------------------------------------------------------
  filter_mce_buttons()
  
  * Add new button to the tinyMCE editor.
-----------------------------------------------------------------------------------*/
    
    function filter_mce_buttons( $buttons ) {
        
        array_push( $buttons, '|', 'wpzoom_shortcodes_button' );
        
        return $buttons;
        
    } // End filter_mce_buttons()

/*-----------------------------------------------------------------------------------
  filter_mce_external_plugins()
  
  * Add functionality to the tinyMCE editor as an external plugin.
-----------------------------------------------------------------------------------*/
    
    function filter_mce_external_plugins( $plugins ) {
        
        $plugins['wpzoomShortcodes'] = WPZOOM::$assetsPath . '/js/shortcode-generator/editor_plugin.js';
        
        return $plugins;
        
    } // End filter_mce_external_plugins()
    
/*-----------------------------------------------------------------------------------
  Utility Functions
  
  * Helper functions for this class.
-----------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------
  framework_url()
-----------------------------------------------------------------------------------*/

function framework_url() {
    
    return trailingslashit( get_template_directory_uri() . '/' . basename( dirname( __FILE__ ) ) );

} // End framework_url()

/*-----------------------------------------------------------------------------------
  ajax_action_check_url()
  
  * Checks if a given url (via GET or POST) exists.
  * Returns JSON.
  *
  * NOTE: For users that are not logged in this is not called.
  * The client recieves <code>-1</code> in that case.
-----------------------------------------------------------------------------------*/

function ajax_action_check_url() {

    $hadError = true;

    $url = isset( $_REQUEST['url'] ) ? $_REQUEST['url'] : '';

    if ( strlen( $url ) > 0  && function_exists( 'get_headers' ) ) {
            
        $file_headers = @get_headers( $url );
        $exists       = $file_headers && $file_headers[0] != 'HTTP/1.1 404 Not Found';
        $hadError     = false;
    }

    echo '{ "exists": '. ($exists ? '1' : '0') . ($hadError ? ', "error" : 1 ' : '') . ' }';

    die();
    
} // End ajax_action_check_url()

/*-----------------------------------------------------------------------------------
  shortcode_testing()
  
  * Used for testing that the shortcodes are functioning.
-----------------------------------------------------------------------------------*/

function shortcode_testing( $atts, $content = null ) {
    
    if ($content === null) return '';
    
    return '<strong>Working: ' . $content . '</strong>' . "\n";
    
} // End shortcode_testing()

} // End Class

/*-----------------------------------------------------------------------------------
  INSTANTIATE CLASS
-----------------------------------------------------------------------------------*/

$wpz_shortcode_generator = new wpzoom_Shortcode_Generator();
