<?php
require_once('WordpressBackup.php');
function bte_wb_head_admin() {
	wp_enqueue_script('jquery-ui-tabs');
	$home = get_settings('siteurl');
	$base = '/'.end(explode('/', str_replace(array('\\','/BTE_WB_admin.php'),array('/',''),__FILE__)));
	$stylesheet = $home.'/wp-content/plugins' . $base . '/css/wordpress-backup.css';
	echo('<link rel="stylesheet" href="' . $stylesheet . '" type="text/css" media="screen" />');
}

function bte_wb_options() {	 	
	$message = null;
	$message_updated = __("Wordpress Backup Options Updated.", 'bte_wordpress_backup');
	if (!empty($_POST['bte_wb_action'])) {
		$message = $message_updated;
		if (isset($_POST['bte_wb_interval'])) {
			update_option('bte_wb_interval',$_POST['bte_wb_interval']);
		}
		if (isset($_POST['bte_wb_email'])) {
			update_option('bte_wb_email',$_POST['bte_wb_email']);
		}
		if (isset($_POST['bte_wb_upload_dir'])) {
			update_option('bte_wb_upload_dir',$_POST['bte_wb_upload_dir']);
		}
		if (isset($_POST['bte_wb_template_dir'])) {
			update_option('bte_wb_template_dir',$_POST['bte_wb_template_dir']);
		}
		if (isset($_POST['bte_wb_plugin_dir'])) {
			update_option('bte_wb_plugin_dir',$_POST['bte_wb_plugin_dir']);
		}
		if (isset($_POST['bte_wb_backup_dir'])) {
			update_option('bte_wb_backup_dir',$_POST['bte_wb_backup_dir']);
		}
		if (isset($_POST['bte_wb_backup_url'])) {
			update_option('bte_wb_backup_url',$_POST['bte_wb_backup_url']);
		}
		
		print('
			<div id="message" class="updated fade">
				<p>'.__('Wordpress Backup Options Updated.', 'WordpressBackup').'</p>
			</div>');
	}
	$bte_wb_interval = get_option('bte_wb_interval');		
	if (!(isset($bte_wb_interval) && is_numeric($bte_wb_interval))) {
		$bte_wb_interval = BTE_WB_INTERVAL;
	}
	$bte_wb_email = get_option('bte_wb_email');		
	$bte_wb_upload_dir = get_option('bte_wb_upload_dir');		
	if(empty($bte_wb_upload_dir)) {
		$bte_wb_upload_dir = WP_UPLOAD_DIR;
		update_option('bte_wb_upload_dir',$bte_wb_upload_dir);
	}
	$bte_wb_template_dir = get_option('bte_wb_template_dir');		
	if(empty($bte_wb_template_dir)) {
		$bte_wb_template_dir = WP_TEMPLATE_DIR;
		update_option('bte_wb_template_dir',$bte_wb_template_dir);
	}
	$bte_wb_plugin_dir = get_option('bte_wb_plugin_dir');		
	if(empty($bte_wb_plugin_dir)) {
		$bte_wb_plugin_dir = WP_PLUGIN_DIR;
		update_option('bte_wb_plugin_dir',$bte_wb_plugin_dir);
	}
	$bte_wb_backup_dir = get_option('bte_wb_backup_dir');		
	if(empty($bte_wb_backup_dir)) {
		$bte_wb_backup_dir = BTE_WB_DIR;
		update_option('bte_wb_backup_dir',$bte_wb_backup_dir);
	}
	$bte_wb_backup_url = get_option('bte_wb_backup_url');		
	if(empty($bte_wb_backup_url)) {
		$bte_wb_backup_url = BTE_WB_URL;
		update_option('bte_wb_backup_url',$bte_wb_backup_url);
	}
	
	
	 
	print('
			<div class="wrap">
				<h2>'.__('Wordpress Backup by', 'WordpressBackup').' <a href="http://www.blogtrafficexchange.com">Blog Traffic Exchange</a></h2>
				<h3>Click Link to download a backup:</h3>
				<ul>');
	if(@is_dir(stripslashes($bte_wb_upload_dir)) && file_exists($bte_wb_backup_dir.'/uploads.zip')) {
		print('
					<li><a href="'.$bte_wb_backup_url.'/uploads.zip">Upload Image Directory Backup</a>  Backup Date: '.date('Y-m-d H:i:s',get_option("bte_wb_last_backup_uploads")).'</li>');
	}
	if(@is_dir(stripslashes($bte_wb_template_dir)) && file_exists($bte_wb_backup_dir.'/themes.zip')) {
		print('
					<li><a href="'.$bte_wb_backup_url.'/themes.zip">Theme Directory Backup</a> Backup Date: '.date('Y-m-d H:i:s',get_option("bte_wb_last_backup_theme")).'</li>');
	}
	if(@is_dir(stripslashes($bte_wb_plugin_dir)) && file_exists($bte_wb_backup_dir.'/plugins.zip')) {
		print('
					<li><a href="'.$bte_wb_backup_url.'/plugins.zip">Pluigin Directory Backup</a> Backup Date: '.date('Y-m-d H:i:s',get_option("bte_wb_last_backup_plugin")).'</li>');
	}
	print('
				</ul>
				<h3>Wordpress Backup Options</h3><form id="bte_wb" name="bte_wordpressbackup" action="'.get_bloginfo('wpurl').'/wp-admin/options-general.php?page=BTE_WB_admin.php" method="post">
					<input type="hidden" name="bte_wb_action" value="bte_wb_update_settings" />
					<fieldset class="options">
						<div class="option">
							<label for="bte_wb_interval">'.__('Interval between backups: ', 'WordpressBackup').'</label>
							<select name="bte_wb_interval" id="bte_wb_interval">
									<option value="'.BTE_WB_1_HOUR.'" '.bte_wb_optionselected(BTE_WB_1_HOUR,$bte_wb_interval).'>'.__('1 Hour', 'WordpressBackup').'</option>
									<option value="'.BTE_WB_1_DAY.'" '.bte_wb_optionselected(BTE_WB_1_DAY,$bte_wb_interval).'>'.__('1 Day', 'WordpressBackup').'</option>
									<option value="'.BTE_WB_1_WEEK.'" '.bte_wb_optionselected(BTE_WB_1_WEEK,$bte_wb_interval).'>'.__('1 Week', 'WordpressBackup').'</option>
							</select>
						</div>
						<div class="option">
							<label for="bte_wb_email">'.__('Email address (blank for no email): ', 'WordpressBackup').'</label>
							<input size="120" name="bte_wb_email" type="text" value="'.htmlspecialchars(stripslashes($bte_wb_email)).'" /><br/>
							<p>Please note that as the size of the zip files increase, it may not be possible to email the files due to limitations of email servers.</p>
						</div>
						<div class="option">
							<label for="bte_wb_backup_dir">'.__('Backup Directory: ', 'WordpressBackup').'</label>
							<input size="120" name="bte_wb_backup_dir" type="text" value="'.stripslashes($bte_wb_backup_dir).'" /><br/>');
							if(@is_dir(stripslashes($bte_wb_backup_dir))) {
								print('<p><font color="green">'.__('Backup folder exists', 'WordpressBackup').'</font></p>');
							} else {
								print('<p><font color="red">'.sprintf(__('Backup folder does NOT exist. Please create \'bte-wb\' folder in \'%s\' folder and CHMOD it to \'777\' or change the location of the backup folder under DB Option.', 'WordpressBackup'), WP_CONTENT_DIR).'</font></p>');
							}
							if(@is_writable(stripslashes($bte_wb_backup_dir))) {				
								print('<font color="green">'.__('Backup folder is writable', 'WordpressBackup').'</font>');
							} else {
								print('<font color="red">'.__('Backup folder is NOT writable. Please CHMOD it to \'777\'.', 'WordpressBackup').'</font>');
							}
							if(@file_exists(stripslashes($bte_wb_backup_dir.'/plugins.zip')) && @is_writable(stripslashes($bte_wb_backup_dir.'/plugins.zip'))) {				
								print('<p><font color="green">'.__('plugins.zip is writeable', 'WordpressBackup').'</font></p>');
							} else if(@file_exists(stripslashes($bte_wb_backup_dir.'/plugins.zip'))) {
								print('<font color="red">'.__('plugins.zip is NOT writable. Please CHMOD it to \'666\'.', 'WordpressBackup').'</font>');								
							}
							if(@file_exists(stripslashes($bte_wb_backup_dir.'/uploads.zip')) && @is_writable(stripslashes($bte_wb_backup_dir.'/uploads.zip'))) {				
								print('<p><font color="green">'.__('uploads.zip is writeable', 'WordpressBackup').'</font></p>');
							} else if(@file_exists(stripslashes($bte_wb_backup_dir.'/uploads.zip'))) {
								print('<font color="red">'.__('uploads.zip is NOT writable. Please CHMOD it to \'666\'.', 'WordpressBackup').'</font>');								
							}
							if(@file_exists(stripslashes($bte_wb_backup_dir.'/themes.zip')) && @is_writable(stripslashes($bte_wb_backup_dir.'/themes.zip'))) {				
								print('<p><font color="green">'.__('theme.zip is writeable', 'WordpressBackup').'</font></p>');
							} else if(@file_exists(stripslashes($bte_wb_backup_dir.'/themes.zip'))) {
								print('<font color="red">'.__('theme.zip is NOT writable. Please CHMOD it to \'666\'.', 'WordpressBackup').'</font>');								
							}
	print('												
						</div>
						<div class="option">
							<label for="bte_wb_backup_url">'.__('Backup URL: ', 'WordpressBackup').'</label>
							<input size="120" name="bte_wb_backup_url" type="text" value="'.stripslashes($bte_wb_backup_url).'" /><br/>
						</div>
						<div class="option">
							<label for="bte_wb_plugin_dir">'.__('Plugin Directory: ', 'WordpressBackup').'</label>
							<input size="120" name="bte_wb_plugin_dir" type="text" value="'.stripslashes($bte_wb_plugin_dir).'" /><br/>');
							if(@is_dir(stripslashes($bte_wb_plugin_dir))) {
								print('<p><font color="green">'.__('Plugin folder exists', 'WordpressBackup').'</font></p>');
							} else {
								print('<p><font color="red">'.sprintf(__('Plugin folder does NOT exist. It will not be backed up.', 'WordpressBackup'), WP_CONTENT_DIR).'</font></p>');
							}
	print('					
						</div>
						<div class="option">
							<label for="bte_wb_template_dir">'.__('Theme Directory: ', 'WordpressBackup').'</label>
							<input size="120" name="bte_wb_template_dir" type="text" value="'.stripslashes($bte_wb_template_dir).'" /><br/>');
							if(@is_dir(stripslashes($bte_wb_template_dir))) {
								print('<p><font color="green">'.__('Template folder exists', 'WordpressBackup').'</font></p>');
							} else {
								print('<p><font color="red">'.sprintf(__('Template folder does NOT exist. It will not be backed up.', 'WordpressBackup'), WP_CONTENT_DIR).'</font></p>');
							}
	print('					
						</div>
						<div class="option">
							<label for="bte_wb_upload_dir">'.__('Upload Directory: ', 'WordpressBackup').'</label>
							<input size="120" name="bte_wb_upload_dir" type="text" value="'.stripslashes($bte_wb_upload_dir).'" /><br/>');
							if(@is_dir(stripslashes($bte_wb_upload_dir))) {
								print('<p><font color="green">'.__('Uploads folder exists', 'WordpressBackup').'</font></p>');
							} else {
								print('<p><font color="red">'.sprintf(__('Uploads folder does NOT exist.  It will not be backed up.', 'WordpressBackup'), WP_CONTENT_DIR).'</font></p>');
							}
	print('					
						</div>
					</fieldset>
					<p class="submit">
						<input type="submit" name="submit" value="'.__('Update Wordpress Backup Options', 'WordpressBackup').'" />
					</p>
						<div class="option">
							<h4>Other Blog Traffic Exchange <a href="http://www.blogtrafficexchange.com/wordpress-plugins/">Wordpress Plugins</a></h4>
							<ul>
							<li><a href="http://www.blogtrafficexchange.com/wordpress-backup/">Wordpress Backup</a></li>
							<li><a href="http://www.blogtrafficexchange.com/blog-copyright/">Blog Copyright</a></li>
							<li><a href="http://www.blogtrafficexchange.com/old-post-promoter/">Old Post Promoter</a></li>
							<li><a href="http://www.blogtrafficexchange.com/related-websites/">Related Websites</a></li>
							<li><a href="http://www.blogtrafficexchange.com/related-posts/">Related Posts</a></li>
							<li><a href="http://www.blogtrafficexchange.com/online-stores/">Online Stores</a></li>
							<li><a href="http://www.blogtranslated.com/">Blog Translated</a></li>
							</ul>
						</div>
				</form>' );

}

function bte_wb_optionselected($opValue, $value) {
	if($opValue==$value) {
		return 'selected="selected"';
	}
	return '';
}

function bte_wb_options_setup() {	
	add_options_page('WordpressBackup', 'Wordpress Backup', 10, basename(__FILE__), 'bte_wb_options');
}

?>
