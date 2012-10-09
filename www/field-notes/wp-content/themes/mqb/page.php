<?php get_header(); ?>
<div id="content">
<?php if (have_posts()) : while (have_posts()) : the_post(); ?> 
<div id="main-<?php the_ID(); ?>" class="postMain">
<div class="post" id="post-<?php the_ID(); ?>"> 
<div class="postMeta"><span class="date"><a href="<?php the_permalink() ?>" rel="bookmark" title="<?php the_title(); ?>"><?php the_title(); ?></A></span></div> 
<div class="entry"><?php the_content(__('Read the rest of this entry &raquo;')); ?>	
<?php link_pages('<p><strong>Pages:</strong> ', '</p>', 'number'); ?>		
<?php edit_post_link('Edit', '', ''); ?></div> 
</div>
</div>
<?php comments_template(); ?>
<?php endwhile; else: ?> 
<h2>Not found!</h2>
<p><?php _e('Sorry, no pages matched your criteria.'); ?></p>
<?php include (TEMPLATEPATH . "/searchform.php"); ?>
<?php endif; ?>
</div>
<?php get_sidebar(); ?>
<?php get_footer(); ?>