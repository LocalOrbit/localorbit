<?php
require_once("../../../wp-config.php");
require_once("../../../wp-includes/wp-db.php");

header('Cache-Control: no-cache');
header('Pragma: no-cache');

switch($_REQUEST['faction']) {
	case 'browse':
		displayBrowse();
		break;
	case 'upload':
		displayUpload();
		break;
}

function displayBrowse() {
	global $flickr_manager, $flickr_settings;
	$token = $flickr_settings->getSetting('token');
	
	if(!empty($token)) {
		$params = array('auth_token' => $token);
		$auth_status = $flickr_manager->call('flickr.auth.checkToken',$params, true);
		if($auth_status['stat'] != 'ok') {
			echo '<h3>Error: Please authenticate through <a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$flickr_manager->plugin_directory/$flickr_manager->plugin_filename\">Options->Flickr</a></h3>";
			return;
		}
	} else {
		echo '<h3>Error: Please authenticate through <a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$flickr_manager->plugin_directory/$flickr_manager->plugin_filename\">Options->Flickr</a></h3>";
		return;
	}
	
	$_REQUEST['flightbox'] = $flickr_settings->getSetting('lightbox_enable');
	
	$is_pro = $flickr_settings->getSetting('is_pro');
	
	$page = (isset($_REQUEST['fpage']) && !empty($_REQUEST['fpage'])) ? $_REQUEST['fpage'] : '1';
	
	$exists = $flickr_settings->getSetting('per_page');
	if(!empty($exists)) $_REQUEST['fper_page'] = $exists;
	$per_page = (isset($_REQUEST['fper_page'])) ? $_REQUEST['fper_page'] : '5';
	
	$nsid = $flickr_settings->getSetting('nsid');
	$fscope = $_REQUEST['fscope'];
	$params = array('extras' => 'original_format,license,owner_name'); 
	
	if($fscope == "Personal") {
		$params = array_merge($params, array('user_id' => $nsid, 'auth_token' => $token));
	} else {
		$licences = $flickr_manager->call('flickr.photos.licenses.getInfo',array());
		$licence_search = array();
		for($i = 1; $i < count($licences['licenses']['license']); $i++) {
			array_push($licence_search,$i);
		}
		$licence_search = implode(',', $licence_search);
	}
	
	$size = (isset($_REQUEST['photoSize']) && !empty($_REQUEST['photoSize'])) ? $_REQUEST['photoSize'] : "thumbnail";
	if(($browse_check = $flickr_settings->getSetting('browse_check')) == "true") {
		$size = $flickr_settings->getSetting('browse_size');
	}
	
	if(isset($_REQUEST['filter']) && !empty($_REQUEST['filter'])) {
		$params = array_merge($params,array('tags' => $_REQUEST['filter'],'tag_mode' => 'all'));
	} elseif($fscope == "Public") {
		$params = array_merge($params,array('text' => " "));
	}
	
	if($fscope == "Public") {
		$params = array_merge($params, array('license' => $licence_search));
	}
	
	$params = array_merge($params,array('per_page' => $per_page, 'page' => $page));
	
	if($fscope == "Personal" && !empty($_REQUEST['fphotoset'])) {
		$params = array('per_page' => $per_page, 'page' => $page, 'extras' => 'original_format,license,owner_name', 'photoset_id' => $_REQUEST['fphotoset'], 'auth_token' => $token);
		if(isset($_REQUEST['filter']) && !empty($_REQUEST['filter'])) $params = array_merge($params,array('tags' => $_REQUEST['filter'],'tag_mode' => 'all'));
		$photos = $flickr_manager->call('flickr.photosets.getPhotos', $params, true);
		$photos['photos'] = $photos['photoset'];
		unset($photos['photoset']);
		$owner = $photos['photos']['owner'];
	} else {
		$photos = $flickr_manager->call('flickr.photos.search', $params, true);
	}
	
	$pages = $photos['photos']['pages'];
	
	$exists = $flickr_settings->getSetting('lightbox_default');
	$lightbox_default = ($exists) ? $exists : "medium";
	if(empty($_REQUEST['photoSize'])) $_REQUEST['photoSize'] = "thumbnail";
	?>
	
	<div id="flickr-browse">
			
		<?php foreach ($photos['photos']['photo'] as $photo) : ?>

		<div class="flickr-img <?php echo strtolower($fscope); ?>" id="flickr-<?php echo $photo['id']; ?>">
		
			<?php 
			if($fscope == "Personal" && !empty($_REQUEST['fphotoset'])) $photo['owner'] = $owner; 
			$patterns = array('/\&quot\;/','/\"/');
			$photo['title'] = preg_replace($patterns,"'",$photo['title']);
			?>
			
			
			<img src="<?php echo $flickr_manager->getPhotoUrl($photo,$size); ?>" alt="<?php echo str_replace("&amp;amp;","&amp;",str_replace("&","&amp;",$photo['title'])); ?>" onclick="return insertImage(this,'<?php echo $photo['owner']; ?>','<?php echo $photo['id']; ?>','<?php echo str_replace("'","&lsquo;",$photo['ownername']); ?>')" />
			
			<?php 
			if($fscope == "Public") {
				foreach ($licences['licenses']['license'] as $licence) {
					if($licence['id'] == $photo['license']) {
						if($licence['url'] == '') $licence['url'] = "http://www.flickr.com/people/{$photo['owner']}/";
						echo "<br /><small><a href='{$licence['url']}' title='{$licence['name']}' rel='license' id='license-{$photo['id']}' onclick='return false'><img src='".$flickr_manager->getAbsoluteUrl()."/images/creative_commons_bw.gif' alt='{$licence['name']}'/></a> by {$photo['ownername']}</small>";
					}
				}
			}
			?>
			<input type="hidden" id="url-<?php echo $photo['id']; ?>" value="<?php echo $flickr_manager->getPhotoUrl($photo,$_REQUEST['photoSize']); ?>" />
			
		</div>

		<?php endforeach; ?>
		
	</div>
	
	<div style="clear: both;">&nbsp;</div>
	
	<div style="float: left; text-align: left; width: 180px;">
		<div style="text-align:center;"><strong>Photosets</strong></div>
		<?php if($fscope == "Personal") : ?>
		
		<?php
		if(!empty($_REQUEST['fphotoset'])) {
			echo '<div style="text-align:center;"><a href="javascript:void(0);" onclick="return insertSet('."'{$_REQUEST['fphotoset']}');\" >Insert Set</a></div>\n";
		}
		?>
		
		<select name="flickr-photosets" id="flickr-photosets" onchange="performFilter('flickr-ajax');" style="width: 180px;">
			<option value="" <?php if(empty($_REQUEST['fphotoset'])) echo 'selected="selected"'; ?>></option>
					
			<?php	
			$photosets = $flickr_manager->call('flickr.photosets.getList', array('user_id' => $nsid), true);
			foreach ($photosets['photosets']['photoset'] as $photoset) :
			?>
			
			<option value="<?php echo $photoset['id']; ?>" <?php if($_REQUEST['fphotoset'] == $photoset['id']) echo 'selected="selected"'; ?>><?php echo $photoset['title']['_content']; ?></option>
		
			<?php endforeach; ?>
		
		</select><br />
		
		<?php endif; ?>
		
		<label><input type="checkbox" name="lbox-photoset" id="lbox-photoset" value="true" <?php if($_REQUEST['flbox-photoset'] == "true") echo 'checked="checked"'; ?> onchange="document.getElementById('fphotoset-name').focus();" /> Insert into a set </label><br /><label>with the name: 
		<input type="text" name="fphotoset-name" id="fphotoset-name" value="<?php echo $_REQUEST['fphotoset-name']; ?>" style="width: 70px; padding: 2px;" /></label>
		
	</div>
	
	<div style="float: right; text-align: left;">
		<div style="text-align:center;"><strong>Lightbox</strong></div>
		<label>Insert with lightbox: <input type="checkbox" id="flickr-lightbox" name="flickr-lightbox" value="1" <?php if($_REQUEST['flightbox'] == "true") echo 'checked="checked"'; ?>/></label>
		<br /><label>Lightbox size: <select name="flickr-lbsize" id="flickr-lbsize">
		<?php
		$lightbox_sizes = array("small","medium","large");
		foreach ($lightbox_sizes as $lightbox_size) {
			echo "<option value=\"flickr-$lightbox_size\"";
			if($lightbox_default == $lightbox_size) echo ' selected="selected"';
			echo ">" . ucfirst($lightbox_size) . "</option>\n";
		}
		?>
		</select></label>
	</div>
	
	<div id="flickr-nav">
			
		<?php if($page > 1) :?>
		
		<a href="#?faction=<?php echo $_REQUEST['faction']; ?>&amp;filter=<?php echo $_REQUEST['filter']; ?>&amp;fpage=1&amp;photoSize=<?php echo $_REQUEST['photoSize']; ?>" title="&laquo; First Page" onclick="return executeLink(this,'flickr-ajax')">&laquo;</a>&nbsp;
		<a href="#?faction=<?php echo $_REQUEST['faction']; ?>&amp;filter=<?php echo $_REQUEST['filter']; ?>&amp;fpage=<?php echo $page - 1; ?>&amp;photoSize=<?php echo $_REQUEST['photoSize']; ?>" title="&lsaquo; Previous Page" onclick="return executeLink(this,'flickr-ajax')">&lsaquo;</a>&nbsp;
		
		<?php endif; ?>
		
		<label>Filter: 
		<input type="text" name="filter" id="flickr-filter" value="<?php echo $_REQUEST['filter']; ?>" onkeypress="return kH(event);" />
		</label>
		<input type="hidden" name="faction" id="flickr-action" value="<?php echo $_REQUEST['faction']; ?>" />
		<input type="hidden" name="fpage" id="flickr-page" value="<?php echo $_REQUEST['fpage']; ?>" />
		<input type="hidden" name="fold_filter" id="flickr-old-filter" value="<?php echo $_REQUEST['filter']; ?>" />
		<input type="hidden" name="flickr_blank" id="flickr_blank" value="<?php echo $flickr_settings->getSetting('new_window'); ?>" />
		<input type="submit" class="button" name="button" value="Filter" onclick="return performFilter('flickr-ajax')"/>
		
		<?php if($page < $pages) :?>
		
		&nbsp;<a href="#?faction=<?php echo $_REQUEST['faction']; ?>&amp;filter=<?php echo $_REQUEST['filter']; ?>&amp;fpage=<?php echo $page + 1; ?>&amp;photoSize=<?php echo $_REQUEST['photoSize']; ?>" title="Next Page &rsaquo;" onclick="return executeLink(this,'flickr-ajax')">&rsaquo;</a>
		&nbsp;<a href="#?faction=<?php echo $_REQUEST['faction']; ?>&amp;filter=<?php echo $_REQUEST['filter']; ?>&amp;fpage=<?php echo $pages; ?>&amp;photoSize=<?php echo $_REQUEST['photoSize']; ?>" title="Last Page &raquo;" onclick="return executeLink(this,'flickr-ajax')">&raquo;</a>
		
		<?php endif; ?>
		<br>
		<?php 
		$sizes = array("square", 'thumbnail', 'small', 'medium', 'large'); 
		if(!empty($is_pro)) $sizes = array_merge($sizes,array('original'));
		?>
		<label>Size: <select name="photoSize" id="flickr-size" onchange="return performFilter('flickr-ajax')">
		
			<?php
			if(empty($_REQUEST['photoSize'])) $_REQUEST['photoSize'] = "thumbnail";
			foreach ($sizes as $v) {
				echo '<option value="' . strtolower($v) . '" ';
				if($v == $_REQUEST['photoSize']) echo 'selected="selected" ';
				echo '>' . ucfirst($v) . "</option>\n";
			}
			?>
			
		</select></label>
		
		<input type="hidden" name="wfm-insert-before" id="wfm-insert-before" value="<?php 
			$settings['before_wrap'] = str_replace("\n", "", $settings['before_wrap']);
			echo rawurlencode($settings['before_wrap']);
		?>" />
		<input type="hidden" name="wfm-insert-after" id="wfm-insert-after" value="<?php 
			$settings['after_wrap'] = str_replace("\n", "", $settings['after_wrap']);
			echo rawurlencode($settings['after_wrap']);
		?>" />
		
		<div style="width: 100%; height: 1%; clear: both;"></div>
	</div>
	
	<?php
}



function displayUpload() {
	global $flickr_manager, $flickr_settings;
	$token = $flickr_settings->getSetting('token');
	
	if(!empty($token)) {
		$params = array('auth_token' => $token);
		$auth_status = $flickr_manager->call('flickr.auth.checkToken',$params, true);
		if($auth_status['stat'] != 'ok') {
			echo '<h3>Error: Please authenticate through <a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$flickr_manager->plugin_directory/$flickr_manager->plugin_filename\">Options->Flickr</a></h3>";
			return;
		}
	} else {
		echo '<h3>Error: Please authenticate through <a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$flickr_manager->plugin_directory/$flickr_manager->plugin_filename\">Options->Flickr</a></h3>";
		return;
	}
	
	echo '<iframe id="flickr-uploader" name="flickr-uploader" src="'.$flickr_manager->getAbsoluteUrl().'/upload.php"></iframe>';
}

?>
