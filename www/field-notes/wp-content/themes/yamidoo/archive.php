<?php get_header(); 
	if ( is_author() ) {
		$curauth = (isset($_GET['author_name'])) ? get_user_by('slug', $author_name) : get_userdata(intval($author));
	}
?>

<div id="articles">

	<?php if ( have_posts() ) the_post(); ?>

	<h3 class="archive_title">
		<?php /* category archive */ if (is_category()) { ?> <?php single_cat_title(); ?>
		<?php /* tag archive */ } elseif( is_tag() ) { ?><?php _e('Post Tagged with:', 'wpzoom'); ?> "<?php single_tag_title(); ?>"
		<?php /* daily archive */ } elseif (is_day()) { ?><?php _e('Archive for', 'wpzoom'); ?> <?php the_time('F jS, Y'); ?>
		<?php /* monthly archive */ } elseif (is_month()) { ?><?php _e('Archive for', 'wpzoom'); ?> <?php the_time('F, Y'); ?>
		<?php /* yearly archive */ } elseif (is_year()) { ?><?php _e('Archive for', 'wpzoom'); ?> <?php the_time('Y'); ?>
		<?php /* author archive */ } elseif (is_author()) { ?><?php _e( ' Articles written by: ', 'wpzoom' ); echo $curauth->display_name; ?>  
 		<?php /* paged archive */ } elseif (isset($_GET['paged']) && !empty($_GET['paged'])) { ?><?php _e('Archives', 'wpzoom'); } ?>
 	</h3>

	<?php
	if ( is_author() ) {
		?><div class="author-info">
			<?php echo get_avatar( get_the_author_meta('ID'), 65 ); ?>
			<p><?php the_author_meta( 'description' ); ?></p>
			<div class="clear"></div>
		</div><?php
	}

	rewind_posts();

	get_template_part('loop');
	?>

</div>

<?php get_sidebar(); ?>

<?php get_footer(); ?>