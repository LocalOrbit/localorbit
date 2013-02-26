<?php while (have_posts()) : the_post();?>
	<div class="article" id="post-<?php the_ID(); ?>">
  
		<?php if ( option::get('display_thumb') == 'on' ) {
	 
 			$custom_field = ( option::get( 'cf_use' ) == 'on' ) ? get_post_meta( $post->ID, option::get( 'cf_photo' ), true ) : '';
 			$args = array(  'size' => 'thumbnail', 'width' => option::get('thumb_width'), 'height' => option::get('thumb_height'), 'before' => '<div class="post-thumb">', 'after' => '</div>'  );
			if ($custom_field) { 
				$args['meta_key'] = option::get( 'cf_photo' );
			}
			get_the_image( $args );

			} ?>

		<div class="post-content">

			<?php if ( option::get('display_category') == 'on' ) { ?><span class="category"><?php the_category(' / '); ?></span> <?php } ?>

			<h2 class="title"><a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title_attribute(); ?>"><?php the_title(); ?></a></h2>

 			<div class="post-meta">
				<?php
				if (option::get('display_author') == 'on') { ?><span><?php _e('by', 'wpzoom'); ?> <?php the_author_posts_link(); ?></span> <span class="separator">&times;</span> <?php } 
 				if ( option::get('display_date') == 'on' ) { ?><span class="date"><?php printf( __('on %s at %s', 'wpzoom'),  get_the_date(), get_the_time()); ?></span> <span class="separator">&times;</span> <?php }
				if ( option::get('display_comm_count') == 'on' ) { ?><span class="comments"><?php comments_popup_link(__('0 comments', 'wpzoom'), __('1 comment', 'wpzoom'), __('% comments', 'wpzoom')); ?></span><?php }
				edit_post_link(__('Edit', 'wpzoom'), ' ', ' ');
				?>
			</div>
 
			<?php if ( option::get('display_type') == 'Post Excerpts' ) the_excerpt(); else { ?>

				<div class="entry">
					<?php the_content(); ?>
				</div>
			<?php } ?>
 
			<div class="clear"></div>
		</div><div class="clear"></div>
 
	</div> <!-- /.article -->
	
<?php endwhile; ?>
<?php get_template_part( 'pagination'); ?>
<?php wp_reset_query(); ?>