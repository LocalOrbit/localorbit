<div id="sidebarr">
<!--sidebar.php-->
<?php if ( !function_exists('dynamic_sidebar')
        || !dynamic_sidebar(2) ) : ?>
<!--links or blogroll-->
<div align="left"><a href="<?php bloginfo('rss2_url'); ?>"><img src="<?php bloginfo('template_url'); ?>/images/rss.png" alt="Feed" border="0" /></a></div>
<br />
<h2>Blogroll</h2>
<ul><?php get_links(-1, '<li>', '</li>', ' - '); ?></ul>
<br />

<!--archives ordered per month-->
<h2>Archives</h2>
<ul>
<?php wp_get_archives('type=monthly'); ?>
</ul>
<br />

<br />
<!--sidebar.php end-->
<?php endif; ?>
</div>
