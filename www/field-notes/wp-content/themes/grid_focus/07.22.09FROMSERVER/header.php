<?php
require_once("navigation.php");
$nav = new Navigation();
$userId = $nav->userid;
$utype = $nav->usertypeID;
?>
<?php
/**
 *	@package WordPress
 *	@subpackage Grid_Focus
 */
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head profile="http://gmpg.org/xfn/11">
	<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />
	<title><?php if (function_exists('is_tag') && is_tag()) { echo 'Posts tagged &quot;'.$tag.'&quot; - '; } elseif (is_archive()) { wp_title(''); echo ' Archive - '; } elseif (is_search()) { echo 'Search for &quot;'.wp_specialchars($s).'&quot; - '; } elseif (!(is_404()) && (is_single()) || (is_page())) { wp_title(''); echo ' - '; } elseif (is_404()) { echo 'Not Found - '; } bloginfo('name'); ?></title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<meta name="generator" content="WordPress <?php bloginfo('version'); ?>" />
	<link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>" type="text/css" media="screen" />
	<link rel="alternate" type="application/rss+xml" title="<?php bloginfo('name'); ?> RSS Feed" href="<?php bloginfo('rss2_url'); ?>" />
	<script src="<?php bloginfo('template_url') ?>/js/jquery-1.2.6.min.js" type="text/javascript" charset="utf-8"></script>
	<script src="<?php bloginfo('template_url') ?>/js/functions.js" type="text/javascript" charset="utf-8"></script>
	<script type="text/javascript" src="http://localorb.it/MAGstore/js/lo/localOrbit.js"></script>
	<?php if ( is_singular() ) wp_enqueue_script( 'comment-reply' ); ?>
	<?php wp_head(); ?>
</head>
<body>
<div id="wrapper">
	
	<div id="masthead" class="fix">
	<div class="header">
<a href="../" onclick="addParams(this)"><img src="/img/common/logo.gif" alt="Local Orbit"  /></a>
   <div id="topNavBar">
<?php $nav->topUtilmenu(); ?>
    </div>
 <div  id="navigation">
<?php $nav->globalmenu(); ?>
	</div>


		
		<h1><a href="<?php echo get_settings('home'); ?>/"><?php bloginfo('name'); ?></a></h1>
		<div id="blogLead">
			
			
		</div>
	</div>
	
	<?php include (TEMPLATEPATH . '/navigation.strip.php'); ?>