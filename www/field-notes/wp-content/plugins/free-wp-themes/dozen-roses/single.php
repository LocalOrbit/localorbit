<?php get_header(); ?>


<div id="content">
<!--single.php-->
	
<!--loop-->			
  <?php if (have_posts()) : while (have_posts()) : the_post(); ?>

<div id="content_box">


	
		<!--post title-->

			<h1 id="post-<?php the_ID(); ?>"><a href="<?php echo get_permalink() ?>" rel="bookmark" title="Permanent Link: <?php the_title(); ?>"><?php the_title(); ?></a></h1>
	<div class="toptags">By <?php the_author(); ?> | <?php the_time('F j, Y'); ?></div>
<div class="postspace2">
	</div>			
<!--content with more link-->



			<?php the_content('<p class="serif">Read the rest of this entry &raquo;</p>'); ?>
	
                       <!--for paginate posts-->
			<?php link_pages('<p><strong>Pages:</strong> ', '</p>', 'number'); ?>

		
<div class="postspace">
	</div>

				<!--all options over and out-->
	
		
	<!--include comments template-->
	<?php comments_template(); ?>
	
<div class="tags"><?php previous_post_link('&laquo; %link  |') ?>  <a href="<?php bloginfo('url'); ?>">Home</a>  <?php next_post_link('|  %link &raquo;') ?></div>


        <!--do not delete-->
	<?php endwhile; else: ?>
	
	Sorry, no posts matched your criteria.

<!--do not delete-->
<?php endif; ?>
	
<!--single.php end-->
</div>
</div>

<!--include sidebar-->
<?php include(TEMPLATEPATH."/sidebar.php");?>


<!--include footer-->
<?php get_footer(); ?>