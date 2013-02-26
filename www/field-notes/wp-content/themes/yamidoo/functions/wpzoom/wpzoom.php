<?php
/**
 * WPZOOM Framework Core & Heart
 *
 * @package WPZOOM
 */

class WPZOOM {
    public static $wpzoomVersion = '1.3.7';
    public static $wpzoomPath;
    
    public static $assetsPath;
    
    public static $theme_raw_name;

    public static $themeName;
    public static $themePath;
    public static $themeVersion;
    
    public static $config;
    public static $themeData;

    public static $tf;
    
    /**
     * Initializes WPZOOM framework
     *
     * @return void
     */
    public static function init() {
        self::load_theme_data();
        option::init();

        add_action('after_setup_theme', array('option', 'init'), 1);
        add_action('after_setup_theme', array(__CLASS__, 'locale'));

        add_action('admin_bar_menu', array(__CLASS__, 'add_node_to_admin_bar'), 1000);
    }
    
    /**
     * WordPress localization
     *
     * @return void
     */
    public static function locale() {
        load_theme_textdomain('wpzoom', get_template_directory() . '/languages');
        
        $locale     = get_locale();
        $localeFile = get_template_directory() . "/languages/$locale.php";
        
        if (is_readable($localeFile)) {
            require_once($localeFile);
        }
    }
    
    /**
     * Load and run theme config file
     *
     * @return boolean
     */
    public static function get_config() {
        return require_once(FUNC_INC . "/theme/config.php");
    }

    public static function get_wpzoom_root() {
        return dirname(__FILE__);
    }

    /**
     * Loads theme data and configs
     *
     * @return void
     */
    private static function load_theme_data() {
        self::$config = self::get_config();

        /*
         * WordPress 3.4 deprecated `get_theme_data()` so we must use
         * `wp_get_theme()` which returns an instance of `WP_Theme`
         */
        if (function_exists('wp_get_theme')) {
            self::$themeData    = wp_get_theme();
            self::$themeVersion = self::$themeData->version;
            self::$themeName    = self::$themeData->name;
        } else {
            self::$themeData    = get_theme_data(get_template_directory() . '/style.css');
            self::$themeVersion = self::$themeData['Version'];
            self::$themeName    = self::$config['name'];
        }
        
        self::$theme_raw_name = basename(get_template_directory());
        self::$themePath      = get_template_directory_uri();
        self::$wpzoomPath     = self::$themePath . "/functions/wpzoom";
        
        self::$assetsPath = WPZOOM::$wpzoomPath . '/assets';

        self::$tf = isset(self::$config['tf_url']);
    }
    
    /**
     * Add Theme Options to Admin Bar
     */
    public static function add_node_to_admin_bar($wp_admin_bar) {
        if (!is_super_admin() || !is_admin_bar_showing()) return;

        $wp_admin_bar->add_menu(array('id' => 'wpzoom', 'title' => __( 'WPZOOM', 'wpzoom' ), 'href' => admin_url('admin.php?page=wpzoom_options')));
        $wp_admin_bar->add_menu(array('id' => 'wpzoom-theme-options', 'parent' => 'wpzoom', 'title' => __( 'Theme Options', 'wpzoom' ), 'href' => admin_url('admin.php?page=wpzoom_options')));
        
        if (option::is_on('framework_update_enable')) {
            $wp_admin_bar->add_menu(array('id' => 'wpzoom-framework-update', 'parent' => 'wpzoom', 'title' => __( 'Framework Update', 'wpzoom' ), 'href' => admin_url('admin.php?page=wpzoom_update')));
        }
    }
}
