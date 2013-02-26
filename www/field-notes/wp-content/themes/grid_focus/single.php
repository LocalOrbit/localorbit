<?php
/**
 *	@package WordPress
 *	@subpackage Grid_Focus
 */
get_header();
?>
<tr>
	<td>
		<a name="main"></a>
		<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
		<div id="post-<?php the_ID(); ?>" class="post">
			<div class="postMeta fix">
				<p class="container">
					<span class="date"><?php the_time('M j, Y') ?> by <?php the_author_posts_link(', '); ?><?php edit_post_link(' (Edit)', '', ''); ?></span>
				</p>
			</div>
			<h2><a href="<?php the_permalink() ?>" title="<?php the_title(); ?>"><?php the_title() ?></a></h2>
			<div class="entry">
				<?php the_content('<p>Read the rest of this entry &raquo;</p>'); ?>
			</div>
			<div class="entry meta">

                                <p><span class="highlight">Author:</span> <?php the_author_posts_link(', '); ?></p>
				<p><span class="highlight">Category:</span> <?php the_category(', ') ?></p>
				<p><span class="highlight">Tagged:</span> <?php the_tags( '', ', ', ''); ?></p>
			</div>
		</div>
		<div id="commentsContainer">
			<?php comments_template(); ?>
		</div>
		<?php endwhile; else: ?>
		<div class="post">
			<h2>No matching results</h2>
			<div class="entry">
				<p>You seem to have found a mis-linked page or search query with no associated results. Please trying your search again. If you feel that you should be staring at something a little more concrete, feel free to email the author of this site or browse the archives.</p>
			</div>
		</div>
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