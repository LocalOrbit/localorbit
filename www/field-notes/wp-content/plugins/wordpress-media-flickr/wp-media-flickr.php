<?php
/*
Plugin Name: Wordpress Media Flickr
Plugin URI: http://factage.com/yu-ji/tag/wp-media-flickr
Description: You can post with flickr photo, on visual editor toolbar.<br />It's very interactive interface than other plugins.
Author: yu-ji
Version: 1.1.2
Author URI: http://factage.com/yu-ji
*/

class WpMediaFlickr {
    var $pluginURI = null;
    var $settings = array();
    var $default_settings = array(
        'username' => '',
        'user_id' => '',
        'photo_link' => '0',
        'link_rel' => '',
        'link_class' => '',
    );

    var $flickr_auth_url = 'http://flickr.com/services/auth/?';
    var $flickr_api_url = 'http://api.flickr.com/services/rest/?';

    var $flickr_api_key = '448e0602a1f453c0e668e701f4bf8924';
    var $flickr_api_secret = '2e5bb6215c1c3061';
    var $flickr_api_frob = null;

    function WpMediaFlickr() {
        load_plugin_textdomain('wp-media-flickr', PLUGINDIR.'/'.dirname(plugin_basename(__FILE__)));

        $this->settings = get_option(get_class($this));

        $flush_settings = false;
        foreach($this->default_settings as $key => $value) {
            if(!isset($this->settings[$key])) {
                $this->settings[$key] = $value;
                $flush_settings = true;
            }
        }
        if($flush_settings) {
            $this->update_settings();
        }

        $this->pluginURI = get_option('siteurl').'/wp-content/plugins/'.dirname(plugin_basename(__FILE__));

        add_action('media_buttons', array($this, 'addMediaButton'), 20);
        add_action('media_upload_flickr', array($this, 'media_upload_flickr'));
        add_action('admin_menu', array(&$this, 'addAdminMenu'));

        // check auth enabled
        if(!function_exists('curl_init') && !ini_get('allow_url_fopen')) {
            $this->disabled = true;
        }
    }

    function addMediaButton() {
        global $post_ID, $temp_ID;
        $uploading_iframe_ID = (int) (0 == $post_ID ? $temp_ID : $post_ID);
        $media_upload_iframe_src = "media-upload.php?post_id=$uploading_iframe_ID";

        $media_flickr_iframe_src = apply_filters('media_flickr_iframe_src', "$media_upload_iframe_src&amp;type=flickr&amp;tab=flickr");
        $media_flickr_title = __('Add Flickr photo', 'wp-media-flickr');

        echo "<a href=\"{$media_flickr_iframe_src}&amp;TB_iframe=true&amp;height=500&amp;width=640\" class=\"thickbox\" title=\"$media_flickr_title\"><img src=\"{$this->pluginURI}/media-flickr.gif\" alt=\"$media_flickr_title\" /></a>";
    }

    function modifyMediaTab($tabs) {
        return array(
            'flickr' =>  __('Flickr photo', 'wp-media-flickr')
        );
    }

    function addAdminMenu() {
        if (function_exists('add_options_page')) {
            $plugin_basename = dirname(plugin_basename(__FILE__));
            add_options_page(__('Media Flickr', 'wp-media-flickr'), __('Media Flickr', 'wp-media-flickr'), 8, dirname(__FILE__)."/wp-media-flickr-admin.php");
        }
    }

    function media_upload_flickr() {
        wp_iframe('media_upload_type_flickr');
    }

    function update_settings($settings=null){
        if($settings) {
            foreach($settings as $key => $val) {
                $this->settings[$key] = $val;
            }
        }

        // Boolean values
        // if (!empty($settings['isafter']))
        //  $this->settings['isafter'] = true;
        // else
        //  $this->settings['isafter'] = false;

        $_settings = array();
        foreach($this->settings as $key => $value) {
            if(isset($this->default_settings[$key])) {
                $_settings[$key] = $value;
            }
        }

        update_option(get_class($this), $_settings);
    }

    function flickrGetToken() {
        $params = array(
            'api_key' => $this->flickr_api_key,
            'format' => 'php_serial',
            'frob' => $this->flickrGetFrob(),
            'method' => 'flickr.auth.getToken',
            'api_sig' => $this->flickrGenerateSignature('format', 'php_serial', 'frob', $this->flickrGetFrob(), 'method', 'flickr.auth.getToken'),
        );
        $result = unserialize($this->get_contents($this->flickr_api_url.http_build_query($params)));
        if(!empty($result) && $result['stat'] == 'ok') {
            return $result;
        }else{
            return null;
        }
    }

    function flickrGetFrob() {
        if(empty($this->flickr_api_frob)) {
            $params = array(
                'api_key' => $this->flickr_api_key,
                'method' => 'flickr.auth.getFrob',
                'format' => 'php_serial',
                'api_sig' => $this->flickrGenerateSignature('format', 'php_serial', 'method', 'flickr.auth.getFrob'),
            );
            $result = unserialize($this->get_contents($this->flickr_api_url.http_build_query($params)));
            if(!empty($result) && $result['stat'] == 'ok') {
                $this->flickr_api_frob = $result['frob']['_content'];
            }
        }
        return $this->flickr_api_frob;
    }

    function flickrGetAuthUrl() {
        $params = array(
            'api_key' => $this->flickr_api_key,
            'frob' => $this->flickrGetFrob(),
            'perms' => 'read',
            'api_sig' => $this->flickrGenerateSignature('frob', $this->flickrGetFrob(), 'perms', 'read'),
        );
        return $this->flickr_auth_url.http_build_query($params);
    }

    function flickrGenerateSignature() {
        $args = func_get_args();
        $raws = array(
            $this->flickr_api_secret,
            'api_key',
            $this->flickr_api_key,
        );
        return md5(join('', $raws).join('', $args));
    }

    function get_contents($url) {
        if(function_exists('curl_init')) {
            $ch = curl_init();
            $timeout = 5; // set to zero for no timeout
            curl_setopt ($ch, CURLOPT_URL, $url);
            curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
            $file_contents = curl_exec($ch);
            curl_close($ch);
            return $file_contents;
        }else{
            return file_get_contents($url);
        }
    }
}

function media_upload_type_flickr() {
    global $wpdb, $wp_query, $wp_locale, $type, $tab, $post_mime_types, $mediaFlickr;

    add_filter('media_upload_tabs', array($mediaFlickr, 'modifyMediaTab'));

    media_upload_header();
?>
<style type="text/css">
h3 {
    margin: 0px;
}
.flickr_photo {
    width: 90px;
    padding: 5px 7px;
    float: left;
    height: 110px;
}
.flickr_image {
    border: 0px;
    width: 75px;
    height: 75px;
    cursor: pointer;
}
.flickr_title {
    font-size: 80%;
    cursor: pointer;
    padding-top: 2px;
}
#search-filter label {
    display: inline;
    font-size: 80%;
}
#pager {
}
#prev_page {
    display: none;
    font-weight: bold;
    float: left;
    padding-bottom: 10px;
}
#next_page {
    display: none;
    font-weight: bold;
    float: right;
    padding-bottom: 10px;
}
#pages {
    font-size: 70%;
    font-weight: normal;
}
#items {
    text-align: center;
}
form input {
    vertical-align: middle;
}
#put_dialog {
    display: none;
    position: absolute;
    border: 1px solid #888;
    background-color: #fff;
    top: 120px;
    left: 110px;
    padding: 10px;
}
#put_dialog div{
    padding-top: 10px;
}
#put_background {
    position: absolute;
    display: none;
    top: 0px;
    left: 0px;
    width: 100%;
    height: 100%;
    background-color: #fff;
    filter:alpha(opacity=75); /*IE*/
    -moz-opacity:0.75; /*FF*/
    opacity:0.75;
}
#alignment_preview,
#size_preview {
    text-align: center;
}
#buttons {
    text-align: center;
}
#alignments {
    padding-left: 40px;
}
#sizes {
    padding-left: 20px;
}
#sizes div {
    padding: 0px;
}
#select_size {
    float: left;
    width: 200px;
}
#select_alignment {
    float: left;
    width: 200px;
}
#options {
    clear: both;
    text-align: center;
}

select#photoset {
    width: 170px;
    vertical-align: middle;
    padding: 0px;
    display: none;
}
div#div_size_o_disabled {
    display: none;
    color: #888;
}
h3 {
    padding-top: 10px;
}
/* clearfix */
.pkg:after{
    content: ".";
    display: block;
    clear: both;
    height: 0px;
    visibility:hidden;
}
.pkg{ display: inline-block; }
/* no ie mac \*/
* html .pkg{ height: 1%; }
.pkg{ display: block; }
/* */
</style>
<form method="get" class="media-upload-form type-form" onsubmit="return false">
    <input type="hidden" name="type" value="<?php echo $type ?>" />
    <input type="hidden" name="tab" value="<?php echo $tab ?>" />
    <div id="search-filter">
        <?php _e('Search:', 'wp-media-flickr') ?>
        <input type="text" id="flickr_search_query" />
        <?php if(!empty($mediaFlickr->settings['username'])) { ?>
        <select id="photoset" name="photoset">
        </select>
        <input type="radio" id="flickr_search_0" name="flickr_search" class="searchTypes" value="own" checked="checked"/><label for="flickr_search_0"><?php _e('Your Photos', 'wp-media-flickr') ?></label>
        <input type="radio" id="flickr_search_1" name="flickr_search" class="searchTypes" value="sets"/><label for="flickr_search_1"><?php _e('Your Sets', 'wp-media-flickr') ?></label>
        <input type="radio" id="flickr_search_2" name="flickr_search" class="searchTypes" value="everyone"/><label for="flickr_search_2"><?php _e('Everyone\'s Photos', 'wp-media-flickr') ?></label>
        <?php } ?>
        <input type="submit" onclick="mediaFlickr.searchPhoto(0)" value="<?php _e('Search photo', 'wp-media-flickr'); ?>" class="button" />
    </div>
    <h3><?php _e('Flickr photos', 'wp-media-flickr') ?><span id="pages"></span></h3>
    <div id="pager">
        <div id="prev_page">
            <a href="javascript:void(0)" onclick="return mediaFlickr.searchPhoto(-1)"><?php _e('&laquo; Prev page', 'wp-media-flickr') ?></a>
        </div>
        <div id="next_page">
            <a href="javascript:void(0)" onclick="return mediaFlickr.searchPhoto(+1)"><?php _e('Next page &raquo;', 'wp-media-flickr') ?></a>
        </div>
        <br style="clear: both;" />
    </div>
    <div id="items" class="pkg">
    </div>
</form>
<div id="put_background"></div>
<form onsubmit="return false" id="put_dialog">
    <div id="select_size">
        1. <?php _e('Select size of photo', 'wp-media-flickr') ?>
        <div id="size_preview"><img id="size_image" rel="none" src="<?php echo $mediaFlickr->pluginURI ?>/size_t.png" alt=""/></div>
        <div id="sizes">
            <div id="div_size_sq"><input type="radio" id="size_sq" name="size" value="size_sq" /> <label for="size_sq"><?php _e('Square', 'wp-media-flickr') ?> (75 x 75)</label></div>
            <div id="div_size_t"><input type="radio" id="size_t" name="size" value="size_t" /> <label for="size_t"><?php _e('Thumbnail', 'wp-media-flickr') ?> (100 x 75)</label></div>
            <div id="div_size_s"><input type="radio" id="size_s" name="size" value="size_s" /> <label for="size_s"><?php _e('Small', 'wp-media-flickr') ?> (240 x 180)</label></div>
            <div id="div_size_m"><input type="radio" id="size_m" name="size" value="size_m" /> <label for="size_m"><?php _e('Medium', 'wp-media-flickr') ?> (500 x 375)</label></div>
            <div id="div_size_l"><input type="radio" id="size_l" name="size" value="size_l" /> <label for="size_l"><?php _e('Large', 'wp-media-flickr') ?> (1024 x 768)</label></div>
            <div id="div_size_o"><input type="radio" id="size_o" name="size" value="size_o" /> <label for="size_o"><?php _e('Original', 'wp-media-flickr') ?></label></div>
            <div id="div_size_o_disabled"><input type="radio" id="size_o" name="size" value="size_o" disabled="disabled"/> <?php _e('Original', 'wp-media-flickr') ?><?php _e('(not permitted)', 'wp-media-flickr') ?></div>
        </div>
    </div>
    <div id="select_alignment">
        2. <?php _e('Select alignment of photo', 'wp-media-flickr') ?>
        <div id="alignment_preview"><img id="alignment_image" rel="none" src="<?php echo $mediaFlickr->pluginURI ?>/alignment_none.png" alt=""/></div>
        <div id="alignments">
            <input type="radio" id="alignment_none" name="alignment" value="none" /> <label for="alignment_none"><?php _e('Default', 'wp-media-flickr') ?></label><br />
            <input type="radio" id="alignment_left" name="alignment" value="left" /> <label for="alignment_left"><?php _e('Left', 'wp-media-flickr') ?></label><br />
            <input type="radio" id="alignment_center" name="alignment" value="center" /> <label for="alignment_center"><?php _e('Center', 'wp-media-flickr') ?></label><br />
            <input type="radio" id="alignment_right" name="alignment" value="right" /> <label for="alignment_right"><?php _e('Right', 'wp-media-flickr') ?></label><br />
        </div>
    </div>
    <div id="options">
        <input type="checkbox" id="continue_insert" name="continue_insert" value="1" />
        <label for="continue_insert"><?php _e('Continue to insert other photo.', 'wp-media-flickr') ?></label><br />
    </div>
    <div id="buttons">
        <input type="button" value="<?php _e('Cancel', 'wp-media-flickr') ?>" onclick="mediaFlickr.cancelInsertImage()" class="button"/>
        <input type="submit" value="<?php _e('Insert', 'wp-media-flickr') ?>" onclick="mediaFlickr.insertImage()" class="button"/>
    </div>
</form>
<script type="text/javascript" src="<?php echo $mediaFlickr->pluginURI ?>/wp-media-flickr.js"></script>
<script type="text/javascript">
<!--
var is_msie = /*@cc_on!@*/false;

var plugin_uri = '<?php echo $mediaFlickr->pluginURI ?>';
var flickr_api_url = '<?php echo $mediaFlickr->flickr_api_url ?>';

var flickr_user_id = '<?php echo !empty($mediaFlickr->settings['user_id']) ? $mediaFlickr->settings['user_id'] : '' ?>';
var flickr_api_key = '<?php echo $mediaFlickr->flickr_api_key ?>';
var flickr_errors = {
    0: "<?php _e('Not found photo', 'wp-media-flickr') ?>",
    1: "<?php _e('Too many tags in ALL query', 'wp-media-flickr') ?>",
    2: "<?php _e('Unknown user', 'wp-media-flickr') ?>",
    3: "<?php _e('Parameterless searches have been disabled', 'wp-media-flickr') ?>",
    4: "<?php _e('You don\'t have permission to view this pool', 'wp-media-flickr') ?>",
   10: "<?php _e('Sorry, the Flickr search API is not currently available.', 'wp-media-flickr') ?>",
   11: "<?php _e('No valid machine tags', 'wp-media-flickr') ?>",
   12: "<?php _e('Exceeded maximum allowable machine tags', 'wp-media-flickr') ?>",
  100: "<?php _e('Invalid API Key', 'wp-media-flickr') ?>",
  105: "<?php _e('Service currently unavailable', 'wp-media-flickr') ?>",
  999: "<?php _e('Unknown error', 'wp-media-flickr') ?>"
};

var msg_pages = '<?php _e('(%1$s / %2$s page(s), %3$s photo(s))', 'wp-media-flickr')?>';

var setting_photo_link = <?php echo !empty($mediaFlickr->settings['photo_link']) ? 1 : 0 ?>;
var setting_link_rel = '<?php echo !empty($mediaFlickr->settings['link_rel']) ? $mediaFlickr->settings['link_rel'] : '' ?>';
var setting_link_class = '<?php echo !empty($mediaFlickr->settings['link_class']) ? $mediaFlickr->settings['link_class'] : '' ?>';
//-->
</script>
<?php
}

$mediaFlickr = new WpMediaFlickr;
