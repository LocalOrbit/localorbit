<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>

<head profile="http://gmpg.org/xfn/11">
<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />

<title><?php wp_title('&laquo;', true, 'right'); ?> <?php bloginfo('name'); ?></title>

<link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>" type="text/css" media="screen" />
<!--[if lt IE 7]><style type="text/css">
.sidebars li {display:inline-block;padding-top:1px;}
</style><![endif]-->

<link rel="alternate" type="application/rss+xml" title="<?php bloginfo('name'); ?> RSS Feed" href="<?php bloginfo('rss2_url'); ?>" />
<link rel="alternate" type="application/atom+xml" title="<?php bloginfo('name'); ?> Atom Feed" href="<?php bloginfo('atom_url'); ?>" />
<link rel="pingback" href="<?php bloginfo('pingback_url'); ?>" />

<?php wp_head(); ?>
</head>
<body>
<div class="wrapper">

    <div class="header"><!--alternate-header-nav-
    <ul class="topnav"> 
        <li><a href="<?php echo get_settings('home'); ?>">Home</a></li>
        <?php wp_list_pages('title_li=&depth=1'); ?>
        <li class="searchbox"><form id="searchformtop" method="get" action="<?php echo $_SERVER['PHP_SELF']; ?>"><input type="text" name="s" id="s" size="25" onclick="if(this.value == 'Search...') this.value='';" onblur="if(this.value.length == 0) this.value='Search...';" value="Search..." tabindex="1" /></form></li>
    </ul> -->
    <div class="clr"></div>
    <h1 class="marginleft"><a href="<?php echo get_settings('home'); ?>"><?php bloginfo('name');?></a></h1>
    <h3 class="marginleft"><?php bloginfo('description'); ?></h3>
    <div class="clr"></div>
    <ul class="bottomnav">
        <li><a href="<?php echo get_settings('home'); ?>">Home</a></li>
        <?php wp_list_pages('title_li=&depth=1'); ?>
        <li class="searchbox"><form id="searchformbottom" method="get" action="<?php echo $_SERVER['PHP_SELF']; ?>"><input type="text" name="s" id="s" size="25" onclick="if(this.value == 'Search...') this.value='';" onblur="if(this.value.length == 0) this.value='Search...';" value="Search..." tabindex="1" /></form></li>
    </ul> 
    <!--<div class="solidline"></div>-->
    </div>