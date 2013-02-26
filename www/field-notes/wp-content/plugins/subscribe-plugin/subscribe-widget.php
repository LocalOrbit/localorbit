<?php
/*
Plugin Name: Subscribe widget
Version: 2.0.4
Plugin URI: http://www.itlastnews.com/subscribe-widget-plugin
Description: Adds a subscribe widget to the sidebar. 
Author: Kestas Mindziulis
Author URI: http://www.itlastnews.com
*/


$sw_admin = new subscribe_widget_admin();

register_activation_hook( __FILE__, array( &$sw_admin, 'installPlugin' ) );

function sw_displaySubscribeWidget( $type="post" ){
    $html_content = '';
           
    $sw_admin = new subscribe_widget_admin();
	$options = get_option('subscribe_widget');
    $widgetOptions = $sw_admin->array2Object( $options );
    $title = htmlspecialchars($widgetOptions->sw_title, ENT_QUOTES);
    
    $img_web_path = get_option("home").'/subscribe-widget/';
    $img_dir = ABSPATH.'subscribe-widget/';
    
    if( !function_exists(gd_info) ){
        $image_width = " width: ".$widgetOptions->sw_image_width."px;";
    }
    else { $image_width = ''; }
    
    $sw_postsfeed = $sw_admin->array2Object( $widgetOptions->sw_postsfeed );
    $sw_commentsfeed = $sw_admin->array2Object( $widgetOptions->sw_commentsfeed );
    $sw_twitter = $sw_admin->array2Object( $widgetOptions->sw_twitter );
    $sw_feedburner = $sw_admin->array2Object( $widgetOptions->sw_feedburner );
    $sw_facebook = $sw_admin->array2Object( $widgetOptions->sw_facebook );
    // These lines generate our output.
	if( ($sw_postsfeed->show == 1 || $sw_commentsfeed->show == 1 || $sw_twitter->show == 1 || $sw_feedburner->show == 1) && ($widgetOptions->sw-showontheme != 1 ) ){
        
        
        if( $type != 'post' ) { $html_content .= '<div id="subscribe-widget-theme">'; }
        if( $title != '' ){
            $html_content .= '<h2>' . $title . '<h2>';
        }
        if( $type == 'post' ){ $html_content .= '<p>'; }
        
        if( $sw_postsfeed->show == 1  ){
            $strings = array(
							'title'=>'Subscribe RSS',
							'link'=>get_feed_link(), 
							);
			$html_content .= $sw_admin->getSubscribeElementForView( $sw_postsfeed, 'postsfeed', $img_dir, $img_web_path, $strings );
        }
        if( $sw_commentsfeed->show == 1 ){
            $strings = array(
							'title'=>'Subscribe comments RSS',
							'link'=>get_feed_link('comments_'), 
							);
			$html_content .= $sw_admin->getSubscribeElementForView( $sw_commentsfeed, 'commentsfeed', $img_dir, $img_web_path, $strings );
        }
        if( $sw_twitter->show == 1 && $sw_twitter->acount != '' ){
            $strings = array(
							'title'=>'Follow me on Twitter',
							'link'=>'http://twitter.com/'.$sw_twitter->acount, 
							);
			$html_content .= $sw_admin->getSubscribeElementForView( $sw_twitter, 'twitter', $img_dir, $img_web_path, $strings );
        }
        if( $sw_feedburner->show == 1 && $sw_feedburner->acount != '' ){
            $strings = array(
							'title'=>'Subscribe on FeedBurner',
							'link'=>'http://feedburner.google.com/fb/a/mailverify?uri='.($sw_feedburner->acount).'&amp;loc=en_US', 
							);
			$html_content .= $sw_admin->getSubscribeElementForView( $sw_feedburner, 'feedburner', $img_dir, $img_web_path, $strings );
        }
        if( $sw_facebook->show == 1 && $sw_facebook->acount != '' ){
        	$strings = array(
							'title'=>'Facebook',
							'link'=>$sw_facebook->acount, 
							);
            $html_content .= $sw_admin->getSubscribeElementForView( $sw_facebook, 'facebook', $img_dir, $img_web_path, $strings );
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


add_action("wp_head","sw_wpHead");
function sw_wpHead(){
    $head = '';
    $options = get_option('subscribe_widget');
    if( isset( $options['sw_align'] ) && !is_admin() ){
        if( !empty( $options['sw_align'] ) ){
            $head .= '<style type="text/css" >';
            $head .= '#subscribe-widget-div { text-align: '.$options['sw_align'].'; margin-top:5px; }';
            $head .= '</style>';
        }
    }
    elseif( is_admin() ) {
        $head .= '<style type="text/css" >';
        $head .= '#sw-element-box { border: 1px solid #999999; }';
        $head .= '</style>';
        
	}
    echo $head;
}


add_action("admin_head","sw_adminHead");
function sw_adminHead(){
    $head = '';
    ?>
    <style type="text/css" >
    .sw-element-box { border: 1px solid #999999; padding:3px; margin-bottom:6px; }
    </style>  
    <script type="text/javascript">   
	jQuery(document).ready(function() {
		jQuery(".sw-element-box").css({display: "none"}); // Opera Fix
		
	});	
	function sw_expand( clicker, box ){
		jQuery( clicker ).parent().html( '<a href="#" class="show-element-box" onclick="sw_shrink( this, \''+box+'\' ); return false;">[-]</a>' );
		jQuery( box ).css({display: "block"});
	}
	function sw_shrink( clicker, box ){
		jQuery( clicker ).parent().html( '<a href="#" class="show-element-box" onclick="sw_expand( this, \''+box+'\' ); return false;">[+]</a>' );
		jQuery( box ).css({display: "none"});
	}
	
	
	function sw_changeImg( clicker, box, img_path ){
		var image = '';
		image = jQuery( clicker ).val();
		img_src = '<?php echo get_option( 'siteurl' ); ?>/wp-content/plugins/subscribe-plugin/images/'+img_path+'/'+image;
		jQuery( box ).attr( "src", img_src );
	}
    </script>
    <?php
}

function sw_loadSubscribeWidget() {
	register_widget('sw_SubscribeWidget');
}
add_action('widgets_init', 'sw_loadSubscribeWidget');

class sw_SubscribeWidget extends WP_Widget {
	var $sw_admin;
	function sw_SubscribeWidget() {
		$this->sw_admin = new subscribe_widget_admin();
		@mkdir( $this->sw_admin->img_dir );
		
		$options = get_option('subscribe_widget');
		/* assign older values to new structure */
		if( count( $options ) > 0 ){ 
			if( isset( $options['sw-title'] ) ){ $options['sw_title'] = $options['sw-title']; }
            if( isset( $options['sw-image-height'] ) ){ $options['sw_image_height'] = $options['sw-image-height']; }
            if( isset( $options['sw-image-width'] ) ){ $options['sw_image_width'] = $options['sw-image-width']; }
            if( isset( $options['sw-postsfeed'] ) ){ $options['sw_postsfeed'] = $options['sw-postsfeed']; }
            if( isset( $options['sw-commentsfeed'] ) ){ $options['sw_commentsfeed'] = $options['sw-commentsfeed']; }
            if( isset( $options['sw-twitter'] ) ){ $options['sw_twitter'] = $options['sw-twitter']; }
            if( isset( $options['sw-feedburner'] ) ){ $options['sw_feedburner'] = $options['sw-feedburner']; }
            if( isset( $options['sw-align'] ) ){ $options['sw_align'] = $options['sw-align']; }
            if( isset( $options['sw-showontheme'] ) ){ $options['sw_showontheme'] = $options['sw-showontheme']; }
		}
		
		// widget actual processes
		$widget_ops = array( 'classname' => '', 
		                     'description' => __('Shows subscribe icons on a sidebar.', 'sw_subscribe_widget') );
		$this->WP_Widget('sw-subscribe-widget', __('Subscribe Widget', 'sw_subscribe_widget'), $widget_ops );
	}

	function form($instance) {
		$widgetOptions = (object)array();
		$widget_content = '';
		
		if( isset( $_POST['sw_submit'] ) && $_POST['sw_submit'] == 1 ){
			/*echo '<pre>';
			print_r( $_POST );
			echo '</pre>'; */
			$options = array();
			$options['sw_title'] = strip_tags(stripslashes($_POST['sw_title']));
            $options['sw_image_height'] = strip_tags(stripslashes($_POST['sw_image_height']));
            $options['sw_image_width'] = strip_tags(stripslashes($_POST['sw_image_width']));
            $options['sw_align'] = $_POST['sw_align'];
            $options['sw_showontheme'] = $_POST['sw_showontheme'];
            
            $options['sw_postsfeed'] = $_POST['sw_postsfeed'];
            $options['sw_commentsfeed'] = $_POST['sw_commentsfeed'];
            $_POST['sw_twitter']['acount'] = htmlentities($_POST['sw_twitter']['acount']);
            $options['sw_twitter'] = $_POST['sw_twitter'];
            $_POST['sw_feedburner']['acount'] = htmlentities($_POST['sw_feedburner']['acount']);
            $options['sw_feedburner'] = $_POST['sw_feedburner'];
            
            $_POST['sw_facebook']['acount'] = htmlentities($_POST['sw_facebook']['acount']);
            $options['sw_facebook'] = $_POST['sw_facebook'];
            
            $resize = new sw_ResizeComponent();
            $all_images_dir = ABSPATH.'wp-content/plugins/subscribe-plugin/images/';
            if( !is_dir( ABSPATH.'subscribe-widget/' ) ){
                mkdir( ABSPATH.'subscribe-widget/', 0777 );
            }
            else { @chmod( ABSPATH.'subscribe-widget/', 0777 ); }
            if( is_dir( ABSPATH.'subscribe-widget/' ) ){
                if( is_file( $all_images_dir.'posts-feed/'.$_POST['sw_postsfeed']['image'] ) ){
					$this->sw_admin->resizeElementImage( $all_images_dir.'posts-feed/', 'postsfeed', $_POST['sw_postsfeed'], $options['sw_image_height'], $options['sw_image_width'] );
                }
                if( is_file( $all_images_dir.'comments-feed/'.$_POST['sw_commentsfeed']['image'] ) ){
                	$this->sw_admin->resizeElementImage( $all_images_dir.'comments-feed/', 'commentsfeed', $_POST['sw_commentsfeed'], $options['sw_image_height'], $options['sw_image_width'] );
                }
                if( is_file( $all_images_dir.'twitter/'.$_POST['sw_twitter']['image'] ) ){
					$this->sw_admin->resizeElementImage( $all_images_dir.'twitter/', 'twitter', $_POST['sw_twitter'], $options['sw_image_height'], $options['sw_image_width'] );
                }
                if( is_file( $all_images_dir.'feedburner/'.$_POST['sw_feedburner']['image'] ) ){
                    $this->sw_admin->resizeElementImage( $all_images_dir.'feedburner/', 'feedburner', $_POST['sw_feedburner'], $options['sw_image_height'], $options['sw_image_width'] );
                }
                if( is_file( $all_images_dir.'facebook/'.$_POST['sw_facebook']['image'] ) ){
                    $this->sw_admin->resizeElementImage( $all_images_dir.'facebook/', 'facebook', $_POST['sw_facebook'], $options['sw_image_height'], $options['sw_image_width'] );
                }
                @chmod( ABSPATH.'subscribe-widget/', 0755 );
            }
            update_option('subscribe_widget', $options);
		}
		
		$options = get_option('subscribe_widget');
		if ( !is_array( $options ) ) {
			$options = array(
								'sw_title'=>'',
						        'sw_postsfeed'=>array(),
						        'sw_commentsfeed'=>array(),
						        'sw_twitter'=>array(),
						        'sw_feedburner'=>array(),
						        'sw_facebook'=>array(),
						        'sw_image_height'=>'',
						        'sw_image_width'=>'',
						        'sw_align'=>'',
						        'sw_showonposts'=>'',
						         );
		}
		$widgetOptions = $this->sw_admin->array2Object( $options );
		//print_r( $widgetOptions );
		if( $widgetOptions->sw_title != '' ){
			$widgetOptions->sw_title = htmlspecialchars( $widgetOptions->sw_title , ENT_QUOTES);
		}
		
		if( is_dir( $this->sw_admin->img_dir ) ){
			$widget_content = $this->sw_admin->getStandartOptions( $widgetOptions );
			$widget_content .= '<script type="text/javascript">	
				jQuery(".sw-element-box").css({display: "none"});	
			</script>';
			$widget_content .= '<h3>Widget Content:</h3>';
			
			/* posts feed settings */
			$elementTexts = array(
				  					'show_element'=>'Show Posts Feed: ',
				  					'open_link_in'=>'Open link in: ',
				  					'element_image'=>'Posts Feed Image: ',
									);
			$elementTexts = $this->sw_admin->array2Object( $elementTexts );
			$elementOptions = $this->sw_admin->array2Object( $widgetOptions->sw_postsfeed );
			$feedimages = $this->sw_admin->getElementImages( 'posts-feed' );
			$widget_content .= '<h4 style="margin-bottom:0px; margin-top: 3px;">
									Posts Feed
									<span> 
									<a href="#" class="show-element-box" onclick="sw_expand( this, \'.sw_postsfeed\' ); return false;">[+]</a>
									</span>
								</h4>';
			$widget_content .= $this->sw_admin->getSubscribeElementOptions( $elementOptions, $elementTexts, $feedimages, 'sw_postsfeed', 'posts-feed' );
			
			/* comments feed settings */
			$elementTexts = array(
				  					'show_element'=>'Show Comments Feed: ',
				  					'open_link_in'=>'Open link in: ',
				  					'element_image'=>'Comments Feed Image: ',
									);
			$elementTexts = $this->sw_admin->array2Object( $elementTexts );
			$elementOptions = $this->sw_admin->array2Object( $widgetOptions->sw_commentsfeed );
			$feedimages = $this->sw_admin->getElementImages( 'comments-feed' );
			$widget_content .= '<h4 style="margin-bottom:0px; margin-top: 3px;">
									Comments Feed
									<span> 
									<a href="#" class="show-element-box" onclick="sw_expand( this, \'.sw_commentsfeed\' ); return false;">[+]</a>
									</span>
								</h4>';
			$widget_content .= $this->sw_admin->getSubscribeElementOptions( $elementOptions, $elementTexts, $feedimages, 'sw_commentsfeed', 'comments-feed' );
			
			/* Twitter settings */
			$elementTexts = array(
				  					'show_element'=>'Show Twitter: ',
				  					'open_link_in'=>'Open link in: ',
				  					'acount_name'=>'Twitter Acount Name(Required): ',
				  					'element_image'=>'Twitter Image: ',
									);
			$elementTexts = $this->sw_admin->array2Object( $elementTexts );
			$elementOptions = $this->sw_admin->array2Object( $widgetOptions->sw_twitter );
			$feedimages = $this->sw_admin->getElementImages( 'twitter' );
			$widget_content .= '<h4 style="margin-bottom:0px; margin-top: 3px;">
									Twitter
									<span> 
									<a href="#" class="show-element-box" onclick="sw_expand( this, \'.sw_twitter\' ); return false;">[+]</a>
									</span>
								</h4>';
			$widget_content .= $this->sw_admin->getSubscribeElementOptions( $elementOptions, $elementTexts, $feedimages, 'sw_twitter', 'twitter' );
			
			/* FeedBurner settings */
			$elementTexts = array(
				  					'show_element'=>'Show FeedBurner: ',
				  					'open_link_in'=>'Open link in: ',
				  					'acount_name'=>'FeedBurner Acount Name(Required): ',
				  					'element_image'=>'FeedBurner Image: ',
									);
			$elementTexts = $this->sw_admin->array2Object( $elementTexts );
			$elementOptions = $this->sw_admin->array2Object( $widgetOptions->sw_feedburner );
			$feedimages = $this->sw_admin->getElementImages( 'feedburner' );
			$widget_content .= '<h4 style="margin-bottom:0px; margin-top: 3px;">
									FeedBurner
									<span> 
									<a href="#" class="show-element-box" onclick="sw_expand( this, \'.sw_feedburner\' ); return false;">[+]</a>
									</span>
								</h4>';
			$widget_content .= $this->sw_admin->getSubscribeElementOptions( $elementOptions, $elementTexts, $feedimages, 'sw_feedburner', 'feedburner' );
			
			/* FeedBurner settings */
			$elementTexts = array(
				  					'show_element'=>'Show Facebook: ',
				  					'open_link_in'=>'Open link in: ',
				  					'acount_name'=>'Facebook profile link: ',
				  					'element_image'=>'Facebook Image: ',
									);
			$elementTexts = $this->sw_admin->array2Object( $elementTexts );
			$elementOptions = $this->sw_admin->array2Object( $widgetOptions->sw_facebook );
			$feedimages = $this->sw_admin->getElementImages( 'facebook' );
			$widget_content .= '<h4 style="margin-bottom:0px; margin-top: 3px;">
									Facebook
									<span> 
									<a href="#" class="show-element-box" onclick="sw_expand( this, \'.sw_facebook\' ); return false;">[+]</a>
									</span>
								</h4>';
			$widget_content .= $this->sw_admin->getSubscribeElementOptions( $elementOptions, $elementTexts, $feedimages, 'sw_facebook', 'facebook' );
			
			$widget_content .= $this->sw_admin->getWidgetFormFooter();
		}
		else {
        	$widget_content .= '<p>';
        	$widget_content .= 'Plugin couldn\'t create directory on the server.  Please add to this folder `'.ABSPATH.'` permissions 0777 and reinstall plugin, or create inside this folder directory "subscribe-widget" and add permissions 0777. This is important for the plugin. When folder will be created you can change back permissions on the root folder "'.ABSPATH.'"';
        	$widget_content .= '</p>';
        }
        echo $widget_content;
	}

	function update($new_instance, $old_instance) {
		// processes widget options to be saved
	}

	function widget($args, $instance) {
		global $wpdb, $table_prefix, $post;
		
		extract($args);
    
        $options = get_option('subscribe_widget');
        $widgetOptions = $this->sw_admin->array2Object( $options );
        $title = htmlspecialchars($widgetOptions->sw_title, ENT_QUOTES);
        
        $img_web_path = get_option("home").'/subscribe-widget/';
        $img_dir = ABSPATH.'subscribe-widget/';
        
        if( !function_exists(gd_info) ){
            $image_width = " width: ".$widgetOptions->sw_image_width."px;";
        }
        else { $image_width = ''; }
        
        $sw_postsfeed = $this->sw_admin->array2Object( $widgetOptions->sw_postsfeed );
        $sw_commentsfeed = $this->sw_admin->array2Object( $widgetOptions->sw_commentsfeed );
        $sw_twitter = $this->sw_admin->array2Object( $widgetOptions->sw_twitter );
        $sw_feedburner = $this->sw_admin->array2Object( $widgetOptions->sw_feedburner );
        $sw_facebook = $this->sw_admin->array2Object( $widgetOptions->sw_facebook );
        // These lines generate our output.
		if( ($sw_postsfeed->show == 1 || $sw_commentsfeed->show == 1 || $sw_twitter->show == 1 || $sw_feedburner->show == 1) && ($widgetOptions->sw-showontheme != 1 ) ){
            echo $before_widget;
			
			if( $title != '' ){
                echo $before_title . $title . $after_title;
            }
            echo '<div id="subscribe-widget-div">';
            if( $sw_postsfeed->show == 1  ){
                $strings = array(
								'title'=>'Subscribe RSS',
								'link'=>get_feed_link(), 
								);
				echo $this->sw_admin->getSubscribeElementForView( $sw_postsfeed, 'postsfeed', $img_dir, $img_web_path, $strings );
            }
            if( $sw_commentsfeed->show == 1 ){
                $strings = array(
								'title'=>'Subscribe comments RSS',
								'link'=>get_feed_link('comments_'), 
								);
				echo $this->sw_admin->getSubscribeElementForView( $sw_commentsfeed, 'commentsfeed', $img_dir, $img_web_path, $strings );
            }
            if( $sw_twitter->show == 1 && $sw_twitter->acount != '' ){
                $strings = array(
								'title'=>'Follow me on Twitter',
								'link'=>'http://twitter.com/'.$sw_twitter->acount, 
								);
				echo $this->sw_admin->getSubscribeElementForView( $sw_twitter, 'twitter', $img_dir, $img_web_path, $strings );
            }
            if( $sw_feedburner->show == 1 && $sw_feedburner->acount != '' ){
                $strings = array(
								'title'=>'Subscribe on FeedBurner',
								'link'=>'http://feedburner.google.com/fb/a/mailverify?uri='.($sw_feedburner->acount).'&amp;loc=en_US', 
								);
				echo $this->sw_admin->getSubscribeElementForView( $sw_feedburner, 'feedburner', $img_dir, $img_web_path, $strings );
            }
            if( $sw_facebook->show == 1 && $sw_facebook->acount != '' ){
            	$strings = array(
								'title'=>'Facebook',
								'link'=>$sw_facebook->acount, 
								);
                echo $this->sw_admin->getSubscribeElementForView( $sw_facebook, 'facebook', $img_dir, $img_web_path, $strings );
            }
            echo '</div>';
            echo $after_widget;
		}
		
		
	}

}

/* class is used to handle plugin install and all widget actions */
class subscribe_widget_admin {
	var $img_dir;
	var $aligns;
	var $link_targets;
	var $plugin_dir;
	var $resize;
	
	function subscribe_widget_admin(){
		$this->__construct();
	}
	
	function __construct(){
		global $wpdb, $table_prefix;
		
		$this->wpdb = $wpdb;
		$this->table_prefix = $table_prefix;
		$this->img_dir = ABSPATH.'subscribe-widget/';
		$this->plugin_dir = 'wp-content/plugins/subscribe-plugin/';
		$this->aligns = array("left", "center", "right");
		$this->link_targets = array(""=>"In the same window", "_blank"=>"In new window", );
		$this->resize = new sw_ResizeComponent();
	}
	
	function resizeElementImage( $img_dir_from, $img_name, $elementData, $image_height, $image_width ){
		if( is_file( $img_dir_from.$elementData['image'] ) ){
            $image_ext = $this->getExtension( $elementData['image'] );
            copy( $img_dir_from.$elementData['image'], $this->img_dir.$img_name.'.'.$image_ext ) ;
            $image = $this->img_dir.$img_name.'.'.$image_ext;
            $this->resizeImage( $image, $image_height, $image_width );
        }
	}
	
	/* Functions resize image by width and height. */
	function resizeImage( $image, $image_height, $image_width ){
	    if( is_file( $image ) && function_exists(gd_info) ){
	        list( $width, $height ) = getimagesize( $image );
	        if($width > $image_width){
	            $thumb= $this->resize->Resize($image );
	            $this->resize->size_width($image_width);    
	            $this->resize->save( $image );       
	        }
	        list( $width, $height ) = getimagesize( $image );
	        if($height > $image_height ){
	            $thumb= $this->resize->Resize( $image ); 
	            $this->resize->size_height( $image_height );   
	            $this->resize->save( $image );       
	        }
	    }
	}
	
	/* Functions gets files extension from files name */
	function getExtension( $fileName ){
	    $extension = array_reverse(explode( ".", $fileName));
	    $extension = $extension[0];
	    return $extension;
	}
	
	function getElementImages( $element_dir ){
		$images_temp = array();
        $images = array();
        if( is_dir( ABSPATH . $this->plugin_dir . 'images/'.$element_dir.'/' ) ){
            sw_ReadDirectory( ABSPATH . $this->plugin_dir . 'images/'.$element_dir.'/', $images_temp );
            sw_GetFilesFromPath( $images_temp, $images );
        }
        return $images;
	}
	
	function getSubscribeElementForView( $element, $img_name, $img_dir, $img_web_path, $strings ){
		$html = '';
		$image_ext = $this->getExtension( $element->image );
        if( @is_file( $img_dir.$img_name.'.'.$image_ext ) ){
            if( $element->link_target != '' ){ $target = ' target="'.$element->link_target.'" '; }
            else { $target = ""; }
            $img_size = @getimagesize( $img_dir.$img_name.'.'.$image_ext );
            if( is_array( $img_size ) ){ $img_size = $img_size[3]; }
            else { $img_size = ''; }
            $html .= '<a title="'.$strings['link_title'].'" '.$target.' rel="nofallow" href="'.$strings['link'].'">';
            $html .= '<img '.$img_size.' src="'.$img_web_path.$img_name.'.'.$image_ext.'" border="0" style="margin-right:5px;margin-left:5px;" alt="'.$strings['link_title'].'" />';
            $html .= '</a>';
        }
        
        return $html;
	}
	
	function getSubscribeElementOptions( $elementOptions, $elementTexts, $elementImages, $element_name, $element_dir ){
		$html_content = '';

		$html_content .= '<div id="'.$element_name.'_box" class="sw-element-box '.$element_name.'">';
		$html_content .= '<p style="text-align:right">
                				<label>' . __($elementTexts->show_element) . '</label>';
        if( $elementOptions->show == 1 ){ $checked = ' checked '; }
        else { $checked = ''; }
        $html_content .= '<input '.$checked.' name="'.$element_name.'[show]" type="checkbox" value="1" />';
        $html_content .= '</p>';
        
        if( $elementTexts->acount_name != '' ){
        	$html_content .= '<p style="text-align:right">
                <label>' . __($elementTexts->acount_name) . '</label> 
                <input name="'.$element_name.'[acount]" type="text" value="'.$elementOptions->acount.'" />
            </p>';
		}
        
        $html_content .= '<p style="text-align:right">
            					<label>' . __($elementTexts->open_link_in) . '</label> 
            					<select name="'.$element_name.'[link_target]" ';
        if( $this->link_targets ){
            foreach( $this->link_targets as $target=>$name ){
                if( $elementOptions->link_target == $name ){ $selected = ' selected '; }
                else { $selected = ''; }
                $html_content .= '<option value="'.$target.'" '.$selected.'>'.$name.'</option>';
            }
        }
        $html_content .= '</select></p>';
        
        $html_content .= '<p style="text-align:right">
					            <label>' . __($elementTexts->element_image) . '</label> 
					            <select name="'.$element_name.'[image]" onchange="sw_changeImg( this, \'.'.$element_name.'_img\', \''.$element_dir.'\' )" onkeydown="sw_changeImg( this, \'.'.$element_name.'_img\', \''.$element_dir.'\' )" onkeyup="sw_changeImg( this, \'.'.$element_name.'_img\', \''.$element_dir.'\' )" >
                <option value="">-</option>';
        if( count( $elementImages ) > 0 ){
            foreach( $elementImages as $image ){
                if( $elementOptions->image == $image ){ $selected = ' selected '; }
                else { $selected = ''; }
                $html_content .= '<option value="'.$image.'" '.$selected.'>'.$image.'</option>';
            }
        }
        $html_content .= '</select></p>';
        $html_content .= '<p style="text-align:right">
					            <img id="'.$element_name.'-image" class="'.$element_name.'_img" src="'.get_option("home").'/wp-content/plugins/subscribe-plugin/images/'.$element_dir.'/'.$elementOptions->image.'" style="height:50px; border: 1px solid #999999;" />
					        </p>';
		$html_content .= '</div>';
		return $html_content;
	}
	
	function getStandartOptions( $widgetOptions ){
		$html_content = '';
		$html_content .= '<p style="text-align:right">
								<label for="sw-title">' . __('Title (Optional):') . '</label> 
								<input style="width: 200px" id="sw-title" name="sw_title" type="text" value="'.$widgetOptions->sw_title.'" />
							</p>';
        
        if( $widgetOptions->sw_showontheme == 1 ){ $checked = ' checked '; }
        else { $checked = ''; }
        $html_content .= '<p style="text-align:right">
								<label for="sw-showontheme">' . __('Show "Subscribe Icons" on the theme*:') . '</label> 
								<input id="sw-showontheme" '.$checked.' name="sw_showontheme" type="checkbox" value="1" />
								<small>* icons will be shown only on theme, where php code was inserted. For more details look at the readme file in subscribe-plugin folder</small>
							</p>';
        
        $html_content .= '<p style="text-align:right">
								<label for="sw-align">' . __('Align images:') . '</label>
        						<select id="sw-align" name="sw_align">';
        foreach( $this->aligns as $align ){
            if( $align == $widgetOptions->sw_align ){ $selected = ' selected '; }
            else{ $selected = ''; }
            $html_content .= '<option value="'.$align.'" '.$selected.'>'.$align.'</option>';
        }
        $html_content .= '</select></p>';
        
        $html_content .= '<p style="text-align:right">
								<label for="sw-image-height">' . __('Images height *:') . '</label> 
        						<select id="sw-image-height" name="sw_image_height">';
        for( $i=20; $i<101; $i=$i+5 ){
            if( $i == $widgetOptions->sw_image_height ){ $selected = ' selected '; }
            else{ $selected = ''; }
			$html_content .= '<option value="'.$i.'" '.$selected.'>'.$i.'</option>'; 
        }
        $html_content .= '</select></p>';

        $html_content .= '<p style="text-align:right">
								<label for="sw-image-width">' . __('Images width *:') . '</label>
        							<select id="sw-image-width" name="sw_image_width">';
        for( $i=20; $i<101; $i=$i+5 ){
            if( $i == $widgetOptions->sw_image_width ){ $selected = ' selected '; }
            else{ $selected = ''; }
			$html_content .= '<option value="'.$i.'" '.$selected.'>'.$i.'</option>'; 
        }
        $html_content .= '</select><br />
        	<small>* Image will be resized firstly by width and then by height. If image width will be smaller then selected, then image will be not resized. The same is with image height.</small>
        	</p>';
        
        return $html_content;
	}
	
	function  getWidgetFormFooter(){
		$html_content = '';
		$html_content .= '<p style="margin-top: 5px;">If you have any suggestions about this plugin or it not works like it should, write to <a href="mailto:kestas.mindziulis@gmail.com">me</a></p>';
        $html_content .= '<input type="hidden" name="sw_submit" value="1" />';
        return $html_content;
	}
	
	/* function converts array to object */
	function array2Object( $array = array() ){
		$object = (object)array();
		if( count( $array ) > 0 ){
			foreach( $array as $field => $value ){
				$object->$field = $value;
			}
		}
		return $object;
	}
	
	/* functions install plugin and creates folder on the root folder */
	function installPlugin(){
		if( !is_dir( $this->img_dir ) ){
        	mkdir( $this->img_dir, 0777 );
	    }
	    else { chmod( $this->img_dir, 0777 ); }
	}
}


/* Resize class - start */
class sw_ResizeComponent {
    var $img;

    function Resize($imgfile){
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

    function size_height($size=100){
        //height
        $this->img["height_thumb"]=$size;
        @$this->img["width_thumb"] = ($this->img["height_thumb"]/$this->img["height"])*$this->img["width"];
    }

    function size_width($size=100){
        //width
        $this->img["width_thumb"]=$size;
        @$this->img["height_thumb"] = ($this->img["width_thumb"]/$this->img["width"])*$this->img["height"];
    }

    function size_auto($size=100){
        //size
        if ($this->img["width"]>=$this->img["height"]) {
            $this->img["width_thumb"]=$size;
            @$this->img["height_thumb"] = ($this->img["width_thumb"]/$this->img["width"])*$this->img["height"];
        } else {
            $this->img["height_thumb"]=$size;
            @$this->img["width_thumb"] = ($this->img["height_thumb"]/$this->img["height"])*$this->img["width"];
        }
    }

    function jpeg_quality($quality=75){
        //jpeg quality
        $this->img["quality"]=$quality;
    }

    function show(){
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

    function save($save=""){
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


?>
