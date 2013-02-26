<?php

class WPZOOM_Admin_Settings_Interface {
    private $settings_fields;
    private $content = '';

    public function __construct() {
        $this->settings_fields = new WPZOOM_Admin_Settings_Fields();
    }

    public function add_field($type, $args) {
        $type = str_replace('-', '_', $type);
        
        if (!method_exists($this->settings_fields, $type)) {
            return false;
        }

        $skipfor = array('preheader', 'startsub', 'endsub');
        $skipforend = array('endsub');
        $skipdeprecated =  array(
            'framework_theme_update_notification_enable',
            'framework_newthemes_enable'
        );

        if (wpzoom::$tf && in_array($args[0]['id'], $skipdeprecated)) {
            return false;
        }

        if (!in_array($type, $skipfor)) {
            $this->content.= '<div class="wpz_option_container clear">';
        }

        $this->content.= call_user_func_array(array($this->settings_fields, $type), $args);

        if (!in_array($type, $skipforend)) {
             $this->content.= '<div class="cleaner"></div>';
        }

        if (!in_array($type, $skipfor)) {
            $this->content.= '</div>';
        }
    }

    public function get_content() {
        return $this->content;
    }

    public function flush_content() {
        echo $this->content;
        $this->content = '';
    }

    public function add_tab($rid) {
        $this->content .= '<div id="tab'.$rid.'" class="tab_content">';
        $this->content .= '<div class="zoomForms">';
        $this->settings_fields->first = true;
    }

    public function end_tab() {
        $this->content .= '</div>'; // end .zoomForms
        $this->content .= '</div>';
        $this->content .= '<div class="clear"></div></div>';
    }
}
