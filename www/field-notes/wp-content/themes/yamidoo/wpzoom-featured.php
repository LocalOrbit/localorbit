<?php
$featured = new WP_Query( array(
	'showposts' => 4,
	'post__not_in' => get_option('sticky_posts'),
	'meta_key' => 'wpzoom_is_featured',
	'meta_value' => 1
) );
?>

<div id="feature">

 	<div id="panes">

		<?php
		while( $featured->have_posts() ) :

			$featured->the_post();

			unset($videocode);
			$videocode = get_post_meta($post->ID, 'wpzoom_post_embed_code', true);

			?><div>

				<?php if ( strlen($videocode) > 1 ) {

					$videocode = preg_replace("/(width\s*=\s*[\"\'])[0-9]+([\"\'])/i", "$1 520 $2", $videocode);
					$videocode = preg_replace("/(height\s*=\s*[\"\'])[0-9]+([\"\'])/i", "$1 300 $2", $videocode);
					$videocode = str_replace("<embed", "<param name='wmode' value='transparent'></param><embed", $videocode);
					$videocode = str_replace("<embed", "<embed wmode='transparent' ", $videocode);
					?><span class="cover"><?php echo "$videocode"; ?></span><?php

				}

				if ( !$videocode ) {

					?><span class="overlay"><a href="<?php the_permalink(); ?>" title="<?php the_title(); ?>"><?php the_title(); ?></a></span>
					
					<?php

					$custom_field = ( option::get( 'cf_use' ) == 'on' ) ? get_post_meta($post->ID, option::get('cf_photo'), true) : '';
					$args = array( 'size' => 'slider', 'width' => 520, 'height' => 300, 'default_image' => 'http://placehold.it/520x300' );
					if ($custom_field) { 
						$args['meta_key'] = option::get( 'cf_photo' );
					}
					get_the_image( $args );

 				} // if a video does not exist

				?>


				<span class="post-info">

					<h3><a href="<?php the_permalink(); ?>" title="<?php the_title(); ?>"><?php the_title(); ?></a></h3>

					<ul class="meta-feature">
						<li><?php echo get_the_date(); ?></li>
						<li><span class="separator">&times;</span> <?php comments_popup_link( __('0 comments', 'wpzoom'), __('1 comment', 'wpzoom'), __('% comments', 'wpzoom')); ?></li>
						<?php edit_post_link( __('Edit', 'wpzoom'), ' <li> <span class="separator"> &times;</span> ', '</li>'); ?>
					</ul>

					<?php the_excerpt(); ?>

					<span class="more"><a href="<?php the_permalink(); ?>" title="<?php the_title(); ?>"><?php _e('Read more...', 'wpzoom'); ?></a></span>
				</span>

			</div><?php
		
		endwhile;
		?>

	</div>

 
 	<div id="navi">

		<ul>

			<?php
			while( $featured->have_posts() ) :

				$featured->the_post();

				?><li>
				
 					<?php
						$custom_field = ( option::get( 'cf_use' ) == 'on' ) ? get_post_meta($post->ID, option::get('cf_photo'), true) : '';
  						get_the_image( array( 'size' => 'slider-small', 'meta_key' => $custom_field, 'width' => 90, 'height' => 66, 'link_to_post' => false, 'before' => '<a href="#">', 'after' => '</a>', 'default_image' => 'http://placehold.it/90x66' ) ); 
 						?>

  				</li><?php

			endwhile;

			wp_reset_query();
			?>

		</ul>

	</div>

</div>