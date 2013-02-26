<?php

class WPZOOM_Admin_Settings_Page {
    public static function init() {
        if (isset($_POST['action']) && $_POST['action'] == 'reset') {
            option::reset();
        }
        
        add_action('admin_enqueue_scripts',             array(__CLASS__, 'load_assets'));
        add_action('admin_print_styles',                array(__CLASS__, 'fonts_families_preview'));

        add_action('load-toplevel_page_wpzoom_options', array(__CLASS__, 'contextual_help'));

        add_filter('wpzoom_field_misc_debug',           array(__CLASS__, 'get_debug_text'));
        add_filter('wpzoom_field_misc_import',          array('option', 'get_empty'));
        add_filter('wpzoom_field_misc_import_widgets',  array('option', 'get_empty'));
        add_filter('wpzoom_field_misc_export',          array('option', 'export_options'));
        add_filter('wpzoom_field_misc_export_widgets',  array('option', 'export_widgets'));
    }

    public static function load_assets() {
        wp_enqueue_script('wpzoom-options', WPZOOM::$assetsPath . '/js/zoomAdmin.js', array('jquery', 'thickbox'), WPZOOM::$wpzoomVersion);
        wp_enqueue_style('wpzoom-options', WPZOOM::$assetsPath . '/options.css', array(), WPZOOM::$wpzoomVersion);
        
        // Register the colourpicker JavaScript.
        wp_register_script( 'wpz-colourpicker', WPZOOM::$assetsPath . '/js/colorpicker.js', array( 'jquery' ), WPZOOM::$wpzoomVersion, true ); // Loaded into the footer.
        wp_enqueue_script( 'wpz-colourpicker' );

        // Register the colourpicker CSS.
        wp_register_style( 'wpz-colourpicker', WPZOOM::$assetsPath . '/css/colorpicker.css', array(), WPZOOM::$wpzoomVersion );
        wp_enqueue_style( 'wpz-colourpicker' );
    }

    /**
     * Menu for theme/framework options page
     */
    public static function menu() {
        $menu = option::$evoOptions['menu'];
        $out = '<ul class="tabs">';

        foreach ($menu as $item) {
            $class = strtolower(str_replace(" ", "_", preg_replace("/[^a-zA-Z0-9\s]/", "", $item['name'])));
            
            $out.= '<li class="' . $class . ' wz-parent" id="wzm-' . $class . '"><a href="#tab' . $item['id'] . '">' . $item['name'] . '</a><em></em>';
            $out.= '<ul>';
            foreach (option::$evoOptions['id' . $item['id']] as $submenu) {
                if ($submenu['type'] == 'preheader') {
                    $name = $submenu['name'];
                    
                    $stitle = 'wpz_' . substr(md5($name), 0, 8);    
                    
                    $out.= '<li class="sub"><a href="#' . $stitle . '">' . $name . '</a></li>';
                }    
            }
            $out.= '</ul>';
            $out.= '</li>';
        }
        
        $out.= '</ul>';
        
        echo $out;
    }
    
    public static function content() {
        $options = option::$evoOptions;
        $tabs = array();

        unset($options['menu']);

        $settings_ui = new WPZOOM_Admin_Settings_Interface;

        foreach ($options as $tab_id => $tab_content) {
            $tab_id = preg_replace("/[^0-9]/", '', $tab_id);
            $settings_ui->add_tab($tab_id);

            foreach ($tab_content as $field) {
                $defaults_args = array(
                    'id'    => '',
                    'type'  => '',
                    'name'  => '',
                    'std'   => '',
                    'desc'  => '',
                    'value' => '',
                    'out'   => ''
                );

                $args = wp_parse_args($field, $defaults_args);
                extract($args);

                if (option::get($id) != "" && !is_array(option::get($id))) {
                    $value = $args['value'] = stripslashes(option::get($id));
                } else {
                    $value = $args['value'] = $std;
                }

                $settings_ui->add_field($type, array($args));
            }

            $settings_ui->end_tab();
            $settings_ui->flush_content(); 
        }

    }

    public static function contextual_help() {
        if (!method_exists('WP_Screen', 'add_help_tab')) return;

        $screen = get_current_screen();

        $screen->add_help_tab(
            array(
                 'id'       => 'zoom-welcome'
                ,'title'    => 'Overview'
                ,'content'  => '<p>Some themes provide customization options that are grouped together on a Theme Options screen. If you change themes, options may change or disappear, as they are theme-specific. </p><p>Your current theme is running on <a href="http://www.wpzoom.com/framework-tour/" target="_blank">ZOOM Framework</a>. The <strong>ZOOM framework</strong> is designed to ease the process of customizing WPZOOM themes. The many options available allow you to change almost every aspect of your WPZOOM theme without needing to know how to write any sort of code. The framework has also been designed to stay as consistent as possible across all WPZOOM themes so you can take your knowledge from one theme to another with ease.
</p>'
            )
        );

        $sidebar = '<p><strong>' . __( 'For more information:', 'wpzoom' ) . '</strong></p>' .
        '<p>' . __( '<a href="http://www.wpzoom.com/support/documentation" target="_blank">Documentation and Tutorials</a>', 'wpzoom' ) . '</p>' .
        '<p>' . __( '<a href="http://www.wpzoom.com/forum/" target="_blank">Support Forums</a>', 'wpzoom' ) . '</p>';

        $screen->set_help_sidebar( $sidebar );


        $screen->add_help_tab(
            array(
                 'id'       => 'zoom-seo'
                ,'title'    => 'About SEO'
                ,'content'  => '<p>The SEO options (or Search Engine Optimization options) help make your site more visible to major search engines like Google, Bing, etc. By simply filling in the necessary fields you can ensure people will be able to easily find your site no matter where they are coming from.
</p>'
            )
        );
 
        $screen->add_help_tab(
            array(
                 'id'       => 'zoom-import'
                ,'title'    => 'Using Import/Export'
                ,'content'  => "<p>The <Strong>ZOOM Framework</strong> has the ability to import and export various theme and widget settings. This allows you to easily transfer specific setups between different sites and also to backup settings so you won't ever lose them.</p>"
            )
        );
 
    }

    /**
     * Handle Ajax calls for option updates.
     *
     * @return void
     */
    public static function ajax_options() {
        parse_str($_POST['data'], $data);

        check_ajax_referer('wpzoom-ajax-save', '_ajax_nonce');
        
        if ($data['misc_import']) {
            option::setupOptions($data['misc_import'], true);
            die('success');
        }
        
        if ($data['misc_import_widgets']) {
            option::setupWidgetOptions($data['misc_import_widgets'], true);
            die('success');
        }

        foreach(option::$options as $name => $null) {
            $ignored = array('misc_export', 'misc_export_widgets', 'misc_debug');
            if (in_array($name, $ignored)) continue;

            if (isset($data[$name])) {
                $value = $data[$name];
                
                if (!is_array($data[$name])) {
                    $value = stripslashes($value);
                }

                option::set($name, $value);
            } else {
                option::set($name, 'off');
            }
        }

        die('success');
    }
    
    /**
     * Handle Ajax calls for widgets default.
     *
     * @return void
     */
    public static function ajax_widgets_default() {
        check_ajax_referer('wpzoom-ajax-save', '_ajax_nonce');
        
        $settingsFile = THEME_INC . "/widgets/default.json";
        
        if (file_exists($settingsFile)) {
            $settings = file_get_contents($settingsFile);

            option::setupWidgetOptions($settings, true);
        }
        
        die('success');
    }

    /**
     * Generates CSS to preview Typography Fonts families
     * 
     * @return void
     */
    public static function fonts_families_preview() {
        if (!option::is_on('framework_fonts_preview')) {
            return;
        }

        $css = '';
        $fonts = '';

        $font_families = ui::recognized_font_families();
        $google_font_families = ui::recognized_google_webfonts_families();

        foreach ($font_families as $slug => $font) {
            $css.= '.selectBox-dropdown-menu a[rel=' . $slug . ']{font-family:' . $font . ';}';
        }

        foreach ($google_font_families as $font) {
            if (isset($font['separator'])) continue;

            $slug = str_replace(' ', '-', strtolower($font['name']));
            $css.= '.selectBox-dropdown-menu a[rel=' . $slug . ']{font-family:' . $font['name'] . ';}';
            $fonts.= $font['name'] . '|';
        }

        $fonts = str_replace( " ","+",$fonts);
        $google_css = '@import url("http'. (is_ssl() ? 's' : '') .'://fonts.googleapis.com/css?family=' . $fonts . "\");\n";
        $google_css = str_replace('|"', '"', $google_css);

        echo '<style type="text/css">';
            echo $google_css;
            echo $css;
        echo '</style>';
    }
    
    /**
     * Get debug information
     *
     * Usually when someone have a problem, for a faster resolve we need to
     * know what theme version is, what framework is running and what WordPress
     * is installed. Also most problems are related to 3rd party plugins,
     * so let's also keep track them.
     *
     * This information is private and is displayed only on framework admin
     * page `/wp-admin/admin.php?page=wpzoom_options`
     *
     * @return string
     */
    public static function get_debug_text() {
        // we'll need access to WordPress version
        global $wp_version;

        $debug  = "\n# Debug\n";

        // site url, theme info
        $debug .= "\nSite URL: "          . get_home_url();
        $debug .= "\nTheme Name: "        . WPZOOM::$themeName;
        $debug .= "\nTheme Version: "     . WPZOOM::$themeVersion;
        $debug .= "\nWPZOOM Version: "    . WPZOOM::$wpzoomVersion;
        $debug .= "\nWordPress Version: " . $wp_version;

        $debug .= "\n\n# Plugins\n";

        // active plugins
        $active_plugins = get_option('active_plugins');

        // in order to be able to intersect plugins vs. active plugins by
        // keys, we need to change keys with values
        $active_plugins = array_flip($active_plugins);

        if (!function_exists('get_plugins')) {
            include('wp-admin/includes/plugin.php');
        }

        // get all installed plugins
        $plugins = get_plugins();

        // select only active plugins
        $active_plugins = array_intersect_key($plugins, $active_plugins);

        $i = 1;
        if ($active_plugins && is_array($active_plugins)) {
            // if there are active plugins, get their name, version.
            foreach ($active_plugins as $id => $plugin) {
                $debug .= "\n$i. " . $plugin['Name'] . " " . $plugin['Version'];
                $debug .= "\n   "  . $id;
                $i++;
            }
        }

        // return debug text
        return $debug;
    }  
}
