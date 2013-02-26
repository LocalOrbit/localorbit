<?php

if (function_exists('add_image_size' )) { 
    add_image_size('wzslider-thumbnail', 9999, 55);
}

class wzslider {
    public static $atts;
    public static $scriptAtts;

    public static $galleries = array();

    static public function init($atts, $content = null, $code = '') {
        global $post;

        // Shortcode defaults
        $default_atts = array(
            'autoplay' => 'false',
            'interval' => '3000',
            'info' => 'false',
            'height'   => '500',
            'lightbox' => 'false',
            'clicknext' => 'true',
            'transition' => 'fade'
         );

        $atts = shortcode_atts($default_atts, $atts);

        if ($atts['height'] != '500') {
            self::$scriptAtts.= "height: {$atts['height']},";
        } else {
            self::$scriptAtts.= "height: 500,";
        }
        
        if ($atts['info'] != 'false') {
            self::$scriptAtts.= "showInfo: true,";
        } else {
            self::$scriptAtts.= "showInfo: false,";
        }
 
        if ($atts['lightbox'] != 'true') {
            self::$scriptAtts.= "clicknext: true,";
        } 

        if ($atts['lightbox'] != 'false') {
            self::$scriptAtts.= "lightbox: true,";
        } else {
            self::$scriptAtts.= "lightbox: false,";
        }

        if ($atts['autoplay'] != 'false') {
            self::$scriptAtts.= "autoplay: {$atts['interval']},";
        } else {
            self::$scriptAtts.= "autoplay: false,";
        }

        if ($atts['transition'] != 'fade') {
            self::$scriptAtts.= "transition: {$atts['transition']}";
        } else {
            self::$scriptAtts.= "transition: 'fade'";
        }

        $args = array(
            'order'          => 'ASC',
            'orderby'        => 'menu_order',
            'post_type'      => 'attachment',
            'post_parent'    => $post->ID,
            'post_mime_type' => 'image',
            'post_status'    => null,
            'numberposts'    => -1,
        );

        $attachments = get_posts($args);

        if ($attachments) {       
            $content = '<div id="galleria-' . $post->ID . '">';

            foreach ($attachments as $attachment) {
                $url = wp_get_attachment_image_src($attachment->ID, 'large');
                $url = $url[0];

                $thumb = wp_get_attachment_image_src($attachment->ID, 'wzslider-thumbnail');
                $thumb = $thumb[0];

                $alt = $attachment->post_content;
                $title = apply_filters('the_title', $attachment->post_title);
            
                $content .= '<a href="' . $url . '"><img title="' . $title . '" alt="' . $alt . '" src="' . $thumb . '"></a>';
            }
            
            $content .= '</div>';
        }

        self::$galleries[] = array(
            "id" => $post->ID,
            "options" => self::$scriptAtts
        );

        self::$scriptAtts = "";
        self::$atts = "";

        return $content;
    }

    static public function loadStatic() {
        wp_enqueue_script('galleria', WPZOOM::$assetsPath . '/js/galleria.js', array('jquery'), null, true); 
        wp_enqueue_script('wzslider', WPZOOM::$assetsPath . '/js/wzslider.js', array('jquery'), null, true);
     }

    static public function loadStyles() {
        wp_register_style('wzslider', WPZOOM::$assetsPath . '/css/wzslider.css');
        wp_enqueue_style('wzslider');
    }

    static public function galleriaScript() {
        $script = '<script>(function($){$(document).ready(function(){';

        foreach (self::$galleries as $galleria) {
            $id = $galleria['id'];
            $options = $galleria['options'];
            $script.= "$('#galleria-$id').galleria({{$options}});";
        }
       
        $script.= '});})(jQuery);</script>'; 

        // fire
        echo $script;
    }

    static public function check($posts) {
        if (empty($posts)) {
            return $posts;
        }

        $found = false;

        foreach ($posts as $post) {
            if (stripos($post->post_content, '[wzslider') !== false) {
                $found = true;
            }

            break;
        }
        
        $found = true;

        if ($found) {            
            add_action('wp_footer', 'wzslider::galleriaScript');

            add_action('wp_enqueue_scripts', 'wzslider::loadStatic');
            add_action('wp_enqueue_scripts', 'wzslider::loadStyles');
        }

        return $posts;
    }
}

add_shortcode('wzslider', 'wzslider::init');
add_action('the_posts', 'wzslider::check');

// Adding shortcode button to TynyMCE editor
function add_slider_button() {
    if (!current_user_can('edit_posts') && ! current_user_can('edit_pages')) {
        return;   
    }

    if (get_user_option('rich_editing') == 'true') {
        add_filter('mce_external_plugins', 'add_slider_tinymce_plugin');
        add_filter('mce_buttons', 'register_slider_button');
    }
}
add_action('init', 'add_slider_button');


function register_slider_button($buttons) {
   array_push($buttons, "|", "wzslider");

   return $buttons;
}

function add_slider_tinymce_plugin($plugin_array) {
   $plugin_array['wzslider'] = WPZOOM::$assetsPath . '/js/wzslider_button.js';

   return $plugin_array;
}

function wzslider_refresh_mce($ver) {
  $ver += 3;

  return $ver;
}
add_filter( 'tiny_mce_version', 'wzslider_refresh_mce');
