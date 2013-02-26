<?php
/**
 *	@package WordPress
 *	@subpackage Grid_Focus
 */
get_header();
?>
<tr>
	<td>

		<h1 style="float:left; margin-top: 0px;"><a href="<?php echo get_settings('home'); ?>/"><?php bloginfo('name'); ?></a></h1>
		<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
		<div id="post-<?php the_ID(); ?>" class="post">
			<div class="postMeta">
				<p class="container">
					<span class="date">&nbsp;<?php edit_post_link(' (Edit)', '', ''); ?></span>
				</p>
			</div>
			<h2><a href="<?php the_permalink() ?>" title="<?php the_title(); ?>"><?php the_title() ?></a></h2>
			<div class="entry">
				<?php the_content('<p class="serif">Read the rest of this entry &raquo;</p>'); ?>
			</div>
		</div>
		<?php endwhile; else: ?>
		<?php endif; ?>
	</td>
	<td>
		<?php include (TEMPLATEPATH . '/second.column.post.php'); ?>
		<?php include (TEMPLATEPATH . '/third.column.shared.php'); ?>

		<?php function_exists('apture_script') && apture_script(); ?>
		
	</td>
</tr>
<tr>
	<td colspan="2">
		<?php wp_footer(); ?>
	</td>
</tr>

<?php get_footer(); ?>