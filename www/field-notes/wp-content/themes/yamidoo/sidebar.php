<div id="sidebar">

	<?php
	if ( option::get('ad_side_select') == 'on' && option::get('ad_side_pos') == 'Before widgets' ) {

		?><div id="ads" class="widget">

			<?php if ( option::get('ad_side_code') <> "" ) {
				echo stripslashes(option::get('ad_side_code'));
			} else {
				?><a href="<?php echo option::get('ad_side_imgurl'); ?>"><img src="<?php echo option::get('ad_side_imgpath'); ?>" alt="<?php echo option::get('ad_side_imgalt'); ?>" /></a><?php
			} ?>

		</div><?php

	}
	
	if ( option::get('sidebar_thumb_show') == 'on' && ( is_single() || is_page() ) ) {
 
		$custom_field = ( option::get( 'cf_use' ) == 'on' ) ? get_post_meta( $post->ID, option::get( 'cf_photo' ), true ) : '';
			$args = array( 'width' => 310, 'image_class' => 'post-cover', 'size' => 'post-cover');
		if ($custom_field) { 
			$args['meta_key'] = option::get( 'cf_photo' );
		}
		get_the_image( $args );


	}

	if ( is_single() ) {
	
		if ( option::get('post_related') == 'on' && function_exists('wp_related_posts') ) wp_related_posts(); 
 	}

	if ( function_exists('dynamic_sidebar') ) {

		dynamic_sidebar('Sidebar');
		echo '<div id="sidebar_left">';
		dynamic_sidebar('Sidebar (half left)');
		echo '</div><div id="sidebar_right">';
		dynamic_sidebar('Sidebar (half right)');
		echo '</div>';

	}

	if ( option::get('ad_side_select') == 'on' && option::get('ad_side_pos') == 'After widgets' ) {

		?><div id="ads" class="widget">

			<?php if ( option::get('ad_side_code') <> "" ) {
				echo stripslashes(option::get('ad_side_code'));
			} else {
				?><a href="<?php echo option::get('ad_side_imgurl'); ?>"><img src="<?php echo option::get('ad_side_imgpath'); ?>" alt="<?php echo option::get('ad_side_imgalt'); ?>" /></a><?php
			} ?>

		</div><?php

	}
	?>

</div> <!-- /#sidebar -->