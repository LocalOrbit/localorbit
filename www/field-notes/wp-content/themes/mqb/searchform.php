	<div id="search">
		<form method="get" id="searchform" action="<?php bloginfo('url'); ?>">
		<input type="text" value="<?php echo wp_specialchars($s, 1); ?>" name="s" id="s" />
		<input id="searchsubmit" src="<?php bloginfo('template_url'); ?>/images/btn_search.gif"  alt="Submit" type="image" />
		</form>
	</div>
