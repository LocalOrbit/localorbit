<?php
/*
Template Name: Links Page
*/
?>
<?php get_header() ?>
	
	<div id="container">
		<div id="content">

<?php the_post() ?>
<h3>Page</h3>
			<div id="post-<?php the_ID(); ?>" class="<?php sandbox_post_class() ?>">
				<h2 class="entry-title"><a href="<?php the_permalink(); ?>" title="<?php the_title(); ?>" rel="bookmark"><?php the_title(); ?></a></h2>
				<div class="excerpt"><p>These are some of my favorite <a href="http://www.futurosity.com/links" rel="bookmark" class="permalink" >Links</a>.</p></div>
				<div class="entry-content">


					<ul id="links-page" class="xoxo">
<?php wp_list_bookmarks('&title_before=<h3>&title_after=</h3>&title_li=&show_description=1') ?>

					</ul>
<?php edit_post_link(__('Edit', 'sandbox'),'<span class="edit-link">','</span>') ?>

				</div>
			</div><!-- .post -->

<?php if ( get_post_custom_values('comments') ) comments_template() // Add a key/value of "comments" to enable comments on pages! ?>

		</div><!-- #content -->
	</div><!-- #container -->

<?php get_sidebar() ?>
<?php get_footer() ?>