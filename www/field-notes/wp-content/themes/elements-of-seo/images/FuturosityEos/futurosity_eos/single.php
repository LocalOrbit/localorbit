<?php get_header() ?>

	<div id="container">
	<div id="nav-above" class="navigation">
				<div class="nav-previous"><?php previous_post_link('%link', '<span class="meta-nav">&laquo;</span> %title') ?></div>
				<div class="nav-next"><?php next_post_link('%link', '%title <span class="meta-nav">&raquo;</span>') ?></div>
			</div>

		<div id="content">

<?php the_post(); ?>
			
			<div id="post-<?php the_ID(); ?>" class="<?php sandbox_post_class(); ?>">
			<h3>Entry</h3>
				<h2 class="entry-title"><a href="<?php the_permalink(); ?>" title="<?php the_title(); ?>" rel="bookmark"><?php the_title(); ?></a></h2>
				
				<div class="entry-content">
				<div class="excerpt"><?php the_excerpt(); ?></div>
<?php the_content(''.__('Read More <span class="meta-nav">&raquo;</span>', 'sandbox').''); ?>
<?php if (function_exists('sharethis_button')) { sharethis_button(); } ?>

					<?php wp_link_pages('before=<div class="page-link">' .__('Pages:', 'sandbox') . '&after=</div>') ?>
				</div>
							</div><!-- .post -->
							
							<div class="entry-meta">
				<h3>Meta</h3>
					<?php printf(__('<ul><li>%1$s</li><li><abbr class="published" title="%2$sT%3$s">%4$s</abbr></li><li>Category: %6$s</li><li>%7$s</li><li><a href="%8$s" title="Permalink to %9$s" rel="bookmark">Permalink</a></li><li><a href="%10$s" title="Comments RSS to %9$s" rel="alternate" type="application/rss+xml">Comments RSS</a></li>', 'sandbox'),
						'<span class="author vcard"><a class="url fn n" href="'.get_author_link(false, $authordata->ID, $authordata->user_nicename).'" title="' . sprintf(__('View all posts by %s', 'sandbox'), $authordata->display_name) . '">'.get_the_author().'</a></span>',
						get_the_time('Y-m-d'),
						get_the_time('H:i:sO'),
						the_date('', '', '', false),
						get_the_time(),
						get_the_category_list(', '),
						get_the_tag_list(' '.__('Tags: ').' ', ', ', ''),
						get_permalink(),
						wp_specialchars(get_the_title(), 'double'),
						comments_rss() ) ?>

<?php if (('open' == $post-> comment_status) && ('open' == $post->ping_status)) : // Comments and trackbacks open ?>
					<?php printf(__('<li><a class="comment-link" href="#respond" title="Post a comment">Post a comment</a></li><li><a class="trackback-link" href="%s" title="Trackback URL for your post" rel="trackback">Trackback URL</a></li>', 'sandbox'), get_trackback_url()) ?>
<?php elseif (!('open' == $post-> comment_status) && ('open' == $post->ping_status)) : // Only trackbacks open ?>
					<?php printf(__('Comments are closed, but you can leave a trackback: <a class="trackback-link" href="%s" title="Trackback URL for your post" rel="trackback">Trackback URL</a>.', 'sandbox'), get_trackback_url()) ?>
<?php elseif (('open' == $post-> comment_status) && !('open' == $post->ping_status)) : // Only comments open ?>
					<?php printf(__('Trackbacks are closed, but you can <a class="comment-link" href="#respond" title="Post a comment">post a comment</a>.', 'sandbox')) ?>
<?php elseif (!('open' == $post-> comment_status) && !('open' == $post->ping_status)) : // Comments and trackbacks closed ?>
					<?php _e('Both comments and trackbacks are currently closed.') ?>
<?php endif; ?></ul>
<?php edit_post_link(__('Edit', 'sandbox'), "\n\t\t\t\t\t<span class=\"edit-link\">", "</span>"); ?>

				</div>


			<div id="nav-below" class="navigation">
				<?php if (function_exists('related_posts')) { ?>
			<h3>Related Posts</h3>
			<ul class="related">
			<?php related_posts(null, null, null, null, null, null, null, null, null, null, false); ?>
			</ul>
			<?php } ?>			
						<h3>Browse</h3>
				<div class="nav-previous"><?php previous_post_link('%link', '<span class="meta-nav">&laquo;</span> %title') ?></div>
				<div class="nav-next"><?php next_post_link('%link', '%title <span class="meta-nav">&raquo;</span>') ?></div>
			</div>

<?php comments_template(); ?>

		</div><!-- #content -->
	</div><!-- #container -->

<?php get_sidebar() ?>
<?php get_footer() ?>
