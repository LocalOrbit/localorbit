<?php
/*
Plugin Name: Authors Widget
Plugin URI: http://blog.fleischer.hu/wordpress/authors/
Description: Authors Widget shows the list of the authors, with the number of posts, link to RSS feed next to their name. It is useful in a multi-author blog, where you want to have the list in the sidemenu.
Version: 1.6.1
Author: Gavriel Fleischer
Author URI: http://blog.fleischer.hu/gavriel/
*/

// Multi-language support
if (defined('WPLANG') && function_exists('load_plugin_textdomain')) {
	load_plugin_textdomain('authors', PLUGINDIR.'/'.dirname(plugin_basename(__FILE__)).'/lang');
}

// Widget stuff
function widget_authors_register() {
if ( function_exists('register_sidebar_widget') ) :
	if ( function_exists('seo_tag_cloud_generate') ) :
	function widget_authors_cloud($args = '') {
		global $wpdb;

		$defaults = array(
			'optioncount' => false, 'exclude_admin' => true,
			'show_fullname' => false, 'hide_empty' => true,
			'feed' => '', 'feed_image' => '', 'feed_type' => '', 'echo' => true,
			'limit' => 0, 'em_step' => 0.1
		);

		$r = wp_parse_args( $args, $defaults );
		extract($r, EXTR_SKIP);

		$return = '';

		$authors = $wpdb->get_results('SELECT ID, user_nicename, display_name FROM '.$wpdb->users.' ' . ($exclude_admin ? 'WHERE ID <> 1 ' : '') . 'ORDER BY display_name');

		$author_count = array();
		foreach ((array) $wpdb->get_results('SELECT DISTINCT post_author, COUNT(ID) AS count FROM '.$wpdb->posts.' WHERE post_type = "post" AND ' . get_private_posts_cap_sql( 'post' ) . ' GROUP BY post_author') as $row) {
			$author_count[$row->post_author] = $row->count;
		}

		foreach ( (array) $authors as $key => $author ) {
			$posts = (isset($author_count[$author->ID])) ? $author_count[$author->ID] : 0;
			if ( $posts != 0 || !$hide_empty ) {
				$author = get_userdata( $author->ID );
				$name = $author->display_name;
				if ( $show_fullname && ($author->first_name != '' && $author->last_name != '') )
					$name = "$author->first_name $author->last_name";

				if ( $posts == 0 ) {
					if ( !$hide_empty )
						$link = '';
				}
				else {
					$link = get_author_posts_url($author->ID, $author->user_nicename);
				}
				$authors[$key]->name = $name;
				$authors[$key]->count = $posts;
				$authors[$key]->link = $link;
				$authors[$key]->extra = $optioncount ? '('.$posts.')' : '';
			}
			else
				unset($authors[$key]);
		}

		$args['number'] = $limit;
		$return = seo_tag_cloud_generate( $authors, $args ); // Here's where those top tags get sorted according to $args
		echo $return;
	}
	endif;

	function widget_authors_dropdown($args = '') {
#		$echo = $args['echo'];
		$args['echo'] = false;
		unset($args['feed']);
		$arr = array_slice(explode('<li>', wp_list_authors($args)), 1);
		switch ($order) {
			case 'posts': usort($arr, 'widget_authors_sort_by_posts');break;
			case 'name':
			default:
		}
		$options = '';
		foreach ($arr as $author) {
			preg_match('#<a href="([^"]*)"[^>]*>([^<]*)</a>( \(([0-9]*)\))?#', $author, $matches);
#			$authors[] = array('url'=>$matches[1], 'name'=>$matches[2], 'count'=>$matches[4]);
			$options .= '<option value="'.htmlspecialchars($matches[1]).'">'.$matches[2].($args['optioncount'] ? ' ('.$matches[4].')' : '').'</option>'."\n";
		}
		unset($arr);
		$dropdown = '<select onchange="window.location=this.options[this.selectedIndex].value">'."\n";
		$dropdown .= '<option value="#">'.__('Select Author...', 'authors').'</option>'."\n";
		$dropdown .= $options;
		$dropdown .= '</select>';
#		if ($echo)
			echo $dropdown;
#		return $dropdown;
	}

	function widget_authors($args, $widget_args = 1) {
		extract($args, EXTR_SKIP);
		if ( is_numeric($widget_args) )
			$widget_args = array( 'number' => $widget_args );
		$widget_args = wp_parse_args( $widget_args, array( 'number' => -1 ) );
		extract($widget_args, EXTR_SKIP);

		$options = get_option('widget_authors');
		if (isset($options[$number]))
			$options = $options[$number];
		$options = wp_parse_args($args, $options);
#		if (!isset($options[$number]))
#			return;

		$title = empty($options['title']) ? __('Authors','authors') : apply_filters('widget_title', $options['title']);
		$format = $options['format'];
		$order = $options['order'];
		$limit = $options['limit'];
		$feedlink = $options['feedlink'] ? '1' : '0';
		$count = $options['count'] ? '1' : '0';
		$exclude_admin = $options['exclude_admin'] ? '1' : '0';
		$hide_credit = $options['hide_credit'] ? '1' : '0';

		?>
		<?php echo $before_widget; ?>
			<?php echo $before_title . $title . $after_title; ?>
			<ul>
				<?php
					$list_args = array('orderby'=>$order, 'limit'=>$limit, 'optioncount'=>$count, 'exclude_admin'=>$exclude_admin, 'show_fullname'=>0, 'hide_empty'=>1);
					if ($feedlink) {
						$list_args['feed'] = 'RSS';
						$list_args['feed_image'] = '';
					}
					if ('cloud' == $format && function_exists('seo_tag_cloud_generate') ) {
						widget_authors_cloud($list_args);
					}
					elseif ('dropdown' == $format) {
						widget_authors_dropdown($list_args);
					}
					else /*if ('list' == $format)*/ {
						$list_args['echo'] = false;
						$arr = array_slice(explode('<li>', wp_list_authors($list_args)), 1);
						switch ($order) {
							case 'posts': usort($arr, 'widget_authors_sort_by_posts');break;
							case 'name':
							default:
						}
						echo '<li>'.implode('<li>', $arr);
						unset($arr);
					}
				?>
			</ul>
			<?php if ($options['hide_credit'] != 1) printf('<span class="credit">'.__('Powered by %s','authors').'</span>', '<a href="http://blog.fleischer.hu/wordpress/authors/" title="'.__('Authors Widget Plugin for Wordpress','authors').'">'.__('Authors Widget','authors').'</a>');?>
		<?php echo $after_widget; ?>
	<?php
	}

	function widget_authors_sort_by_posts($a, $b) {
		$matches = array();
		preg_match('#\(([0-9]*)\)</li>#', $a, $matches);
		$aC = is_array($matches) && count($matches) >= 2 ? intval($matches[1]) : 0;
		preg_match('#\(([0-9]*)\)</li>#', $b, $matches);
		$bC = is_array($matches) && count($matches) >= 2 ? intval($matches[1]) : 0;
		return $aC < $bC ? 1 : -1;
	}
	
	function widget_authors_style() {
		?>
<style type="text/css">
.credit {font-size: 50%;}
</style>
		<?php
	}

	function widget_authors_control( $widget_args ) {
		global $wp_registered_widgets;
		static $updated = false;

		if ( is_numeric($widget_args) )
			$widget_args = array( 'number' => $widget_args );
		$widget_args = wp_parse_args( $widget_args, array( 'number' => -1 ) );
		extract($widget_args, EXTR_SKIP);

		$options = get_option('widget_authors');

		if ( !is_array( $options ) )
			$options = array();

		if ( !$updated && !empty($_POST['sidebar']) ) {
			$sidebar = (string) $_POST['sidebar'];

			$sidebars_widgets = wp_get_sidebars_widgets();
			if ( isset($sidebars_widgets[$sidebar]) )
				$this_sidebar =& $sidebars_widgets[$sidebar];
			else
				$this_sidebar = array();

			foreach ( (array) $this_sidebar as $_widget_id ) {
				if ( 'widget_authors' == $wp_registered_widgets[$_widget_id]['callback'] && isset($wp_registered_widgets[$_widget_id]['params'][0]['number']) ) {
					$widget_number = $wp_registered_widgets[$_widget_id]['params'][0]['number'];
					if ( !in_array( "authors-$widget_number", $_POST['widget-id'] ) ) // the widget has been removed.
						unset($options[$widget_number]);
				}
			}

			foreach ( (array) $_POST['widget-authors'] as $widget_number => $widget_authors ) {
				if ( !isset($widget_authors['title']) && isset($options[$widget_number]) ) // user clicked cancel
					continue;
				$title = trim(strip_tags(stripslashes($widget_authors['title'])));
				$format = !empty($widget_authors['format']) ? $widget_authors['format'] : 'list';
				$order = !empty($widget_authors['order']) ? $widget_authors['order'] : 'name';
				$limit = !empty($widget_authors['limit']) ? $widget_authors['limit'] : '';
				$feedlink = isset($widget_authors['feedlink']);
				$count = isset($widget_authors['count']);
				$exclude_admin = isset($widget_authors['exclude_admin']);
				$hide_credit = isset($widget_authors['hide_credit']);
				$options[$widget_number] = compact( 'title', 'format', 'order', 'limit', 'feedlink', 'count', 'exclude_admin', 'hide_credit' );
			}

			update_option('widget_authors', $options);
			$updated = true;
		}

		if ( -1 == $number ) {
			$title = '';
			$format = 'list';
			$order = 'name';
			$limit = '';
			$feedlink = false;
			$count = false;
			$exclude_admin = 0;
			$hide_credit = 0;
			$number = '%i%';
		} else {
			$title = attribute_escape( $options[$number]['title'] );
			$format = attribute_escape( $options[$number]['format'] );
			$order = attribute_escape( $options[$number]['order'] );
			$limit = attribute_escape( $options[$number]['limit'] );
			$feedlink = (bool) $options[$number]['feedlink'];
			$count = (bool) $options[$number]['count'];
			$exclude_admin = (bool) $options[$number]['exclude_admin'];
			$hide_credit = (bool) $options[$number]['hide_credit'];
		}
		?>
		<p><label for="authors-title-<?php echo $number; ?>"><?php _e('Title','authors'); ?>: <input id="authors-title-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][title]" type="text" value="<?php echo $title; ?>" class="widefat" /></label></p>
		<p>
			<?php _e('Format','authors') ?>:<br />
			<label for="authors-format-<?php echo $number; ?>-list"><input type="radio" class="radio" id="authors-format-<?php echo $number; ?>-list" name="widget-authors[<?php echo $number; ?>][format]" value="list"<?php echo 'list' == $format || '' == $format ? ' checked="checked"' : '' ?> /> <?php _e('List','authors') ?></label>
		<?php if ( function_exists('seo_tag_cloud_generate') ) : ?>
			<label for="authors-format-<?php echo $number; ?>-cloud"><input type="radio" class="radio" id="authors-format-<?php echo $number; ?>-cloud" name="widget-authors[<?php echo $number; ?>][format]" value="cloud"<?php echo 'cloud' == $format ? ' checked="checked"' : '' ?> /> <?php _e('Cloud','authors') ?></label>
		<?php endif; ?>
			<label for="authors-format-<?php echo $number; ?>-dropdown"><input type="radio" class="radio" id="authors-format-<?php echo $number; ?>-dropdown" name="widget-authors[<?php echo $number; ?>][format]" value="dropdown"<?php echo 'dropdown' == $format ? ' checked="checked"' : '' ?> /> <?php _e('Dropdown','authors') ?></label>
		</p>
		<p>
			<?php _e('Order by','authors') ?>:<br />
			<label for="authors-order-<?php echo $number; ?>-name"><input type="radio" class="radio" id="authors-order-<?php echo $number; ?>-name" name="widget-authors[<?php echo $number; ?>][order]" value="name"<?php echo 'name' == $order || '' == $order ? ' checked="checked"' : '' ?> /> <?php _e('Name','authors') ?></label>
			<label for="authors-order-<?php echo $number; ?>-posts"><input type="radio" class="radio" id="authors-order-<?php echo $number; ?>-posts" name="widget-authors[<?php echo $number; ?>][order]" value="posts"<?php echo 'posts' == $order ? ' checked="checked"' : '' ?> /> <?php _e('Post count','authors') ?></label>
		</p>
		<p><label for="authors-limit-<?php echo $number; ?>"><?php _e('Number of authors to show', 'authors') ?>: <input type="text" class="widefat" style="width: 25px; text-align: center;" id="authors-limit-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][limit]" value="<?php echo $limit ?>" /></label></p>
		<p><label for="authors-feedlink-<?php echo $number; ?>"><input id="authors-feedlink-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][feedlink]" type="checkbox" <?php checked( $feedlink, true ); ?> class="checkbox" /> <?php _e('Show RSS links','authors'); ?></label></p>
		<p><label for="authors-count-<?php echo $number; ?>"><input id="authors-count-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][count]" type="checkbox" <?php checked( $count, true ); ?> class="checkbox" /> <?php _e('Show post counts','authors'); ?></label></p>
		<p><label for="authors-exclude-admin-<?php echo $number; ?>"><input id="authors-exclude-admin-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][exclude_admin]" type="checkbox" <?php checked( $exclude_admin, true ); ?> class="checkbox" /> <?php _e('Exclude admin','authors'); ?></label></p>
		<p><label for="authors-hide-credit-<?php echo $number; ?>"><input id="authors-hide-credit-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][hide_credit]" type="checkbox" <?php checked( $hide_credit, true ); ?> class="checkbox" /> <?php _e('Hide credit','authors'); ?></label></p>
		<p><a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&amp;hosted_button_id=10234211" target="_blank"><img src="https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif" alt="<?_e('Donate')?>" /></a></p>
		<input type="hidden" name="widget-authors[<?php echo $number; ?>][submit]" value="1" />
	<?php
	}

	function widget_authors_upgrade() {
		$options = get_option( 'widget_authors' );

		if ( !isset( $options['title'] ) )
			return $options;

		$newoptions = array( 1 => $options );

		update_option( 'widget_authors', $newoptions );

		$sidebars_widgets = get_option( 'sidebars_widgets' );
		if ( is_array( $sidebars_widgets ) ) {
			foreach ( $sidebars_widgets as $sidebar => $widgets ) {
				if ( is_array( $widgets ) ) {
					foreach ( $widgets as $widget )
						$new_widgets[$sidebar][] = ( $widget == 'authors' ) ? 'authors-1' : $widget;
				} else {
					$new_widgets[$sidebar] = $widgets;
				}
			}
			if ( $new_widgets != $sidebars_widgets )
				update_option( 'sidebars_widgets', $new_widgets );
			}

		return $newoptions;
	}

	if ( !$options = get_option( 'widget_authors' ) )
		$options = array();

	if ( isset($options['title']) )
		$options = widget_authors_upgrade();

	$widget_ops = array( 'classname' => 'widget_authors', 'description' => __( 'A list of the authors','authors' ) );

	$name = __( 'Authors','authors' );

	$id = false;
	foreach ( (array) array_keys($options) as $o ) {
		// Old widgets can have null values for some reason
		if ( !isset($options[$o]['title']) )
			continue;
		$id = "authors-$o";
		wp_register_sidebar_widget( $id, $name, 'widget_authors', $widget_ops, array( 'number' => $o ) );
		wp_register_widget_control( $id, $name, 'widget_authors_control', array( 'id_base' => 'authors' ), array( 'number' => $o ) );
	}

	// If there are none, we register the widget's existance with a generic template
	if ( !$id ) {
		wp_register_sidebar_widget( 'authors-1', $name, 'widget_authors', $widget_ops, array( 'number' => -1 ) );
		wp_register_widget_control( 'authors-1', $name, 'widget_authors_control', array( 'id_base' => 'authors' ), array( 'number' => -1 ) );
	}
	if ( is_active_widget('widget_authors') )
		add_action('wp_head', 'widget_authors_style');
endif;
}

add_action('init', 'widget_authors_register');

?>