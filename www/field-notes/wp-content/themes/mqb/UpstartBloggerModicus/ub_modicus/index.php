<?php get_header(); ?>
<div class="post">
<div class="entry">
<p><?php bloginfo('description'); ?></p><br/>
	<?php if (have_posts()) : ?>
	
			<?php while (have_posts()) : the_post(); ?>
	<ul class="archive">
		<li><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a>
				
					<?php the_excerpt(); ?>
			<p class="postmetadata">Posted on <?php the_time('M d.y') ?> to <?php the_category(', ') ?> &nbsp;&nbsp;<?php edit_post_link('Edit', '', ''); ?></p>
			
		</li>
	</ul>

	<?php endwhile; ?>
	<?php endif; ?>
	<div class="navigation">
		<div class="alignleft"><?php next_posts_link('&laquo; Previous Entries') ?></div>
		<div class="alignright"><?php previous_posts_link('Next Entries &raquo;') ?></div>
	</div>
</div>
</div><!-- end post -->

<div id="sidebar2">
	<h1>Weclome to <?php bloginfo('name'); ?>.</h1>
	<p>
		<small>
			Here's where you add a little blurb about yourself and your site. For the latest information on the Upstart Blogger Modicus theme, visit <a href="http://www.upstartblogger.com/wordpress-theme-upstart-blogger-modicus">WordPress Theme: Upstart Blogger Modicus</a>. You can delete this text by editing the index.php file in the Modicus theme folder.
		</small>
	</p>
<?php get_sidebar(); ?>

<?php get_footer(); ?>