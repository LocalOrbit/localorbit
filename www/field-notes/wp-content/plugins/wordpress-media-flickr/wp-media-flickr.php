<?php
/*
Plugin Name: Wordpress Media Flickr
Plugin URI: http://factage.com/yu-ji/tag/wp-media-flickr
Description: You can post with flickr photo, on visual editor toolbar.<br />It's very interactive interface than other plugins.
Author: yu-ji
Version: 1.0.3
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

        $this->settings = get_settings(get_class($this));

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
        add_action('admin_head_media_upload_type_flickr', 'media_admin_css');
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
            add_options_page(__('Media Flickr', 'wp-media-flickr'), __('Media Flickr', 'wp-media-flickr'), 8, "options-general.php?page=".$plugin_basename."/wp-media-flickr-admin.php");
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
    padding: 5px;
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
	clear: both;
    text-align: center;
}
#allignments {
    padding-left: 40px;
}
#sizes {
	padding-left: 20px;
}
#select_size {
	float: left;
	width: 200px;
}
#select_alignment {
	float: left;
	width: 200px;
}
</style>
<form method="get" class="media-upload-form type-form" onsubmit="return false">
    <input type="hidden" name="type" value="<?php echo $type ?>" />
    <input type="hidden" name="tab" value="<?php echo $tab ?>" />
    <div id="search-filter">
        <input type="text" id="flickr_search_query" />
        <?php if(!empty($mediaFlickr->settings['username'])) { ?>
        <input type="radio" id="flickr_user_id_0" name="w" value="" checked="checked"/><label for="flickr_user_id_0"><?php _e('Your Photos', 'wp-media-flickr') ?></label>
        <input type="radio" id="flickr_user_id_1" name="w" value=""/><label for="flickr_user_id_1"><?php _e('Everyone\'s Photos', 'wp-media-flickr') ?></label>
        <?php } ?>
        <input type="submit" onclick="flickr_search(0)" value="<?php _e('Search photo', 'wp-media-flickr'); ?>" class="button" />
    </div>
    <h3><?php _e('Flickr photos', 'wp-media-flickr') ?><span id="pages"></span></h3>
    <div id="pager">
        <div id="prev_page">
            <a href="javascript:void(0)" onclick="return flickr_search(-1)"><?php _e('&laquo; Prev page', 'wp-media-flickr') ?></a>
        </div>
        <div id="next_page">
            <a href="javascript:void(0)" onclick="return flickr_search(+1)"><?php _e('Next page &raquo;', 'wp-media-flickr') ?></a>
        </div>
        <br style="clear: both;" />
    </div>
    <div id="items">
    </div>
</form>
<div id="put_background"></div>
<form onsubmit="return false" id="put_dialog">
	<div id="select_size">
	    1. <?php _e('Select size of photo', 'wp-media-flickr') ?>
	    <div id="size_preview"><img id="size_image" rel="none" src="<?php echo $mediaFlickr->pluginURI ?>/size_t.png" alt=""/></div>
	    <div id="sizes">
	        <input type="radio" id="size_sq" name="size" value="sq" /> <label for="size_sq"><?php _e('Square', 'wp-media-flickr') ?> (75 x 75)</label><br />
	        <input type="radio" id="size_t" name="size" value="t" /> <label for="size_t"><?php _e('Thumbnail', 'wp-media-flickr') ?> (100 x 75)</label><br />
	        <input type="radio" id="size_s" name="size" value="s" /> <label for="size_s"><?php _e('Small', 'wp-media-flickr') ?> (240 x 180)</label><br />
	        <input type="radio" id="size_m" name="size" value="m" /> <label for="size_m"><?php _e('Medium', 'wp-media-flickr') ?> (500 x 375)</label><br />
	        <input type="radio" id="size_l" name="size" value="l" /> <label for="size_l"><?php _e('Large', 'wp-media-flickr') ?> (1024 x 768)</label><br />
	    </div>
	</div>
	<div id="select_alignment">
	    2. <?php _e('Select alignment of photo', 'wp-media-flickr') ?>
	    <div id="alignment_preview"><img id="alignment_image" rel="none" src="<?php echo $mediaFlickr->pluginURI ?>/alignment_none.png" alt=""/></div>
	    <div id="allignments">
	        <input type="radio" id="alignment_none" name="alignment" value="none" /> <label for="alignment_none"><?php _e('Default', 'wp-media-flickr') ?></label><br />
	        <input type="radio" id="alignment_left" name="alignment" value="left" /> <label for="alignment_left"><?php _e('Left', 'wp-media-flickr') ?></label><br />
	        <input type="radio" id="alignment_center" name="alignment" value="center" /> <label for="alignment_center"><?php _e('Center', 'wp-media-flickr') ?></label><br />
	        <input type="radio" id="alignment_right" name="alignment" value="right" /> <label for="alignment_right"><?php _e('Right', 'wp-media-flickr') ?></label><br />
	    </div>
	</div>
    <div id="buttons">
        <input type="button" value="<?php _e('Cancel', 'wp-media-flickr') ?>" onclick="cancelInsertImage()" class="button"/>
        <input type="submit" value="<?php _e('Insert', 'wp-media-flickr') ?>" onclick="insertImage()" class="button"/>
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

var _page = 1;
var _user_id = null;
var _query = null;

function flickr_search(paging) {
    if(paging == 0) {
        _page = 1;
        if(document.getElementById('flickr_user_id_0') && document.getElementById('flickr_user_id_0').checked) {
            _user_id = flickr_user_id;
        }else{
            _user_id = null;
        }
        _query = document.getElementById('flickr_search_query').value;
    }else{
        _page += paging;
    }
    if(_user_id) {
        photo_search({ api_key: flickr_api_key, text: _query, page: _page, user_id: _user_id });
    }else{
        photo_search({ api_key: flickr_api_key, text: _query, page: _page });
    }
    return false;
}

var _image_url = '';
var _flickr_url = '';
var _title_text = '';

function showInsertImageDialog(image_url, flickr_url, title_text) {
    window['_image_url'] = image_url;
    window['_flickr_url'] = flickr_url;
    window['_title_text'] = title_text;

    document.getElementById('alignment_none').checked = true;
    document.getElementById('size_t').checked = true;
    document.getElementById('put_dialog').style.display = 'block';
    document.getElementById('put_background').style.display = 'block';
}

var alignments = ['alignment_none', 'alignment_left', 'alignment_center', 'alignment_right'];
for(var i=0;i<alignments.length;i++) {
	document.getElementById(alignments[i]).onchange = changeAlignment;
	document.getElementById(alignments[i]).onchange = changeAlignment;
	document.getElementById(alignments[i]).onchange = changeAlignment;
	document.getElementById(alignments[i]).onchange = changeAlignment;
}

var sizes = ['size_sq', 'size_t', 'size_s', 'size_m', 'size_l'];
for(var i=0;i<sizes.length;i++) {
	document.getElementById(sizes[i]).onchange = changeSize;
	document.getElementById(sizes[i]).onchange = changeSize;
	document.getElementById(sizes[i]).onchange = changeSize;
	document.getElementById(sizes[i]).onchange = changeSize;
}

function changeSize() {
    var sizes = document.getElementsByName('size');
    var size = null;
    for(var i=0;i<sizes.length;i++) {
        if(sizes[i].checked) {
            size = sizes[i].value;
            break;
        }
    }
    if(size && document.getElementById('size_image').getAttribute('rel') != size) {
        document.getElementById('size_preview').innerHTML = '<img id="size_image" rel="'+size+'" src="'+plugin_uri+'/size_'+size+'.png" alt=""/>';
    }
}

function changeAlignment() {
    var alignments = document.getElementsByName('alignment');
    var alignment = null;
    for(var i=0;i<alignments.length;i++) {
        if(alignments[i].checked) {
            alignment = alignments[i].value;
            break;
        }
    }
    if(alignment && document.getElementById('alignment_image').getAttribute('rel') != alignment) {
        document.getElementById('alignment_preview').innerHTML = '<img id="alignment_image" rel="'+alignment+'" src="'+plugin_uri+'/alignment_'+alignment+'.png" alt=""/>';
    }
}

var size_mapping = {
	'sq': '_s',
	't': '_t',
	's': '_m',
	'm': '',
	'l': '_b'
};

function insertImage() {
    image_url = window['_image_url'];
    flickr_url = window['_flickr_url'];
    title_text = window['_title_text'];

    var sizes = document.getElementsByName('size');
    var size = null;
    for(var i=0;i<sizes.length;i++) {
        if(sizes[i].checked) {
            size = sizes[i].value;
            break;
        }
    }
    
    var img = document.createElement('img');
    img.alt = title_text;
    if(!size || typeof size_mapping[size] == 'undefined') {
		size = t;
    }
    img.src = image_url.replace(/\.jpg$/, size_mapping[size] + '.jpg');

    var a = document.createElement('a');
    a.href = flickr_url;
    a.title = title_text;
    a.rel = setting_link_rel;
    
    if(/*@cc_on!@*/false){
	    a.setAttribute('className', setting_link_class);
	}else{
	    a.setAttribute('class', setting_link_class);
	}
	
    var p = document.createElement('p');

    var div = document.createElement('div');

    var alignments = document.getElementsByName('alignment');
    var alignment = null;
    for(var i=0;i<alignments.length;i++) {
        if(alignments[i].checked) {
            alignment = alignments[i].value;
            break;
        }
    }

    if(alignment != 'none') {
        if(alignment != 'center') {
            if(is_msie) {
                img.style.styleFloat = alignment;
                img.setAttribute('className', 'align'+alignment);
            }else{
                img.style.cssFloat = alignment;
                img.setAttribute('class', 'align'+alignment);
            }
        }else{
            if(is_msie) {
                img.setAttribute('className', 'alignnone');
            }else{
                img.setAttribute('class', 'alignnone');
            }
            p.style.textAlign = 'center';
        }
    }

    a.appendChild(img);
    p.appendChild(a);
    div.appendChild(p);

    top.send_to_editor(div.innerHTML);
    top.tb_remove();
}

function cancelInsertImage() {
    document.getElementById('put_dialog').style.display = 'none';
    document.getElementById('put_background').style.display = 'none';
}

new Image().src = plugin_uri+'/alignment_none.png';
new Image().src = plugin_uri+'/alignment_left.png';
new Image().src = plugin_uri+'/alignment_center.png';
new Image().src = plugin_uri+'/alignment_right.png';

new Image().src = plugin_uri+'/size_sq.png';
new Image().src = plugin_uri+'/size_t.png';
new Image().src = plugin_uri+'/size_s.png';
new Image().src = plugin_uri+'/size_m.png';
new Image().src = plugin_uri+'/size_l.png';

window.onload = function() { flickr_search(0) };
//-->
</script>
<?php
}

$mediaFlickr = new WpMediaFlickr;
