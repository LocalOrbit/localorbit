<?php
/*
Plugin Name: Related Posts
Plugin URI: http://www.w-a-s-a-b-i.com/archives/2006/02/02/wordpress-related-entries-20/
Description: Returns a list of the related entries based on active/passive keyword matches.
Version: 2.04
Author: Alexander Malov, Mike Lu & Jon Bourne
*/

// Begin setup

global $ran_plugin;
if (! isset($ran_plugin)) {
      	$ran_plugin = true;
		if (isset($_REQUEST['setup'])) // Setup is initiated using related-posts.php?setup
		{
        global $file_path, $user_level;
        require_once(dirname(__FILE__).'/../../' .'wp-config.php');
        get_currentuserinfo();
        if ($user_level < 8)
        	die ("Sorry, you must be at least a level 8 user."); // Make sure that user has sufficient priveleges

// SQL query to setup the actual full-text index

		require(dirname(__FILE__).'/../../' .'wp-config.php');

		global $table_prefix;
		
		$connexion = mysql_connect(DB_HOST,DB_USER,DB_PASSWORD) or die("Can't connect.<br />".mysql_error());
		$dbconnexion = mysql_select_db(DB_NAME, $connexion);
		
		if (!$dbconnexion)
		{
			echo mysql_error();
			die();
			}
		$sql_run = 'ALTER TABLE `'.$table_prefix.'posts` ADD FULLTEXT `post_related` ( `post_name` ,'
        . ' `post_content` )';
		$sql_result = mysql_query($sql_run);
		
		if ($sql_result)
			echo ("Congratulations! Full text index was created successfully!");
		
		else
			echo (" Something went wrong. Please check the instructions on how to setup the full text index manually.");
			}
}

// End setup

// Begin Related Posts

function related_posts($return_bool = false, $limit=5, $len=10, $before_title = '', $after_title = '', $before_post = '', $after_post = '', $show_pass_post = false, $show_excerpt = false) {
   
global $wpdb, $post;

	// Get option values from the options page
	
  	$limit = get_option('limit');
  	$len = get_option('len');
  	$before_title = stripslashes(get_option('before_title'));
  	$after_title = stripslashes(get_option('after_title'));
  	$before_post = stripslashes(get_option('before_post'));
  	$after_post = stripslashes(get_option('after_post'));
  	$show_pass_post = get_option('show_pass_post');
	$show_excerpt = get_option('show_excerpt');
	
	// Fetch keywords

	$postcustom = get_post_custom_values('keyword');
	if (!empty($postcustom)) {
		$values = array_map('trim', $postcustom);
		$terms = implode($values, ' ');
	} else {
    	$terms = str_replace('-', ' ', $post->post_name);
    }

	// Make sure the post is not from the future

	$time_difference = get_settings('gmt_offset');
	$now = gmdate("Y-m-d H:i:s",(time()+($time_difference*3600)));
	
	if (!$limit) $limit = '0,3'; // Quick fix for "no defaults" bug 28.9
	
	// Primary SQL query
	
    $sql = "SELECT ID, post_title, post_content,"
         . "MATCH (post_name, post_content) "
         . "AGAINST ('$terms') AS score "
         . "FROM $wpdb->posts WHERE "
         . "MATCH (post_name, post_content) "
         . "AGAINST ('$terms') "
		 . "AND post_date <= '$now' "
         . "AND (post_status IN ( 'publish',  'static' ) && ID != '$post->ID') ";
    if ($show_pass_post=='false') { $sql .= "AND post_password ='' "; }
    $sql .= "ORDER BY score DESC LIMIT $limit";
    $results = $wpdb->get_results($sql);
    $output = '';
    if ($results) {
        if($return_bool) {
			return true;
		}
		else {
			foreach ($results as $result) {
				$title = stripslashes(apply_filters('the_title', $result->post_title));
				$permalink = get_permalink($result->ID);
				$post_content = strip_tags($result->post_content);
				$post_content = stripslashes($post_content);
				$output .= $before_title .'<a href="'. $permalink .'" rel="bookmark" title="Permanent Link: ' . $title . '">' . $title . '</a>' . $after_title;
				if ($show_excerpt=='true') {
					$ze = substr($post_content, 0, $len);
					$ze = substr($ze, 0, strrpos($ze,''));
					$ze = $ze . '...';
					$output .= $before_post . $ze . $after_post;
//					$words=split(" ",$post_content);
//					$post_strip = join(" ", array_slice($words,0,$len));
//					$output .= $before_post . $post_strip . $after_post;
				}
			}
			echo $output;
		}
	} else {
        if($return_bool) {
			return false;
		} else {
			echo $before_title.'No related posts'.$after_title;
		}
    }
}

function related_posts_exist() {
	return related_posts(true);
}

// End Related Posts

// Begin Keywords

function find_keywords($id) {
	global $wpdb;
	$content = $wpdb->get_var("SELECT post_content FROM $wpdb->posts WHERE ID = '$id'");
	if (preg_match_all('/<!--kw=([\s\S]*?)-->/i', $content, $matches, PREG_SET_ORDER)) {
		$test = $wpdb->get_var("SELECT meta_value FROM $wpdb->postmeta WHERE post_id = '$id' AND meta_key = 'keyword'");
		if (!empty($test)) {
			$output = explode(' ', $test);
		} else {
			$output = array();
		}
		foreach($matches as $match) {
			$output = array_merge($output, explode(' ', $match[1]));
		}
		$output = array_unique($output);
		$keywords = implode(' ', $output);
		if (!empty($test)) {
      		$results=  $wpdb->query("UPDATE $wpdb->postmeta SET meta_value = '$keywords' WHERE post_id = '$id' AND meta_key = 'keyword'");
		} else {
			$results = $wpdb->query("INSERT INTO $wpdb->postmeta (post_id,meta_key,meta_value) VALUES ('$id', 'keyword', '$keywords')");
		}
		$content = format_to_post(balanceTags(preg_replace("/<!--kw=([\s\S]*?)-->/i", "<!--$1-->", $content)));
		$content = str_replace("'", "'", $content); // Fix for ' in $content
		$results = $wpdb->query("UPDATE $wpdb->posts SET post_content = '$content' WHERE ID = '$id'");
	}
	return $id;
}

// End Keywords

// Begin Related Posts Options

function rp_subpanel() {
     if (isset($_POST['update_rp'])) {
       $option_limit = $_POST['limit'];
	   $option_len = $_POST['len'];
       $option_before_title = $_POST['before_title'];
       $option_after_title = $_POST['after_title'];
       $option_before_post = $_POST['before_post'];
       $option_after_post = $_POST['after_post'];
       $option_show_pass_post = $_POST['show_pass_post'];
       $option_show_excerpt = $_POST['show_excerpt'];
       update_option('limit', $option_limit);
       update_option('len', $option_len);
       update_option('before_title', $option_before_title);
       update_option('after_title', $option_after_title);
       update_option('before_post', $option_before_post);
       update_option('after_post', $option_after_post);
       update_option('show_pass_post', $option_show_pass_post);
	   update_option('show_excerpt', $option_show_excerpt);
       ?> <div class="updated"><p>Options saved!</p></div> <?php
     }
	?>

	<div class="wrap">
		<h2>Related Posts Options</h2>
		<form method="post">
		<fieldset class="options">
		<table>
			<tr>
				<td><label for="limit">How many related posts would you like to show?</label>:</td>
				<td><input name="limit" type="text" id="limit" value="<?php echo get_option('limit'); ?>" size="2" /></td>
			</tr>
		 	<tr>
           		<td><label for="before_title">Before</label> / <label for="after_title">After (Post Title) </label>:</td>
				<td><input name="before_title" type="text" id="before_title" value="<?php echo htmlspecialchars(stripslashes(get_option('before_title'))); ?>" size="10" /> / <input name="after_title" type="text" id="after_title" value="<?php echo htmlspecialchars(stripslashes(get_option('after_title'))); ?>" size="10" /><em><small> For example: &lt;li&gt;&lt;/li&gt; or &lt;dl&gt;&lt;/dl&gt;</small></em>
				</td>
			</tr>
			<tr>
				<td>Show excerpt?</td>
          		<td>
        			<select name="show_excerpt" id="show_excerpt">
        	  		<option <?php if(get_option('show_excerpt') == 'false') { echo 'selected'; } ?> value="false">False</option>
					<option <?php if(get_option('show_excerpt') == 'true') { echo 'selected'; } ?> value="true">True</option>
					</select>
				</td> 
			</tr>
			<tr>
				<td><label for="len">Excerpt length (No. of words):</label></td>
				<td><input name="len" type="text" id="len" value="<?php echo get_option('len'); ?>" size="2" /> 
			</tr>
			<tr>
				<td><label for="before_post">Before</label> / <label for="after_post">After</label> (Excerpt):</td>
				<td><input name="before_post" type="text" id="before_post" value="<?php echo htmlspecialchars(stripslashes(get_option('before_post'))); ?>" size="10" /> / <input name="after_post" type="text" id="after_post" value="<?php echo htmlspecialchars(stripslashes(get_option('after_post'))); ?>" size="10" /><em><small> For example: &lt;li&gt;&lt;/li&gt; or &lt;dl&gt;&lt;/dl&gt;</small></em>
				</td>
			</tr>
			<tr>
				<td><label for="show_pass_post">Show password protected posts?</label></td>
				<td>
            	<select name="show_pass_post" id="show_pass_post">
              	<option <?php if(get_option('show_pass_post') == 'false') { echo 'selected'; } ?> value="false">False</option>
              	<option <?php if(get_option('show_pass_post') == 'true') { echo 'selected'; } ?> value="true">True</option>
            	</select> 
				</td>
			</tr>
		</table>
		</fieldset>

		<p><div class="submit"><input type="submit" name="update_rp" value="<?php _e('Save!', 'update_rp') ?>"  style="font-weight:bold;" /></div></p>
        
		</form>       
		
    </div>
    
    <div class="wrap">   
        <h2>SQL Index Table Setup</h2>
		<p>If this is your first time installing this plugin you will have to run <a href="../wp-content/plugins/related-posts.php?setup" onclick="window.open(this.href, 'popupwindow', 'width=400,height=150,scrollbars,resizable'); return false;">this script</a> (opens a new window) in order to create the index table required by the plugin. If this fails, please refer to the readme on how to create it manually.</p>
		
    </div>

<?php } 

// End Related Posts Options

function rp_admin_menu() {
   if (function_exists('add_submenu_page')) {
        add_submenu_page('plugins.php', __('Related Posts Options'), __('Related Posts Options'), 1, __FILE__, 'rp_subpanel');
        }
}

add_action('edit_post', 'find_keywords', 1);
// add_action('publish_post', 'find_keywords', 1);
add_action('admin_menu', 'rp_admin_menu');

?>
