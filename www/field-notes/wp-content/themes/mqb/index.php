<?php get_header(); ?>
  <div id="content">
  <?php if (have_posts()) : while (have_posts()) : the_post(); ?> 
<div id="main-<?php the_ID(); ?>" class="postMain">
<div class="post" id="post-<?php the_ID(); ?>"> 
<div class="postMeta"><span class="date"><?php the_time('M', ", "); ?> <?php the_time('d', ", "); ?>, <?php the_time('Y', ", "); ?></span><span class="comments"><?php comments_popup_link(__(' 0 '), __(' 1  '), __(' %  ')); ?> </span></div> 
<h2 class="post-title"><a title="Read more about: <?php the_title(); ?>" href="<?php the_permalink() ?>" rel="bookmark"><?php the_title(); ?></a></h2>
<h5> Categories: &nbsp;<?php the_category(', ') ?></h5>
<?php the_tags('<h5>Tags: ', ', ', '</h5>'); ?>
<div class="entry"><?php the_content(__('Read the rest of this entry &raquo;')); ?></div> 
<?php edit_post_link('Edit', '', ''); ?>
</div>
</div>
<?php comments_template(); ?>
<?php endwhile; else: ?> 
<p><?php _e('Sorry, no posts matched your criteria.'); ?></p> 
<?php include (TEMPLATEPATH . "/searchform.php"); ?>
<?php endif; 
if ((!is_single()) && ($wp_query->max_num_pages > 1)) {
__('<div id="more">continue: ');
posts_nav_link(__(' BROWSE '), __('<img src="'.get_bloginfo('template_directory').'/images/arrow_prev.gif" />'), __('<img src="'.get_bloginfo('template_directory').'/images/arrow_next.gif" />')); 
__('</div>');
}
?>
</div>
<?php get_sidebar(); ?>
<?php get_footer(); ?>