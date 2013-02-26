<?php get_header(); ?>


<div id="content">
	<!--the loop-->
<div id="content_box">
		<?php if (have_posts()) : ?>

		<?php $post = $posts[0]; // Hack. Set $post so that the_date() works. ?>
<?php /* If this is a category archive */ if (is_category()) { ?>				
		<h2><?php echo single_cat_title(); ?></h2>
		
 	  <?php /* If this is a daily archive */ } elseif (is_day()) { ?>
		<h2>Archive for <?php the_time('F jS, Y'); ?></h2>
		
	 <?php /* If this is a monthly archive */ } elseif (is_month()) { ?>
		<h2>Archive for <?php the_time('F, Y'); ?></h2>

		<?php /* If this is a yearly archive */ } elseif (is_year()) { ?>
		<h2>Archive for <?php the_time('Y'); ?></h2>
		
	  <?php /* If this is a search */ } elseif (is_search()) { ?>
		<h2>Search Results</h2>
		
	  <?php /* If this is an author archive */ } elseif (is_author()) { ?>
		Author Archive

		<?php /* If this is a paged archive */ } elseif (isset($_GET['paged']) && !empty($_GET['paged'])) { ?>
		Blog Archives

               <!--do not delete-->
		<?php } ?>


		<!-- navigation-->

               <?php next_posts_link('&laquo; Previous Entries') ?>
		<?php previous_posts_link('Next Entries &raquo;') ?>
		
                <!--loop article begin-->
		<?php while (have_posts()) : the_post(); ?>
		                <!--post title as a link-->
<div class="postspace3">
	</div>	
				<h1 id="post-<?php the_ID(); ?>"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a></h1>
                                <!--post time-->

				
			<!--optional excerpt or automatic excerpt of the post-->
				<?php the_excerpt(); ?>

			
	       <!--one post end-->
		<?php endwhile; ?>
                
               <!-- navigation-->
               <?php next_posts_link('&laquo; Previous Entries') ?>
		<?php previous_posts_link('Next Entries &raquo;') ?>
	<!-- do not delete-->
	<?php else : ?>

		Not Found
		<?php include (TEMPLATEPATH . '/searchform.php'); ?>

         <!--do not delete-->
	<?php endif; ?>
		
	
<!--archive.php end-->
</div>
</div>

<!--include sidebar-->
<?php include(TEMPLATEPATH."/sidebar.php");?>

<!--include footer-->
<?php get_footer(); ?>