<?php

/* Register Thumbnails Size
================================== */

if ( function_exists( 'add_image_size' ) ) {

	/* Slider */
	add_image_size( 'slider', 520, 300, true );
	add_image_size( 'slider-small', 90, 66, true );

 	/* Featured Category */
	add_image_size( 'featured-cat', 210, 140, true );

	/* Sidebar Thumbnail */
	add_image_size( 'post-cover', 310 );

	/* Recent Posts Widget */
	add_image_size( 'recent-widget', 60, 45, true );

}

/* Default Thubmnail */
update_option('thumbnail_size_w', option::get('thumb_width'));
update_option('thumbnail_size_h', option::get('thumb_height'));
update_option('thumbnail_crop', 1);


/* 	Register Custom Menu
==================================== */

register_nav_menu('secondary', 'Top Menu');
register_nav_menu('primary', 'Main Menu');
register_nav_menu('tertiary', 'Footer Menu');



/* 	Reset default WP styling for [gallery] shortcode
===================================================== */

add_filter('gallery_style', create_function('$a', 'return "<div class=\'gallery\'>";'));



/* 	Maximum width for images placed in posts
============================================= */

if ( ! isset( $content_width ) ) $content_width = 610;



/* 	This will enable to insert [shortcodes] inside Text Widgets
================================================================ */

add_filter('widget_text', 'do_shortcode');



/* Add support for Custom Background
==================================== */

if ( ui::is_wp_version( '3.4' ) )
	add_theme_support( 'custom-background' );
else
	add_custom_background( $args );



/* Custom Excerpt Length
==================================== */

if ( !function_exists( 'new_excerpt_length' ) ) {

	function new_excerpt_length($length) {
		return (int) option::get("excerpt_length") ? (int) option::get("excerpt_length") : 50;
	}
	add_filter('excerpt_length', 'new_excerpt_length');

}

/* Email validation
==================================== */

if ( !function_exists( 'simple_email_check' ) ) {

	function simple_email_check($email) {
		// First, we check that there's one @ symbol, and that the lengths are right
		if (!ereg("^[^@]{1,64}@[^@]{1,255}$", $email)) {
			// Email invalid because wrong number of characters in one section, or wrong number of @ symbols.
			return false;
		}

		return true;
	}
}



/* Tabbed Widget
============================ */

function tabber_tabs_load_widget() {
	// Register widget.
	register_widget( 'Slipfire_Widget_Tabber' );
}


/**
 * Temporarily hide the "tabber" class so it does not "flash"
 * on the page as plain HTML. After tabber runs, the class is changed
 * to "tabberlive" and it will appear.
 */
function tabber_tabs_temp_hide(){
	echo '<script type="text/javascript">document.write(\'<style type="text/css">.tabber{display:none;}</style>\');</script>';
}


// Function to check if there are widgets in the Tabber Tabs widget area
// Thanks to Themeshaper: http://themeshaper.com/collapsing-wordpress-widget-ready-areas-sidebars/
function is_tabber_tabs_area_active( $index ){
  global $wp_registered_sidebars;

  $widgetcolums = wp_get_sidebars_widgets();

  if ($widgetcolums[$index]) return true;

	return false;
}


 // Let's build a widget
class Slipfire_Widget_Tabber extends WP_Widget {

	function Slipfire_Widget_Tabber() {
		$widget_ops = array( 'classname' => 'tabbertabs', 'description' => __('Drag me to the Sidebar', 'wpzoom') );
		$control_ops = array( 'width' => 230, 'height' => 300, 'id_base' => 'slipfire-tabber' );
		$this->WP_Widget( 'slipfire-tabber', __('WPZOOM: Tabs', 'wpzoom'), $widget_ops, $control_ops );
	}

	function widget( $args, $instance ) {
		extract( $args );

		$style = $instance['style']; // get the widget style from settings

		echo "\n\t\t\t" . $before_widget;

		// Show the Tabs
		echo '<div class="tabber">'; // set the class with style
			if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar('tabber_tabs') )
		echo '</div>';

		echo "\n\t\t\t" . $after_widget;
		echo '</div>';
	}

	function update( $new_instance, $old_instance ) {
		$instance = $old_instance;
		$instance['style'] = $new_instance['style'];

		return $instance;
	}

	function form( $instance ) {

		//Defaults
		$defaults = array( 'title' => __('Tabber', 'wpzoom'), 'style' => 'style1' );
		$instance = wp_parse_args( (array) $instance, $defaults ); ?>

		<div style="float:left;width:98%;"></div>
		<p>
		<?php _e('Place your widgets in the <strong>WPZOOM: Tabs Widget Area</strong> and have them show up here.', 'wpzoom')?>
		</p>

		<div style="clear:both;">&nbsp;</div>
	<?php
	}
}

/* Tabber Tabs Widget */
tabber_tabs_plugin_init();

/* Initializes the plugin and it's features. */
function tabber_tabs_plugin_init() {

	// Loads and registers the new widget.
	add_action( 'widgets_init', 'tabber_tabs_load_widget' );

	//Registers the new widget area.
	register_sidebar(
		array(
			'name' => __('WPZOOM: Tabs Widget Area', 'wpzoom'),
			'id' => 'tabber_tabs',
			'description' => __('Build your tabbed area by placing widgets here.  !! DO NOT PLACE THE WPZOOM: TABS IN THIS AREA.', 'wpzoom'),
			'before_widget' => '<div id="%1$s" class="tabbertab %2$s">',
			'after_widget' => '</div>'
 		)
	);

	// Hide Tabber until page load
	add_action( 'wp_head', 'tabber_tabs_temp_hide' );


}


/* Related Posts
==================================== */

if ( ! function_exists( 'wp_get_related_posts' ) ) :

	function wp_get_related_posts() {
		global $wpdb, $post,$table_prefix;
		$wp_rp = get_option("wp_rp");

		$exclude = explode(",",$wp_rp["wp_rp_exclude"]);
		$limit = $wp_rp["wp_rp_limit"];
		$wp_rp_title = $wp_rp["wp_rp_title"];
		$wp_no_rp = $wp_rp["wp_no_rp"];

		if ( $exclude != '' ) {
			$q = "SELECT tt.term_id FROM ". $table_prefix ."term_taxonomy tt, " . $table_prefix . "term_relationships tr WHERE tt.taxonomy = 'category' AND tt.term_taxonomy_id = tr.term_taxonomy_id AND tr.object_id = $post->ID";

			$cats = $wpdb->get_results($q);

			foreach(($cats) as $cat) {
				if (in_array($cat->term_id, $exclude) != false){
					return;
				}
			}
		}

		if(!$post->ID){return;}
		$now = current_time('mysql', 1);
		$tags = wp_get_post_tags($post->ID);

		$tagcount = count($tags);
		if ($tagcount) {
			$taglist = "'" . $tags[0]->term_id. "'";
			for ($i = 1; $i < $tagcount; $i++) {
				$taglist = $taglist . ", '" . $tags[$i]->term_id . "'";
			}
		} else {
			$taglist = "''";
		}

		if ($limit) {
			$limitclause = "LIMIT $limit";
		}	else {
			$limitclause = "LIMIT 4";
		}

		$q = "SELECT p.ID, p.post_title, p.post_date, p.comment_count, count(t_r.object_id) as cnt FROM $wpdb->term_taxonomy t_t, $wpdb->term_relationships t_r, $wpdb->posts p WHERE t_t.taxonomy ='post_tag' AND t_t.term_taxonomy_id = t_r.term_taxonomy_id AND t_r.object_id  = p.ID AND (t_t.term_id IN ($taglist)) AND p.ID != $post->ID AND p.post_status = 'publish' AND p.post_date_gmt < '$now' GROUP BY t_r.object_id ORDER BY cnt DESC, p.post_date_gmt DESC $limitclause;";

		$related_posts = $wpdb->get_results($q);
		$output = "";

		if ($related_posts) {

			$output  .= '<div class="related_posts widget">';
			$output  .= '<h3 class="title">'.__('Related Posts', 'wpzoom').'</h3>';
			$output  .= '<ul class="wpzoom-feature-posts">';

		}

		foreach ($related_posts as $related_post ){
			$output .= '<li>';

			$image = get_the_image( array( 'width' => 46, 'height' => 45, 'size' => 'recent-widget', 'echo' => false, 'post_id' => $related_post->ID, 'format' => 'array' ) );
			$url = $image['src'];

			$dateformat = get_option('date_format');
			$wrappeddate = mysql2date($dateformat, $related_post->post_date);

			if (!empty($url )) { $output .=  '<a class="thumb" href="'.get_permalink($related_post->ID).'" title="'.wptexturize($related_post->post_title).'"><img src="'.$url.'" width="60" height="45" alt="'.wptexturize($related_post->post_title).'" /></a><a href="'.get_permalink($related_post->ID).'" title="'.wptexturize($related_post->post_title).'">'.wptexturize($related_post->post_title).'</a>'; }

			else { $output .=  '<a href="'.get_permalink($related_post->ID).'" title="'.wptexturize($related_post->post_title).'">'.wptexturize($related_post->post_title).'</a>'; }

			$output .=  "<small>$wrappeddate</small><div class=\"clear\"></div></li>";
		}

		if ($related_posts) {

			$output  .= '</ul><div class="clear"></div></div>';

		}

		return $output;
	}

endif;



if ( ! function_exists( 'wp_related_posts' ) ) :

	function wp_related_posts(){

		$output = wp_get_related_posts() ;

		echo $output;
	}

endif;

 

/*  Limit Posts
/*
/*  Plugin URI: http://labitacora.net/comunBlog/limit-post.phps
/*	Usage: the_content_limit($max_charaters, $more_link)
===================================================== */

if ( !function_exists( 'the_content_limit' ) ) {

	function the_content_limit($max_char, $more_link_text = '(more...)', $stripteaser = 0, $more_file = '', $echo = true) {
		$content = get_the_content($more_link_text, $stripteaser, $more_file);
		$content = apply_filters('the_content', $content);
		$content = str_replace(']]>', ']]&gt;', $content);
		$content = strip_tags($content);

	   if (strlen($_GET['p']) > 0 && $thisshouldnotapply) {
		  echo $content;
	   }
	   else if ((strlen($content)>$max_char) && ($espacio = strpos($content, " ", $max_char ))) {
			$content = substr($content, 0, $espacio);
			if ($echo == true) { echo $content . "..."; } else {return $content; }
	   }
	   else {
		  if ($echo == true) { echo $content . "..."; } else {return $content; }
	   }
	}
}


/* Comments Custom Template
==================================== */

function wpzoom_comment( $comment, $args, $depth ) {
	$GLOBALS['comment'] = $comment;
	switch ( $comment->comment_type ) :
		case '' :
	?>
	<li <?php comment_class(); ?> id="li-comment-<?php comment_ID(); ?>">
		<div id="comment-<?php comment_ID(); ?>">
		<div class="comment-author vcard">
			<?php echo get_avatar( $comment, 60 ); ?>
			<?php printf( __( '%s <span class="says">says:</span>', 'wpzoom' ), sprintf( '<cite class="fn">%s</cite>', get_comment_author_link() ) ); ?>

			<div class="comment-meta commentmetadata"><a href="<?php echo esc_url( get_comment_link( $comment->comment_ID ) ); ?>">
				<?php printf( __('%s at %s', 'wpzoom'), get_comment_date(), get_comment_time()); ?></a><?php edit_comment_link( __( '(Edit)', 'wpzoom' ), ' ' );
				?>

			</div><!-- .comment-meta .commentmetadata -->

		</div><!-- .comment-author .vcard -->
		<?php if ( $comment->comment_approved == '0' ) : ?>
			<em class="comment-awaiting-moderation"><?php _e( 'Your comment is awaiting moderation.', 'wpzoom' ); ?></em>
			<br />
		<?php endif; ?>



		<div class="comment-body"><?php comment_text(); ?></div>

		<div class="reply">
			<?php comment_reply_link( array_merge( $args, array( 'depth' => $depth, 'max_depth' => $args['max_depth'] ) ) ); ?>
		</div><!-- .reply -->
	</div><!-- #comment-##  -->

	<?php
			break;
		case 'pingback'  :
		case 'trackback' :
	?>
	<li class="post pingback">
		<p><?php _e( 'Pingback:', 'wpzoom' ); ?> <?php comment_author_link(); ?><?php edit_comment_link( __( '(Edit)', 'wpzoom' ), ' ' ); ?></p>
	<?php
			break;
	endswitch;
}


/* Video auto-thumbnail
==================================== */

if (is_admin()) {
	WPZOOM_Video_Thumb::init();
}


?>