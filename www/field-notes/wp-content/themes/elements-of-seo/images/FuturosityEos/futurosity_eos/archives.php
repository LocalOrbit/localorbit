<?php
/*
Template Name: Archives Page
*/
?>
<?php get_header() ?>
	
	<div id="container">
		<div id="content">

<?php the_post() ?>
<h3>Page</h3>
			<div id="post-<?php the_ID() ?>" class="<?php sandbox_post_class() ?>">
				<h2 class="entry-title"><a href="<?php the_permalink(); ?>" title="<?php the_title(); ?>" rel="bookmark"><?php the_title(); ?></a></h2>
				<div class="excerpt"><p>These are the archives.</p></div>

				<div class="entry-content">
 					<ul id="archives-page" class="xoxo">
						<li id="category-archives" class="content-column">
							<h3><?php _e('Archives by Category', 'sandbox') ?></h3>
							<ul>
								<?php wp_list_categories('orderby=name&show_count=1&use_desc_for_title=1&title_li=') ?> 
							</ul>
						</li>
						<li id="monthly-archives" class="content-column">
							<h3><?php _e('Archives by Month', 'sandbox') ?></h3>
							<ul>
								<?php wp_get_archives('type=monthly&show_post_count=1') ?>
							</ul>
						</li>
						
						<li id="tags"><h3>Tags</h3>
		<?php wp_tag_cloud('smallest=8&largest=14'); ?>
		</li>

					</ul>
					
	

<?php edit_post_link(__('Edit', 'sandbox'),'<p class="edit-link">','</p>') ?>

				</div>
			</div><!-- .post -->

<?php if ( get_post_custom_values('comments') ) comments_template() // Add a key/value of "comments" to enable comments on pages! ?>

		</div><!-- #content -->
	</div><!-- #container -->

<?php get_sidebar() ?>
<?php get_footer() ?>