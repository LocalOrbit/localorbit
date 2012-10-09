<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" <?php if (function_exists('language_attributes')) { language_attributes(); } ?>>

<head profile="http://gmpg.org/xfn/11">

    <title><?php bloginfo('name'); ?><?php if ( !(is_404()) && (is_single()) or (is_page()) or (is_archive()) ) { ?> | <?php } ?><?php wp_title(''); ?>
    </title>
    
    <meta http-equiv="content-type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />       
    <meta name="generator" content="WordPress <?php bloginfo('version'); ?>" /> <!-- leave this for stats -->
    
    <link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>" type="text/css" media="screen, projection" />
    
    <!--[if lt IE 7]>
	    <link rel="stylesheet" href="<?php bloginfo('stylesheet_directory'); ?>/ie.css" type="text/css" media="screen, projection">
    <![endif]-->
    
    <link rel="alternate" type="application/rss+xml" title="<?php bloginfo('name'); ?> RSS Feed" href="<?php bloginfo('rss2_url'); ?>" />
	<link rel="pingback" href="<?php bloginfo('pingback_url'); ?>" />
    
    <link rel="shortcut icon" href="<?php bloginfo('stylesheet_directory'); ?>/images/favicon2.ico" />

	<?php if ( is_singular() ) wp_enqueue_script('comment-reply'); ?>
    
    <?php wp_head(); ?>

</head>

<body>   <!--start body-->

    <div class="container">   <!--start container-->
    
        <div id="header" class="column span-14">
        
            <div id="logo" class="column first">
            
                <div class="title">
                    <div><a href="<?php echo get_option('home'); ?>/"><?php bloginfo('name'); ?></a></div>
                    <div class="desc"><?php bloginfo('description'); ?></div>                    
                </div>
        
			<!--<a href="<?php echo get_option('home'); ?>/" title="<?php bloginfo('description'); ?>: Home" class="sitelogo"></a>-->
            
            </div>
            
            <div id="search_menu" class="column span-6 border_left last push-0">
            
                <div id="search" class="column first">
                    <h3 class="mast4">Search</h3>
                    
                    <div id="search-form">                  
                        <form method="get" id="searchform" action="<?php bloginfo('url'); ?>/">
                            
						<div><label for="s" class="none">Search for:</label>
						<input type="text" name="s" id="s" class="search_input" value="<?php the_search_query(); ?>" />
						
						<label for="searchsubmit" class="none">Go</label>
						<input type="submit" id="searchsubmit" class="submit_input" value="Search" /></div>
                            
                        </form>
                    </div>
                </div>
                
                <ul id="menu">
                    <li><span class="home"><a href="#">Home</a></span></li>
                    <li><span class="about"><a href="#">About</a></span></li>
                    <li><span class="archives"><a href="#">Archives</a></span></li>
                    <li><span class="subscribe"><a href="#">Subscribe</a></span></li>
                    <li><span class="contact"><a href="#">Contact</a></span></li>
                </ul>
            
            </div>
        
        </div>   <!--end header-->
