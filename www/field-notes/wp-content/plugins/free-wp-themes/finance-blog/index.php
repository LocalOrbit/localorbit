<?php 
get_header(); ?>


<div id="content">

<div id="topphoto"><img src="<?php bloginfo('template_url'); ?>/images/photo.jpg" border="0" alt="<?php bloginfo('name'); ?>" /></div>

	<!--index.php-->
        <!--the loop-->
	<?php if (have_posts()) : ?>
		<!--the loop-->
		<?php while (have_posts()) : the_post(); ?>
				
<div id="content_box">
			<!--post title as a link-->
<p><?php the_time('F j, Y'); ?></p>
				<h1 id="post-<?php the_ID(); ?>"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a></h1>
	<p><b>By <?php the_author(); ?></b></p>
		<div class="postspace2">
	</div>	
				<!--post text with the read more link-->
					<?php the_content('Read the rest of this entry »'); ?>
				<!--show categories, edit link ,comments-->
		
				<p><b>Topics:</b> <?php the_category(', ') ?> | <?php edit_post_link('Edit', '', ' | '); ?>  <?php comments_popup_link('No Comments »', '1 Comment »', '% Comments »'); ?></p>
		</div>		

<div class="postspace">
	</div>		
	        <!--end of one post-->
		<?php endwhile; ?>

		<!--navigation-->
                <div id="content_box"><?php next_posts_link('« Previous Entries') ?>
		<?php previous_posts_link('Next Entries »') ?></div>
		
	<!--do not delete-->
	<?php else : ?>

		Not Found
		Sorry, but you are looking for something that isn't here.
		<?php include (TEMPLATEPATH . "/searchform.php"); ?>
        <!--do not delete-->
	<?php endif; ?>

<!--index.php end-->
</div>
	
<!--include sidebar-->
<?php include(TEMPLATEPATH."/sidebar.php");?>


<!--include footer-->
<?php get_footer(); ?>
