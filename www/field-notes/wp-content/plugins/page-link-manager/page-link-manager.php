<?php
/*
Plugin Name: Page Link Manager
Version: 1.0b
Description: Adds admin panel to choose which pages appear in the site navigation.
Author: Garrett Murphey
Author URI: http://gmurphey.com/
Plugin URI: http://gmurphey.com/2006/10/05/wordpress-plugin-page-link-manager/
*/

define('GDM_MARGIN', 10);

$gdmPageWidgetIndex = 0;

// widget specific code
function gdmWidgetPageLinkManagerRegister() {
	$options = get_option('widget_page_link_manager');
	$number = $options['number'];
	if ($number < 1) $number = 1;
	if ($number > 9) $number = 9;
	$dims = array('width' => 460, 'height' => 450);
	$class = array('classname' => 'widget_page_link_manager');
	
	for ($i = 1; $i <= 9; $i++) {
		$name = sprintf(__('Pages %d'), $i);
		$id = "gdm-plm-$i";
		wp_register_sidebar_widget($id, $name, ($i <= $number) ? 'gdmWidgetPageLinkManager' : '', $class, $i);
		wp_register_widget_control($id, $name, ($i <= $number) ? 'gdmWidgetPageLinkManagerControl' : '', $dims, $i);
	}
	
	add_action('sidebar_admin_setup', 'gdmWidgetPageLinkManagerSetup');
	add_action('sidebar_admin_page', 'gdmWidgetPageLinkManagerPage');
}

function gdmWidgetPageLinkManagerSetup() {
	$options = $newOptions = get_option('widget_page_link_manager');
	if (isset($_POST['gdm-plm-number-submit'])) {
		$number = (int)$_POST['gdm-plm-number'];
		if ($number > 9) $number = 9;
		if ($number < 1) $number = 1;
		$newOptions['number'] = $number;
	}
	if ($options != $newOptions) {
		$options = $newOptions;
		update_option('widget_page_link_manager', $options);
		gdmWidgetPageLinkManagerRegister();
	}
}

function gdmWidgetPageLinkManagerPage() {
	$options = get_option('widget_page_link_manager');
	?>
	<div class="wrap">
		<form method="POST">
			<h2><?php _e('Page Widgets'); ?></h2>
			<p style="line-height: 30px;"><?php _e('How many page widgets would you like?'); ?>
				<select id="gdm-plm-number" name="gdm-plm-number">
					<?php 
					for ($i = 1; $i <= 9; $i++) { 
						$selected = ($i == $options['number']) ? 'selected="selected"' : '';
					?>
					<option value="<?php echo $i; ?>" <?php echo $selected; ?>><?php echo $i; ?></option>
					<?php } ?>	
				</select>
				<span class="submit"><input type="submit" name="gdm-plm-number-submit" id="gdm-plm-number-submit" value="<?php echo __('Save'); ?>" /></span>
			</p>
		</form>
	</div>
	<?php
}

function gdmWidgetPageLinkManager($args, $number = 1) {
	global $gdmPageWidgetIndex;
	$gdmPageWidgetIndex = $number;
	extract($args);
	$options = get_option('widget_page_link_manager');
	$title = $options[$number]['title'];
	$sortOrder = (empty($options[$number]['sort_order'])) ? 'menu_order' : $options[$number]['sort_order'];
	$excludes = (!is_array($options[$number]['excludes'])) ? array() : $options[$number]['excludes'];
	
	if ($sortOrder == 'menu_order')
		$sortOrder = 'menu_order, post_title';
	
	$out = wp_list_pages(array('title_li' => '', 'echo' => 0, 'sort_column' => $sortOrder));
	
	if (!empty($out)) {
	?>
	<?php echo $before_widget; ?>
	<?php echo $before_title . $title . $after_title; ?>
	<ul>
		<?php echo $out; ?>
	</ul>
	<?php echo $after_widget; ?>
	<?php
	}
	$gdmPageWidgetIndex = 0;
}

function gdmWidgetPageLinkManagerControl($number) {
	$gdmAllPages = get_all_page_ids();
	$options = $newOptions = get_option('widget_page_link_manager');
	if (!is_array($options))
		$options = $newOptions = array();
		$options[$number]['title'] = '';
		$options[$number]['sort_order'] = '';
		$options[$number]['excludes'] = array();
	if ($_POST["gdm-plm-submit-$number"]) {
		$newOptions[$number]['title'] = strip_tags(stripslashes($_POST["gdm-plm-title-$number"]));
		$newOptions[$number]['sort_order'] = $_POST["gdm-plm-order-$number"];
		if (is_array($_POST["gdm-plm-includes-$number"])) {
			$newOptions[$number]['excludes'] = array_diff($gdmAllPages, $_POST["gdm-plm-includes-$number"]);
		} else {
			$newOptions[$number]['excludes'] = $gdmAllPages;
		}
	}
	if ($options != $newOptions) {
		$options = $newOptions;
		update_option('widget_page_link_manager', $options);
	}
	$title = (empty($options[$number]['title'])) ? __('Pages') : $options[$number]['title'];
	$sortOrder = (empty($options[$number]['sort_order'])) ? 'menu_order' : $options[$number]['sort_order'];
	$excludes = (is_array($options[$number]['excludes'])) ? $options[$number]['excludes'] : array();
	
	?>
	<p style="text-align: left;">
		<label style="display: block;"><?php _e('Title') ?></label>
		<input style="width: 450px;" id="gdm-plm-title-<?php echo $number; ?>" name="gdm-plm-title-<?php echo $number ?>" type="text" value="<?php echo $title; ?>" />
	</p>
	
	<p style="text-align: left;">
		<label style="display: block"><?php _e('Sort By') ?></label>
		<select name="gdm-plm-order-<?php echo $number; ?>" id="gdm-plm-order-<?php echo $number; ?>">
			<option value="post_title"<?php selected( $sortOrder, 'post_title' ); ?>><?php _e('Page title'); ?></option>
			<option value="menu_order"<?php selected( $sortOrder, 'menu_order' ); ?>><?php _e('Page order'); ?></option>
			<option value="ID"<?php selected( $sortOrder, 'ID' ); ?>><?php _e( 'Page ID' ); ?></option>
		</select>
	</p>
	
	<p style="text-align: left;">
		<h3><?php _e('Included Pages') ?></h3>
		<div id="gdm-plm-page-frame" style="height: 255px; overflow-y: auto;">
			<?php gdmPageLinkManagerHierarchy($number, 0, 0, $excludes); ?>
		</div>
	</p>
	
	<input type="hidden" id="gdm-plm-submit-<?php echo $number; ?>" name="gdm-plm-submit-<?php echo $number; ?>" value="1" />
	<?php
}

function gdmPageLinkManagerHierarchy($number, $parent, $margin, $excludedPages) {
	global $wpdb;
	$pages = $wpdb->get_results('SELECT id, post_title FROM ' . $wpdb->prefix . 'posts WHERE post_parent = ' . $parent . ' AND post_type = "page"', ARRAY_A);
	?><div id="children-<?php echo $parent; ?>"><?php
	for ($x = 0; $pages[$x]; $x++) {
		?><span style="display: block; text-align: left; margin-left: <?php echo $margin; ?>px"><input type="checkbox" name="gdm-plm-includes-<?php echo $number; ?>[]" value="<?php echo $pages[$x]['id']; ?>" <?php if (!in_array($pages[$x]['id'], $excludedPages)) { ?> checked<?php } ?> /> <?php echo $pages[$x]['post_title']; ?></span><?php
		gdmPageLinkManagerHierarchy($number, $pages[$x]['id'], $margin + GDM_MARGIN, $excludedPages);
	}
	?></div><?php
}

function gdmWidgetPageLinkManagerInit() {
	unregister_sidebar_widget('Pages');
	gdmWidgetPageLinkManagerRegister();
}
// end widget specific code

// standard code
function gdmPageLinksManagementForm() {
	$excludedPages = get_option('gdm_excluded_pages');
	?>
    <script type="text/javascript">
		function gdmCheckChildren(obj) {
			var parent = jQuery(obj);
			jQuery('#children-' + parent.val() + ' input[type=checkbox]').each(function () {
				var child = jQuery(this);
				if (parent.is(':checked') == false) {
					child.attr('checked', 'false');
					child.attr('disabled', 'true');
				} else {
					child.attr('disabled', 'false');
				}
			});
		}
		
		jQuery(document).ready(function () {
			jQuery('#wrap input[type=checkbox]').each(function () {
				gdmCheckChildren(this);
			});
			
			jQuery('#wrap input[type=checkbox]').change(function () { gdmCheckChildren(this) });
		});
	</script>
	<div class="wrap">
	<h2><?php _e('Manage Page Links'); ?></h2>
	<fieldset class="options">
	<legend><?php _e('Select the Pages to Include in Site Navigation'); ?></legend>
	<form action="<?php echo $_SERVER['REQUEST_URI']; ?>" method="post">
		<?php
		gdmPrintPages(0, 0, $excludedPages);
		?>
		<input type="submit" name="gdm_submit" value="<?php _e('Update Navigation'); ?>" />
	</form>
	</fieldset>
	</div>
	<?php
}

function gdmPrintPages($parent, $margin, $excludedPages) {
	global $wpdb;
	$pages = $wpdb->get_results('SELECT id, post_title FROM ' . $wpdb->prefix . 'posts WHERE post_parent = ' . $parent . ' AND post_type = "page"', ARRAY_A);
	?><div id="children-<?php echo $parent; ?>"><?php
	for ($x = 0; $pages[$x]; $x++) {
		?><p style="margin-left: <?php echo $margin; ?>px"><input type="checkbox" name="includedPages[]" value="<?php echo $pages[$x]['id']; ?>" onchange="gdmCheckChildren(this)"<?php if (!in_array($pages[$x]['id'], $excludedPages)) { ?> checked<?php } ?> /> <?php echo $pages[$x]['post_title']; ?></p><?php
		gdmPrintPages($pages[$x]['id'], $margin + GDM_MARGIN, $excludedPages);
	}
	?></div><?php
}

function gdmPageLinksManagement() {
	$gdmAllPages = get_all_page_ids();
	if (empty($_POST['gdm_submit'])) {
		gdmPageLinksManagementForm();
	} else {
		if (is_array($_POST['includedPages']))
			$excludedPages = array_diff($gdmAllPages, $_POST['includedPages']);
		else
			$excludedPages = $gdmAllPages;
		update_option('gdm_excluded_pages', $excludedPages);
		?><div id="message" class="updated fade"><p><strong><?php _e('Page Links Updated'); ?>.</strong></p></div><?php
		gdmPageLinksManagementForm();
	}
}

function gdmAddAdminPages() {
	add_management_page('Page Links', 'Page Links', 5, __FILE__, 'gdmPageLinksManagement');
}

function gdmAddJs() {
	wp_enqueue_script('jquery');
}

// core functionality
function gdmPageLinkManagerIncludeExcludes($explicitExcludes) {
	global $gdmPageWidgetIndex;
	if ($gdmPageWidgetIndex == 0) {
		if (!get_option('gdm_excluded_pages'))
			gdmPageLinkActivate();
		$excludes = get_option('gdm_excluded_pages');
	} else {
		$options = get_option('widget_page_link_manager');
		$excludes = $options[$gdmPageWidgetIndex]['excludes'];
	}
	$excludes = array_merge($excludes, $explicitExcludes);
	sort($excludes);
	return $excludes;
}
// end core functionality

function gdmPageLinkActivate() {
	if (!get_option('gdm_excluded_pages'))
		add_option('gdm_excluded_pages', array());
}

register_activation_hook( __FILE__, 'gdmPageLinkActivate');
add_action('admin_menu', 'gdmAddAdminPages');
add_action('admin_print_scripts', 'gdmAddJs');
add_action('widgets_init', 'gdmWidgetPageLinkManagerInit', 1);
add_action('wp_list_pages_excludes', 'gdmPageLinkManagerIncludeExcludes');

?>