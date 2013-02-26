<?php
/**
 * WPZOOM Global Theme Features
 *
 * @package WPZOOM
 * @subpackage ui
 */

class ui {
    public static function logo() {
        if (option::get('misc_logo_path')) {
            return esc_url(option::get('misc_logo_path'));
        } else {
            return get_template_directory_uri() . '/images/logo.png';
        }
    }

    /**
     * Includes rss link if is specified in theme options
     */
    public static function rss() {
        $feed = esc_attr(trim(option::get('misc_feedburner')));
        if (!$feed) {
            bloginfo('rss2_url');
        } else {
            echo option::get('misc_feedburner');
        }
    }

    /**
     * Smart pages title
     */
    public static function title() {
        if (option::get('seo_enable') == 'off') {
            bloginfo('name');
            wp_title('-');
            return;
        }
        
        if (is_home()) {
            if (option::get('seo_home_title') == 'Site Title - Site Description') echo get_bloginfo('name').option::get('title_separator').get_bloginfo('description');
            if (option::get('seo_home_title') == 'Site Description - Site Title') echo get_bloginfo('description').option::get('title_separator').get_bloginfo('name');
            if (option::get('seo_home_title') == 'Site Title') echo get_bloginfo('name');
        }
        
        #if the title is being displayed on single posts/pages
        if (is_single() || is_page()) {
            if (option::get('seo_posts_title') == 'Site Title - Page Title') echo get_bloginfo('name').option::get('title_separator').wp_title('',false,'');
            if (option::get('seo_posts_title') == 'Page Title - Site Title') echo wp_title('',false,'').option::get('title_separator').get_bloginfo('name');
            if (option::get('seo_posts_title') == 'Page Title') echo wp_title('',false,'');
        }
        
        #if the title is being displayed on index pages (categories/archives/search results)
        if (is_category() || is_archive() || is_search()) {
            if (option::get('seo_pages_title') == 'Site Title - Page Title') echo get_bloginfo('name').option::get('title_separator').wp_title('',false,'');
            if (option::get('seo_pages_title') == 'Page Title - Site Title') echo wp_title('',false,'').option::get('title_separator').get_bloginfo('name');
            if (option::get('seo_pages_title') == 'Page Title') echo wp_title('',false,'');
        }
    }

    /**
     * Prepares TimThumb's crop location
     */
     
    public static function getCropLocation($location = 'c') {

        switch (strtolower($location)) {
            case"center (default)":
            default:
            $zone = 'c';
            break;
            
            case"align top":
            $zone = 't';
            break;
            
            case"align bottom":
            $zone = 'b';
            break;
            
            case"align left":
            $zone = 'l';
            break;
            
            case"align right":
            $zone = 'r';
            break;
        }

        return $zone;
    }
    
    /**
     * Returns the link to image
     */
    public static function getImage($width, $height, $location = 'c') {
        global $blog_id;
    
        $image = get_the_image(array(
            'format' => 'array'
        ));
        
       if (isset($image['src']) && $image['src'] != '') {
            $image = $image['src'];
             
            $imageParts = explode('/files/', $image);
            
            $filehost = parse_url($image);
            $localhost = $_SERVER['HTTP_HOST'];
            
            if (isset($imageParts[1]) && ($filehost['host'] == $localhost)) {
                $image = '/blogs.dir/' . $blog_id . '/files/' . $imageParts[1];
            }
            
            $location = ui::getCropLocation($location);
            
            return get_template_directory_uri() . '/functions/theme/thumb.php?src=' . $image . '&amp;w=' . $width . '&amp;h=' . $height . '&amp;zc=1' . '&amp;a=' . $location;
        }
        
        return false;
    }
    
    public static function thumbIt($image, $width, $height, $return = false, $location = 'c') {
        if (!$image) {
            return false;
        }
    
        global $blog_id;
    
        $imageParts = explode('/files/', $image);
            
        $filehost = parse_url($image);
        $localhost = $_SERVER['HTTP_HOST'];
            
        if (isset($imageParts[1]) && ($filehost['host'] == $localhost)) {
            $image = '/blogs.dir/' . $blog_id . '/files/' . $imageParts[1];
        }
        
        $location = ui::getCropLocation($location);
            
         $url = get_template_directory_uri() . '/functions/theme/thumb.php?src=' . $image . '&amp;w=' . $width . '&amp;h=' . $height . '&amp;zc=1' . '&amp;a=' . $location;
        
        if ($return) {
            return $url;
        }
        
        echo $url;
    }
    
    /**
     * Return an array of categories 
     * if $parent is true returns only top level categories
     *
     * @param boolean $parent
     * @return array
     */
    public static function getCategories($parent = false) {
        global $wpdb, $table_prefix;
        
        $tb1 = $table_prefix . "terms";
        $tb2 = $table_prefix . "term_taxonomy";
        
        $qqq = $parent ? "AND $tb2" . ".parent = 0" : "";
        
        $q = "SELECT $tb1.term_id,$tb1.name,$tb1.slug FROM $tb1,$tb2 WHERE $tb1.term_id = $tb2.term_id AND $tb2.taxonomy = 'category' $qqq ORDER BY $tb1.name ASC";
        $q = $wpdb->get_results($q);
        
        foreach ($q as $cat) {
            $categories[$cat->term_id] = $cat->name;
        }

        return $categories;
    }

    /**
     * Returns an array of pages
     *
     * @return array
     */
    public static function getPages() {
        global $wpdb, $table_prefix;
        
        $tb1 = $table_prefix . "posts";
        
        $q = "SELECT $tb1.ID,$tb1.post_title FROM $tb1 WHERE $tb1.post_type = 'page' AND $tb1.post_status = 'publish' ORDER BY $tb1.post_title ASC";
        $q = $wpdb->get_results($q);
        
        foreach ($q as $pag) {
            $pages[$pag->ID] = $pag->post_title;
        }
        
        return $pages;
    }

    /**
     * Trims $moreText to $maxChars
     *
     * @param int $maxChars
     * @param string $moreText
     * @param string $stripteaser
     * @param string $morefile
     * @return void
     */
    public static function theContentLimit($maxChars, $moreText = '(more ...)', $stripteaser, $moreFile = '') {
        $content = get_the_content($moreText, $stripteaser, $moreFile);
        $content = apply_filters('the_content', $content);
        $content = str_replace(']]>', ']]&gt;', $content);
        $content = strip_tags($content);
        
        if (strlen($_GET['p']) > 0 && $thisshouldnotapply) {
            echo $content;
        } elseif ((strlen($content) > $maxChars) && ($espacio = strpos($content, " ", $maxChars))) {
            $content = substr($content, 0, $espacio);
            $content = $content;
            echo $content;
            echo "...";
        } else {
            echo $content;
        }
    }

    

    /**
     * WPZOOM javascript includer
     *
     * Includes every single file specified as argument
     *
     * @params string
     * @return void
     */
    public static function js() {
        $args = func_get_args();
        
        foreach ($args as $name) {
            echo '<script type="text/javascript" src="' . get_template_directory_uri() . '/js/' . $name . '.js"></script>' . "\n";
        }
    }
    
    /**
     * Checks if WordPress version is greater or equal to $is_ver
     * 
     * @param  string  $is_ver version to be checked
     * @return boolean
     */
    public static function is_wp_version($is_ver) {
        $wp_ver = explode('.', get_bloginfo('version'));
        $is_ver = explode('.', $is_ver);

        for($i = 0; $i <= count($is_ver); $i++) {
            if (!isset($wp_ver[$i])) {
                array_push($wp_ver, 0);
            }
        }

        foreach ($is_ver as $i => $is_val) {
            if ($wp_ver[$i] < $is_val) {
                return false;
            }
        }
        
        return true;
    }

    /**
     * Recognized font families
     * 
     * @param  string $id The unique field id
     * @return array      Fonts supported by theme
     */
    public static function recognized_font_families($id = 'global') {
        return apply_filters('wpzoom_recognized_font_families', array(
            'arial'     => 'Arial',
            'georgia'   => 'Georgia',
            'helvetica' => 'Helvetica',
            'palatino'  => 'Palatino',
            'tahoma'    => 'Tahoma',
            'times'     => '"Times New Roman", sans-serif',
            'trebuchet' => 'Trebuchet',
            'verdana'   => 'Verdana'
        ), $id);
    }

    /**
     * Recognized google web fonts
     */
    public static function recognized_google_webfonts_families($id = 'global') {
        return apply_filters('wpzoom_recognized_google_webfonts_families', array(
            array( 'separator' => "~ Sans Serif Fonts ~"),

            array( 'name' => "Open Sans", 'variant' => ':r,i,b,bi'),
            array( 'name' => "Open Sans Condensed", 'variant' => ':300,300italic'),
            array( 'name' => "Droid Sans", 'variant' => ':r,b'),
            array( 'name' => "Oswald", 'variant' => ':400,300,700'),
            array( 'name' => "PT Sans", 'variant' => ':r,b,i,bi'),
            array( 'name' => "Ubuntu", 'variant' => ':r,b,i,bi'),
            array( 'name' => "Yanone Kaffeesatz", 'variant' => ':r,b'),
            array( 'name' => "Lato", 'variant' => ':400,700,400italic'),
            array( 'name' => "Nunito", 'variant' => ''),
            array( 'name' => "Francois One", 'variant' => ''),


            array( 'separator' => "~ Serif Fonts ~"),
            array( 'name' => "Droid Serif", 'variant' => ':r,b,i,bi'),
            array( 'name' => "Lora", 'variant' => ''),
            array( 'name' => "Avro", 'variant' => ':400,700,400italic,700italic'),
            array( 'name' => "Bitter", 'variant' => ':400,700,400italic'),
            array( 'name' => "Merriweather", 'variant' => ''),
            array( 'name' => "Kreon", 'variant' => ':r,b'),
            array( 'name' => "Vollkorn", 'variant' => ':400italic,700italic,400,700'),
            array( 'name' => "PT Serif", 'variant' => ':r,b,i,bi'),
            array( 'name' => "Quattrocento", 'variant' => ''),
            array( 'name' => "Rokkitt", 'variant' => ':400,700'),

            array( 'separator' => "~ Others ~"),
            array( 'name' => "Lobster", 'variant' => ''),
            array( 'name' => "Changa One", 'variant' => ''),
            array( 'name' => "Shadows Into Light", 'variant' => ''),
            array( 'name' => "The Girl Next Door", 'variant' => ''),
            array( 'name' => "Crafty Girls", 'variant' => ''),
            array( 'name' => "Dancing Script", 'variant' => ''),
            array( 'name' => "Raleway", 'variant' => ':100'),
            array( 'name' => "Calligraffitti", 'variant' => ''),
            array( 'name' => "Gloria Hallelujah", 'variant' => ''),
            array( 'name' => "Cherry Cream Soda", 'variant' => ''),
        ), $id);
    }

    /**
     * Recognized font styles
     * 
     * @param  string $id The unique field id
     * @return array      Font styles supported by theme
     */
    public static function recognized_font_styles($id = 'global') {
        return apply_filters('wpzoom_recognized_font_styles', array(
            'normal'      => 'Normal',
            'italic'      => 'Italic',
            'bold'        => 'Bold',
            'bold-italic' => 'Bold/Italic'
        ), $id);
    }

    /**
     * WPZOOM public head
     */
    public static function head() {
        /**
         * Call WordPress head hook
         */
        wp_head();
    }
    
    /**
     * WPZOOM public footer
     */
    public static function footer() {
        /**
         * Call WordPress footer hook
         */
        wp_footer();
    }

}
