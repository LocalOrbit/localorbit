<?php get_header() ?>

	<div id="container">
		<div id="content">

<?php the_post() ?>
<h3>Archive</h3>
							
<?php if ( is_day() ) : ?>
			<h2 class="page-title"><?php printf(__('Daily Archives for <span>%s</span>', 'sandbox'), get_the_time(get_option('date_format'))) ?></h2><div class="excerpt"><p>It was a very good day. Dig in. Every entry is a classic.</p></div>
<?php elseif ( is_month() ) : ?>
			<h2 class="page-title"><?php printf(__('Monthly Archives for <span>%s</span>', 'sandbox'), get_the_time('F Y')) ?></h2><div class="excerpt"><p>It was a very good month. Dig in. Every entry is a classic.</p></div>
<?php elseif ( is_year() ) : ?>
			<h2 class="page-title"><?php printf(__('Yearly Archives for <span>%s</span>', 'sandbox'), get_the_time('Y')) ?></h2><div class="excerpt"><p>It was a very good year. Dig in. Every entry is a classic.</p></div>
<?php elseif ( isset($_GET['paged']) && !empty($_GET['paged']) ) : ?>
			<h2 class="page-title"><?php _e('Blog Archives', 'sandbox') ?></h2>
<?php endif; ?>

<?php rewind_posts() ?>

			<div id="nav-above" class="navigation">
				<div class="nav-previous"><?php next_posts_link(__('<span class="meta-nav">&laquo;</span> Older posts', 'sandbox')) ?></div>
				<div class="nav-next"><?php previous_posts_link(__('Newer posts <span class="meta-nav">&raquo;</span>', 'sandbox')) ?></div>
			</div>

<?php while ( have_posts() ) : the_post(); ?>

			<div id="post-<?php the_ID() ?>" class="<?php sandbox_post_class() ?>">
				<h3 class="entry-title"><a href="<?php the_permalink() ?>" title="<?php printf(__('Permalink to %s', 'sandbox'), wp_specialchars(get_the_title(), 1)) ?>" rel="bookmark"><?php the_title() ?></a></h3>
				
				<div class="entry-content">
<?php the_excerpt(''.__('Read More <span class="meta-nav">&raquo;</span>', 'sandbox').'') ?>

				</div>
				<div class="entry-meta">
				<div class="entry-date"><abbr class="published" title="<?php the_time('Y-m-d\TH:i:sO'); ?>"><?php unset($previousday); printf(__('%1$s', 'sandbox'), the_date('', '', '', false), get_the_time()) ?></abbr></div>
				<span class="meta-sep">|</span>
					<span class="author vcard"><?php printf(__('%s', 'sandbox'), '<a class="url fn n" href="'.get_author_link(false, $authordata->ID, $authordata->user_nicename).'" title="' . sprintf(__('View all posts by %s', 'sandbox'), $authordata->display_name) . '">'.get_the_author().'</a>') ?></span>
					<span class="meta-sep">|</span>
					<span class="cat-links"><?php printf(__('%s', 'sandbox'), get_the_category_list(', ')) ?></span>
					<span class="meta-sep">|</span>
					<?php the_tags(__('<span class="tag-links">Tags: ', 'sandbox'), ", ", "</span>\n\t\t\t\t\t<span class=\"meta-sep\">|</span>\n") ?>
<?php edit_post_link(__('Edit', 'sandbox'), "\t\t\t\t\t<span class=\"edit-link\">", "</span>\n\t\t\t\t\t<span class=\"meta-sep\">|</span>\n"); ?>
					<span class="comments-link"><?php comments_popup_link(__('Add a Comment', 'sandbox'), __('1 Comment', 'sandbox'), __('% Comments', 'sandbox')) ?></span>
				</div>
			</div><!-- .post -->

<?php endwhile ?>

			<div id="nav-below" class="navigation">
				<div class="nav-previous"><?php next_posts_link(__('<span class="meta-nav">&laquo;</span> Older posts', 'sandbox')) ?></div>
				<div class="nav-next"><?php previous_posts_link(__('Newer posts <span class="meta-nav">&raquo;</span>', 'sandbox')) ?></div>
			</div>

		</div><!-- #content .hfeed -->
	</div><!-- #container -->

<?php get_sidebar() ?>
<?php get_footer() ?>