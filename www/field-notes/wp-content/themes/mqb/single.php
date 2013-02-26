<?php get_header(); ?>
<div id="content">
<?php if (have_posts()) : while (have_posts()) : the_post(); ?> 
<div id="main-<?php the_ID(); ?>" class="postMain">
<div class="post" id="post-<?php the_ID(); ?>"> 
<div class="postMeta"><span class="date"><?php the_time('M', ", "); ?> <?php the_time('d', ", "); ?>, <?php the_time('Y', ", "); ?></span></div> 
<h2 class="post-title"><a href="<?php the_permalink() ?>" rel="bookmark" title="<?php the_title(); ?>"><?php the_title(); ?></a></h2>
<h5> Categories: &nbsp;<?php the_category(', ') ?></h5>
<div class="entry"><?php the_content(__('Read the rest of this entry &raquo;')); ?>	
<?php the_tags('<h5>Tags: ', ', ', '</h5>'); ?>
<?php link_pages('<p><strong>Pages:</strong> ', '</p>', 'number'); ?>		
<?php edit_post_link('Edit', '', ''); ?></div> 
</div>
</div>
<?php comments_template(); ?>
<?php endwhile; else: ?> 
<h2>Not found!</h2>
<p><?php _e('Sorry, no posts matched your criteria.'); ?></p>
<?php include (TEMPLATEPATH . "/searchform.php"); ?>
<?php endif; ?>
</div>
<?php get_sidebar(); ?>
<?php get_footer(); ?>