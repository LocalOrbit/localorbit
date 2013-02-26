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
	<?php if ( is_singular() ) wp_enqueue_script( 'comment-reply' ); ?>
	<?php wp_head(); ?>
</head>
<body>
<div id="wrapper">
	
	<div id="masthead" class="fix">
    <div class="header">
    <a href="../"><img src="http://www.localorb.it/img/common/logo.gif" alt="Local Orbit"  /></a>
    <div id="utilContainer">
		<div id="utilityUpperNav">
			<ul>
            <li class="homeLi"><a href="/" class="home" title="click to go to's local orbit home page"><span>home</span></a></li>
			<li class="cartLi"><a href="/cart.html" title="shop local orbit" class="cart"><span>cart</span></a></li>
			<li class="loginLi"><a href="/login.html" title="log into local orbit" class="login"><span>login</span></a></li>
			</ul>
		</div>
		<p class="utilNavDivider"></p>
		<div id="utilityLowerNav">
			<ul>
			
			<li class="helpLi"><a href="/help.html" class="help" title="find information about local orbit"><span>help</span></a></li>
			<li class="aboutLi"><a href="/about-us/index.html" class="about" title="about local orbit"><span>about us</span></a></li>
			<li class="signupLi"><a href="/signup.html" class="signup" title="signup for local orbit"><span>sign up</span></a></li>
			</ul>
		</div>
	</div>
	
		<div id="navigation">
			<ul>
			<li class="knowLi"><a href="http://localorb.it/know-local/index.html" title="know local" class="know knowHere" ><span>Know Local</span></a></li>
			<li class="sellLi"><a href="http://localorb.it/sell-local/index.html" title="sell local" class="sell"><span>Sell Local</span></a></li>
			<li class="buyLi"><a href="http://localorb.it/buy-local/index.html" title="buy local" class="buy"><span>Buy Local</span></a></li>
			</ul>
		</div>
		
	
</div>


		
		<h1><a href="<?php echo get_settings('home'); ?>/"><?php bloginfo('name'); ?></a></h1>
		<div id="blogLead">
			
			
		</div>
	</div>
	
	<?php include (TEMPLATEPATH . '/navigation.strip.php'); ?>