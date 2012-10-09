<?php
/*
+----------------------------------------------------------------+
|																							|
|	WordPress 2.7 Plugin: WP-EMail 2.40										|
|	Copyright (c) 2008 Lester "GaMerZ" Chan									|
|																							|
|	File Written By:																	|
|	- Lester "GaMerZ" Chan															|
|	- http://lesterchan.net															|
|																							|
|	File Information:																	|
|	- Uninstall WP-EMail																|
|	- wp-content/plugins/wp-email/email-uninstall.php						|
|																							|
+----------------------------------------------------------------+
*/


### Check Whether User Can Manage EMail
if(!current_user_can('manage_email')) {
	die('Access Denied');
}


### Variables Variables Variables
$base_name = plugin_basename('wp-email/email-manager.php');
$base_page = 'admin.php?page='.$base_name;
$mode = trim($_GET['mode']);
$email_tables = array($wpdb->email);
$email_settings = array('email_smtp', 'email_contenttype', 'email_mailer', 'email_template_subject', 'email_template_body', 'email_template_bodyalt', 'email_template_sentsuccess', 'email_template_sentfailed', 'email_template_error', 'email_interval', 'email_snippet', 'email_multiple', 'email_imageverify', 'email_options', 'email_fields', 'email_template_title', 'email_template_subtitle', 'widget_email_most_emailed');


### Form Processing 
if(!empty($_POST['do'])) {
	// Decide What To Do
	switch($_POST['do']) {
		//  Uninstall WP-EMail
		case __('UNINSTALL WP-EMail', 'wp-email') :
			if(trim($_POST['uninstall_email_yes']) == 'yes') {
				echo '<div id="message" class="updated fade">';
				echo '<p>';
				foreach($email_tables as $table) {
					$wpdb->query("DROP TABLE {$table}");
					echo '<font style="color: green;">';
					printf(__('Table \'%s\' has been deleted.', 'wp-email'), "<strong><em>{$table}</em></strong>");
					echo '</font><br />';
				}
				echo '</p>';
				echo '<p>';
				foreach($email_settings as $setting) {
					$delete_setting = delete_option($setting);
					if($delete_setting) {
						echo '<font color="green">';
						printf(__('Setting Key \'%s\' has been deleted.', 'wp-email'), "<strong><em>{$setting}</em></strong>");
						echo '</font><br />';
					} else {
						echo '<font color="red">';
						printf(__('Error deleting Setting Key \'%s\'.', 'wp-email'), "<strong><em>{$setting}</em></strong>");
						echo '</font><br />';
					}
				}
				echo '</p>';
				echo '</div>'; 
				$mode = 'end-UNINSTALL';
			}
			break;
	}
}


### Determines Which Mode It Is
switch($mode) {
		//  Deactivating WP-EMail
		case 'end-UNINSTALL':
			$deactivate_url = 'plugins.php?action=deactivate&amp;plugin=wp-email/wp-email.php';
			if(function_exists('wp_nonce_url')) { 
				$deactivate_url = wp_nonce_url($deactivate_url, 'deactivate-plugin_wp-email/wp-email.php');
			}
			echo '<div class="wrap">';
			echo '<h2>'.__('Uninstall WP-EMail', 'wp-email').'</h2>';
			echo '<p><strong>'.sprintf(__('<a href="%s">Click Here</a> To Finish The Uninstallation And WP-EMail Will Be Deactivated Automatically.', 'wp-email'), $deactivate_url).'</strong></p>';
			echo '</div>';
			break;
	// Main Page
	default:
?>
<!-- Uninstall WP-EMail -->
<form action="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']); ?>" method="post">
<div class="wrap">
	<div id="icon-wp-email" class="icon32"><br /></div>
	<h2><?php _e('Uninstall WP-EMail', 'wp-email'); ?></h2>
	<p>
		<?php _e('Deactivating WP-EMail plugin does not remove any data that may have been created, such as the email options and the email logs. To completely remove this plugin, you can uninstall it here.', 'wp-email'); ?>
	</p>
	<p style="color: red">
		<strong><?php _e('WARNING:', 'wp-email'); ?></strong><br />
		<?php _e('Once uninstalled, this cannot be undone. You should use a Database Backup plugin of WordPress to back up all the data first.', 'wp-email'); ?>
	</p>
	<p style="color: red">
		<strong><?php _e('The following WordPress Options/Tables will be DELETED:', 'wp-email'); ?></strong><br />
	</p>
	<table class="widefat">
		<thead>
			<tr>
				<th><?php _e('WordPress Options', 'wp-email'); ?></th>
				<th><?php _e('WordPress Tables', 'wp-email'); ?></th>
			</tr>
		</thead>
		<tr>
			<td valign="top">
				<ol>
				<?php
					foreach($email_settings as $settings) {
						echo '<li>'.$settings.'</li>'."\n";
					}
				?>
				</ol>
			</td>
			<td valign="top" class="alternate">
				<ol>
				<?php
					foreach($email_tables as $tables) {
						echo '<li>'.$tables.'</li>'."\n";
					}
				?>
				</ol>
			</td>
		</tr>
	</table>
	<p>&nbsp;</p>
	<p style="text-align: center;">
		<input type="checkbox" name="uninstall_email_yes" value="yes" />&nbsp;<?php _e('Yes', 'wp-email'); ?><br /><br />
		<input type="submit" name="do" value="<?php _e('UNINSTALL WP-EMail', 'wp-email'); ?>" class="button" onclick="return confirm('<?php _e('You Are About To Uninstall WP-EMail From WordPress.\nThis Action Is Not Reversible.\n\n Choose [Cancel] To Stop, [OK] To Uninstall.', 'wp-email'); ?>')" />
	</p>
</div>
</form>
<?php
} // End switch($mode)
?>