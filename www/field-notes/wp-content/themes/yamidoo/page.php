<?php get_header(); ?>

<div id="main">

	<div class="post">

		<?php
		if ( have_posts() ) :

			while ( have_posts() ) :

				the_post();

				?><div class="post" id="post-<?php the_ID(); ?>">

					<h1 class="title"><?php the_title(); ?></h1>
					<small><?php edit_post_link( __('Edit', 'wpzoom'), ' ', ''); ?></small>
					<div class="entry">
						<?php the_content(); ?>

						<?php wp_link_pages(array('before' => '<p><strong>Pages:</strong> ', 'after' => '</p>', 'next_or_number' => 'number')); ?>
						</div>

				</div><?php

			endwhile;

		else:

			?><p><?php _e('Sorry, no posts matched your criteria', 'wpzoom'); ?></p><?php

		endif;
		?>

	</div>
	
</div>

<?php get_sidebar(); ?>

<?php get_footer(); ?>
