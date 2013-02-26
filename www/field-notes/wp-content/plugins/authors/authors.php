<?php
/*
Plugin Name: Authors Widget
Plugin URI: http://blog.fleischer.hu/wordpress/authors/
Description: Authors Widget shows the list or cloud of the authors, with the number of posts, link to RSS feed next to their name, avatar. It is useful in a multi-author blog, where you want to have the list in the sidemenu.
Version: 2.2.2
Author: Gavriel Fleischer
Author URI: http://blog.fleischer.hu/author/gavriel/
*/

// Multi-language support
if (defined('WPLANG') && function_exists('load_plugin_textdomain')) {
	load_plugin_textdomain('authors', PLUGINDIR.'/'.dirname(plugin_basename(__FILE__)).'/lang', dirname(plugin_basename(__FILE__)).'/lang');
}

// Widget stuff
function widget_authors_register() {
if ( function_exists('register_sidebar_widget') ) :
	function widget_authors_add_last_name(&$author) {
		$author_data = get_userdata($author->ID);
		$author->first_name = $author_data->first_name;
		$author->last_name = $author_data->last_name;
	}

	function widget_authors_sort_by_first_name($a, $b) {
		$cmp_first_name = strcmp($a->first_name, $b->first_name);
		return $cmp_first_name !== 0 ? $cmp_first_name : strcmp($a->last_name, $b->last_name);
	}

	function widget_authors_sort_by_last_name($a, $b) {
		$cmp_last_name = strcmp($a->last_name, $b->last_name);
		return $cmp_last_name !== 0 ? $cmp_last_name : strcmp($a->first_name, $b->first_name);
	}

	function widget_authors_sort_by($orderby, &$authors) {
		if ('first_name' != $orderby && 'last_name' != $orderby) {
			return;
		}
		array_walk($authors, widget_authors_add_last_name);
		switch ($orderby) {
		case 'first_name':
			usort($authors, widget_authors_sort_by_first_name);
			break;
		case 'last_name':
			usort($authors, widget_authors_sort_by_last_name);
			break;
		}
	}

	if ( function_exists('seo_tag_cloud_generate') ) :
	function widget_authors_cloud($args = '') {
		global $wpdb;

		$defaults = array(
			'optioncount' => false, 'exclude_admin' => true,
			'show_fullname' => false, 'hide_empty' => true,
			'feed' => '', 'feed_image' => '', 'feed_type' => '', 'echo' => true,
			'limit' => 0, 'em_step' => 0.1,
			'orderby' => 'name',
			'exclude' => '"0"',
			'include' => '',
		);

		$r = wp_parse_args( $args, $defaults );
		extract($r, EXTR_SKIP);

		$return = '';

		if (empty($include)) {
			$include_sql = '';
			$exclude_sql = ' AND ID NOT IN (' . $exclude . ') AND user_login NOT IN (' . $exclude . ')';
		} else {
			$include_sql = ' AND (ID IN (' . $include . ') OR user_login IN (' . $include . '))';
			$exclude_sql = '';
		}
		$authors = $wpdb->get_results('SELECT ID, user_nicename, display_name FROM ' . $wpdb->users . ' WHERE 0=0' . ($exclude_admin ? ' AND ID <> 1' : '') . $exclude_sql . $include_sql . ' ORDER BY display_name');

		$author_count = array();
		foreach ((array) $wpdb->get_results('SELECT DISTINCT post_author, COUNT(ID) AS count FROM '.$wpdb->posts.' WHERE post_type = "post" AND ' . get_private_posts_cap_sql( 'post' ) . ' GROUP BY post_author') as $row) {
			$author_count[$row->post_author] = $row->count;
		}

		widget_authors_sort_by($orderby, $authors);

		foreach ( (array) $authors as $key => $author ) {
			$posts = (isset($author_count[$author->ID])) ? $author_count[$author->ID] : 0;
			if ( $posts != 0 || !$hide_empty ) {
				$author = get_userdata( $author->ID );
				$name = $author->display_name;
				if ( $show_fullname && ($author->first_name != '' && $author->last_name != '') )
					$name = $author->first_name . ' ' . $author->last_name;

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

	function widget_authors_order_by($args) {
		$count = $args['optioncount'];
		$args['optioncount'] = 1;
		$arr = array_slice(explode('<li>', widget_authors_list_authors($args)), 1);
		switch ($args['orderby']) {
			case 'posts': usort($arr, 'widget_authors_sort_by_posts');break;
			default:
		}
		if ('0' == $count) {
			array_walk($arr, 'widget_authors_format', 'no-count');
		}
		if ($args['limit']) {
		    $arr = array_slice($arr, 0, $args['limit']);
		}
		return $arr;
	}

	function widget_authors_format(&$val, $i, $format) {
		switch ($format) {
		case 'no-count':
		    $val = preg_replace('#\(\s*([0-9]*)\)</li>#', '</li>', $val);
		    break;
		}
	}

	function widget_authors_dropdown($args = '') {
		$args['echo'] = false;
		unset($args['feed']);
		$arr = widget_authors_order_by($args);
		$options = '';
		foreach ($arr as $author) {
			preg_match('#<a href="([^"]*)"[^>]*>([^<]*)</a>( \(([0-9]*)\))?#', $author, $matches);
			$options .= '<option value="'.htmlspecialchars($matches[1]).'">'.$matches[2].($args['optioncount'] ? ' ('.$matches[4].')' : '').'</option>'."\n";
		}
		unset($arr);
		$dropdown = '<select onchange="window.location=this.options[this.selectedIndex].value">'."\n";
		$dropdown .= '<option value="#">'.__('Select Author...', 'authors').'</option>'."\n";
		$dropdown .= $options;
		$dropdown .= '</select>';
		echo $dropdown;
	}

/**
 * List all the authors of the blog, with several options available.
 *
 * <ul>
 * <li>optioncount (boolean) (false): Show the count in parenthesis next to the
 * author's name.</li>
 * <li>exclude_admin (boolean) (true): Exclude the 'admin' user that is
 * installed bydefault.</li>
 * <li>show_fullname (boolean) (false): Show their full names.</li>
 * <li>hide_empty (boolean) (true): Don't show authors without any posts.</li>
 * <li>feed (string) (''): If isn't empty, show links to author's feeds.</li>
 * <li>feed_image (string) (''): If isn't empty, use this image to link to
 * feeds.</li>
 * <li>echo (boolean) (true): Set to false to return the output, instead of
 * echoing.</li>
 * <li>style (string) ('list'): Whether to display list of authors in list form
 * or as a string.</li>
 * <li>html (bool) (true): Whether to list the items in html for or plaintext.
 * </li>
 * </ul>
 *
 * @link http://codex.wordpress.org/Template_Tags/wp_list_authors
 * @since 1.2.0
 * @param array $args The argument array.
 * @return null|string The output, if echo is set to false.
 */
function widget_authors_list_authors($args = '') {
	global $wpdb;

	$defaults = array(
		'optioncount' => false, 'exclude_admin' => true,
		'show_fullname' => false, 'hide_empty' => true,
		'feed' => '', 'feed_image' => '', 'feed_type' => '', 'echo' => true,
		'style' => 'list', 'html' => true,
		'show_avatar' => false, 'avatar_size' => 32,
		'orderby' => 'name',
		'exclude' => '"0"',
		'include' => '',
	);

	$r = wp_parse_args( $args, $defaults );
	extract($r, EXTR_SKIP);
	$return = '';

	if (empty($include)) {
		$include_sql = '';
		$exclude_sql = ' AND ID NOT IN (' . $exclude . ') AND user_login NOT IN (' . $exclude . ')';
	} else {
		$include_sql = ' AND (ID IN (' . $include . ') OR user_login IN (' . $include . '))';
		$exclude_sql = '';
	}
	/** @todo Move select to get_authors(). */
	$authors = $wpdb->get_results('SELECT ID, user_nicename FROM ' . $wpdb->users . ' WHERE 0=0' . ($exclude_admin ? ' AND ID <> 1' : '') . $exclude_sql . $include_sql . ' ORDER BY display_name');

	$author_count = array();
	foreach ((array) $wpdb->get_results('SELECT DISTINCT post_author, COUNT(ID) AS count FROM ' . $wpdb->posts . ' WHERE post_type = "post" AND ' . get_private_posts_cap_sql('post') . ' GROUP BY post_author') as $row) {
		$author_count[$row->post_author] = $row->count;
	}

	widget_authors_sort_by($orderby, $authors);

	foreach ( (array) $authors as $author ) {

		$link = '';

		$author = get_userdata( $author->ID );
		if ($exclude_admin && 10 == $author->user_level)
			continue;
		$posts = (isset($author_count[$author->ID])) ? $author_count[$author->ID] : 0;
		$name = $author->display_name;
		$email = $author->user_email;
		$avatar = get_avatar($email, $avatar_size);

		if ( $show_fullname && ($author->first_name != '' && $author->last_name != '') ) {
			$name = $author->first_name . ' ' . $author->last_name;
		}

		if( !$html ) {
			if ( $posts == 0 ) {
				if ( ! $hide_empty )
					$return .= $name . ', ';
			} else
				$return .= $name . ', ';

			// No need to go further to process HTML.
			continue;
		}

		if ( !($posts == 0 && $hide_empty) && 'list' == $style )
			$return .= '<li>';
		if ( $posts == 0 ) {
			if ( ! $hide_empty )
				$link = $name;
		} else {
			$link = '';
			if ( $show_avatar && !empty($avatar) )
				$link .= $avatar;

			$link .= '<a href="' . get_author_posts_url($author->ID, $author->user_nicename) . '" title="' . esc_attr( sprintf(__("Posts by %s"), $author->display_name) ) . '">' . $name . '</a>';

			if ( (! empty($feed_image)) || (! empty($feed)) ) {
				$link .= ' ';
				if (empty($feed_image))
					$link .= '(';
				$link .= '<a href="' . get_author_feed_link($author->ID) . '"';

				if ( !empty($feed) ) {
					$title = ' title="' . esc_attr($feed) . '"';
					$alt = ' alt="' . esc_attr($feed) . '"';
					$name = $feed;
					$link .= $title;
				}

				$link .= '>';

				if ( !empty($feed_image) )
					$link .= "<img src=\"" . esc_url($feed_image) . "\" style=\"border: none;\"$alt$title" . ' />';
				else
					$link .= $name;

				$link .= '</a>';

				if ( empty($feed_image) )
					$link .= ')';
			}

			if ( $optioncount )
				$link .= ' ('. $posts . ')';

		}

		if ( !($posts == 0 && $hide_empty) && 'list' == $style )
			$return .= $link . '</li>'."\n";
		else if ( ! $hide_empty )
			$return .= $link . ', ';
	}

	$return = trim($return, ', ');

	if ( ! $echo )
		return $return;
	echo $return;
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
		$show_fullname = $options['show_fullname'] ? '1' : '0';
		$show_avatar = $options['show_avatar'] ? '1' : '0';
		$avatar_size = $options['avatar_size'];
		$feedlink = $options['feedlink'] ? '1' : '0';
		$count = $options['count'] ? '1' : '0';
		$exclude_admin = $options['exclude_admin'] ? '1' : '0';
		$exclude = !empty($options['exclude']) ? $options['exclude'] : '"0"';
		$include = !empty($options['include']) ? $options['include'] : '';
		$show_credit = $options['show_credit'] ? '1' : '0';

		?>
		<?php echo $before_widget; ?>
			<?php echo $before_title . $title . $after_title; ?>
			<?php
				$list_args = array('orderby'=>$order, 'limit'=>$limit, 'show_fullname'=>$show_fullname, 'show_avatar'=>$show_avatar, 'avatar_size'=>$avatar_size, 'optioncount'=>$count, 'exclude_admin'=>$exclude_admin, 'exclude'=>$exclude, 'include'=>$include, 'hide_empty'=>1);
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
					$arr = widget_authors_order_by($list_args);
					echo '<ul><li>' . implode('<li>', $arr) . '</ul>';
				}
			?>
			<?php if ($options['show_credit'] == 1) printf('<span class="credit">'.__('Powered by %s','authors').'</span>', '<a href="http://blog.fleischer.hu/wordpress/authors/" title="'.__('Authors Widget Plugin for Wordpress','authors').'">'.__('Authors Widget','authors').'</a>');?>
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
.avatar {vertical-align:middle}
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
				$show_fullname = isset($widget_authors['show_fullname']);
				$show_avatar = isset($widget_authors['show_avatar']);
				$avatar_size = !empty($widget_authors['avatar_size']) ? $widget_authors['avatar_size'] : 32;
				$feedlink = isset($widget_authors['feedlink']);
				$count = isset($widget_authors['count']);
				$hide_empty = isset($widget_authors['hide_empty']);
				$exclude_admin = isset($widget_authors['exclude_admin']);
				$exclude = trim(strip_tags(stripslashes($widget_authors['exclude'])));
				$include = trim(strip_tags(stripslashes($widget_authors['include'])));
				$show_credit = isset($widget_authors['show_credit']);
				$options[$widget_number] = compact( 'title', 'format', 'order', 'limit', 'show_fullname', 'show_avatar', 'avatar_size', 'feedlink', 'count', 'hide_empty', 'exclude_admin', 'exclude', 'include', 'show_credit' );
			}

			update_option('widget_authors', $options);
			$updated = true;
		}

		if ( -1 == $number ) {
			$title = '';
			$format = 'list';
			$order = 'name';
			$limit = '';
			$show_fullname = false;
			$show_avatar = false;
			$avatar_size = 32;
			$feedlink = false;
			$count = false;
			$hide_empty = 0;
			$exclude_admin = 0;
			$exclude = '';
			$include = '';
			$show_credit = 0;
			$number = '%i%';
		} else {
			$title = attribute_escape( $options[$number]['title'] );
			$format = attribute_escape( $options[$number]['format'] );
			$order = attribute_escape( $options[$number]['order'] );
			$limit = attribute_escape( $options[$number]['limit'] );
			$show_fullname = (bool) $options[$number]['show_fullname'];
			$show_avatar = (bool) $options[$number]['show_avatar'];
			$avatar_size = attribute_escape( $options[$number]['avatar_size'] );
			$feedlink = (bool) $options[$number]['feedlink'];
			$count = (bool) $options[$number]['count'];
			$hide_empty = (bool) $options[$number]['hide_empty'];
			$exclude_admin = (bool) $options[$number]['exclude_admin'];
			$exclude = $options[$number]['exclude'];
			$include = $options[$number]['include'];
			$show_credit = (bool) $options[$number]['show_credit'];
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
			<label for="authors-order-<?php echo $number; ?>-name"><input type="radio" class="radio" id="authors-order-<?php echo $number; ?>-name" name="widget-authors[<?php echo $number; ?>][order]" value="name"<?php echo 'name' == $order || '' == $order ? ' checked="checked"' : '' ?> />&nbsp;<?php _e('Display name','authors') ?></label>
			<label for="authors-order-<?php echo $number; ?>-firstname"><input type="radio" class="radio" id="authors-order-<?php echo $number; ?>-firstname" name="widget-authors[<?php echo $number; ?>][order]" value="first_name"<?php echo 'first_name' == $order || '' == $order ? ' checked="checked"' : '' ?> />&nbsp;<?php _e('First name','authors') ?></label>
			<label for="authors-order-<?php echo $number; ?>-lastname"><input type="radio" class="radio" id="authors-order-<?php echo $number; ?>-lastname" name="widget-authors[<?php echo $number; ?>][order]" value="last_name"<?php echo 'last_name' == $order || '' == $order ? ' checked="checked"' : '' ?> />&nbsp;<?php _e('Last name','authors') ?></label>
			<label for="authors-order-<?php echo $number; ?>-posts"><input type="radio" class="radio" id="authors-order-<?php echo $number; ?>-posts" name="widget-authors[<?php echo $number; ?>][order]" value="posts"<?php echo 'posts' == $order ? ' checked="checked"' : '' ?> />&nbsp;<?php _e('Post count','authors') ?></label>
		</p>
		<p><label for="authors-limit-<?php echo $number; ?>"><?php _e('Number of authors to show', 'authors') ?>: <input type="text" class="widefat" style="width: 25px; text-align: center;" id="authors-limit-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][limit]" value="<?php echo $limit ?>" /></label></p>
		<p><label for="authors-show-fullname-<?php echo $number; ?>"><input id="authors-show-fullname-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][show_fullname]" type="checkbox" <?php checked( $show_fullname, true ); ?> class="checkbox" /> <?php _e('Show full name','authors'); ?></label></p>
		<p><label for="authors-show-avatar-<?php echo $number; ?>"><input id="authors-show-avatar-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][show_avatar]" type="checkbox" <?php checked( $show_avatar, true ); ?> class="checkbox" /> <?php _e('Show avatar','authors'); ?></label></p>
		<p><label for="authors-avatar-size-<?php echo $number; ?>"><?php _e('Avatar size', 'authors') ?>: <input type="text" class="widefat" style="width: 25px; text-align: center;" id="authors-avatar-size-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][avatar_size]" value="<?php echo $avatar_size ?>" /></label></p>
		<p><label for="authors-feedlink-<?php echo $number; ?>"><input id="authors-feedlink-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][feedlink]" type="checkbox" <?php checked( $feedlink, true ); ?> class="checkbox" /> <?php _e('Show RSS links','authors'); ?></label></p>
		<p><label for="authors-count-<?php echo $number; ?>"><input id="authors-count-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][count]" type="checkbox" <?php checked( $count, true ); ?> class="checkbox" /> <?php _e('Show post counts','authors'); ?></label></p>
		<p><label for="authors-hide-empty-<?php echo $number; ?>"><input id="authors-hide-empty-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][hide_empty]" type="checkbox" <?php checked( $hide_empty, true ); ?> class="checkbox" /> <?php _e('Hide empty','authors'); ?></label></p>
		<p><label for="authors-exclude-admin-<?php echo $number; ?>"><input id="authors-exclude-admin-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][exclude_admin]" type="checkbox" <?php checked( $exclude_admin, true ); ?> class="checkbox" /> <?php _e('Exclude admin','authors'); ?></label></p>
		<p><label for="authors-exclude-<?php echo $number; ?>"><?php _e('Exclude','authors'); ?>: <input id="authors-exclude-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][exclude]" type="text" value="<?php echo htmlspecialchars($exclude); ?>" class="widefat" style="width:100px" /></label></p>
		<p><label for="authors-include-<?php echo $number; ?>"><?php _e('Include','authors'); ?>: <input id="authors-include-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][include]" type="text" value="<?php echo htmlspecialchars($include); ?>" class="widefat" style="width:100px" /></label></p>
		<p>
			<?php _e('How satisfied you are with the plugin?','authors') ?><br />
			<ul>
				<li>Very much - <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&amp;hosted_button_id=10234211" target="_blank"><img src="<?php echo WP_PLUGIN_URL.'/'.dirname(plugin_basename(__FILE__)).'/donate.gif'; ?>" alt="<?_e('Donate')?>" style="vertical-align:middle" /></a></li>
				<li>Not that much - <label for="authors-show-credit-<?php echo $number; ?>" title="<?php echo htmlspecialchars(translate('Display "Powered by Authors widget" link', 'authors')); ?>"><input id="authors-show-credit-<?php echo $number; ?>" name="widget-authors[<?php echo $number; ?>][show_credit]" type="checkbox" <?php checked( $show_credit, true ); ?> class="checkbox" /> <?php _e('Show credit','authors'); ?></label></li>
			</ul>
		</p>
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
