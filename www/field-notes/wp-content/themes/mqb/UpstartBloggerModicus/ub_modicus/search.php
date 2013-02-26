<?php get_header(); ?>
<div class="post">
	<div class="entry">
		<p>Look what we found.</p><br/>
	</div>
	<ul class="archive">
<?php if (have_posts()) : ?>

		<?php while (have_posts()) : the_post(); ?>

		<li id="post-<?php the_ID(); ?>"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a>
				
					<?php the_excerpt_reloaded(15, '', 'excerpt', FALSE, '[more]', FALSE, 1, TRUE); ?>
			<p class="postmetadata">Posted on <?php the_time('M d.y') ?> to <?php the_category(', ') ?> &nbsp; <?php comments_popup_link('Add a Comment', '1 Comment', '% Comments'); ?> &nbsp;&nbsp;<?php edit_post_link('Edit', '', ''); ?>
			</p>
		</li>
	

		<?php endwhile; ?>
		</ul>

		<div class="navigation">
		<div class="alignleft"><?php next_posts_link('&laquo; Previous Entries') ?></div>
		<div class="alignright"><?php previous_posts_link('Next Entries &raquo;') ?></div>
	</div>

	<?php else : ?>
	<li>Hmm. Nothing. That's not what either one of us expected.</li>
	</ul>		
	

	<?php endif; ?>
</div>
<div id="sidebar2">
	<h1>Search Results</h1>
	<p>
		<small>
			Look what we found.
		</small>
	</p>
	<ul>
		<li><b>TRY</b> / AGAIN?</li>
		<li>
			<?php include (TEMPLATEPATH . '/searchform.php'); ?>		</li>
	</ul><br/>


<?php get_sidebar(); ?>

<?php get_footer(); ?>