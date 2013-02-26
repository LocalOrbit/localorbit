<div class="clear"></div>
<div class="hr"></div>

<div id="columns">

	<?php
	for ( $i = 1; $i <= 4; $i++ ) {

		$catid = option::get('featured_category_' . $i);
		$cat = get_category($catid, false);

		if (is_wp_error($cat)) continue;

		$catlink = get_category_link($catid);
		$breaking_cat = "cat=$catid";

		?><div class="column<?php if ( $i == 1 ) echo '_first'; ?>">

			<?php
			query_posts('showposts=1&' . $breaking_cat);

			while ( have_posts() ) :

				the_post();

				?><span class="category"><?php echo"<a href=\"$catlink\">$cat->name</a>";?></span>
				 
 					<?php 
					$custom_field = ( option::get( 'cf_use' ) == 'on' ) ? get_post_meta( $post->ID, option::get( 'cf_photo' ), true ) : '';
  					$args = array( 'size' => 'featured-cat', 'width' => 210, 'height' => 140 );
					if ($custom_field) { 
						$args['meta_key'] = option::get( 'cf_photo' );
					}
					get_the_image( $args );

  					?>
 
				<h3 class="title"><a href="<?php the_permalink(); ?>" title="<?php the_title(); ?>"><?php the_title(); ?></a></h3>

				<?php the_excerpt(); ?>
  				
				<div class="post-meta">
					<?php
					if ( option::get('display_date') == 'on' ) { ?><span class="date"><?php echo get_the_date(); ?></span> <?php }
					if ( option::get('display_comm_count') == 'on' ) { ?><span class="comments"><?php comments_popup_link(__('0 comments', 'wpzoom'), __('1 comment', 'wpzoom'), __('% comments', 'wpzoom')); ?></span><?php }
					edit_post_link(__('Edit', 'wpzoom'), ' <span class="separator"> &times;</span> ', ' ');
					?>
				</div>
				
			
			<?php endwhile;	?>

		</div><?php

	}
	?>
	<div class="clear"></div>
</div> <!-- /#columns -->

<?php wp_reset_query(); ?>