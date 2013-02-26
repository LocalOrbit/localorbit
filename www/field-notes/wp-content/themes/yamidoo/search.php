<?php get_header(); ?>

<div id="articles">

	<h3 class="archive_title"><?php _e('Search Results for:', 'wpzoom'); ?> <?php the_search_query(); ?></h3>

	<?php if (have_posts()) :

		$post = $posts[0]; // Hack. Set $post so that the_date() works.

		get_template_part('loop');

	else :

		?><br/>
		<h2><?php _e('No results for:', 'wpzoom'); ?> <em>"<?php the_search_query(); ?>"</em></h2>
		<br/><?php
		get_template_part('searchform');

	endif; ?>

</div><!-- /#articles -->

<?php get_sidebar(); ?>

<?php get_footer(); ?>
