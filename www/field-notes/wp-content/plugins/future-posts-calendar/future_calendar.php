<?php
/*
Plugin Name: Future Calendar
Plugin URI: http://aahacreative.com/our-projects/future-posts-calendar-plugin/
Description: A simple plugin that utilizes a modified get_calendar function that shows what dates have a future post scheduled in a calendar format, and makes it easy to change the current timestamp. Includes a widget to display posts on your website.
Author: Aaron Harun
Version: 1.6.2
Author URI: http://aahacreative.com/
 Temperature Functionality and some tweaks by Flavio Jarabeck (www.InternetDrops.com.br)
 Updated Dashboard widgets suggested by Pedro Sampaio (e-pedro.com)
*/

/*Uncomment the following line if you want to have the calendar appear as a widget on the dashboard.*/
//add_action('wp_dashboard_setup', 'fpc_setup_dashboard_widget');


add_action('admin_menu', 'fpc_init');
add_action('widgets_init', 'fpc_widgets_init');

function fpc_init(){
global $wp_version;
	add_meta_box( 'future_calendar', 'Future Posts', 'get_future_calendar_html', 'post', 'side', 'high' );
}

function fpc_widgets_init() {
	register_widget('fpc_widget');
}

function fcal_javascript(){
	?>
	<script type="text/javascript">
		function fcal_set_date(day,month,year){
				if(jQuery('.edit-timestamp:visible').length > 0){
					jQuery('.edit-timestamp:visible').click();
				}

				if(day > 0 && month <= 12 && month >= 0 && year > 0){
				document.getElementById("jj").value = day;
				document.getElementById("aa").value = year;
				document.getElementsByName("mm")[0].selectedIndex = month;
				}

		}

	jQuery(document).ready( function($) {
		// close postboxes that should be closed
		jQuery('.if-js-closed').removeClass('if-js-closed').addClass('closed');

		// postboxes
		<?php
		global $wp_version;
		if(version_compare($wp_version,"2.7-alpha", "<")){
			echo "add_postbox_toggles('future_calendar');"; //For WP2.6 and below
		}
		else{
			echo "postboxes.add_postbox_toggles('future_calendar');"; //For WP2.7 and above
		}
		?>

	});


	</script>
<?php
}


function get_future_calendar_html(){
global $wp_version;
	
	fcal_javascript();
	// output editing form
	fcal_get_future_posts();
	
	wp_nonce_field( 'closedpostboxes', 'closedpostboxesnonce', false );
	wp_nonce_field( 'meta-box-order', 'meta-box-order-nonce', false );

	
}

function fcal_get_future_posts($onclick = 1){
global $wpdb, $wp_locale;

	$thisyear = gmdate('Y', current_time('timestamp'));
	$thismonth = gmdate('m', current_time('timestamp'));

	// Quick check. If we have no posts at all, abort!
	if ( !$posts ) {
		$gotsome = $wpdb->get_var("SELECT ID from $wpdb->posts WHERE post_type = 'post' AND post_status = 'future' ORDER BY post_date DESC LIMIT 1");
		if ( !$gotsome ){
			get_future_calendar($thismonth,$thisyear,$onclick);
			return;
		}
	}

	get_future_calendar($thismonth,$thisyear,$onclick);

	//Technically thismonth is really nextmonth, but no reason to be technical about it
	//But if thismonth is 12 then we need to reset it, and add a year otherwise we will be checking
	// out the 13th month of this year.
	if($thismonth == 12){
		$thismonth = 0;
		$thisyear +=1;
	}
	// Get months this year and next with at least one post
	$future = $wpdb->get_results("SELECT
		DISTINCT MONTH(post_date) AS month, YEAR(post_date) AS year
		FROM $wpdb->posts
		WHERE post_date >'$thisyear-".($thismonth+1)."-01'
		AND post_type = 'post' AND post_status = 'future'
		ORDER	BY post_date ASC");

	foreach($future as $now){
		get_future_calendar($now->month,$now->year);
	}
}


// Calendar Output...
function get_future_calendar( $thismonth ='', $thisyear='', $onclick=1, $initial=true ) {
	global $wpdb, $timedifference, $wp_locale;
	$unixmonth = mktime(0, 0 , 0, $thismonth, 1, $thisyear);

	// week_begins = 0 stands for Sunday
	$week_begins = intval(get_option('start_of_week'));
	$add_hours = intval(get_option('gmt_offset'));
	$add_minutes = intval(60 * (get_option('gmt_offset') - $add_hours));

	echo '<table class="wp-calendar" style="margin: 0pt auto; width:160px;">
	<caption><em>' . $wp_locale->get_month($thismonth) . ' ' . $thisyear . '</em></caption>
	<thead>
	<tr>';

	$myweek = array();

	for ( $wdcount=0; $wdcount<=6; $wdcount++ ) {
		$myweek[] = $wp_locale->get_weekday(($wdcount+$week_begins)%7);
	}
	foreach ( $myweek as $wd ) {
		$day_name = (true == $initial) ? $wp_locale->get_weekday_initial($wd) : $wp_locale->get_weekday_abbrev($wd);
		echo "\n\t\t<th abbr=\"$wd\" scope=\"col\" title=\"$wd\">$day_name</th>";
	}

	echo '
	</tr>
	</thead>
	<tbody>
	<tr>';

	// Get days with posts
	$dayswithposts = $wpdb->get_results("SELECT DISTINCT DAYOFMONTH(post_date)
		FROM $wpdb->posts WHERE MONTH(post_date) = '$thismonth'
		AND YEAR(post_date) = '$thisyear'
		AND post_type = 'post' AND post_status = 'future'
		AND post_date > '" . current_time('mysql') . '\'', ARRAY_N);
	if ( $dayswithposts ) {
		foreach ( $dayswithposts as $daywith ) {
			$daywithpost[] = $daywith[0];
		}
	} else {
		$daywithpost = array();
	}



	if ( strstr($_SERVER['HTTP_USER_AGENT'], 'MSIE') || strstr(strtolower($_SERVER['HTTP_USER_AGENT']), 'camino') || strstr(strtolower($_SERVER['HTTP_USER_AGENT']), 'safari') )
		$ak_title_separator = "\n";
	else
		$ak_title_separator = ', ';

	$ak_titles_for_day = array();
    //sets the Density Thermometer
	$ak_posts_for_day = array();

	$ak_post_titles = $wpdb->get_results("SELECT post_title, DAYOFMONTH(post_date) as dom "
		."FROM $wpdb->posts "
		."WHERE YEAR(post_date) = '$thisyear' "
		."AND MONTH(post_date) = '$thismonth' "
		."AND post_date > '".current_time('mysql')."' "
		."AND post_type = 'post' AND post_status = 'future'"
	);
	if ( $ak_post_titles ) {
		foreach ( $ak_post_titles as $ak_post_title ) {
				if ( empty($ak_titles_for_day['day_'.$ak_post_title->dom]) )
					$ak_titles_for_day['day_'.$ak_post_title->dom] = '';
				if ( empty($ak_titles_for_day["$ak_post_title->dom"]) ) // first one
					$ak_titles_for_day["$ak_post_title->dom"] = str_replace('"', '&quot;', wptexturize($ak_post_title->post_title));
				else
					$ak_titles_for_day["$ak_post_title->dom"] .= $ak_title_separator . str_replace('"', '&quot;', wptexturize($ak_post_title->post_title));

                $ak_posts_for_day["$ak_post_title->dom"] +=1;

		}
	}


	// See how much we should pad in the beginning
	$pad = calendar_week_mod(date('w', $unixmonth)-$week_begins);
	if ( 0 != $pad ) { echo "\n\t\t".'<td colspan="'.$pad.'" class="pad">&nbsp;</td>'; }

	    //Determines the Density Thermometer colors
	    $thermo = Array( "#BDFFBE", "#7AFFDE", "#2FEEFF", "#108BFF", "#0E72FF" );


	$daysinmonth = intval(date('t', $unixmonth));
	for ( $day = 1; $day <= $daysinmonth; ++$day ) {
		if ( isset($newrow) && $newrow )
			echo "\n\t</tr>\n\t<tr>\n\t\t";
		$newrow = false;

		if ( $day == gmdate('j', (time() + (get_option('gmt_offset') * 3600))) && $thismonth == gmdate('m', time()+(get_option('gmt_offset') * 3600)) && $thisyear == gmdate('Y', time()+(get_option('gmt_offset') * 3600)) )
			echo '<td style="font-weight:bold;">';
		else
			echo '<td>';

		if($onclick == 1){
			$onclick1 = 'onclick="fcal_set_date('.$day.','.($thismonth-1).','.$thisyear.')"';
		}

        // any posts on that day?
		if ( in_array($day, $daywithpost) ) {
            //Outputs the Density Thermometer along with the day...
			echo '<span style="background-color:'.($ak_posts_for_day[$day]<=Count($thermo) ? $thermo[$ak_posts_for_day[$day]-1] : $thermo[Count($thermo)-1]).';" title="'.$ak_titles_for_day[$day].'" '.$onclick1.' >'.$day.'</span>';

		} else {
			echo '<span '.$onclick1.' >'.$day.'</span>';
        }
		echo '</td>';

		if ( 6 == calendar_week_mod(date('w', mktime(0, 0 , 0, $thismonth, $day, $thisyear))-$week_begins) )
			$newrow = true;
	}

	$pad = 7 - calendar_week_mod(date('w', mktime(0, 0 , 0, $thismonth, $day, $thisyear))-$week_begins);
	if ( $pad != 0 && $pad != 7 )
		echo "\n\t\t".'<td class="pad" colspan="'.$pad.'">&nbsp;</td>';

	echo "\n\t</tr>\n\t</tbody>\n\t</table>";
}


/*Add Dashboard Widget via function wp_add_dashboard_widget()*/
function fpc_setup_dashboard_widget() {
    wp_add_dashboard_widget( 'fpc_add_dashboard_widget', __( 'Future Posts' ), 'fpc_add_dashboard_widget' );
}

function fpc_add_dashboard_widget(){
	fcal_get_future_posts(0);
}


class fpc_widget extends WP_Widget {

	function fpc_widget() {

		$widget_ops = array('classname' => 'fpc_widget', 'description' => __( "Show your blog's Future Posts in the sidebar.") );
		echo $this->WP_Widget('fpc_widget', __('Future Posts Sidebar'), $widget_ops);
	}


	function update( $new_instance, $old_instance ) {
		$instance = $old_instance;
		$instance['title'] = strip_tags($new_instance['title']);
		$this->flush_widget_cache();

		$alloptions = wp_cache_get( 'alloptions', 'options' );
		if ( isset($alloptions['fpc_widget']) )
			delete_option('fpc_widget');

		return $instance;
	}

	function flush_widget_cache() {
		wp_cache_delete('fpc_widget', 'widget');
	}

	function form( $instance ) {
		$title = isset($instance['title']) ? esc_attr($instance['title']) : '';
?>

		<p><label for="<?php echo $this->get_field_id('title'); ?>"><?php _e('Title'); ?></label>
		<input type="text" name="<?php echo $this->get_field_name('title'); ?> id="<?php echo $this->get_field_id('title'); ?>" value="<?php echo $title;?>">
		</p>
<?php
	}

	function widget($args, $instance) {
		global $wpdb;

		$cache = wp_cache_get('fpc_widget', 'widget');

		if ( !is_array($cache) )
			$cache = array();

		if ( isset($cache[$args['widget_id']]) ) {
			echo $cache[$args['widget_id']];
			return;
		}

		ob_start();
		extract($args);

		$title = apply_filters('widget_title', empty($instance['title']) ? __('Scheduled Posts') : $instance['title']);
?>
		<?php echo $before_widget; ?>
		<?php echo $before_title; ?><?php if ( $title ) echo $title; ?><?php echo $after_title; ?>
		<div id="fpc">
			<?php fcal_get_future_posts(0);?>
		</div>
		<?php echo $after_widget; ?>
<?php

		$cache[$args['widget_id']] = ob_get_flush();

		wp_cache_add('fpc_widget', $cache, 'widget');
	}



}


?>