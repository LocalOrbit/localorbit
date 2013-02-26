<?php
/*
Plugin Name: NewsPage
Plugin URI: http://www.rogerstringer.com
Description: Create an Rss-powered news page on your website
Author: Roger Stringer
Version: 3.0
Author URI: http://www.rogerstringer.com
*/
	if (!defined('WP_CONTENT_DIR')) {
		define( 'WP_CONTENT_DIR', ABSPATH.'wp-content');
	}
	if (!defined('WP_CONTENT_URL')) {
		define('WP_CONTENT_URL', get_option('siteurl').'/wp-content');
	}
	if (!defined('WP_PLUGIN_DIR')) {
		define('WP_PLUGIN_DIR', WP_CONTENT_DIR.'/plugins');
	}
	if (!defined('WP_PLUGIN_URL')) {
		define('WP_PLUGIN_URL', WP_CONTENT_URL.'/plugins');
	}
	define('IMG_URL', WP_PLUGIN_URL.'/newspage/images');
	define('NB_FAVICON_DEFAULT', IMG_URL.'/alternate_favicon.png');
	define('NB_NEW_HTML', '<img src="'.IMG_URL.'/new.png" alt="New!" title="This was posted within the last 24 hours." style="vertical-align:middle;">');

	define('SIMPLEPIE_CACHEDIR', dirname(__FILE__) . '/cache');
	define('SIMPLEPIE_CACHEDURATION', 3600 );	//The number of seconds that feed data should be cached for before asking the feed if it's been changed
	if (!class_exists('SimplePie')) {
		require_once(dirname(__FILE__).'/simplepie.inc');
	}
	require_once(dirname(__FILE__).'/newsblocks.php');
	
	$npVersion = '2.0';

	function npInit() {
		global $npVersion;
		if (!headers_sent() && !session_id()) session_start();
		if (!defined('WP_CONTENT_URL')) define('WP_CONTENT_URL', get_option( 'siteurl' ) . '/wp-content');
		if (!defined('WP_PLUGIN_URL')) define('WP_PLUGIN_URL', WP_CONTENT_URL . '/plugins');
		if (!get_option('newspage_version')) npInstall();
		if (version_compare(get_option('newspage_version'), $npVersion, '<')) npUpdate();	
		add_action('wp_head', 'npHead', 30);
		add_action('admin_head', 'npAdminHead');
		add_action('admin_menu', 'npAddAdmin', 20);
		add_filter('the_content', 'npPostTags');
		add_shortcode("newspage","npscBlocks");
		add_shortcode("newstopics","npscTopics");
	}
	add_action('init', 'npInit');
	function npInstall(){
		global $wpdb, $npVersion;
		add_option('newspage_version', $npVersion);
		$tableName = $wpdb->prefix . 'rssfeeds';
		add_option('newspage_dbname', $tableName);
		if ($wpdb->get_var("SHOW TABLES LIKE '" . $tableName . "'") != $tableName) {
			$sql = "CREATE TABLE " . $tableName . " (
						Id INT( 20 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
						Title VARCHAR( 150 ) NOT NULL ,
						feedurl VARCHAR( 250 ) NOT NULL ,
						httpurl VARCHAR( 250 ) NOT NULL ,
						topics VARCHAR( 250 ) NOT NULL ,
						Description MEDIUMTEXT NOT NULL ,
						active tinyint( 4 ) NOT NULL,
						porder int( 12 ) NOT NULL
					);";
			if (file_exists(ABSPATH . 'wp-admin/includes/upgrade.php')) require_once ABSPATH . 'wp-admin/includes/upgrade.php';
			dbDelta($sql);
		}
		add_option('newspage_maxTitleLength', '50');
		add_option('newspage_titleBreaker', '&hellip;');
		add_option('newspage_maxDescriptionLength', '200');
		add_option('newspage_descriptionBreaker', '&hellip;');
		add_option('newspage_numitems', '10');
		add_option('newspage_template', '');
		add_option('newspage_newwindow', "0");
		add_option('newspage_cache_on', 1);
		add_option('newspage_cache_duration', 1);
		add_option('newspage_cache_duration_units', 3600);
		add_option('newspage_linklove', 1);
		add_option('newspage_incStyle', true);
		add_option('newspage_useFeedTitle', 1);
		add_option('newspage_showtopics', 1);
		add_option('newspage_use_externalstyle', "0");
	}
	function npUpdate(){
		global $wpdb, $npVersion;
		$tableName = $wpdb->prefix . 'rssfeeds';
		add_option('newspage_useFeedTitle', 1);	
		add_option('newspage_showtopics', 1);
		add_option('newspage_use_externalstyle', "0");
		add_option('newspage_newwindow', "0");
		$sql = "CREATE TABLE " . $tableName . " (
					Id INT( 20 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
					Title VARCHAR( 150 ) NOT NULL ,
					feedurl VARCHAR( 250 ) NOT NULL ,
					httpurl VARCHAR( 250 ) NOT NULL ,
					topics VARCHAR( 250 ) NOT NULL ,
					Description MEDIUMTEXT NOT NULL ,
					active tinyint( 4 ) NOT NULL,
					porder int( 12 ) NOT NULL
				);";
		if (file_exists(ABSPATH . 'wp-admin/includes/upgrade.php')) require_once ABSPATH . 'wp-admin/includes/upgrade.php';
		dbDelta($sql);
		update_option('newspage_version', $npVersion);
	}
	function npHead(){
		if( get_option("newspage_use_externalstyle") != 1){
			echo '<link rel="stylesheet" type="text/css" href="' . WP_PLUGIN_URL . '/newspage/newspage.css" />' . "\n";
		}
	}
	function npAdminHead(){
	
	}
	function npAddAdmin(){
		add_menu_page(__('Manage RSS Feeds', 'np'), __('NewsPage', 'np'), 'Manage RSS Feeds', dirname(__FILE__), 'npFeeds');
		add_submenu_page(dirname(__FILE__), __('NewsPage RSS Feeds', 'np'), __('RSS Feeds', 'np'), 'manage_options', 'npFeeds', 'npFeeds');
		add_submenu_page(dirname(__FILE__), __('NewsPage Settings', 'np'), __('Settings', 'np'), 'manage_options', 'npSettings', 'npSettings');
	}
	function npFeeds(){
		global $wpdb;
//		Manage RSS Feeds
		require_once(dirname(__FILE__).'/newspage.feeds.php');	
	}	
	function npSettings(){
//		Manage Settings
		require_once(dirname(__FILE__).'/newspage.settings.php');	
	}
	function newsTopics(){
		global $wpdb;
		$sql = "SELECT DISTINCT topics FROM " . get_option('newspage_dbname') . " WHERE active = '1' ORDER BY porder ASC";
		$posts = $wpdb->get_results($sql);
		$html = "<!-- START of newsPage output -->";
		if (empty($posts)) return '<!-- No posts found. //--><p>No feeds have been added yet</p>';
		$topics = array();
		foreach ($posts as $post) {
			$first = $post->topics[0];
			if( !isset($topics[ $first ]) ) $topics[ $first ] = array();
			$topics[ $first ][] = $post->topics;
		}
		foreach($topics as $key=>$list){
			$html .= '<div class="feed">';
			$html .= '<div class="feedtitle">'.$key.'</div>' . "\n";
			$html .= '<ul>' . "\n";
			foreach($list as $row){
				$url = get_permalink();
				if( stristr($url,"?") ){
					$url = $url ."&topic=".str_replace(" ","_",$row);
				}else{
					$url = $url ."?topic=".str_replace(" ","_",$row);;
				}
				$html .= "<li><a href='{$url}'>{$row}</a></li>\n";
			}
			$html .= '</ul>' . "\n";
			$html .= '</div>' . "\n";
		}
		$html .= "<!-- END of newsPage output - Powered by newsPage (http://www.rogerstringer.com/projects/newspage/) -->";
		return $html;
	}
	function newsPage($limit=0,$topic=""){
		global $wpdb;
		$dtop = $topic;
		if( isset($_GET['topic']) && !empty($_GET['topic']) ){
			$topic = $_GET['topic'];
			$topic = str_replace("_"," ",$topic);
		}
		if($topic != ""){
			$sql = "SELECT * FROM " . get_option('newspage_dbname') . " WHERE active = '1' && topics LIKE '%{$topic}%' ORDER BY porder ASC";
		}else{
			$sql = "SELECT * FROM " . get_option('newspage_dbname') . " WHERE active = '1' ORDER BY porder ASC";
		}
		if($limit){
			$sql .= " LIMIT 0,{$limit}";
		}
		$posts = $wpdb->get_results($sql);
		echo "<!-- START of newsPage output -->";
#		echo "<div style='clear:both;'>";
		if (empty($posts)) return '<!-- No posts found. //--><p>No feeds have been added yet</p>';
		foreach ($posts as $post) {
			$feedurl = $post->feedurl;
			$title = $post->Title;
			echo newsblocks::listing($feedurl, array('items' => get_option('newspage_numitems'),'ftitle'=>$title));
		}
		if( get_option("newspage_showtopics") == 1){
			echo "<div style='clear:both;'>";
			echo "<h2>List of Topics</h2>";
			echo newsTopics();
			echo "</div>";
		}
		if( get_option("newspage_linklove") == 1 ){
			echo "<p style='clear:both;'>newsPage brought to you by <a href='http://www.rogerstringer.com/projects/newspage/'>newsPage Plugin</a></p>";
		}
#		echo "</div>";
		echo "<!-- END of newsPage output - Powered by newsPage (http://www.rogerstringer.com/projects/newspage/) -->";
	}
	function npPostTags($content){
		if (strstr($content, '<!--newspage-->')) {
			ob_start();
				newsPage();
				$dapage = ob_get_contents();
			ob_end_clean();
			$content = str_replace('<!--newspage-->', $dapage, $content);
		}elseif (strstr($content, '<!--newstopics-->')) {
			ob_start();
				if( isset($_GET['topic']) && !empty($_GET['topic']) ){
					newsPage();
				}else{
					echo newsTopics();
				}
				$dapage = ob_get_contents();
			ob_end_clean();
			$content = str_replace('<!--newstopics-->', $dapage, $content);
		}
		return $content;
	}
	function npscBlocks($atts,$content = null){
		extract(shortcode_atts(array("limit"=>0,"topic"=>""),$atts));
		$_GET['topic'] = $topic;
		ob_start();
			newsPage($limit,$topic);
			$dapage = ob_get_contents();
		ob_end_clean();
		return $dapage;
	}
	function npscTopics($atts,$content = null){
		ob_start();
			extract(shortcode_atts(array("limit"=>0,"topic"=>""),$atts));
			$_GET['topic'] = $topic;
			if( isset($_GET['topic']) && !empty($_GET['topic']) ){
				newsPage();
			}else{
				echo newsTopics();
			}
			$dapage = ob_get_contents();
		ob_end_clean();
		return $dapage;
	}
?>