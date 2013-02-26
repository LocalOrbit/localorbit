<?php
/**
 * WPZOOM_Video_Thumb Class
 *
 * @package WPZOOM
 * @subpackage Video_Thumb
 */


class WPZOOM_Video_Thumb extends WPZOOM_Video_API {
	public static function init() {
		if(current_user_can('edit_posts')) {
			add_action('wp_ajax_wpzoom_autothumb_get', array(__CLASS__, 'admin_ajax_thumb_get'));
			if(current_user_can('upload_files')) add_action('wp_ajax_wpzoom_autothumb_attach', array(__CLASS__, 'admin_ajax_thumb_attach'));
			add_action('admin_head-post-new.php', array(__CLASS__, 'admin_newpost_head'), 100);
			add_action('admin_head-post.php', array(__CLASS__, 'admin_newpost_head'), 100);
			add_action('admin_footer-post-new.php', array(__CLASS__, 'admin_newpost_foot'), 100);
			add_action('admin_footer-post.php', array(__CLASS__, 'admin_newpost_foot'), 100);
		}
	}

	/**
	 * Called when we receive the AJAX call to fetch a thumbnail from a given URL
	 */
	public static function admin_ajax_thumb_get() {
		if (isset($_POST['wpzoom_autothumb_embedcode']) && isset($_POST['wpzoom_autothumb_postid'])) {
			$url = parent::extract_url_from_embed(trim(stripslashes($_POST['wpzoom_autothumb_embedcode'])));
			$postid = intval($_POST['wpzoom_autothumb_postid']);

			if(empty($url) || filter_var($url, FILTER_VALIDATE_URL) === false || $postid < 1) die('ERROR');

			$thumb_url = self::fetch_video_thumbnail($url, $postid);
			header('Content-type: application/json');
			die($thumb_url !== false ? json_encode($thumb_url) : 'ERROR');
		}
	}

	/**
	 * Called when we receive the AJAX call to attach a given thumbnail URL to a given post
	 */
	public static function admin_ajax_thumb_attach() {
		if(isset($_POST['wpzoom_autothumb_embedcode']) && isset($_POST['wpzoom_autothumb_postid']) && isset($_POST['wpzoom_autothumb_nonce'])) {
			$url = parent::extract_url_from_embed(trim(stripslashes($_POST['wpzoom_autothumb_embedcode'])));
			$postid = intval($_POST['wpzoom_autothumb_postid']);
			$nonce = trim($_POST['wpzoom_autothumb_nonce']);

			if(empty($url) || filter_var($url, FILTER_VALIDATE_URL) === false || $postid < 1 || !wp_verify_nonce($nonce, 'wpzoom_attach_thumbnail-' . $postid)) return false;

			header('Content-type: text/plain');
			$id = self::attach_remote_video_thumb($url, $postid);
			die($id !== false && $id > 0 ? '' . $id : 'false');
		}
	}

	/**
	 * Just some styles to make things look better
	 */
	public static function admin_newpost_head() {
		?><style type="text/css">
			#layout_select1 { position: relative; }
			#wpz_autothumb { position: relative; }
			#wpzoom_autothumb_preview { display: none; text-align: center; margin: 0; }
			#normal-sortables #wpzoom_autothumb_preview { display: none; text-align: left; margin: 0; }
			#wpzoom_autothumb_preview img { display: block; width: 100%; margin-bottom: 5px; }
			#normal-sortables #wpzoom_autothumb_preview img { display: block; width: 300px; margin-bottom: 5px; }
			#wpzoom_autothumb_preview #wpz_usethis { display: inline-block; text-align: center; line-height: 15px; padding: 3px 10px; cursor: pointer; }
			#normal-sortables #wpzoom_autothumb_preview #wpz_usethis { display: inline-block; text-align: left; line-height: 15px; padding: 3px 10px; cursor: pointer; }
			#wpzoom_autothumb_preview #wpz_usethis.button-disabled { cursor: default; }
			#wpz_autothumb_error { background-color: #ffffe0; padding: 5px 8px; border: 1px solid #e6db55; -webkit-border-radius: 3px; -moz-border-radius: 3px; border-radius: 3px; margin: 0; }
			#wpz_autothumb_error strong { display: inline-block; margin-bottom: 3px; }
			#wpz_autothumb_error small#wpz_autothumb_remind { display: block; line-height: 1.5; color: #a19a3c; margin-top: 8px; }
			#wpz_ajax_loading { display: block; position: absolute; left: 0; right: 0; z-index: 100; text-align: center; text-shadow: 0 0 5px #fff, 0 0 5px #fff, 0 0 5px #fff, 0 0 5px #fff, 0 0 5px #fff; color: #000; }
		</style><?php
	}


	/**
	 * All the JavaScript to make all the AJAX goodness work
	 */
	public static function admin_newpost_foot() {
		?><script type="text/javascript">
			var wpzVideoUrlInputTimeout,
					wpzValidIframeRegex = /<iframe[^>]* src="[^"]+"[^>]*><\/iframe>/i; // This isn't super strict... It just loosely checks to see if the string kinda looks like it contains an embed code.

			jQuery(function($){
				$('<div id="wpz_autothumb"><small id="wpz_ajax_loading" style="display:none">Loading...</small><p id="wpz_autothumb_error" class="updated" style="display:none"><?php _e('<strong>NOTICE!&nbsp;&nbsp;Unable to fetch video thumbnail</strong><br/>Either an invalid embed code was provided, or there is no thumbnail available for the specified video&hellip;<br/><small id="wpz_autothumb_remind"><strong>REMINDER:</strong> You can always manually upload a featured image via the WordPress Media Uploader.</small>', 'wpzoom'); ?></p><p id="wpzoom_autothumb_preview"><img src=""/><small id="wpz_usethis" class="button">Use This as the Featured Image</small></p></div>')
					.insertAfter('#wpzoom_post_embed_code');

				$('#wpzoom_autothumb_preview img').on('load', function(){
					$('#wpz_ajax_loading, #wpz_autothumb_error').hide();
					$('#wpzoom_autothumb_preview').animate({height:'show',opacity:'show'});
				});

				$('#wpzoom_post_embed_code').on('input', function(){
					clearTimeout(wpzVideoUrlInputTimeout);

					if('' != (val = $.trim($('#wpzoom_post_embed_code').val())) && wpzValidIframeRegex.test(val)) {
						$('#wpz_ajax_loading').fadeIn();

						wpzVideoUrlInputTimeout = setTimeout(WPZVideoUrlOnInput, 1000);
					} else {
						$('#wpz_ajax_loading, #wpz_autothumb_error').hide();

						WPZRemovePreviewImage();
					}
				}).triggerHandler('input');

				$('#wpz_usethis').on('click', WPZUseThisOnClick);

				$('#postimagediv').on('click', '#remove-post-thumbnail', WPZEnableSetFeaturedButton);
			});

			// This is called onInput if an actual embed code is provided
			function WPZVideoUrlOnInput() {
				var embed = jQuery.trim(jQuery('#wpzoom_post_embed_code').val());
				
				jQuery.ajax({
					url: ajaxurl,
					type: 'post',
					data: { action: 'wpzoom_autothumb_get', wpzoom_autothumb_embedcode: embed, wpzoom_autothumb_postid: jQuery('#post_ID').val() },
					dataType: 'json',
					complete: function(xhr,status){
						var response = xhr.responseText;

						if(response == 'ERROR') {
							WPZRemovePreviewImage();
							jQuery('#wpz_ajax_loading').hide();
							jQuery('#wpz_autothumb_error').show();
							return;
						}

						response = jQuery.parseJSON(response);

						var thumb_url = typeof response.thumb_url !== 'undefined' ? response.thumb_url : '',
								is_featured = typeof response.is_already_featured !== 'undefined' ? response.is_already_featured : false;

						if(thumb_url != '') {
							jQuery('#wpzoom_autothumb_preview img').attr('src', '' + thumb_url);

							if(is_featured == true) {
								WPZDisableSetFeaturedButton();
							} else {
								WPZEnableSetFeaturedButton();
							}
						} else {
							WPZRemovePreviewImage();
						}

						return;
					}
				});

				return;
			}

			// This is called when the "Use This as the Featured Image" button is clicked
			function WPZUseThisOnClick() {
				if('' != (embed = jQuery.trim(jQuery('#wpzoom_post_embed_code').val()))) {
					jQuery.ajax({
						url: ajaxurl,
						type: 'post',
						data: {
						        action: 'wpzoom_autothumb_attach',
						        wpzoom_autothumb_embedcode: embed,
						        wpzoom_autothumb_postid: jQuery('#post_ID').val(),
						        wpzoom_autothumb_nonce: '<?php global $post; echo wp_create_nonce('wpzoom_attach_thumbnail-' . $post->ID); ?>'
									},
						dataType: 'text',
						complete: function(xhr,status){
							var response = jQuery.trim(xhr.responseText);

							if(response != 'false' && response > 0) {
								WPZSetAsThumbnail(response, '<?php echo wp_create_nonce('set_post_thumbnail-' . $post->ID); ?>');
							}

							return;
						}
					});
				}

				return;
			}

			// Enable the "Use This as the Featured Image" button
			function WPZEnableSetFeaturedButton() {
				jQuery('#wpz_usethis')
					.html('Use This as the Featured Image')
					.off('click', WPZUseThisOnClick)
					.on('click', WPZUseThisOnClick)
					.removeClass('button-disabled');
			}

			// Disable the "Use This as the Featured Image" button
			function WPZDisableSetFeaturedButton() {
				jQuery('#wpz_usethis')
					.html('This is the Featured Image')
					.off('click', WPZUseThisOnClick)
					.addClass('button-disabled');
			}

			// Hide/Remove the preview image
			function WPZRemovePreviewImage() {
				jQuery('#wpzoom_autothumb_preview').hide().removeAttr('src');
			}

			// Almost the same as the core WPSetAsThumbnail function
			function WPZSetAsThumbnail(id, nonce) {
				jQuery.post(ajaxurl, {
					action: 'set-post-thumbnail',
					post_id: jQuery('#post_ID').val(),
					thumbnail_id: id,
					_ajax_nonce: nonce,
					cookie: encodeURIComponent(document.cookie)
				}, function(str){
					var win = window.dialogArguments || opener || parent || top;

					if(str != '0') {
						win.WPSetThumbnailID(id);
						win.WPSetThumbnailHTML(str);
						WPZDisableSetFeaturedButton();
					}
				}
				);
			}
		</script><?php
	}

	/**
	 * Fetches the thumbnail URL based on a given video URL using oEmbed
	 */
	public static function fetch_video_thumbnail($embed_url, $post_id) {
		$embed_url = trim($embed_url);
		$post_id = intval($post_id);

		if(empty($embed_url) || filter_var($embed_url, FILTER_VALIDATE_URL) === false || empty($post_id) || $post_id < 1) return false;

		$url = parent::convert_embed_url($embed_url);
		if($url === false) return false;

		require_once(ABSPATH . WPINC . '/class-oembed.php');
		$oembed = _wp_oembed_get_object();

		$provider = $oembed->discover($url);
		if(!$provider) return false;

		$data = $oembed->fetch($provider, $url);
		if(!$data) return false;

		$output['thumb_url'] = isset($data->thumbnail_url) && !empty($data->thumbnail_url) ? $data->thumbnail_url : '';

		$output['is_already_featured'] = self::thumb_isset_featured($output['thumb_url'], $post_id);

		return $output;
	}

	/**
	 * Downloads and attaches the given remote thumbnail to the given post and returns the ID
	 */
	public static function attach_remote_video_thumb($thumb_url, $post_id) {
		if(!current_user_can('upload_files')) return false;

		$thumb_url = trim($thumb_url);
		$post_id = intval($post_id);

		if(empty($thumb_url) || filter_var($thumb_url, FILTER_VALIDATE_URL) === false || empty($post_id) || $post_id < 1) return false;

		$fetch = self::fetch_video_thumbnail($thumb_url, $post_id);
		if($fetch === false || !isset($fetch['thumb_url']) || empty($fetch['thumb_url'])) return false;
		$url = $fetch['thumb_url'];

		if(false === ($id=self::thumb_attachment_exists($url, $post_id)) || $id < 1) {
			$id = self::media_sideload_image($url, $post_id);
			if(!is_wp_error($id) && $id !== false && $id > 0) {
				add_post_meta($id, '_wpz_original_thumb_url', $url);
				return $id;
			} else {
				return false;
			}
		}

		return $id !== false && $id > 0 ? $id : false;
	}

	/**
	 * Checks to see if the given thumbnail is already attached to the given post and returns the ID
	 */
	public static function thumb_attachment_exists($thumb_url, $post_id) {
		$thumb_url = trim($thumb_url);
		$post_id = intval($post_id);

		if(empty($thumb_url) || filter_var($thumb_url, FILTER_VALIDATE_URL) === false || empty($post_id) || $post_id < 1) return false;

		$db = get_children(array(
			'post_type' => 'attachment',
			'post_parent' => $post_id,
			'post_mime_type' => 'image',
			'meta_key' => '_wpz_original_thumb_url',
			'meta_value' => $thumb_url,
			'numberposts' => 1
		));

		if(empty($db)) return false;

		foreach($db as $attachment_id => $attachment) $id = $attachment_id;
		
		return !empty($id) && $id > 0 ? $id : false;
	}


	/**
	 * Checks to see if the given thumbnail is currently set as the featured image for the given post
	 */
	public static function thumb_isset_featured($thumb_url, $post_id) {
		$thumb_url = trim($thumb_url);
		$post_id = intval($post_id);

		if(empty($thumb_url) || filter_var($thumb_url, FILTER_VALIDATE_URL) === false || empty($post_id) || $post_id < 1) return false;

		$attachment_id = self::thumb_attachment_exists($thumb_url, $post_id);
		if($attachment_id === false || $attachment_id < 1) return false;

		$current_featured = get_post_thumbnail_id($post_id);
		return $current_featured == $attachment_id;
	}

	/**
	 * Pretty much the same as the core media_sideload_image() function but with just a couple changes
	 */
	public static function media_sideload_image($file, $post_id) {
		if ( ! empty($file) ) {
			require_once(ABSPATH . 'wp-admin/includes/image.php');
			require_once(ABSPATH . 'wp-admin/includes/file.php');
			require_once(ABSPATH . 'wp-admin/includes/media.php');

			// Download file to temp location
			$tmp = download_url( $file );

			// Set variables for storage
			// fix file filename for query strings
			preg_match('/[^\?]+\.(jpg|JPG|jpe|JPE|jpeg|JPEG|gif|GIF|png|PNG)/', $file, $matches);
			$file_array['name'] = basename($matches[0]);
			$file_array['tmp_name'] = $tmp;

			// If error storing temporarily, unlink
			if ( is_wp_error( $tmp ) ) {
				@unlink($file_array['tmp_name']);
				$file_array['tmp_name'] = '';
			}

			// do the validation and storage stuff
			$id = media_handle_sideload( $file_array, $post_id, $desc );
			// If error storing permanently, unlink
			if ( is_wp_error($id) ) {
				@unlink($file_array['tmp_name']);
				return $id;
			}

			return $id;
		}

		return false;
	}

	/**
	 * For use in the get_the_image plugin from the framework. Returns the remote video thumbnail URL for a given post
	 */
	public static function gettheimage_url($post_id) {
		$post_id = intval($post_id);
		if(empty($post_id) || $post_id < 1) return false;

		$embed_code = get_post_meta($post_id, 'wpzoom_post_embed_code', true);
		if(empty($embed_code)) return false;

		$url = parent::extract_url_from_embed(trim($embed_code));
		if($url === false) return false;

		$fetch = self::fetch_video_thumbnail($url, $post_id);
		return $fetch !== false && isset($fetch['thumb_url']) && !empty($fetch['thumb_url']) ? array('src' => $fetch['thumb_url']) : false;
	}
}
