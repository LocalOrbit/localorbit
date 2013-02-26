<?php get_header() ?>

	<div id="container">
<h3>Featured</h3>

<?php $my_query = new WP_Query('showposts=1');
  while ($my_query->have_posts()) : $my_query->the_post();
  $do_not_duplicate = $post->ID; ?>
<div class="featured-image-wrapper">
<h2 class="transparent"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title_attribute(); ?>"><?php the_title(); ?></a></h2>
<img src="<?php $key="featured-image"; echo get_post_meta($post->ID, $key, true); ?>" alt="" />
</div>
<?php endwhile; ?>

		<div id="content">	
<h3>Fresh</h3>	
<?php query_posts('showposts=7'); ?>
<?php while (have_posts()) : the_post(); 
  if( $post->ID == $do_not_duplicate ) continue; update_post_caches($posts); ?>
			<div id="post-<?php the_ID() ?>" class="<?php sandbox_post_class() ?>">
			
			<span class="cat-links"><?php printf(__('%s', 'sandbox'), get_the_category_list(', ')) ?></span>
				<h2 class="entry-title"><a href="<?php the_permalink() ?>" title="<?php printf(__('Permalink to %s', 'sandbox'), wp_specialchars(get_the_title(), 1)) ?>" rel="bookmark"><?php the_title() ?></a></h2>
				<div class="entry-content">

				<?php the_excerpt(); ?>

					</div>
						<div class="entry-date"><abbr class="published" title="<?php the_time('Y-m-d\TH:i:sO'); ?>"><?php unset($previousday); printf(__('%1$s', 'sandbox'), the_date('', '', '', false), get_the_time()) ?></abbr>
						<span class="meta-sep">|</span>
					</div>
						
				<div class="entry-meta">
				
					<span class="author vcard"><?php printf(__('%s', 'sandbox'), '<a class="url fn n" href="'.get_author_link(false, $authordata->ID, $authordata->user_nicename).'" title="' . sprintf(__('View all posts by %s', 'sandbox'), $authordata->display_name) . '">'.get_the_author().'</a>') ?></span>
					<span class="meta-sep">|</span>
					
					<span class="comments-link"><?php comments_popup_link(__('Add a Comment', 'sandbox'), __('1 Comment', 'sandbox'), __('% Comments', 'sandbox')) ?></span>
				</div>
			</div><!-- .post -->
<?php endwhile ?>


		</div><!-- #content -->
		
<div class="middle">
<?php if (function_exists('akpc_most_popular')) { ?>
  <h3>Favorites</h3>			
  	<ul>
  	<?php akpc_most_popular($limit = 5); ?>
  	</ul>
<?php } ?>   

<?php if (function_exists('get_recent_comments')) { ?>
   <h3>Comments</h3>
   <ul><?php get_recent_comments(); ?></ul>
<?php } ?>   

</div><!-- #middle -->
	</div><!-- #container -->

<?php get_sidebar() ?>
<?php get_footer() ?>