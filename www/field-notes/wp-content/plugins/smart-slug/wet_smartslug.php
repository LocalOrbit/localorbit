<?php
/*
Plugin Name: wet_smartslug
Plugin URI: http://talkpress.de/blip/wet-smartslug-wordpress-plugin
Description: Smartify your post and page slugs by removing too short or insignificant stopwords automatically.
Author: Robert Wetzlmayr
Version: 1.7
Author URI: http://wetzlmayr.com/
*/


class wet_smartslug {
	var $min_chars;
	var $stopwords = array();
	var $strlen;

	function wet_smartslug() {
		if (!function_exists('is_admin')) {
			exit();
		}
		if (is_admin()) {
	    	$this->get_options();
			load_plugin_textdomain('wet_smartslug', false, dirname(plugin_basename(__FILE__)));
			add_filter('wp_unique_post_slug', array($this, 'smart_slug'), 100, 6);
			add_action('admin_menu', array($this, 'admin_menu'));
			$this->strlen = (function_exists('mb_strlen')) ? 'mb_strlen' : 'strlen';
		}
	}

	function smart_slug($slug, $post_ID, $post_status, $post_type, $post_parent, $original_slug='' /* @since WP3.5 */) {
		if ($slug === '') return '';

		$old_slug = $slug;
		// strip out too short parts and members of the stoplist array
		$slug = explode('-', $slug);
		$f = $this->strlen;
		foreach ($slug as $t) {
			$t_ = urldecode($t);
			if (($f($t_) >= $this->min_chars) && !(in_array($t_, $this->stopwords)) || is_numeric($t_)) {
				$out[] = $t;
			}
		}
		// are we acting overzealous?
		if (empty($out)) {
			$slug = $old_slug;
		} else {
			$slug = join('-', $out);
		}
		return $slug;
	}

	function admin_menu() {
    	add_submenu_page('options-general.php',
    		__('Smart Slug', 'wet_smartslug'),
    		__('Smart Slug', 'wet_smartslug'),
    		'manage_options', 'wet_smartslug.php', array($this, 'options_panel'));
	}

	function get_options()
	{
		$options = get_option('wet_smartslug');
	    if (!is_array($options)) {
			$options = array('min_chars'=>3, 'stopwords'=>__('stopwords_set' /* translators, beware! */, 'wet_smartslug'));
	    }
		$this->min_chars = $options['min_chars'];
		$this->stopwords = array_map('trim', explode(',', $options['stopwords']));
	}

	function options_panel() {
		if (isset($_POST['wet_smartslug-submit'])) {
			$options['min_chars'] = (int) $_POST['wet_smartslug-min_chars'];
			$stopwords =  stripslashes($_POST['wet_smartslug-stopwords']);
			$options['stopwords'] = join(', ', array_map('trim', explode(',', $stopwords)));
			update_option('wet_smartslug', $options);
			echo '<div id="message" class="updated fade"><p>'.__("Options Updated.", 'wet_smartslug').'</p></div>';
		}
		$this->get_options();
?>
<div class="wrap">
<h2><?php _e('Settings'); ?></h2>

<form name="wet-smartslug" action="" method="post">
<table class="form-table">
<tr>
<th scope="row" style="text-align:right; vertical-align:top;">
<?php _e('Comma separated list of stop words:', 'wet_smartslug'); ?>
</th>
<td>
<textarea cols="57" rows="15" name="wet_smartslug-stopwords"><?php echo htmlspecialchars(join(', ', $this->stopwords), ENT_QUOTES); ?></textarea>
</td>
</tr>
<tr>
<th scope="row" style="text-align:right; vertical-align:top;">
<?php _e('Minimum character count for slug parts:', 'wet_smartslug'); ?>
</th>
<td>
<input size="59" name="wet_smartslug-min_chars" value="<?php echo htmlspecialchars($this->min_chars, ENT_QUOTES); ?>"/>
</td>
</tr>
</table>
<p class="submit">
<input class="button-primary" type="submit" name="wet_smartslug-submit" value="<?php _e('Save Changes'); ?>" />
</p>
</form>
</div>
<?php
	} // options_panel
}
$wet_smartslug = new wet_smartslug();
?>