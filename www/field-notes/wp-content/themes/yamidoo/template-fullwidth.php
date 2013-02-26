<?php
/*
Template Name: Full Width
*/

get_header();
?>

<div class="full-width" id="main">

	<?php
	if ( have_posts() ) :

		while ( have_posts() ) :

			the_post();

			?>
			<div class="post" id="post-<?php the_ID(); ?>">
			
			<h1 class="title"><a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title_attribute(); ?>"><?php the_title(); ?></a></h1>
			<small><?php edit_post_link( __('Edit', 'wpzoom'), '  ', ''); ?></small>
			
				<div class="entry">
				<?php the_content(); ?>

				<?php wp_link_pages(array('before' => '<p><strong>Pages:</strong> ', 'after' => '</p>', 'next_or_number' => 'number')); ?>
				</div>
			
			</div><?php 
 
		endwhile;

	else:

		?><p><?php _e('Sorry, no posts matched your criteria.', 'wpzoom'); ?></p><?php

	endif;
	?>

</div>

<?php get_footer(); ?>