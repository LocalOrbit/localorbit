<?php
/*
Plugin Name: Subscribe widget
Version: 1.1.5
Plugin URI: http://www.pclastnews.com/subscribe-widget.html
Description: Adds a subscribe widget to the sidebar. 
Author: Kestas Mindziulis
Author URI: http://www.pclastnews.com
*/


if (isset($_GET['activate']) && $_GET['activate'] == 'true') {
	add_action('init', 'sw_install');
}
function sw_install() {
	if( !is_dir( ABSPATH.'subscribe-widget/' ) ){
        mkdir( ABSPATH.'subscribe-widget/', 0777 );
    }
    else { chmod( ABSPATH.'subscribe-widget/', 0777 ); }
}


/*add_filter('the_content', 'sw_displayOnPosts');
function sw_displayOnPosts( $content ){
    global $post;
    $options = get_option('subscribe_widget');
    if( ( $post->post_type == 'post' && $options['sw-showonposts'] == '1' ) ) {
		if (!is_feed()) {
			return $content.'<p>'.sw_displaySubscribeWidget().'</p>';
		}
	}
	return $content;
}*/

function sw_displaySubscribeWidget( $type="post" ){
    $html_content = '';
    $options = get_option('subscribe_widget');
    $title = htmlspecialchars($options['sw-title'], ENT_QUOTES);
    $sw_postsfeed = $options['sw-postsfeed'];
    $sw_commentsfeed = $options['sw-commentsfeed'];
    $sw_twitter = $options['sw-twitter'];
    $sw_feedburner = $options['sw-feedburner'];
    
    $all_images_url = get_option("home").'/subscribe-widget/';
    $all_images_dir = ABSPATH.'subscribe-widget/';
    
    if( !function_exists(gd_info) ){
        $image_width = " width: ".$options['sw-image-width']."px;";
    }
    else { $image_width = ''; }
    
    // These lines generate our output.
    if( ($sw_postsfeed['show'] == 1 || $sw_commentsfeed['show'] == 1 || $sw_twitter['show'] == 1 || $sw_feedburner['show'] == 1) && ($options['sw-showontheme'] == 1 ) ){
        
        if( $type != 'post' ) { $html_content .= '<div id="subscribe-widget-theme">'; }
        if( $title != '' ){
            $html_content .= '<h2>' . $title . '<h2>';
        }
        if( $type == 'post' ){ $html_content .= '<p>'; }
        
        if( $sw_postsfeed['show'] == 1  ){
            $image_ext = sw_getExtension( $sw_postsfeed['image'] );
            if( is_file( $all_images_dir.'postsfeed.'.$image_ext ) ){
                if( $sw_postsfeed['link_target'] != '' ){ $target = ' target="'.$sw_postsfeed['link_target'].'" '; }
                else { $target = ""; }
                $html_content .= '<a title="Subscribe RSS" '.$target.' href="'.get_feed_link().'">';
                $html_content .= '<img src="'.$all_images_url.'postsfeed.'.$image_ext.'" border="0" style="margin-right:5px;margin-left:5px; '.$image_width.'" alt="Subscribe RSS" />';
                $html_content .= '</a>';
            }
        }
        if( $sw_commentsfeed['show'] == 1 ){
            $image_ext = sw_getExtension( $sw_commentsfeed['image'] );
            if( is_file( $all_images_dir.'commentsfeed.'.$image_ext ) ){
                if( $sw_commentsfeed['link_target'] != '' ){ $target = ' target="'.$sw_commentsfeed['link_target'].'" '; }
                else { $target = ""; }
                if( $type == 'post' ){
                    global $post;
                    if( $post->ID != '' ) { $comments_feed_link = get_post_comments_feed_link( $post->ID ); }
                    else { $comments_feed_link = get_feed_link('comments_'); }
                }
                else { $comments_feed_link = get_feed_link('comments_'); }
                $html_content .= '<a title="Subscribe comments RSS" '.$target.' href="'.$comments_feed_link.'">';
                $html_content .= '<img src="'.$all_images_url.'commentsfeed.'.$image_ext.'" border="0" style="margin-right:5px;margin-left:5px;'.$image_width.'" alt="Subscribe comments RSS" />';
                $html_content .= '</a>';
            }
        }
        if( $sw_twitter['show'] == 1 && $sw_twitter['acount'] != '' ){
            $image_ext = sw_getExtension( $sw_twitter['image'] );
            if( is_file( $all_images_dir.'twitter.'.$image_ext ) ){
                if( $sw_twitter['link_target'] != '' ){ $target = ' target="'.$sw_twitter['link_target'].'" '; }
                else { $target = ""; }
                $html_content .= '<a title="Follow me on Twitter" '.$target.' href="http://twitter.com/'.($sw_twitter['acount']).'">';
                $html_content .= '<img src="'.$all_images_url.'twitter.'.$image_ext.'" border="0" style="margin-right:5px;margin-left:5px; '.$image_width.'" alt="Follow me on Twitter" />';
                $html_content .= '</a>';
            }
        }
        if( $sw_feedburner['show'] == 1 && $sw_feedburner['acount'] != '' ){
            $image_ext = sw_getExtension( $sw_feedburner['image'] );
            if( is_file( $all_images_dir.'feedburner.'.$image_ext ) ){
                if( $sw_feedburner['link_target'] != '' ){ $target = ' target="'.$sw_feedburner['link_target'].'" '; }
                else { $target = ""; }
                $html_content .= '<a title="Subscribe on FeedBurner" '.$target.' rel="nofallow" href="http://feedburner.google.com/fb/a/mailverify?uri='.($sw_feedburner['acount']).'&amp;loc=en_US">';
                $html_content .= '<img src="'.$all_images_url.'feedburner.'.$image_ext.'" border="0" style="margin-right:5px;margin-left:5px; '.$image_width.'" alt="Subscribe on FeedBurner" />';
                $html_content .= '</a>';
            }
        }
        if( $type == 'post' ){ $html_content .= '</p>'; }
        else { $html_content .= '</div>'; }
    }
    return $html_content;
}

function sw_displayOnTheTheme( ){
    echo sw_displaySubscribeWidget( 'theme' );
}


/* Functions helps to read the directory and returs all content of that directory to the array 
Params:
    @ PATH - directory path, that need to be readed.
    @ DIRFILES - array of files, that are returned when functions are executed 
    @ DONTREAD - array of folders, that shouldn't be readed.
*/
function sw_ReadDirectory($PATH, &$DIRFILES, $DONTREAD=array() ){
    //$DEEP--;
    $i=0;
	if ($DIR_HANDLE = @opendir($PATH)) {
		while (false !== ($FILE = readdir($DIR_HANDLE))) {
			if( ($FILE != '.') && ($FILE != '..') && ( !in_array($FILE, $DONTREAD)) ){
			    
				if(is_file($PATH.'/'.$FILE)){
				    $DIRFILES[$i] = array("Name"=>"$FILE","Type"=>"F");
                }
                else {
                    $DIRFILES[$i] = array("Name"=>"$FILE","Type"=>"D");
                }
                
                if( (!is_file($PATH.'/'.$FILE)) ){
					sw_ReadDirectory($PATH.'/'.$FILE, $DIRFILES[$i]['MORE'], $DONTREAD);
				}
				$i++;
			}
		}
		closedir($DIR_HANDLE);
	}
}

/* Functions makes file paths from directory files 
Params:
    @ DIRFILES - array of files, that are returned when functions are executed 
    @ FileArray - array of files and folders paths.
    @ CURENT_DIR - current directory path
    @ type - what to read, files or directories . F for file, D for directory. 
    
*/
function sw_GetFilesFromPath($DIRFILES, &$FileArray, $CURENT_DIR='', $type='F'){
    if($CURENT_DIR != ''){
        $CURENT_DIR = $CURENT_DIR."/";
    }
    
    foreach($DIRFILES as $key=>$DIRFILE){
        if( $DIRFILE['Type'] == $type ){
            $FileArray[] = $CURENT_DIR.$DIRFILE['Name'];
        }

        if( is_array($DIRFILE['MORE']) ){
            sw_GetFilesFromPath($DIRFILE['MORE'], $FileArray, $CURENT_DIR.$DIRFILE['Name'], $type);
        }
    }   
}


class SubscribeWidget {

    // static init callback
    function init() {
        // Check for the required plugin functions. This will prevent fatal
        // errors occurring when you deactivate the dynamic-sidebar plugin.
        if ( !function_exists('register_sidebar_widget') )
            return;
        $widget = new SubscribeWidget();
        // This registers our widget so it appears with the other available
        // widgets and can be dragged and dropped into any active sidebars.
        register_sidebar_widget('Subscribe Widget', array($widget,'displayWidget'));
        
        // This registers our optional widget control form.
        register_widget_control('Subscribe Widget', array($widget,'controlWidget'), 280, 300);
    }

    
  // This is the function outputs sidebar
    function displayWidget($args) {
    
        // $args is an array of strings that help widgets to conform to
        // the active theme: before_widget, before_title, after_widget,
        // and after_title are the array keys. Default tags: li and h2.
        extract($args);
    
        $options = get_option('subscribe_widget');
        $title = htmlspecialchars($options['sw-title'], ENT_QUOTES);
        $sw_postsfeed = $options['sw-postsfeed'];
        $sw_commentsfeed = $options['sw-commentsfeed'];
        $sw_twitter = $options['sw-twitter'];
        $sw_feedburner = $options['sw-feedburner'];
        
        $all_images_url = get_option("home").'/subscribe-widget/';
        $all_images_dir = ABSPATH.'subscribe-widget/';
        
        if( !function_exists(gd_info) ){
            $image_width = " width: ".$options['sw-image-width']."px;";
        }
        else { $image_width = ''; }
        
        // These lines generate our output.
        if( ($sw_postsfeed['show'] == 1 || $sw_commentsfeed['show'] == 1 || $sw_twitter['show'] == 1 || $sw_feedburner['show'] == 1) && ($options['sw-showontheme'] != 1 ) ){
            echo $before_widget;
            if( $title != '' ){
                echo $before_title . $title . $after_title;
            }
            echo '<div id="subscribe-widget-div">';
            if( $sw_postsfeed['show'] == 1  ){
                $image_ext = sw_getExtension( $sw_postsfeed['image'] );
                if( is_file( $all_images_dir.'postsfeed.'.$image_ext ) ){
                    if( $sw_postsfeed['link_target'] != '' ){ $target = ' target="'.$sw_postsfeed['link_target'].'" '; }
                    else { $target = ""; }
                    echo '<a title="Subscribe RSS" '.$target.' href="'.get_feed_link().'">';
                    echo '<img src="'.$all_images_url.'postsfeed.'.$image_ext.'" border="0" style="margin-right:5px;margin-left:5px; '.$image_width.'" alt="Subscribe RSS" />';
                    echo '</a>';
                }
            }
            if( $sw_commentsfeed['show'] == 1 ){
                $image_ext = sw_getExtension( $sw_commentsfeed['image'] );
                if( is_file( $all_images_dir.'commentsfeed.'.$image_ext ) ){
                    if( $sw_commentsfeed['link_target'] != '' ){ $target = ' target="'.$sw_commentsfeed['link_target'].'" '; }
                    else { $target = ""; }
                    echo '<a title="Subscribe comments RSS" '.$target.' href="'.get_feed_link('comments_').'">';
                    echo '<img src="'.$all_images_url.'commentsfeed.'.$image_ext.'" border="0" style="margin-right:5px;margin-left:5px;'.$image_width.'" alt="Subscribe comments RSS" />';
                    echo '</a>';
                }
            }
            if( $sw_twitter['show'] == 1 && $sw_twitter['acount'] != '' ){
                $image_ext = sw_getExtension( $sw_twitter['image'] );
                if( is_file( $all_images_dir.'twitter.'.$image_ext ) ){
                    if( $sw_twitter['link_target'] != '' ){ $target = ' target="'.$sw_twitter['link_target'].'" '; }
                    else { $target = ""; }
                    echo '<a title="Follow me on Twitter" '.$target.' href="http://twitter.com/'.($sw_twitter['acount']).'">';
                    echo '<img src="'.$all_images_url.'twitter.'.$image_ext.'" border="0" style="margin-right:5px;margin-left:5px; '.$image_width.'" alt="Follow me on Twitter" />';
                    echo '</a>';
                }
            }
            if( $sw_feedburner['show'] == 1 && $sw_feedburner['acount'] != '' ){
                $image_ext = sw_getExtension( $sw_feedburner['image'] );
                if( is_file( $all_images_dir.'feedburner.'.$image_ext ) ){
                    if( $sw_feedburner['link_target'] != '' ){ $target = ' target="'.$sw_feedburner['link_target'].'" '; }
                    else { $target = ""; }
                    echo '<a title="Subscribe on FeedBurner" '.$target.' rel="nofallow" href="http://feedburner.google.com/fb/a/mailverify?uri='.($sw_feedburner['acount']).'&amp;loc=en_US">';
                    echo '<img src="'.$all_images_url.'feedburner.'.$image_ext.'" border="0" style="margin-right:5px;margin-left:5px; '.$image_width.'" alt="Subscribe on FeedBurner" />';
                    echo '</a>';
                }
            }
            echo '</div>';
            echo $after_widget;
        }
        
    }

  // This is the function that outputs the control form
    function controlWidget() {
        // Get our options and see if we're handling a form submission.
        $options = get_option('subscribe_widget');
        
        $aligns = array("left", "center", "right");
        $link_targets = array(""=>"In the same window", "_blank"=>"In new window", );
        if ( !is_array($options) )
          $options = array('sw-title'=>'',
    		        'sw-postsfeed'=>array(),
                    'sw-commentsfeed'=>array(),
                    'sw-twitter'=>array(),
                    'sw-feedburner'=>array(),
                    'sw-image-height'=>'',
                    'sw-image-width'=>'',
                    'sw-align'=>'',
                    'sw-showonposts'=>'',
                     );
    
        if ( $_POST['sw-submit'] ) {
            // Remember to sanitize and format use input appropriately.
            $options['sw-title'] = strip_tags(stripslashes($_POST['sw-title']));
            $options['sw-image-height'] = strip_tags(stripslashes($_POST['sw-image-height']));
            $options['sw-image-width'] = strip_tags(stripslashes($_POST['sw-image-width']));
            
            $options['sw-postsfeed'] = $_POST['sw-postsfeed'];
            $options['sw-commentsfeed'] = $_POST['sw-commentsfeed'];
            $_POST['sw-twitter']['acount'] = htmlentities($_POST['sw-twitter']['acount']);
            $options['sw-twitter'] = $_POST['sw-twitter'];
            $_POST['sw-feedburner']['acount'] = htmlentities($_POST['sw-feedburner']['acount']);
            $options['sw-feedburner'] = $_POST['sw-feedburner'];
            $options['sw-align'] = $_POST['sw-align'];
            $options['sw-showontheme'] = $_POST['sw-showontheme'];
            //$options['sw-showonposts'] = $_POST['sw-showonposts'];
            
            $resize = new ResizeComponent();
            $all_images_dir = ABSPATH.'wp-content/plugins/subscribe-plugin/images/';
            if( !is_dir( ABSPATH.'subscribe-widget/' ) ){
                mkdir( ABSPATH.'subscribe-widget/', 0777 );
            }
            else { chmod( ABSPATH.'subscribe-widget/', 0777 ); }
            if( is_dir( ABSPATH.'subscribe-widget/' ) ){
                if( is_file( $all_images_dir.'posts-feed/'.$_POST['sw-postsfeed']['image'] ) ){
                    $image_ext = sw_getExtension( $_POST['sw-postsfeed']['image'] );
                    copy( $all_images_dir.'posts-feed/'.$_POST['sw-postsfeed']['image'], ABSPATH.'subscribe-widget/postsfeed.'.$image_ext ) ;
                    $image = ABSPATH.'subscribe-widget/postsfeed.'.$image_ext;
                    sw_resizeImage( $resize, $image, $_POST['sw-image-height'], $_POST['sw-image-width'] );
                }
                
                if( is_file( $all_images_dir.'comments-feed/'.$_POST['sw-commentsfeed']['image'] ) ){
                    $image_ext = sw_getExtension( $_POST['sw-commentsfeed']['image'] );
                    copy( $all_images_dir.'comments-feed/'.$_POST['sw-commentsfeed']['image'], ABSPATH.'subscribe-widget/commentsfeed.'.$image_ext ) ;
                    $image = ABSPATH.'subscribe-widget/commentsfeed.'.$image_ext;
                    sw_resizeImage( $resize, $image, $_POST['sw-image-height'], $_POST['sw-image-width'] );
                }
                if( is_file( $all_images_dir.'twitter/'.$_POST['sw-twitter']['image'] ) ){
                    $image_ext = sw_getExtension( $_POST['sw-twitter']['image'] );
                    copy( $all_images_dir.'twitter/'.$_POST['sw-twitter']['image'], ABSPATH.'subscribe-widget/twitter.'.$image_ext ) ;
                    $image = ABSPATH.'subscribe-widget/twitter.'.$image_ext;
                    sw_resizeImage( $resize, $image, $_POST['sw-image-height'], $_POST['sw-image-width'] );
                }
                
                if( is_file( $all_images_dir.'feedburner/'.$_POST['sw-feedburner']['image'] ) ){
                    $image_ext = sw_getExtension( $_POST['sw-feedburner']['image'] );
                    copy( $all_images_dir.'feedburner/'.$_POST['sw-feedburner']['image'], ABSPATH.'subscribe-widget/feedburner.'.$image_ext ) ;
                    $image = ABSPATH.'subscribe-widget/feedburner.'.$image_ext;
                    sw_resizeImage( $resize, $image, $_POST['sw-image-height'], $_POST['sw-image-width'] );
                }
                chmod( ABSPATH.'subscribe-widget/', 0755 );
            }
            update_option('subscribe_widget', $options);
        }

        $title = htmlspecialchars($options['sw-title'], ENT_QUOTES);
        $sw_postsfeed = $options['sw-postsfeed'];
        $sw_commentsfeed = $options['sw-commentsfeed'];
        $sw_twitter = $options['sw-twitter'];
        $sw_feedburner = $options['sw-feedburner'];
        $image_height = $options['sw-image-height'];
        $image_width = $options['sw-image-width'];
        $images_align = $options['sw-align'];
        $showonpostspage = $options['sw-showonposts'];
        $showontheme = $options['sw-showontheme'];
                
        $feedimages_temp = array();
        $feedimages = array();
        if( is_dir( ABSPATH . 'wp-content/plugins/subscribe-plugin/images/posts-feed/' ) ){
            sw_ReadDirectory( ABSPATH . 'wp-content/plugins/subscribe-plugin/images/posts-feed/', $feedimages_temp );
            sw_GetFilesFromPath( $feedimages_temp, $feedimages );
        }
        $commentsfeedimages_temp = array();
        $commentsfeedimages = array();
        if( is_dir( ABSPATH . 'wp-content/plugins/subscribe-plugin/images/comments-feed/' ) ){
            sw_ReadDirectory( ABSPATH . 'wp-content/plugins/subscribe-plugin/images/comments-feed/', $commentsfeedimages_temp );
            sw_GetFilesFromPath( $commentsfeedimages_temp, $commentsfeedimages );
        }
        $twitterimages_temp = array();
        $twitterimages = array();
        if( is_dir( ABSPATH . 'wp-content/plugins/subscribe-plugin/images/twitter/' ) ){
            sw_ReadDirectory( ABSPATH . 'wp-content/plugins/subscribe-plugin/images/twitter/', $twitterimages_temp );
            sw_GetFilesFromPath( $twitterimages_temp, $twitterimages );
        }
        $feedburnerimages_temp = array();
        $feedburnerimages = array();
        if( is_dir( ABSPATH . 'wp-content/plugins/subscribe-plugin/images/feedburner/' ) ){
            sw_ReadDirectory( ABSPATH . 'wp-content/plugins/subscribe-plugin/images/feedburner/', $feedburnerimages_temp );
            sw_GetFilesFromPath( $feedburnerimages_temp, $feedburnerimages );
        }
        
        if( is_dir(ABSPATH . 'subscribe-widget') ){
            echo '<p style="text-align:right"><label for="sw-title">' . __('Title (Optional):') . ' <input style="width: 200px" id="sw-title" name="sw-title" type="text" value="'.$title.'" /></label></p>';
            //echo '<p style="text-align:right"><label for="sw-showonposts">' . __('Show "Subscribe Icons" on the bottom of the post page:') . ' <input id="sw-showonposts" name="sw-showonposts" type="checkbox" value="1"';
            //if( $showonpostspage == 1 ){ echo "checked"; }
            //echo ' /></label></p>';
            
            echo '<p style="text-align:right"><label for="sw-showontheme">' . __('Show "Subscribe Icons" on the theme*:') . ' <input id="sw-showontheme" name="sw-showontheme" type="checkbox" value="1"';
            if( $showontheme == 1 ){ echo "checked"; }
            echo ' /></label><small>* icons will be shown only on theme, where php code was inserted. For more details look at the readme file in subscribe-plugin folder</small></p>';
            
            echo '<p style="text-align:right"><label for="sw-align">' . __('Align images:') . ' 
            <select id="sw-align" name="sw-align">';
            foreach( $aligns as $align ){
                if( $align == $images_align ){
                    echo '<option value="'.$align.'" selected>'.$align.'</option>';
                }
                else {
                    echo '<option value="'.$align.'">'.$align.'</option>';
                }
            }
            echo '
            </select>
            </label></p>';
            echo '<p style="text-align:right"><label for="sw-image-height">' . __('Images height *:') . ' 
            <select id="sw-image-height" name="sw-image-height">';
            for( $i=20; $i<101; $i=$i+5 ){
                if( $image_height == $i ){ echo '<option value="'.$i.'" selected>'.$i.'</option>'; } 
                else { echo '<option value="'.$i.'">'.$i.'</option>'; }
            }
            echo '    
            </select>
            </label></p>';
            echo '<p style="text-align:right"><label for="sw-image-width">' . __('Images width *:') . ' 
            <select id="sw-image-width" name="sw-image-width">';
            for( $i=20; $i<101; $i=$i+5 ){
                if( $image_width == $i ){ echo '<option value="'.$i.'" selected>'.$i.'</option>'; } 
                else { echo '<option value="'.$i.'">'.$i.'</option>'; }
            }
            echo '    
            </select>
            </label>
            <br />
            <small>* Image will be resized firstly by width and then by height. If image width will be smaller then selected, then image will be not resized. The same is with image height.</small>
            </p>';
            
            echo '<h3>Widget Content:</h3>
            <fieldset style="border: 1px solid #000000; margin: 3px; padding:5px;"><legend style="font-weight: bold; font-size: 12px;">Posts Feed</legend>
            <p style="text-align:right">
                <label for="sw-postsfeed-show">' . __('Show Posts Feed:') . '</label>';
            if( $sw_postsfeed['show'] == 1 ){
                $postfeed_show = ' checked ';
            }
            echo '<input id="sw-postsfeed-show" name="sw-postsfeed[show]" type="checkbox" value="1" '.$postfeed_show.' />
            </p>
            <p style="text-align:right">
                <label for="sw-postsfeed-link_target">' . __('Open link in:') . '</label> 
                <select id="sw-postsfeed-link_target" name="sw-postsfeed[link_target]" ';
            if( $link_targets ){
                foreach( $link_targets as $target=>$name ){
                    if( $sw_postsfeed['link_target'] == $name ){
                        echo '<option value="'.$target.'" selected>'.$name.'</option>';
                    }
                    else {
                        echo '<option value="'.$target.'">'.$name.'</option>';
                    }
                }
            }
            echo '  </select>
            </p>
            <p style="text-align:right">
                <label for="sw-postsfeed-image">' . __('Posts Feed Image:') . '</label> 
                <select id="sw-postsfeed-image" name="sw-postsfeed[image]"
                    onchange="document.getElementById(\'postsfeed-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/posts-feed/\'+document.getElementById(\'sw-postsfeed-image\').options[selectedIndex].value;"
                    onkeydown="document.getElementById(\'postsfeed-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/posts-feed/\'+document.getElementById(\'sw-postsfeed-image\').options[selectedIndex].value;"
                    onkeyup="document.getElementById(\'postsfeed-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/posts-feed/\'+document.getElementById(\'sw-postsfeed-image\').options[selectedIndex].value;" >
                    <option value="">-</option>';
            if( $feedimages ){
                foreach( $feedimages as $image ){
                    if( $sw_postsfeed['image'] == $image ){
                        echo '<option value="'.$image.'" selected>'.$image.'</option>';
                    }
                    else {
                        echo '<option value="'.$image.'">'.$image.'</option>';
                    }
                }
            }
            echo '  </select>
            </p>
            <p style="text-align:right">
                <img id="postsfeed-image" src="'.get_option("home").'/wp-content/plugins/subscribe-plugin/images/posts-feed/'.$sw_postsfeed['image'].'" style="height:50px; border: 1px solid #000000;" />
            </p>
            </fieldset>
            
            <fieldset style="border: 1px solid #000000; margin: 3px; padding:5px;"><legend style="font-weight: bold; font-size: 12px;">Comments Feed</legend>
            <p style="text-align:right">
                <label for="sw-commentsfeed-show">' . __('Show Comments Feed:') . '</label>';
            if( $sw_commentsfeed['show'] == 1 ){
                $commentsfeed_show = ' checked ';
            }
            echo '<input id="sw-commentsfeed-show" name="sw-commentsfeed[show]" type="checkbox" value="1" '.$commentsfeed_show.' />
            </p>
            <p style="text-align:right">
                <label for="sw-commentsfeed-link_target">' . __('Open link in:') . '</label> 
                <select id="sw-commentsfeed-link_target" name="sw-commentsfeed[link_target]" ';
            if( $link_targets ){
                foreach( $link_targets as $target=>$name ){
                    if( $sw_commentsfeed['link_target'] == $name ){
                        echo '<option value="'.$target.'" selected>'.$name.'</option>';
                    }
                    else {
                        echo '<option value="'.$target.'">'.$name.'</option>';
                    }
                }
            }
            echo '  </select>
            </p>
            <p style="text-align:right">
                <label for="sw-commentsfeed-image">' . __('Comments Feed Image:') . '</label> 
                <select id="sw-commentsfeed-image" name="sw-commentsfeed[image]"
                    onchange="document.getElementById(\'commentsfeed-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/comments-feed/\'+document.getElementById(\'sw-commentsfeed-image\').options[selectedIndex].value;"
                    onkeydown="document.getElementById(\'commentsfeed-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/comments-feed/\'+document.getElementById(\'sw-commentsfeed-image\').options[selectedIndex].value;"
                    onkeyup="document.getElementById(\'commentsfeed-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/comments-feed/\'+document.getElementById(\'sw-commentsfeed-image\').options[selectedIndex].value;" >
                    <option value="">-</option>';
            if( $commentsfeedimages ){
                foreach( $commentsfeedimages as $image ){
                    if( $sw_commentsfeed['image'] == $image ){
                        echo '<option value="'.$image.'" selected>'.$image.'</option>';
                    }
                    else {
                        echo '<option value="'.$image.'">'.$image.'</option>';
                    }
                }
            }
            echo '  </select>
            </p>
            <p style="text-align:right">
                <img id="commentsfeed-image" src="'.get_option("home").'/wp-content/plugins/subscribe-plugin/images/comments-feed/'.$sw_commentsfeed['image'].'" style="height:50px; border: 1px solid #000000;" />
            </p>
            </fieldset>
        
            <fieldset style="border: 1px solid #000000; margin: 3px; padding:5px;"><legend style="font-weight: bold; font-size: 12px;">Twitter</legend>
            <p style="text-align:right">
                <label for="sw-twitter-show">' . __('Show Twitter:') . '</label>';
            if( $sw_twitter['show'] == 1 ){
                $twitter_show = ' checked ';
            }
            echo '<input id="sw-twitter-show" name="sw-twitter[show]" type="checkbox" value="1" '.$twitter_show.' />
            </p>
            <p style="text-align:right">
                <label for="sw-twitter-link_target">' . __('Open link in:') . '</label> 
                <select id="sw-twitter-link_target" name="sw-twitter[link_target]" ';
            if( $link_targets ){
                foreach( $link_targets as $target=>$name ){
                    if( $sw_twitter['link_target'] == $name ){
                        echo '<option value="'.$target.'" selected>'.$name.'</option>';
                    }
                    else {
                        echo '<option value="'.$target.'">'.$name.'</option>';
                    }
                }
            }
            echo '  </select>
            </p>
            <p style="text-align:right">
                <label for="sw-twitter-acount">' . __('Twitter Acount Name(Required):') . '</label> 
                <input id="sw-twitter-acount" name="sw-twitter[acount]" type="text" value="'.$sw_twitter['acount'].'" />
            </p>
            <p style="text-align:right">';
            echo '<label for="sw-twitter-image">' . __('Twitter Image:') . '</label> 
                <select id="sw-twitter-image" name="sw-twitter[image]" style="width: 100px;" 
                onchange="document.getElementById(\'twitter-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/twitter/\'+document.getElementById(\'sw-twitter-image\').options[selectedIndex].value;"
                onkeydown="document.getElementById(\'twitter-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/twitter/\'+document.getElementById(\'sw-twitter-image\').options[selectedIndex].value;"
                onkeyup="document.getElementById(\'twitter-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/twitter/\'+document.getElementById(\'sw-twitter-image\').options[selectedIndex].value;" >
                    <option value="">-</option>';
            if( $twitterimages ){
                foreach( $twitterimages as $image ){
                    if( $sw_twitter['image'] == $image ){
                        echo '<option value="'.$image.'" selected>'.$image.'</option>';
                    }
                    else {
                        echo '<option value="'.$image.'">'.$image.'</option>';
                    }
                }
            }
            echo '  </select>
            </p>
            <p style="text-align:right">
                <img id="twitter-image" src="'.get_option("home").'/wp-content/plugins/subscribe-plugin/images/twitter/'.$sw_twitter['image'].'" style="height:50px; border: 1px solid #000000;" />
            </p>
            </fieldset>
            
            <fieldset style="border: 1px solid #000000; margin: 3px; padding:5px;"><legend style="font-weight: bold; font-size: 12px;">FeedBurner</legend>
            <p style="text-align:right">
                <label for="sw-feedburner-show">' . __('Show FeedBurner:') . '</label>';
            if( $sw_feedburner['show'] == 1 ){
                $feedburner_show = ' checked ';
            }
            echo '<input id="sw-feedburner-show" name="sw-feedburner[show]" type="checkbox" value="1" '.$feedburner_show.' />
            </p>
            </p>
            <p style="text-align:right">
                <label for="sw-feedburner-link_target">' . __('Open link in:') . '</label> 
                <select id="sw-feedburner-link_target" name="sw-feedburner[link_target]" ';
            if( $link_targets ){
                foreach( $link_targets as $target=>$name ){
                    if( $sw_feedburner['link_target'] == $name ){
                        echo '<option value="'.$target.'" selected>'.$name.'</option>';
                    }
                    else {
                        echo '<option value="'.$target.'">'.$name.'</option>';
                    }
                }
            }
            echo '  </select>
            </p>
            <p style="text-align:right">
                <label for="sw-feedburner-acount">' . __('FeedBurner Acount Name(Required):') . '</label> 
                <input id="sw-feedburner-acount" name="sw-feedburner[acount]" type="text" value="'.$sw_feedburner['acount'].'" />
            </p>
            <p style="text-align:right">
                <label for="sw-feedburner-image">' . __('FeedBurner Image:') . '</label> 
                <select id="sw-feedburner-image" name="sw-feedburner[image]"
                    onchange="document.getElementById(\'feedburner-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/feedburner/\'+document.getElementById(\'sw-feedburner-image\').options[selectedIndex].value;"
                    onkeydown="document.getElementById(\'feedburner-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/feedburner/\'+document.getElementById(\'sw-feedburner-image\').options[selectedIndex].value;"
                    onkeyup="document.getElementById(\'feedburner-image\').src=\''.get_option("home").'/wp-content/plugins/subscribe-plugin/images/feedburner/\'+document.getElementById(\'sw-feedburner-image\').options[selectedIndex].value;" >
                    <option value="">-</option>';
            if( $feedburnerimages ){
                foreach( $feedburnerimages as $image ){
                    if( $sw_feedburner['image'] == $image ){
                        echo '<option value="'.$image.'" selected>'.$image.'</option>';
                    }
                    else {
                        echo '<option value="'.$image.'">'.$image.'</option>';
                    }
                }
            }
            echo '  </select>
            </p>
            <p style="text-align:right">
                <img id="feedburner-image" src="'.get_option("home").'/wp-content/plugins/subscribe-plugin/images/feedburner/'.$sw_feedburner['image'].'" style="height:50px; border: 1px solid #000000;" />
            </p>
            </fieldset>
            <p>If you have any suggestions about this plugin or it not works like it should, write to <a href="mailto:kestas.mindziulis@gmail.com">me</a></p>
            ';
    
            echo '<input type="hidden" id="sw-submit" name="sw-submit" value="1" />';
        }
        else {
            echo '<p>';
            echo 'Plugin couldn\'t create directory on the server.  Please add to this folder `'.ABSPATH.'` permissions 0777 and reinstall plugin, or create inside this folder directory "subscribe-widget" and add permissions 0777. This is important for the plugin. When folder will be created you can change back permissions on the root folder ';
        }
    }
}
/* Functions resize image by width and height. */
function sw_resizeImage( $resize, $image, $image_height, $image_width ){
    if( is_file( $image ) && function_exists(gd_info) ){
        list( $width, $height ) = getimagesize( $image );
        if($width > $image_width){
            $thumb= $resize->Resize($image );
            $resize->size_width($image_width);    
            $resize->save( $image );       
        }
        list( $width, $height ) = getimagesize( $image );
        if($height > $image_height ){
            $thumb= $resize->Resize( $image ); 
            $resize->size_height( $image_height );   
            $resize->save( $image );       
        }
    }
}
/* Functions gets files extension from files name */
function sw_getExtension( $fileName ){
    $extension = array_reverse(explode( ".", $fileName));
    $extension = $extension[0];
    return $extension;
}

add_action("wp_head","sw_wpHead");
function sw_wpHead(){
    $head = '';
    $options = get_option('subscribe_widget');
    if( isset( $options['sw-align'] ) ){
        if( !empty( $options['sw-align'] ) ){
            $head .= '<style type="text/css" >';
            $head .= '#subscribe-widget-div { text-align: '.$options['sw-align'].'; }';
            $head .= '</style>';
        }
    }
    echo $head;
}

/* Resize class - start */
class ResizeComponent
{
    var $img;

    function Resize($imgfile)
    {
        //detect image format
        $this->img["format"]=ereg_replace(".*\.(.*)$","\\1",$imgfile);
        $this->img["format"]=strtoupper($this->img["format"]);
        if ($this->img["format"]=="JPG" || $this->img["format"]=="JPEG") {
            //JPEG
            $this->img["format"]="JPEG";
            $this->img["src"] = ImageCreateFromJPEG ($imgfile);
        } elseif ($this->img["format"]=="PNG") {
            //PNG
            $this->img["format"]="PNG";
            $this->img["src"] = ImageCreateFromPNG ($imgfile);
        } elseif ($this->img["format"]=="GIF") {
            //GIF
            $this->img["format"]="GIF";
            $this->img["src"] = ImageCreateFromGIF ($imgfile);
        } elseif ($this->img["format"]=="WBMP") {
            //WBMP
            $this->img["format"]="WBMP";
            $this->img["src"] = ImageCreateFromWBMP ($imgfile);
        } else {
            //DEFAULT
            exit();
        }
        @$this->img["width"] = imagesx($this->img["src"]);
        @$this->img["height"] = imagesy($this->img["src"]);
        //default quality jpeg
        $this->img["quality"]=100;
    }

    function size_height($size=100)
    {
        //height
        $this->img["height_thumb"]=$size;
        @$this->img["width_thumb"] = ($this->img["height_thumb"]/$this->img["height"])*$this->img["width"];
    }

    function size_width($size=100)
    {
        //width
        $this->img["width_thumb"]=$size;
        @$this->img["height_thumb"] = ($this->img["width_thumb"]/$this->img["width"])*$this->img["height"];
    }

    function size_auto($size=100)
    {
        //size
        if ($this->img["width"]>=$this->img["height"]) {
            $this->img["width_thumb"]=$size;
            @$this->img["height_thumb"] = ($this->img["width_thumb"]/$this->img["width"])*$this->img["height"];
        } else {
            $this->img["height_thumb"]=$size;
            @$this->img["width_thumb"] = ($this->img["height_thumb"]/$this->img["height"])*$this->img["width"];
        }
    }

    function jpeg_quality($quality=75)
    {
        //jpeg quality
        $this->img["quality"]=$quality;
    }

    function show()
    {
        //show thumb
        @Header("Content-Type: image/".$this->img["format"]);

        /* change ImageCreateTrueColor to ImageCreate if your GD not supported ImageCreateTrueColor function*/
        $this->img["des"] = ImageCreateTrueColor($this->img["width_thumb"],$this->img["height_thumb"]);
            @imagecopyresized ($this->img["des"], $this->img["src"], 0, 0, 0, 0, $this->img["width_thumb"], $this->img["height_thumb"], $this->img["width"], $this->img["height"]);

        if ($this->img["format"]=="JPG" || $this->img["format"]=="JPEG") {
            //JPEG
            imageJPEG($this->img["des"],"",$this->img["quality"]);
        } elseif ($this->img["format"]=="PNG") {
            //PNG
            imagePNG($this->img["des"], "10");
        } elseif ($this->img["format"]=="GIF") {
            //GIF
            imageGIF($this->img["des"]);
        } elseif ($this->img["format"]=="WBMP") {
            //WBMP
            imageWBMP($this->img["des"]);
        }
    }

    function save($save="")
    {
        //save thumb
        if (empty($save)) $save=strtolower("./thumb.".$this->img["format"]);
        /* change ImageCreateTrueColor to ImageCreate if your GD not supported ImageCreateTrueColor function*/
        $this->img["des"] = ImageCreateTrueColor($this->img["width_thumb"],$this->img["height_thumb"]);
	
	if($this->img["format"]=="PNG"){
		if(!imagealphablending($this->img["des"],FALSE)){
			return FALSE;
		}
		if(!imagesavealpha($this->img["des"],TRUE)){
			return FALSE;
		}
		if(!imagecopyresampled($this->img["des"],$this->img["src"],0,0,0,0,$this->img["width_thumb"], $this->img["height_thumb"], $this->img["width"], $this->img["height"])){
			return FALSE;
		}
		$background = imagecolorallocate($this->img["des"], 0, 0, 0);
		ImageColorTransparent($this->img["des"], $background); // make the new temp image all transparent
		imagealphablending($this->img["des"], false); // turn off the alpha blending to keep the alpha channel
	}
	else
            @imagecopyresampled ($this->img["des"], $this->img["src"], 0, 0, 0, 0, $this->img["width_thumb"], $this->img["height_thumb"], $this->img["width"], $this->img["height"]);

        if ($this->img["format"]=="JPG" || $this->img["format"]=="JPEG") {
            //JPEG
            imageJPEG($this->img["des"],$save,$this->img["quality"]);
        } elseif ($this->img["format"]=="PNG") {
            //PNG
	   // imagecopy($this->img["src"], $this->img["des"], $this->img["width_thumb"], $this->img["height_thumb"], 0, 0, imagesx($this->img["des"]), imagesy($this->img["des"]) );
            imagePNG($this->img["des"],"$save");
        } elseif ($this->img["format"]=="GIF") {
            //GIF
            imageGIF($this->img["des"],"$save");
        } elseif ($this->img["format"]=="WBMP") {
            //WBMP
            imageWBMP($this->img["des"],"$save");
        }
    }

}
/* Resize class - end */

// Run our code later in case this loads prior to any required plugins.
add_action('widgets_init', array('subscribeWidget','init'));


?>
