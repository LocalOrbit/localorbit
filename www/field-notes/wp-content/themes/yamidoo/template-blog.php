<?php
/**
* Template Name: Blog
*/

get_header();
?>

<div id="articles">

	<h3 class="archive_title"><?php the_title(); ?></h3>

	<?php
	// WP 3.0 PAGED BUG FIX
	$paged = get_query_var('paged') ? get_query_var('paged') : ( get_query_var('page') ? get_query_var('page') : 1 );
	query_posts("paged=$paged");

	if ( have_posts() ) :

		get_template_part('loop');

	else :

		?> 
		<h2><?php _e('No Articles', 'wpzoom'); ?></h2><?php

	endif; ?>

</div>

<?php get_sidebar(); ?>

<?php get_footer(); ?>