<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>
<head>
    <meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />

    <title><?php ui::title(); ?></title>

    <link rel="stylesheet" type="text/css" href="<?php bloginfo('stylesheet_url'); ?>?_v=4.0.6.1" media="screen" />
    <link href='http://fonts.googleapis.com/css?family=Prata' rel='stylesheet' type='text/css'>
	<link href='http://fonts.googleapis.com/css?family=Droid+Serif:400,700,400italic,700italic' rel='stylesheet' type='text/css'>
 	<link href='http://fonts.googleapis.com/css?family=Droid+Sans:400,700' rel='stylesheet' type='text/css'>
 	<link rel="stylesheet" type="text/css" href="/homepage/includes/footer.css?_v=4.0.6.1" />
    <link rel="pingback" href="<?php bloginfo('pingback_url'); ?>" />
		<script language="Javascript" type="text/javascript" src="/js/jquery.min.js?_v=4.0.6.1"></script>

	<?php if ( option::get('sidebar_pos') == 'Left' ) { ?><style type="text/css">#sidebar{float:left;margin-right:20px;} #articles, #main {float:right;}</style><?php } ?>

	<?php wp_head(); ?>
	
</head>

<body <?php body_class(); ?>>
<div id="top_background">
<table id="main_layout_homepage" width="100%">
			<colgroup><col>
			<col width="1100">
			<col>
			</colgroup><tbody><tr>
				<td><img src="/img/blank.png" width="1" height="120"></td>
				<td style="position: relative;">
					<div style="position: relative;width:1100px;height: 120px;">
						<a href="/" class="logo"><img width="112" height="111" src="/homepage/includes/logo5.png"></a>
						<div id="nav1">
							<a class="nav1" style="font-size: 125%;" href="/homepage/features.php">Features</a>
								<a class="nav1" style="font-size: 125%;" href="/homepage/homepage.php#whouses">Customers</a>
								<a class="nav1" style="font-size: 125%;" href="/homepage/pricing.php">Pricing</a>
								<a class="nav1" style="font-size: 125%;" href="/homepage/company.php">About</a>
								<a class="nav1" style="font-size: 125%;" href="/field-notes/">Field Notes</a>
						</div>
						<div id="nav2">
							<a href="/homepage/contact.php" class="nav2" >contact</a>
								
								&nbsp;&nbsp;|&nbsp;&nbsp;
								<? if($core->session['user_id'] == 0){?>
								<a class="nav2" href="/login.php">log in</a>
								<?}else{?>
								<a class="nav2" href="/app.php#!dashboard-home">dashboard</a>
								<?}?>
						</div>
						<div id="tagline">re-linking the food chain ™</div>
					</div>
				</td>
				<td><img src="/img/blank.png" width="1" height="120">					<div id="popup_closer"><a href="#" onclick="$('#overlay,.popup,#popup_closer').fadeOut(100);"><img src="/homepage/img/icon_popup_close.png" /></a></div>
					<div id="overlay"></div>
					<div class="popup" id="popup3">
						<div class="popup_content">
							<iframe height="942" allowTransparency="true" frameborder="0" scrolling="no" style="width:100%;border:none" src="http://localorbit.wufoo.com/embed/z7x3k1/"><a href="http://localorbit.wufoo.com/forms/z7x3k1/">Submit</a></iframe>
						</div>
					</div></td>
			</tr></table></div>
	<div id="page-wrap">

 		<div id="main-wrap">

			<div id="header">

 				
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