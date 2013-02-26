<?php
/**
 *	@package WordPress
 *	@subpackage Grid_Focus
 */
get_header();
?>
<tr>
	<td colspan="2" style="padding: 15px;">
		<div class="wordpress_h1">field notes: news & resources for re-linking the food chain</div>
	</td>
</tr>
<tr>
	<td style="padding: 15px 170px 15px 15px;">
		<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
		<div id="post-<?php the_ID(); ?>" class="post">
			<div class="postMeta">
				<p class="container">
					<span class="date"><?php the_time('M j, Y') ?> by <?php the_author_posts_link(', '); ?></span>
                                   <!--	<span class="comments"><?php comments_popup_link('0', '1', '%'); ?></span>
				</p> -->
			</div>
			<h2><a href="<?php the_permalink() ?>" title="<?php the_title(); ?>"><?php the_title() ?></a></h2>
			<div class="entry">
				<?php the_content('Read the rest of this entry &raquo;'); ?>
			</div>
		</div>
		<?php endwhile; ?>
		<?php else : ?>
		<div class="post">
			<div class="postMeta">
				<p class="container">
					<span class="date">No Matches</span>
				</p>
			</div>
			<h2>No matching results</h2>
			<div class="entry">
				<p>You seem to have found a mis-linked page or search query with no matching results. Please trying your search again. If you feel that you should be staring at something a little more concrete, feel free to email the author of this site or browse the archives.</p>
			</div>
		</div>
		<?php endif; ?>
		<div id="paginateIndex" class="fix">
			<p><span class="left"><?php previous_posts_link('&laquo; Previous') ?></span> <span class="right"><?php next_posts_link('Next &raquo;') ?></span></p>
		</div>
	</td>
	<td style="padding: 15px;">
		<?php include (TEMPLATEPATH . '/second.column.index.php'); ?>
		<!-- <?php include (TEMPLATEPATH . '/second.column.index.php'); ?> -->
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