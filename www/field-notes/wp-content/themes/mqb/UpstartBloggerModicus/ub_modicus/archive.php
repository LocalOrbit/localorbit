<?php get_header(); ?>
<div class="post">
<div class="entry">
<p>Dive into the archives.</p><br/>
	<?php if (have_posts()) : ?>
	
			<?php while (have_posts()) : the_post(); ?>
	<ul class="archive">
		<li><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a>
				
					<?php the_excerpt(); ?>
			<p class="postmetadata">Posted on <?php the_time('M d.y') ?> to <?php the_category(', ') ?> &nbsp;&nbsp;<?php edit_post_link('Edit', '', ''); ?></p>
			
		</li>
	</ul>

	<?php endwhile; ?>
	<div class="navigation">
		<div class="alignleft"><?php next_posts_link('&laquo; Previous Entries') ?></div>
		<div class="alignright"><?php previous_posts_link('Next Entries &raquo;') ?></div>
	</div>
</div><!-- end entry -->
</div><!-- end post -->
<div id="sidebar2">
	<?php rewind_posts(); ?> 
		<?php if (have_posts()) : ?>

	<?php $post = $posts[0]; // Hack. Set $post so that the_date() works. ?>
<?php /* If this is a category archive */ if (is_category()) { ?>
	<h1><?php echo single_cat_title(); ?></h1>
	<p>
		<small>
			This is the archive for <?php echo single_cat_title(); ?>. <?php echo category_description(); ?>
		</small>
	</p>


 	  <?php /* If this is a daily archive */ } elseif (is_day()) { ?>
	<h1><?php the_time('F jS, Y'); ?></h1>

	 <?php /* If this is a monthly archive */ } elseif (is_month()) { ?>
	<h1><?php the_time('F'); ?></h1>
	<p>
		<small>
			This is the archive for <?php the_time('F, Y'); ?>.
		</small>
	</p>
		
		<?php /* If this is a yearly archive */ } elseif (is_year()) { ?>
	<h1><?php the_time('Y'); ?></h1>
	<p>
		<small>
			This is the archive for <?php the_time('Y'); ?>.
		</small>
	</p>
		

	  <?php /* If this is an author archive */ } elseif (is_author()) { ?>
	<h1>Author Archive</h1>
	<p>
		<small>
			This is the archive for <?php the_author(); ?>.
		</small>
	</p>

		<?php /* If this is a paged archive */ } elseif (isset($_GET['paged']) && !empty($_GET['paged'])) { ?>
	<h1>Blog Archive</h1>

		<?php } ?>

		
	<?php endif; else: ?>
	<p>Sorry, no posts matched your criteria.</p>

<?php endif; ?>

<?php get_sidebar(); ?>

<?php get_footer(); ?>