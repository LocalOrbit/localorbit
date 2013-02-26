<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>
<head>
    <meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />

    <title><?php ui::title(); ?></title>

    <link rel="stylesheet" type="text/css" href="<?php bloginfo('stylesheet_url'); ?>" media="screen" />
    <link href='http://fonts.googleapis.com/css?family=Prata' rel='stylesheet' type='text/css'>
	<link href='http://fonts.googleapis.com/css?family=Droid+Serif:400,700,400italic,700italic' rel='stylesheet' type='text/css'>
 	
    <link rel="pingback" href="<?php bloginfo('pingback_url'); ?>" />

	<?php if ( option::get('sidebar_pos') == 'Left' ) { ?><style type="text/css">#sidebar{float:left;margin-right:20px;} #articles, #main {float:right;}</style><?php } ?>

	<?php wp_head(); ?>
	
</head>

<body <?php body_class(); ?>>

	<div id="page-wrap">

 		<div id="main-wrap">

			<div id="header">

 				<div id="search"><?php get_template_part('searchform'); ?></div>

 				<div id="topmenu">
				
					<?php if (has_nav_menu( 'secondary' )) { 
						wp_nav_menu(array(
						'container' => '',
						'container_class' => '',
						'menu_class' => 'dropdown',
						'menu_id' => 'nav',
						'sort_column' => 'menu_order',
						'theme_location' => 'secondary'
						));
					}	

					if ( option::get('head_rss_show') == 'on' ) { ?> <a href="<?php ui::rss(); ?>"><img src="<?php echo get_template_directory_uri(); ?>/images/icons/feed.png" alt="RSS" /></a><?php }
					if ( option::get('head_twitter_show') == 'on' && strlen(option::get('head_twitter_user')) > 1 ) { ?> <a href="http://twitter.com/<?php echo option::get('head_twitter_user'); ?>"><img src="<?php echo get_template_directory_uri(); ?>/images/icons/twitter.png" alt="Twitter" /></a><?php }
					if ( option::get('head_facebook_show') == 'on' && strlen(option::get('head_facebook_url')) > 1 ) { ?> <a href="<?php echo option::get('head_facebook_url'); ?>"><img src="<?php echo get_template_directory_uri(); ?>/images/icons/facebook.png" alt="Facebook" /></a><?php }

 					?>

				</div> <!-- /#topmenu -->
  				<div class="clear"></div>

				<div id="logo">
					<?php if (!option::get('misc_logo_path')) { echo "<h1>"; } ?>
					
					<a href="<?php echo home_url(); ?>" title="<?php bloginfo('description'); ?>">
						<?php if (!option::get('misc_logo_path')) { bloginfo('name'); } else { ?>
							<img src="<?php echo ui::logo(); ?>" alt="<?php bloginfo('name'); ?>" />
						<?php } ?>
					</a><div class="clear"></div>
					
					<?php if (!option::get('misc_logo_path')) { echo "</h1>"; } ?>

					<?php if (option::get('logo_desc') == 'on') {  ?><span><?php bloginfo('description'); ?></span><?php } ?>
				</div><!-- / #logo -->
     
				
				<?php if (option::get('ad_head_select') == 'on') { ?>
 					<div class="banner banner-head">

 					<?php if ( option::get('ad_head_code') <> "") { 
						echo stripslashes(option::get('ad_head_code'));             
					} else { ?>
						<a href="<?php echo option::get('ad_head_imgurl'); ?>"><img src="<?php echo option::get('ad_head_imgpath'); ?>" alt="<?php echo option::get('ad_head_imgalt'); ?>" /></a>
					<?php } ?>		
					</div><!-- /.adv -->

 				<?php } ?>


				<div id="mainmenu">
				
					<?php if (has_nav_menu( 'primary' )) { 
							wp_nav_menu(array(
							'container' => '',
							'container_class' => '',
							'menu_class' => 'dropdown',
							'menu_id' => 'menu',
							'sort_column' => 'menu_order',
							'theme_location' => 'primary'
							));
						}					
						else
							{
								echo '<p>Please set your Main navigation menu on the <strong><a href="'.get_admin_url().'nav-menus.php">Appearance > Menus</a></strong> page.</p>
							 ';
							}
					 
						?>

				</div> <!-- /#menu -->

			</div> <!--/#header -->
			<div class="clear"></div>

 			<div id="content-wrap">