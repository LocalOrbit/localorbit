<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>

<head profile="http://gmpg.org/xfn/11">
<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />

<title><?php bloginfo('name'); ?> <?php if ( is_single() ) { ?> &raquo; Blog Archive <?php } ?> <?php wp_title(); ?></title>

<meta name="generator" content="WordPress <?php bloginfo('version'); ?>" /> <!-- leave this for stats -->

		<style type="text/css" media="screen">
			@import url( <?php bloginfo('stylesheet_url'); ?> );
		</style>
		
		<link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>" type="text/css" media="screen" />
		<link rel="alternate" type="application/rss+xml" title="<?php bloginfo('name'); ?> RSS Feed" href="<?php bloginfo('rss2_url'); ?>" />
		<link rel="pingback" href="<?php bloginfo('pingback_url'); ?>" />

	
	<!-- needed for apple style search box -->
	<link rel="stylesheet" type="text/css" href="default.css" id="default"  />
	<!-- dummy stylesheet - href to be swapped -->
	<link rel="stylesheet" type="text/css" href="dummy.css" id="dummy_css"  />
	
	<script type="text/javascript" src="applesearch.js"></script>
	
	<script type="text/javascript">
	//<![CDATA[
		window.onload = function () { applesearch.init(); }
	//]]>
	</script>

<?php wp_head(); ?>
</head>
<body>

	<a name="top"></a>
<div id="wrapper">
		<div id="header"><a href="<?php echo get_option('home'); ?>/"><img src="<?php bloginfo('template_directory'); ?>/images/m.jpg" alt="moto" /></a>
</div><!-- end header -->