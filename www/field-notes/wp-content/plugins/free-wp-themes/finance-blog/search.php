<?php get_header(); ?>


<div id="content">
<!--search.php-->

        <!--loop-->
	<?php if (have_posts()) : ?>
<div id="content_box">

		<h2>Search Results</h2>
		
                <!--to create links for the previous entries or the next-->
		<?php next_posts_link('&laquo; Previous Entries') ?>

		<?php previous_posts_link('Next Entries &raquo;') ?>
		

                <!--loop-->
		<?php while (have_posts()) : the_post(); ?>
				
			        <!--permalink of the post title-->
				<h1 id="post-<?php the_ID(); ?>"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a></h1>
		
			<!--show the category, edit link, comments-->
                           Posted in <?php the_category(', ') ?>
			
	        <!--loop-->
		<?php endwhile; ?>

		<!--to create links for the previous entries or the next-->
		<?php next_posts_link('&laquo; Previous Entries') ?>

		<?php previous_posts_link('Next Entries &raquo;') ?>
		
	
        <!--necessary do not delete-->
	<?php else : ?>

		No posts found. Try a different search?
                 <!--include searchform-->
		<?php include (TEMPLATEPATH . '/searchform.php'); ?>
        <!--do not delete-->
	<?php endif; ?>
</div>	
</div>
<!--search.php end-->

<!--include sidebar-->
<?php include(TEMPLATEPATH."/sidebar.php");?>

<!--include footer-->
<?php get_footer(); ?>