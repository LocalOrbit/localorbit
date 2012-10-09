<?php get_header(); ?>

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
<div class="post" id="post-<?php the_ID(); ?>">
	<div class="entry">
				<?php the_content('<p class="serif">Read the rest of this entry &raquo;</p>'); ?>
				

				<?php wp_link_pages(array('before' => '<p><strong>Pages:</strong> ', 'after' => '</p>', 'next_or_number' => 'number')); ?>
<br/>
	<ul>
		<li><b>BROWSE</b> / IN TIMELINE</li>
			<li><?php previous_post_link('&laquo; %link'); ?></li>
			<li><?php next_post_link('&raquo; %link'); ?></li>
		</ul>
				<ul>
				<li><b>BROWSE</b> / IN <span class="cat"><?php 
foreach((get_the_category()) as $cat) { 
echo $cat->cat_name . ' '; 
} ?>
			</span>
		</li>

			<li><?php previous_post_link('&laquo; %link', '%title', TRUE); ?></li>
			<li><?php next_post_link('&raquo; %link', '%title', TRUE); ?></li>
		</ul>

		
		<?php if ( function_exists('related_posts')) :?>
		<ul>
			<li><b>RELATED</b> / YOU MIGHT FIND THESE INTERESTING</li>
			<?php related_posts(); ?>
		</ul>
		<?php endif; ?>
			</div><!-- end entry -->
	
				<?php comments_template(); ?>
	<a href="#top" title="Return to Top"><img src="<?php bloginfo(template_directory); ?>/images/top.png" alt="Return to Top" width="20"/></a>

</div><!-- end post -->
<div id="sidebar2">
	<h1><a href="<?php echo get_permalink() ?>" rel="bookmark" title="Permanent Link: <?php the_title(); ?>"><?php the_title(); ?></a></h1>
	<p class="postmetadata alt">
		<small>
			Posted on <?php the_time('m.d.y') ?>
			to <?php the_category(', ') ?>. <?php if (function_exists('the_tags') ) : ?><?php the_tags('Tags: ', ', ', '. '); ?>
<?php endif; ?>

						<?php comments_rss_link('Subscribe'); ?> to follow comments on this post.

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

<?php endif; ?><?php get_sidebar(); ?>

<?php get_footer(); ?>