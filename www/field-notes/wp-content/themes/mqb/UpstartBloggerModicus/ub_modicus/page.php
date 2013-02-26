<?php get_header(); ?>

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
<div class="post" id="post-<?php the_ID(); ?>">
	<div class="entry">
				<?php the_content('<p class="serif">Read the rest of this entry &raquo;</p>'); ?>
	</div>
				<?php comments_template(); ?>
	<a href="#top" title="Return to Top"><img src="<?php bloginfo(template_directory); ?>/images/top.png" alt="Return to Top" width="20"/></a>
</div>
<div id="sidebar2">
	<h1><a href="<?php echo get_permalink() ?>" rel="bookmark" title="Permanent Link: <?php the_title(); ?>"><?php the_title(); ?></a>
	</h1>
	<p class="postmetadata alt">
		<small>
			Posted on <?php the_time('m.d.y') ?>
			to <?php the_category(', ') ?>.
			Grab the <?php comments_rss_link('feed'); ?>.

						<?php if (('open' == $post-> comment_status) && ('open' == $post->ping_status)) {
							// Both Comments and Pings are open ?>
							<?php comments_number('No comments yet.','One comment.','% comments.'); ?> <a href="#respond">Add your thoughts</a> or <a href="<?php trackback_url(true); ?>" rel="trackback">trackback</a> from your own site.

						<?php } elseif (!('open' == $post-> comment_status) && ('open' == $post->ping_status)) {
							// Only Pings are Open ?>
			Responses are currently closed, but you can <a href="<?php trackback_url(true); ?> " rel="trackback">trackback</a> from your own site.

						<?php } elseif (('open' == $post-> comment_status) && !('open' == $post->ping_status)) {
							// Comments are open, Pings are not ?>
			You can skip to the end and leave a response. Pinging is currently not allowed.

						<?php } elseif (!('open' == $post-> comment_status) && !('open' == $post->ping_status)) {
							// Neither Comments, nor Pings are open ?>
			Both comments and pings are currently closed.

						<?php } edit_post_link('Edit this entry.','',''); ?>
		</small>
	</p>

	
	
	<?php endwhile; else: ?>
	<p>Sorry, no posts matched your criteria.</p>

<?php endif; ?>

<?php get_sidebar(); ?>

<?php get_footer(); ?>