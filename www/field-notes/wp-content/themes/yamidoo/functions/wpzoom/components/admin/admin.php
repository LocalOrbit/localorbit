<?php
/**
 * WPZOOM_Admin
 *
 * @package WPZOOM
 * @subpackage Admin
 */

WPZOOM_Admin::init();

class WPZOOM_Admin {

    /**
     * Initialize wp-admin options page
     */
    public static function init() {
        if (isset($_GET['activated']) && $_GET['activated'] == 'true') {
            header('Location: admin.php?page=wpzoom_options');
        }

        if (isset($_GET['page']) && $_GET['page'] == 'wpzoom_options') {
            add_action('init', array('WPZOOM_Admin_Settings_Page', 'init'));
        }

        add_action('admin_menu', array(__CLASS__, 'register_admin_pages'));
        add_action('admin_footer', array(__CLASS__, 'activate'));

        add_action('wp_ajax_wpzoom_ajax_post',       array('WPZOOM_Admin_Settings_Page', 'ajax_options'));
        add_action('wp_ajax_wpzoom_widgets_default', array('WPZOOM_Admin_Settings_Page', 'ajax_widgets_default'));

        add_action('admin_print_scripts-widgets.php', array(__CLASS__, 'widgets_styling_script'));
        add_action('admin_print_scripts-widgets.php', array(__CLASS__, 'widgets_styling_css'));

        add_action('admin_print_scripts', array(__CLASS__, 'wpadmin_script'));
        // add_action('admin_print_styles',  array(__CLASS__, 'wpadmin_css'));
    }

    public static function widgets_styling_script() {
        wp_enqueue_script('wpzoom_widgets_styling', WPZOOM::$assetsPath . '/js/widgets-styling.js', array('jquery'));
    }

    public static function widgets_styling_css() {
        wp_enqueue_style('wpzoom_widgets_styling', WPZOOM::$assetsPath . '/css/widgets-styling.css');
    }

    public static function wpadmin_script() {
        wp_enqueue_script('zoom-wp-admin', WPZOOM::$assetsPath . '/js/wp-admin.js', array('jquery'), WPZOOM::$wpzoomVersion);
    }

    // public static function wpadmin_css() {
    //     wp_enqueue_style('zoom-wp-admin', WPZOOM::$assetsPath . '/css/wp-admin.css', array(), WPZOOM::$wpzoomVersion);
    // }
    
    public static function activate() {
        if (option::get('wpzoom_activated') != 'yes') {
            option::set('wpzoom_activated', 'yes');
            option::set('wpzoom_activated_time', time());
        } else {
            $activated_time = option::get('wpzoom_activated_time');
            if ((time() - $activated_time) < 2592000) {
                return;
            }
        }

        option::set('wpzoom_activated_time', time());
        require_once(WPZOOM_INC . '/pages/welcome.php');
    }
    
    public static function admin() {
        require_once(WPZOOM_INC . '/pages/admin.php');
    }
    
    public static function themes() {
        require_once(WPZOOM_INC . '/pages/themes.php');
    }
    
    public static function update() {
        require_once(WPZOOM_INC . '/pages/update.php');
    }

    /**
     * WPZOOM custom menu for wp-admin
     */
    public static function register_admin_pages() {
        add_object_page ( 'Page Title', 'WPZOOM', 'manage_options','wpzoom_options', 'WPZOOM_Admin::admin', WPZOOM::$assetsPath . '/images/shortcode-icon.png');
        
        add_submenu_page('wpzoom_options', 'WPZOOM',            'Theme Options',     'manage_options', 'wpzoom_options', array(__CLASS__, 'admin'));
        
        if (option::is_on('framework_update_enable')) {
            add_submenu_page('wpzoom_options', 'Update Framework', 'Update Framework', 'update_themes', 'wpzoom_update', array(__CLASS__, 'update'));
        }

        if (option::is_on('framework_newthemes_enable') && !wpzoom::$tf) {
            add_submenu_page('wpzoom_options', 'New Themes',     'New Themes',     'manage_options', 'wpzoom_themes', array(__CLASS__, 'themes'));
        }
    }
}
