<?php

if (isset($_POST['action']) && $_POST['action'] == 'auth'){
    if(!empty($_POST['frob'])) {
        $mediaFlickr->flickr_api_frob = $_POST['frob'];
    }
    $result = $mediaFlickr->flickrGetToken();
    if(!empty($result) && $result['stat'] == 'ok') {
        $mediaFlickr->update_settings(array(
            'username' => $result['auth']['user']['username'],
            'user_id' => $result['auth']['user']['nsid'],
        ));
    }else{
        $mediaFlickr->flickr_api_frob = null;
        $errors[] = __('Cannot get Flickr user informations.<br />Please authorization "Wordpress Media Flickr" on flickr.', 'wp-media-flickr');
    }
}
if (isset($_POST['action']) && $_POST['action'] == 'update'){
        unset($_POST['action']);
        $mediaFlickr->update_settings($_POST);
}
if (isset($_POST['action']) && $_POST['action'] == 'clear'){
    $mediaFlickr->update_settings(array(
        'username' => '',
        'user_id' => '',
    ));
}

$settings = $mediaFlickr->settings;
?>

<?php if(!empty($errors)): ?>
<div id="message" class="error fade"><p><strong><?php echo join('<br/>', $errors) ?></strong></p></div>
<?php elseif(!empty($_POST) && $_POST['action'] == 'update'): ?>
<div id="message" class="updated fade"><p><strong><?php _e('Flickr authorization complete.', 'wp-media-flickr') ?></strong></p></div>
<?php elseif(!empty($_POST) && $_POST['action'] == 'clear'): ?>
<div id="message" class="updated fade"><p><strong><?php _e('Flickr user informations are cleared.', 'wp-media-flickr') ?></strong></p></div>
<?php elseif(!empty($mediaFlickr->disabled)): ?>
<div id="message" class="updated fade"><p><strong><?php _e('Your PHP unsupported curl, and allow_url_fopen is disabled.<br />This is cause of cannot Flickr authentication.', 'wp-media-flickr') ?></strong></p></div>
<?php endif; ?>

<div class="wrap">
<h2><?php _e('Media Flickr', 'wp-media-flickr') ?></h2>

<h3><?php _e('User informations', 'wp-media-flickr') ?></h3>

<?php if(!empty($mediaFlickr->settings['username'])): ?>
<form name="mediaFlickr" method="post" onsubmit="return confirm('<?php _e('Are you sure you want to clear Flickr informations?', 'wp-media-flickr') ?>')">
<input type="hidden" name="action" value="clear" />
<table width="100%" cellspacing="2" cellpadding="5" class="form-table">
    <tr>
        <th width="33%" valign="top" scope="row"><?php _e('Flickr Username', 'wp-media-flickr') ?>: </th>
        <td>
            <?php echo htmlspecialchars($settings['username']); ?>
        </td>
    </tr>
    <tr>
        <th width="33%" valign="top" scope="row"><?php _e('Flickr User ID', 'wp-media-flickr') ?>: </th>
        <td>
            <?php echo htmlspecialchars($settings['user_id']); ?>
        </td>
    </tr>
</table>
<p class="submit"><input type="submit" value="<?php _e('Clear user informations &raquo;', 'wp-media-flickr'); ?>" /></p>
</form>
<?php else: ?>
<p>
<?php _e('Please authorization according to the following instruction.', 'wp-media-flickr') ?>
</p>
<form name="mediaFlickr" method="post" >
<input type="hidden" name="action" value="auth" />
<input type="hidden" name="frob" value="<?php echo $mediaFlickr->flickrGetFrob() ?>" />
<table width="100%" cellspacing="2" cellpadding="5" class="form-table">
    <tr>
        <th width="33%" valign="top" scope="row"><?php _e('Step1', 'wp-media-flickr') ?>: </th>
        <td>
            <input type="button" value="<?php _e('Flickr authenticate', 'wp-media-flickr') ?>" onclick="window.open('<?php echo $mediaFlickr->flickrGetAuthUrl() ?>')" />
        </td>
    </tr>
    <tr>
        <th width="33%" valign="top" scope="row"><?php _e('Step2', 'wp-media-flickr') ?>: </th>
        <td>
            <input type="submit" value="<?php _e('Finish authenticate', 'wp-media-flickr') ?>" />
        </td>
    </tr>
</table>
</form>
<?php endif; ?>

<h3><?php _e('Media Flickr Options', 'wp-media-flickr') ?></h3>

<form name="mediaFlickr" method="post" >
<input type="hidden" name="action" value="update" />
<table width="100%" cellspacing="2" cellpadding="5" class="form-table">
    <tr>
        <th width="33%" valign="top" scope="row"><?php _e('Link of photo', 'wp-media-flickr') ?>: </th>
        <td>
            <input type="radio" id="link_flickr" name="photo_link" value="0" <?php if(empty($settings['photo_link'])){ ?>checked="checked" <?php } ?>/> <label for="link_flickr"><?php _e('The photo page of Flickr', 'wp-media-flickr'); ?></label><br />
            <input type="radio" id="link_photo" name="photo_link" value="1" <?php if(!empty($settings['photo_link'])){ ?>checked="checked" <?php } ?>/> <label for="link_photo"><?php _e('The photo directly', 'wp-media-flickr'); ?></label><br />
        </td>
    </tr>
    <tr>
        <th width="33%" valign="top" scope="row"><?php _e('The "rel" attribute of link tag', 'wp-media-flickr') ?>: </th>
        <td>
            <input type="text" name="link_rel" value="<?php echo htmlspecialchars($settings['link_rel']); ?>" /><br />
            <small><?php _e("(if you want to use the Lightbox, set \"lightbox\")", 'wp-media-flickr'); ?></small>
        </td>
    </tr>
    <tr>
        <th width="33%" valign="top" scope="row"><?php _e('The "class" attribute of link tag', 'wp-media-flickr') ?>: </th>
        <td>
            <input type="text" name="link_class" value="<?php echo htmlspecialchars($settings['link_class']); ?>" /><br />
            <small><?php _e("(if you want to use the Lightview, set \"lightview\")", 'wp-media-flickr'); ?></small>
        </td>
    </tr>
</table>
<p class="submit"><input type="submit" value="<?php _e('Update options &raquo;', 'wp-media-flickr'); ?>" /></p>
</form>
</div>
