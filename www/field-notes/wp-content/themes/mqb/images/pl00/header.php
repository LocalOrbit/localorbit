<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>

<head profile="http://gmpg.org/xfn/11">
<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />

<title><?php bloginfo('name'); ?> <?php if ( is_single() ) { ?> &raquo; Blog Archive <?php } ?> <?php wp_title(); ?></title>

<link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>" type="text/css" media="screen" />
<link rel="alternate" type="application/rss+xml" title="<?php bloginfo('name'); ?> RSS Feed" href="<?php bloginfo('rss2_url'); ?>" />
<link rel="pingback" href="<?php bloginfo('pingback_url'); ?>" />

<style type="text/css" media="screen">

		<!--[if IE 6]>
			<link rel="stylesheet" href="../css/ie6fix.css" type="text/css" media="screen">
		<![endif]-->
		
		<!--[if IE 7]>
			<link rel="stylesheet" href="../css/ie7fix.css" type="text/css" media="screen">
		<![endif]-->

</style>

<?php wp_head(); ?>
</head>

<body>
		<div id="WrapOuter">
		<div id="WrapInner">
		
		
			<div id="PageContainer">
			
				<div id="Header">
				
					<div id="MetaNav">
						<ul>
							<li><a href="<?php echo get_option('home'); ?>/">Home</a></li>
							<li><?php wp_loginout(); ?></li>
						</ul>
					</div><!-- end "MetaNav" div -->

					<div id="SiteTitle"><h1><a href="<?php echo get_option('home'); ?>/"><?php bloginfo('name'); ?></a></h1></div>
					<div id="SiteSubTitle"><?php bloginfo('description'); ?></div>
				
				</div><!-- end "Header" div -->
				
				<div id="MainNav">
					<ul>
						<?php wp_list_pages('title_li='); ?>
					</ul>
				</div><!-- end "MetaNav" div -->