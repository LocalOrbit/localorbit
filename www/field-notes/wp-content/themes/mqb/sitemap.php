<?php
/*
Template Name: Sitemap
*/
?>
<?php get_header(); ?>
<div id="content">

					<div style="width:25%;float:left;">

						<h3>Site Feeds</h3>
						<ul class="archives">
							<li><a href="<?php bloginfo('rss2_url'); ?>">Main RSS Feed</a></li>
							<li><a href="<?php bloginfo('comments_rss2_url'); ?>">Comments RSS Feed</a></li>
						</ul>
						<h3>Pages</h3>
						<ul class="archives">
							<li><a href="<?php bloginfo('url'); ?>">Home</a></li>
							<?php wp_list_pages('title_li='); ?>
						</ul>
						<h3>Categories</h3>
						<ul class="archives">
							<?php wp_list_categories('title_li='); ?>
						</ul>
						<h3>Monthly Archives</h3>
						<ul class="archives">
							<?php wp_get_archives('type=monthly'); ?>
						</ul>
<?php if ( function_exists('wp_tag_cloud') ) : ?>
						<h3>Tags</h3>
						<?php wp_tag_cloud('smallest=9&largest=9&format=list'); ?>
<?php endif; ?>
					</div>
					<div style="float:right;width:72%;">
						<h3>All Articles</h3>
						<ol class="archives">
<?php query_posts('showposts=-1'); ?>
<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
							<li style="margin-bottom:10px;"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a><br /><?php the_time('j M y') ?> &bull; <?php the_author_posts_link(); ?> &bull; <?php comments_popup_link('0 comments', '1 comment', '% comments'); ?></li>
<?php endwhile; endif; ?>
						</ol>
					</div>
</div>
<?php get_sidebar(); ?>
<?php get_footer(); ?>