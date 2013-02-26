<?php get_header(); ?>
	<div id="content">
				<h2>Not found!</h2>
				<p><?php _e('Sorry, no posts matched your criteria.'); ?></p>
				<?php include (TEMPLATEPATH . "/searchform.php"); ?>
	</div>
<?php get_sidebar(); ?>
<?php get_footer(); ?>