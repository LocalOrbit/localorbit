<?php get_header(); ?>
<?php $template = get_post_meta($post->ID, 'wpzoom_post_template', true); ?>

<div id="main"<?php if ($template == 'full') {echo " class=\"full-width\"";} ?>>

	<?php if ( have_posts() ) : while ( have_posts() ) : the_post();	?>
			
 		<div id="post-<?php the_ID(); ?>" <?php post_class(); ?>>

			<?php if (option::get('post_category') == 'on') { ?><span class="category"><?php the_category(' / '); ?></span><?php } ?>
			
			<h1 class="title"><a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title_attribute(); ?>"><?php the_title(); ?></a></h1>

			<span class="post-meta">

				<?php if (option::get('post_author') == 'on') { ?><?php _e('Posted by', 'wpzoom'); ?> <?php the_author_posts_link(); ?><?php } ?>

				<?php if (option::get('post_date') == 'on') { ?><?php printf( __('on %s at %s', 'wpzoom'),  get_the_date(), get_the_time()); ?><?php } ?>

				<?php edit_post_link( __('Edit', 'wpzoom'), ' <span class="separator">&times;</span>  ', '' ); ?>
			
			</span>
			
			<div class="entry">

				<?php the_content(); ?>
				<div class="clear"></div>

 				<?php wp_link_pages( array( 'before' => '<div class="page-link"><span>' . __( 'Pages:', 'wpzoom' ) . '</span>', 'after' => '</div>' ) ); ?>

				<div class="clear"></div>
			
			</div>
			<div class="clear"></div>

			<?php if (option::get('post_tags') == 'on') {  the_tags( __( '<span class="tag-links">Tags: ', 'wpzoom' ), ", ", "</span>\n" ); } ?>

			<div class="clear"></div>

			<?php if ( option::get('post_share') == 'on' ) {

				?><div id="socialicons">

					<ul class="wpzoomSocial">
						<li><a href="http://twitter.com/share" data-url="<?php the_permalink(); ?>" class="twitter-share-button" data-count="horizontal">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></li>
						<li><iframe src="http://www.facebook.com/plugins/like.php?href=<?php echo urlencode(get_permalink($post->ID)); ?>&amp;layout=button_count&amp;show_faces=false&amp;width=110&amp;action=like&amp;font=arial&amp;colorscheme=light&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:110px; height:21px;" allowTransparency="true"></iframe></li>
						<li><g:plusone size="medium"></g:plusone></li>

					</ul>

				</div><div class="clear"></div><?php

			} ?>

			<?php if (option::get('post_authorbio') == 'on') { ?>		
				<div class="post_author">
					<?php echo get_avatar( get_the_author_meta('ID') , 70 ); ?>
					<span><?php _e('Author:', 'wpzoom'); ?> <?php the_author_posts_link(); ?></span>
					<?php the_author_meta('description'); ?><div class="clear"></div>
				</div>
			<?php } ?>

		</div><!-- /.post -->


		<?php if (option::get('post_comments') == 'on') { 
			comments_template();
		} ?>
		
		<?php endwhile; 
		
			else:

		?><p><?php _e('Sorry, no posts matched your criteria.', 'wpzoom');?></p><?php

	endif;
	?>

</div><!-- /#main -->

<?php if ($template != 'full') { 
	get_sidebar(); 
} else { echo "<div class=\"clear\"></div>"; } ?>

<?php get_footer(); ?>