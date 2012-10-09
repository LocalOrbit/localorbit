<?php
/*
 Plugin Name: wet_smartslug
 Plugin URI: http://talkpress.de/blip/wet-smartslug-wordpress-plugin
 Description: Smartify your post, page, tag and category slugs by removing too short or insignificant stopwords automatically.
 Author: Robert Wetzlmayr
 Version: 1.2.0
 Author URI: http://wetzlmayr.at/
 */


class wet_smartslug {
	var $min_chars;
	var $stopwords = array();

	function wet_smartslug() {
		if (!function_exists('is_admin')) {
			exit();
		}
		if (is_admin()) {
	    	$this->get_options();
			load_plugin_textdomain('wet_smartslug', false, dirname(plugin_basename(__FILE__)));
			add_filter('editable_slug', array($this, 'smart_slug'), 100);
			add_action('admin_menu', array($this, 'admin_menu'));
		}
	}

	function smart_slug($title) {
		/*
		// restrict smart slug functions to pages and posts.
		// TODO: detect "save draft"
		if (!in_array($_POST['action'], array('sample-permalink', 'editpost', 'post')))
			return $title;
		 */

		$old_title = $title;
		// strip out too short parts and members of the stoplist array
		$title = explode('-', $title);
		foreach ($title as $t) {
			if ((strlen($t) >= $this->min_chars) && !(in_array($t, $this->stopwords))) {
				$out[] = $t;
			}
		}
		// are we acting overzealous?
		if (empty($out)) {
			$title = $old_title;
		} else {
			$title = join('-', $out);
		}
		return $title;
	}

	function admin_menu() {
    	add_submenu_page('options-general.php',
    		__('Smart Slug', 'wet_smartslug'),
    		__('Smart Slug', 'wet_smartslug'),
    		10, __FILE__, array($this, 'options_panel'));
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
		if ($_POST['wet_smartslug-submit']) {
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