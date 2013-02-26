<?php
require_once("../../../wp-config.php");
require_once("../../../wp-includes/wp-db.php");
require_once("../../../wp-includes/pluggable.php");
global $flickr_manager, $flickr_settings;

get_currentuserinfo();
$upload_level = $flickr_settings->getSetting("upload_level");
$upload_level = (empty($upload_level)) ? 6 : $upload_level;

if(intval($userdata->user_level) < intval($upload_level)) 
	die(__('You do not have permission to upload photos to this stream, you may adjust this in the settings page!', 'flickr-manager'));

if(isset($_FILES['uploadPhoto'])) {
	if(function_exists('check_admin_referer'))
		check_admin_referer('flickr-manager-upload_legacy');
	
	$token = $flickr_settings->getSetting('token');

	/* Perform file upload */
	$file = $_FILES['uploadPhoto'];
	if($file['error'] == 0) {
		
		$params = array('auth_token' => $token, 'photo' => '@'.$file['tmp_name']);
		if(isset($_POST['photoTitle']) && !empty($_POST['photoTitle'])) $params = array_merge($params,array('title' => $_POST['photoTitle']));
		if(isset($_POST['photoTags']) && !empty($_POST['photoTags'])) $params = array_merge($params,array('tags' => $_POST['photoTags']));
		if(isset($_POST['photoDesc']) && !empty($_POST['photoDesc'])) $params = array_merge($params,array('description' => $_POST['photoDesc']));
		$rsp = $flickr_manager->upload($params);
		
		if($rsp !== false) {
		
			$xml_parser = xml_parser_create();
			xml_parse_into_struct($xml_parser, $rsp, $vals, $index);
			xml_parser_free($xml_parser);
			
			$pindex = $index['PHOTOID'][0];
			$pid = $vals[$pindex]['value'];
			$upload_success = true;
		}
	}
}
?>
<!DOCTYPE html PUBLIC "-//W3C//dtd xhtml 1.0 strict//EN" "http://www.w3.org/TR/xhtml1/dtd/xhtml1-strict.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml"> 

<head>
	<link rel='stylesheet' href='<?php echo get_option('siteurl'); ?>/wp-admin/css/global.css' type='text/css' />
	<link rel='stylesheet' href='<?php echo get_option('siteurl'); ?>/wp-admin/wp-admin.css' type='text/css' />
	<link rel="stylesheet" href="<?php echo $flickr_manager->getAbsoluteUrl(); ?>/css/admin_style.css" type="text/css" />
	<link rel="stylesheet" href="<?php echo get_option('siteurl'); ?>/wp-admin/css/colors-fresh.css?version=2.5" type="text/css" />
	
	<style type="text/css">
		html {
			background: #fff; 
			margin: 0px;
			padding: 0px;
		}
	</style>
</head>

<body class="wp-admin">
	<div id="uploadContainer">
		<form id="file_upload_form" method="post" enctype="multipart/form-data" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>" style="padding: 0px 20px;">
			<?php
			if ( function_exists('wp_nonce_field') )
				wp_nonce_field('flickr-manager-upload_legacy');
			
			if($upload_success) : ?>
			
				<div id="wfm-success">
					<strong><?php _e('Image successfully uploaded', 'flickr-manager'); ?></strong>
				</div>
			
			<?php endif; ?>
			<h3><?php _e('Upload Photo', 'flickr-manager'); ?></h3>
			
			<table>
				<tbody>
					<tr>
						<td><label for="uploadPhoto"><?php _e('Upload Photo', 'flickr-manager'); ?>:</label></td>
						<td><input type="file" name="uploadPhoto" id="uploadPhoto" /></td>
					</tr>
					<tr>
						<td><label for="photoTitle"><?php _e('Title', 'flickr-manager'); ?>:</label></td>
						<td><input type="text" name="photoTitle" id="flickrTitle" /></td>
					</tr>
					<tr>
						<td><label for="photoTags"><?php _e('Tags', 'flickr-manager'); ?>:</label></td>
						<td><input type="text" name="photoTags" id="flickrTags" /> <sup>*<?php _e('Space separated list', 'flickr-manager'); ?></sup></td>
					</tr>
					<tr>
						<td><label for="photoDesc"><?php _e('Description', 'flickr-manager'); ?>:</label></td>
						<td><textarea name="photoDesc" id="flickrDesc" rows="4"></textarea></td>
					</tr>
				</tbody>
			</table>
			<div style="width: auto;">
				<input type="submit" name="Submit" class="button submit" value="<?php _e('Upload &raquo;', 'flickr-manager'); ?>" />
				<input type="hidden" name="faction" id="flickr-action" value="<?php echo $_REQUEST['faction']; ?>" />
			</div>
			
		</form>
	</div>
</body>

</html>
