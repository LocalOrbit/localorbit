<?php
/*
Part of Plugin: Ozh' Admin Drop Down Menu
http://planetozh.com/blog/my-projects/wordpress-admin-menu-drop-down-css/
*/

$wp_ozh_adminmenu['icon_names'] = array(
/* Site Admin */

	/* Dashboard */
		'index.php' => 'application_view_tile',
		'my-sites.php' => 'world',
		'update-core' => 'wordpress_icon',
		'akismet-stats-display' => 'comment_delete', // Akismet
	
	/* Posts */
		'edit.php' => 'pencil',
		'post-new.php' => 'page_white_edit',
		'edit-tags.php' => 'tag_blue_edit',  // Deprecated
		'edit-tags.php?taxonomy=category' => 'tag_red',
		'edit-tags.php?taxonomy=post_tag' => 'tag_blue_edit',

	/* Media */
		'upload.php' => 'image',
		'media-new.php' => 'image_add',

	/* Links */
		'link-manager.php' => 'link',
		'link-add.php' => 'link_add',
		'edit-link-categories.php' => 'link_edit', // Deprecated
		'edit-tags.php?taxonomy=link_category' => 'link_edit',

	/* Pages */
		'edit.php?post_type=page' => 'page_edit',
		'post-new.php?post_type=page' => 'page_edit',

	/* Comments */
		'edit-comments.php' => 'comment',

	/* Appearance */
		'themes.php' => 'layout',
		'widgets.php' => 'layout_content',
		'theme-install.php' => 'layout_add',
		'nav-menus.php' => 'layout_header',
		'theme-editor.php' => 'layout_edit',
		'custom-background' => 'layout_edit', // Twenty Ten
		'custom-header' => 'layout_edit', // Twenty Ten
		'functions.php' => 'layout_edit', // Old themes

	/* Plugins */
		'plugins.php' => 'plugin',
		'akismet-key-config' => 'comment_delete', // Akismet
		'plugin-install.php' => 'plugin_add',
		'plugin-editor.php' => 'plugin_edit',

	/* Users */
		'options-misc.php' => 'wrench_orange', // Deprecated
		'users.php' => 'group',
		'user-new.php' => 'user_add',
		'profile.php' => 'user',
		'ozh_admin_menu_logout' => 'cancel',
		
	/* Tools */
		'tools.php' => 'application_lightning',
		'import.php' => 'door_in',
		'export.php' => 'door_out',
		'network.php' => 'world_edit',
		'ms-delete-site' => 'world_delete', // Deprecated

	/* Settings */
		'options-general.php' => 'wrench',
		'options-writing.php' => 'page_white_wrench',
		'options-reading.php' => 'book_open',
		'options-discussion.php' => 'comment_edit',
		'options-media.php' => 'image_options',
		'options-privacy.php' => 'eye',
		'options-permalink.php' => 'link_edit',

/* Network Admin, missing icons only */

	/* Sites */
		'sites.php' => 'world_link',
		'site-new.php' => 'world_edit',
	
	/* Settings */
		'settings.php' => 'wrench_orange',
		'setup.php' => 'computer_edit',
	
	/* Update */
		'upgrade.php' => 'lightning_go',

);

?>