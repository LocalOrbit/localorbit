<!-- begin r_sidebar -->

	<div id="r_sidebar">

	<?php if ( function_exists('dynamic_sidebar') && dynamic_sidebar(2) ) : else : ?>


	<h2>About</h2>
		<p>This is an area on your website where you can add text.  This will serve as an informative location on your website, where you can talk about your site.</p>



	<h2 id="feed"><a href="http://elementsofseo.com/?feed=rss">Subscribe to our feed</a></h2>

	

	<h2>Search</h2>
   		<form id="searchform" method="get" action="<?php echo $_SERVER['../stauffer/PHP_SELF']; ?>">
		<input type="text" alt="search this site" name="s" id="s" size="26" value="search this site..." /></form>

	

	<h2>Admin</h2>
	<ul>
	<?php wp_register(); ?>
	<li><?php wp_loginout(); ?></li>
	<li><a href="http://www.wordpress.org/">Wordpress</a></li>
	<?php wp_meta(); ?>
	<li><a href="http://validator.w3.org/check?uri=referer">XHTML</a></li>
	</ul>

		
		<?php endif; ?>

			
</div>

<!-- end r_sidebar -->