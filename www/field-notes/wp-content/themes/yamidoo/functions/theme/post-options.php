<?php

/* Custom Post Layouts
==================================== */

function wpzoom_post_layout_options() {
	global $post;
	$postLayouts = array('side-right' => 'Sidebar on the right', 'full' => 'Full Width');
	?>

	<style>
	.RadioClass { display: none; }
	.RadioLabelClass { margin-right: 10px; }
	img.layout-select { border: solid 4px #c0cdd6; border-radius: 5px; }
	.RadioSelected img.layout-select { border: solid 4px #3173b2; }
 	#wpzoom_post_embed_code { color: #444444; font-size: 11px; margin: 3px 0 10px; padding: 5px; height:135px; font-family: Consolas,Monaco,Courier,monospace; }

 	</style>

	<script type="text/javascript">
	jQuery(document).ready( function($) {
		$(".RadioClass").change(function(){
		    if($(this).is(":checked")){
		        $(".RadioSelected:not(:checked)").removeClass("RadioSelected");
		        $(this).next("label").addClass("RadioSelected");
		    }
		});
	});
	</script>

	<fieldset>
		<div>
 			<p>
 			<?php
			foreach ($postLayouts as $key => $value)
			{
				?>
				<input id="<?php echo $key; ?>" type="radio" class="RadioClass" name="wpzoom_post_template" value="<?php echo $key; ?>"<?php if (get_post_meta($post->ID, 'wpzoom_post_template', true) == $key) { echo' checked="checked"'; } ?> />
				<label for="<?php echo $key; ?>" class="RadioLabelClass<?php if (get_post_meta($post->ID, 'wpzoom_post_template', true) == $key) { echo' RadioSelected"'; } ?>">
				<img src="<?php echo wpzoom::$wpzoomPath; ?>/assets/images/layout-<?php echo $key; ?>.png" alt="<?php echo $value; ?>" title="<?php echo $value; ?>" class="layout-select" /></label>
			<?php
			}
			?>
 			</p>
   		</div>
	</fieldset>
	<?php
}



/* Register custom metaboxes
==================================== */

add_action('admin_menu', 'wpzoom_options_box');

	function wpzoom_options_box() {
		add_meta_box('wpzoom_post_layout', 'Post Layout', 'wpzoom_post_layout_options', 'post', 'normal', 'high');
		add_meta_box('wpzoom_post_embed', 'Post Options', 'wpzoom_post_embed_info', 'post', 'side', 'high');
  	}


function wpzoom_post_embed_info() {
	global $post;

	?>
	<fieldset>
		<p class="wpz_border">
			<?php $isChecked = ( get_post_meta($post->ID, 'wpzoom_is_featured', true) == 1 ? 'checked="checked"' : '' ); // we store checked checkboxes as 1 ?>
			<input type="checkbox" name="wpzoom_is_featured" id="wpzoom_is_featured" value="1" <?php echo $isChecked; ?> /> <label for="wpzoom_is_featured">Feature on Homepage?</label>
		</p>

		<p class="wpz_border" style="border-bottom:none; padding:0;">
			<strong>Embed Video for Slideshow</strong> (YouTube, Vimeo, etc.):<br />
				<textarea style="height: 110px; width: 255px;" name="wpzoom_post_embed_code" id="wpzoom_post_embed_code"><?php echo get_post_meta($post->ID, 'wpzoom_post_embed_code', true); ?></textarea>

		</p>

	</fieldset>
	<?php
}

add_action('save_post', 'custom_add_save');

function custom_add_save($postID){

	// called after a post or page is saved
	if($parent_id = wp_is_post_revision($postID))
	{
	  $postID = $parent_id;
	}

	if ($_POST['save'] || $_POST['publish']) {

		update_custom_meta($postID, $_POST['wpzoom_is_featured'], 'wpzoom_is_featured');
		update_custom_meta($postID, $_POST['wpzoom_post_template'], 'wpzoom_post_template');
 		update_custom_meta($postID, $_POST['wpzoom_post_embed_code'], 'wpzoom_post_embed_code');
  	}
}

function update_custom_meta($postID, $newvalue, $field_name) {
	// To create new meta
	if(!get_post_meta($postID, $field_name)){
	add_post_meta($postID, $field_name, $newvalue);
	}else{
	// or to update existing meta
	update_post_meta($postID, $field_name, $newvalue);
	}
}


?>