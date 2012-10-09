<?php
/*
Plugin Name: Smart Youtube
Plugin URI: http://www.prelovac.com/vladimir/wordpress-plugins/smart-youtube
Description: Insert YouTube videos in posts, comments and RSS feeds with ease and full customization.
Author: Vladimir Prelovac
Version: 3.3
Author URI: http://www.prelovac.com/vladimir/

Updates:
3.3 - Supports migrated blogs from Wordpress.com replacing [youtube=youtubeadresss]
3.2 - Added title to widget, fixed HTML code issue with widget
3.1.1 - param closed properly for validation
3.1 - wmode transparent parameter updated to better handle transparancy
3.0 - Added video template, option to set sidebar video size, fixed sidebar widget code, fixed video syntax issue
2.8.1 - Display Annotioans added as option
2.8 - Support for playlists
2.7.5 - Plugin url updated to use WP_PLUGIN_URL
2.7.4 - Added option to remove info&ratings
2.7.3 - Removed annotiations
2.7 - Supports a sidebar widget for videos
2.6 - Added option to remove search button
2.5 - Added DVD quality support (httpvq)
2.4.1 - Small fixes in embed and rss links
2.4 - Added support for extra parameters like &start=50 to start the video at 50th second of play
2.2 - Full xHTML validaiton
2.1 - Made the application iPhone compatible and allowed full screen
2.0 - Support for playback high quality YouTube videos
1.9 - Added video autoplay option
1.8 - Solved Problem with HTML validation, enabled full video preview in RSS
1.6 - Solving a problem with wordpress handling special characters
1.5 - Added new admin interface and more options to control the video

To-Doo: 
- marinas javascript suggestion for hq videos
- add editor button
- The plugin places a preview image in the RSS feed which is great, but it links to the video on http://www.youtube.com. I would like to change it so the image links to the blog post so I can generate some traffic on my blog. 
- localization
- the images appear under the embedded Smart Youtube videos. Is there any way to edit the z-index for Smart Youtube CSS? I
*/

$yte_localversion="2.7.5";

$CustomColors=array (
	"blank" => array("d6d6d6","f0f0f0"),
	"storm" => array("3a3a3a","999999"),
	"iceberg" => array("2b405b","6b8ab6"),
	"acid" => array("006699","54abd6"),
	"green" => array("234900","4e9e00"),
	"orange" => array("e1600f","febd01"),
	"pink" => array("cc2550","e87a9f"),
	"purple" => array("402061","9461ca"),
	"rubyred" => array("5d1719","cd311b")
);
	
$wp_yte_plugin_url = defined('WP_PLUGIN_URL') ? trailingslashit(WP_PLUGIN_URL . '/' . dirname(plugin_basename(__FILE__))) : trailingslashit(get_bloginfo('wpurl')) . PLUGINDIR . '/' . dirname(plugin_basename(__FILE__)); 

              
              
	
 // Admin Panel   
function yte_add_pages()
{
	add_options_page('Smart Youtube options', 'Smart Youtube', 8, __FILE__, 'yte_options_page');            
}

    

// Options Page
function yte_options_page()
{ 
	global $yte_localversion;
	$status=yte_getinfo();
			
	$theVersion = $status[1];
	$theMessage = $status[3];	
	
	
	
			if( (version_compare(strval($theVersion), strval($yte_localversion), '>') == 1) )
			{
				$msg = 'Latest version available '.' <strong>'.$theVersion.'</strong><br />'.$theMessage;	
				  _e('<div id="message" class="updated fade"><p>' . $msg . '</p></div>');			
			
			}
			
			
    // If form was submitted
	if (isset($_POST['submitted'])) 
	{			
		  check_admin_referer('smart-youtube');		  
			$disp_img = !isset($_POST['disp_img'])? 'off': 'on';
			$disp_link = !isset($_POST['disp_link'])? 'off': 'on';
			$disp_search = !isset($_POST['disp_search'])? 'off': 'on';
			$disp_ann = !isset($_POST['disp_ann'])? 'off': 'on';
			$disp_info = !isset($_POST['disp_info'])? 'off': 'on';
			$valid = !isset($_POST['valid'])? 'off': 'on';
			
			update_option('smart_yt_img', $disp_img);
			update_option('smart_yt_link', $disp_link);
			update_option('smart_yt_valid', $valid);
			update_option('smart_yt_search', $disp_search);			
			update_option('smart_yt_ann', $disp_ann);		
			update_option('smart_yt_info', $disp_info);			
			
			$disp_width = (int) ($_POST['disp_width']=="")? '425': $_POST['disp_width'];
			$disp_height = (int) ($_POST['disp_height']=="")? '344': $_POST['disp_height'];
			
			update_option('smart_yt_width', $disp_width);
			update_option('smart_yt_height', $disp_height);
			
			$disp_widthhq = (int) ($_POST['disp_widthhq']=="")? '480': $_POST['disp_widthhq'];
			$disp_heighthq = (int) ($_POST['disp_heighthq']=="")? '360': $_POST['disp_heighthq'];
			
			update_option('smart_yt_widthhq', $disp_widthhq);
			update_option('smart_yt_heighthq', $disp_heighthq);
		
			$disp_widthside = (int) ($_POST['disp_widthside']=="")? '150': $_POST['disp_widthside'];
			$disp_heightside = (int) ($_POST['disp_heightside']=="")? '125': $_POST['disp_heightside'];
			
			update_option('smart_yt_widthside', $disp_widthside);
			update_option('smart_yt_heightside', $disp_heightside);
			
			$disp_rel = !isset($_POST['embedRel'])? '1': $_POST['embedRel'];
			
			$disp_border = !isset($_POST['embedBorder'])? '0': '1';
			$disp_color = !isset($_POST['embedColor'])? 'blank': $_POST['embedColor'];
			
			$disp_autoplay = !isset($_POST['autoplay'])? '0': '1';
			
			
			update_option('smart_yt_rel', $disp_rel);			
			
			update_option('smart_yt_border', $disp_border);
			update_option('smart_yt_color', $disp_color);
			
			update_option('smart_yt_autoplay', $disp_autoplay);
			
			$disp_posts = !isset($_POST['disp_posts'])? 'off': 'on';
			$disp_comments = !isset($_POST['disp_comments'])? 'off': 'on';
		
		
			update_option('smart_yt_posts', $disp_posts);
			update_option('smart_yt_comments', $disp_comments);
		
			$disp_template = !isset($_POST['disp_template'])? '{video}': stripslashes(htmlspecialchars($_POST['disp_template']));
			update_option('smart_yt_template', $disp_template);
			
						
			
			$msg_status = 'Smart Youtube options saved.';
							
		    // Show message
		   _e('<div id="message" class="updated fade"><p>' . $msg_status . '</p></div>');
		
	} 
	
		// Fetch code from DB
		$disp_img = (get_option('smart_yt_img')=='on') ? 'checked':'';
		$disp_link = (get_option('smart_yt_link')=='on') ? 'checked':'';
		$disp_search = (get_option('smart_yt_search')=='on') ? 'checked':'';
		$disp_ann = (get_option('smart_yt_ann')=='on') ? 'checked':'';
		$disp_info = (get_option('smart_yt_info')=='on') ? 'checked':'';
		
		$valid = (get_option('smart_yt_valid')=='on') ? 'checked':'';
		
		
		$disp_width = get_option('smart_yt_width');
		$disp_height = get_option('smart_yt_height');
		
		$disp_widthhq = get_option('smart_yt_widthhq');
		$disp_heighthq = get_option('smart_yt_heighthq');
		
		$disp_widthside = get_option('smart_yt_widthside');
		$disp_heightside = get_option('smart_yt_heightside');
		
		$disp_autoplay = (get_option('smart_yt_autoplay')=='1') ? 'checked':'';
		
		
		$disp_rel = (get_option('smart_yt_rel')=='1') ? 'checked':'';
		
		$disp_rel2=$disp_rel ? "" : "checked";
		$disp_border = (get_option('smart_yt_border')=='1') ? 'checked':'';
		$disp_color = get_option('smart_yt_color');
		
		
		$disp_posts = (get_option('smart_yt_posts')=='on') ? 'checked' :'' ;
		$disp_comments = (get_option('smart_yt_comments')=='on') ? 'checked':'';
	
		$disp_template = wp_specialchars(get_option('smart_yt_template'));
		
		
		if ($disp_width=="")
			$disp_width="425";
		if ($disp_height=="")
			$disp_height="355";			
		
	
	global $wp_version;	
	global $wp_yte_plugin_url;
		$embed_img=$wp_yte_plugin_url.'/img/embed_selection-vfl29294.png';
			
		echo '<script src="' . $wp_yte_plugin_url . '/yt.js" type="text/javascript"></script>' . "\n";
echo '<style type="text/css">		
#watch-embed-div,
#watch-url-div{
border-top:1px solid #CCC;
font-size:11px;
}
#watch-url-div{
margin:5px 0;
}
#watch-url-field{
font-size:10px;
width:340px;
margin-top:2px;
}
#watch-embed-div label,
#watch-url-div label{
color:#999;
line-height:18px;
font-size:12px;
}
#watch-embed-div input{
font-size:10px;
width:339px;
margin-top:2px;
}
#watch-embed-div #watch-embed-customize{
font-weight:normal;
color:#03c;
}
#watch-customize-embed-div{
display:none;
background-color:white;
border-top:1px solid #CCC;
margin-top:5px;
padding:5px;
}
#watch-customize-embed-form{
display:block;
width:210px;
}
#watch-customize-embed-desc{
display:block;
padding:6px;
}
#watch-customize-embed-theme{
display:block;
clear:both;
}
#watch-customize-embed-theme-swatches{
padding:5px;
display:block;
margin-top:5px;
width:310px;
height:80px;
}
#watch-customize-embed-theme-preview{
display:block;
float:right;
margin:4px 140px;
background:transparent url('.$embed_img.') no-repeat scroll 0px -23px;
width:100px;
height:86px;
}
.watch-image-radio-link{
border:0;
display:inline-block;
float:left;
margin:3px;
}
.watch-image-radio-link:hover{
background-color:#ADD8E6;
}
.watch-image-radio-link.radio_selected{
border:1px solid #000;
margin:2px;
}
.watch-image-radio-link img{
border:1px solid #fff;
background-color:#fff;
padding:0px;
margin:4px;
}
.watch-embed-select{
width:46px;
height:23px;
}
.watch-embed-iceberg{
background:transparent url('.$embed_img.') no-repeat scroll 0px 0px;
}
.watch-embed-blank{
background:transparent url('.$embed_img.') no-repeat scroll -46px 0px;
}
.watch-embed-acid{
background:transparent url('.$embed_img.') no-repeat scroll -92px 0px;
}
.watch-embed-storm{
background:transparent url('.$embed_img.') no-repeat scroll -138px 0px;
}
.watch-embed-green{
background:transparent url('.$embed_img.') no-repeat scroll -184px 0px;
}
.watch-embed-orange{
background:transparent url('.$embed_img.') no-repeat scroll -230px 0px;
}
.watch-embed-pink{
background:transparent url('.$embed_img.') no-repeat scroll -276px 0px;
}
.watch-embed-purple{
background:transparent url('.$embed_img.') no-repeat scroll -322px 0px;
}
.watch-embed-rubyred{
background:transparent url('.$embed_img.') no-repeat scroll -368px 0px;
}
div#dbx-content a{
text-decoration:none;
}
</style>
		';
	


    $imgpath=$wp_yte_plugin_url.'/i';	
    $actionurl=$_SERVER['REQUEST_URI'];
    $nonce=wp_create_nonce( 'smart-youtube');
    $example=htmlentities('<div style="float:left;margin-right: 10px;">{video}</div>');
    // Configuration Page
    
  
    
    echo <<<END
<div class="wrap" style="max-width:950px !important;">
	<h2>Smart YouTube</h2>
				
	<div id="poststuff" style="margin-top:10px;">
	
	<div id="sideblock" style="float:right;width:220px;margin-left:10px;"> 
		 <h2>Information</h2>
		 <div id="dbx-content" style="text-decoration:none;">
		  <img src="$imgpath/home.png"><a style="text-decoration:none;" href="http://www.prelovac.com/vladimir/wordpress-plugins/smart-youtube"> Smart Youtube Home</a><br /><br />
			<img src="$imgpath/rate.png"><a style="text-decoration:none;" href="http://wordpress.org/extend/plugins/smart-youtube/"> Rate this plugin</a><br /><br />			 
			<img src="$imgpath/help.png"><a style="text-decoration:none;" href="http://www.prelovac.com/vladimir/forum"> Support and Help</a><br />			 
			<p >
			<a style="text-decoration:none;" href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2567254&lc=US"><img src="$imgpath/paypal.gif"></a>			 
			</p><br />		 
			<img src="$imgpath/more.png"><a style="text-decoration:none;" href="http://www.prelovac.com/vladimir/wordpress-plugins"> Cool WordPress Plugins</a><br /><br />
			<img src="$imgpath/twit.png"><a style="text-decoration:none;" href="http://twitter.com/vprelovac"> Follow updates on Twitter</a><br /><br />			
			<img src="$imgpath/idea.png"><a style="text-decoration:none;" href="http://www.prelovac.com/vladimir/services"> Need a WordPress Expert?</a> 
  </div>
 	</div>
	
	 <div id="mainblock" style="width:710px">
	 
		<div class="dbx-content">
		 	<form name="yteform" action="$action_url" method="post">
					<input type="hidden" name="submitted" value="1" /> 
					<input type="hidden" id="_wpnonce" name="_wpnonce" value="$nonce" />
					<h2>Usage</h2>
                           
<p>To use the video in your posts, paste YouTube video URL with <strong>httpv://</strong> (notice the 'v'). </p>
<p><strong>Important:</strong> The URL should just be copied into your post normally and the letter 'v' added, do not create a clickable link!</p>
<p>Example: httpv://www.youtube.com/watch?v=OWfksMD4PAg</p>
<p>If you want to embed high quality video (for videos that have them) use httpvh:// instead (Video High).</p>
<p>If you want to embed HD Quality (DVD quality 720p) video use httpvhd:// instead (Video High Defintion).</p>
<p>To embed playlists	use httpvp:// (eg. httpvp://www.youtube.com/view_play_list?p=528026B4F7B34094)</p>
<p>Smart Youtube also supports migrated blogs from Wordpress.com using [youtube=youtubeadresss]</p>

<ul>
<li>httpv:// - regular video</li>
<li>httpvh:// - high quality</li>
<li>httpvhd:// - HD quality</li>
<li>httpvp:// - playlist</li>
</ul>
<h2>Options</h2>
<p> You can adjust the way your embeded youtube videos behave in the options below.</p>
<p><strong>Video settings</strong></p>

<div><input id="check3" type="checkbox" name="disp_posts" $disp_posts />
<label for="check3">Display videos in posts</label></div>

<div><input id="check4" type="checkbox" name="disp_comments" $disp_comments />
<label for="check4">Display videos in comments</label></div>


<br><br><strong>Video Appearence</strong><br><br>
<p>Video template. Default is just {video}. <br />
You can try $example if you want the text to wrap around video.</p>
<textarea cols="50" id="disp_template" name="disp_template">$disp_template</textarea>

<p>Video width and height in normal mode. Default is 425x344.</p>
<input id="disp_width"  name="disp_width" value="$disp_width" size="7"/>x<input id="disp_height"  name="disp_height" value="$disp_height" size="7" /><br>

<p>Video width and height in <strong>high quality</strong> mode. Default is 480x360.</p>
<input id="disp_widthhq"  name="disp_widthhq" value="$disp_widthhq" size="7" />x<input id="disp_heighthq"  name="disp_heighthq" value="$disp_heighthq" size="7" /><br><br>

<p>Video width and height in <strong>sidebar</strong> mode (regardless of quality). Default is 150x125.</p>
<input id="disp_widthside"  name="disp_widthside" value="$disp_widthside" size="7" />x<input id="disp_heightside"  name="disp_heightside" value="$disp_heightside" size="7" /><br><br>


 <br />		
		<div id="watch-customize-embed-form">
			<input type="radio" $disp_rel id="embedCustomization1" name="embedRel" value="1"/>
			<label for="embedCustomization1">Include related videos</label><br/>
			<input type="radio" $disp_rel2  id="embedCustomization0" name="embedRel" value="0"/>
			<label for="embedCustomization0">Do not include related videos</label><br/>
		</div>
		<img id="watch-customize-embed-theme-preview" src="$wp_yte_plugin_url/img/preview_embed_blank_sm.gif"/>
		<div id="watch-customize-embed-theme-swatches">
				<a onclick="onChangeColor('blank');  return false;" class="watch-image-radio-link radio_selected" href="#" id="theme_color_blank_img"><img alt="" src="http://s.ytimg.com/yt/img/pixel-vfl73.gif" class="watch-embed-select watch-embed-blank"/></a>
				<a onclick="onChangeColor('storm');  return false;" class="watch-image-radio-link" href="#" id="theme_color_storm_img"><img alt="" src="http://s.ytimg.com/yt/img/pixel-vfl73.gif" class="watch-embed-select watch-embed-storm"/></a>
				<a onclick="onChangeColor('iceberg');  return false;" class="watch-image-radio-link " href="#" id="theme_color_iceberg_img"><img alt="" src="http://s.ytimg.com/yt/img/pixel-vfl73.gif" class="watch-embed-select watch-embed-iceberg"/></a>
				<a onclick="onChangeColor('acid');  return false;" class="watch-image-radio-link" href="#" id="theme_color_acid_img"><img alt="" src="http://s.ytimg.com/yt/img/pixel-vfl73.gif" class="watch-embed-select watch-embed-acid"/></a>
				<a onclick="onChangeColor('green');  return false;" class="watch-image-radio-link" href="#" id="theme_color_green_img"><img alt="" src="http://s.ytimg.com/yt/img/pixel-vfl73.gif" class="watch-embed-select watch-embed-green"/></a>
				<a onclick="onChangeColor('orange');  return false;" class="watch-image-radio-link" href="#" id="theme_color_orange_img"><img alt="" src="http://s.ytimg.com/yt/img/pixel-vfl73.gif" class="watch-embed-select watch-embed-orange"/></a>
				<a onclick="onChangeColor('pink');  return false;" class="watch-image-radio-link" href="#" id="theme_color_pink_img"><img alt="" src="http://s.ytimg.com/yt/img/pixel-vfl73.gif" class="watch-embed-select watch-embed-pink"/></a>
				<a onclick="onChangeColor('purple');  return false;" class="watch-image-radio-link" href="#" id="theme_color_purple_img"><img alt="" src="http://s.ytimg.com/yt/img/pixel-vfl73.gif" class="watch-embed-select watch-embed-purple"/></a>
				<a onclick="onChangeColor('rubyred');  return false;" class="watch-image-radio-link" href="#" id="theme_color_rubyred_img"><img alt="" src="http://s.ytimg.com/yt/img/pixel-vfl73.gif" class="watch-embed-select watch-embed-rubyred"/></a>
				<input id="embedColor" type="hidden" name="embedColor" value="$disp_color">
				<input id="prevUrl" type="hidden" name="prevUrl" value="$wp_yte_plugin_url/img/">
		</div>
			<div style="margin: 0px 0px 0px 4px; clear: both;">
				<input type="checkbox" onchange="onUpdatePreviewImage();" id="show_border_checkbox" name="embedBorder" $disp_border /><label for="show_border_checkbox"> Show Border</label><br>
				<input type="checkbox" id="autoplay_checkbox" name="autoplay" $disp_autoplay /><label for="autoplay_checkbox"> Autoplay videos</label><br>
				<input type="checkbox" id="disp_search" name="disp_search" $disp_search /><label for="disp_search"> Display search box</label><br>
				<input type="checkbox" id="disp_info" name="disp_info" $disp_info /><label for="disp_info"> Remove Titles & Ratings</label><br>
				<input type="checkbox" id="disp_ann" name="disp_ann" $disp_ann /><label for="disp_ann"> Remove Annotations</label>
			</div>
		

<br>
<p><strong>xHTML validation</strong></p>
<p>Enabling the option below will make your YouTube code xHTML valid. But be warned that code may not work in some browsers like iPhone and in feed readers.</p>
<div><input id="valid" type="checkbox" name="valid" $valid />
<label for="valid">Enable xHTML Validation</label></div>
<br />


<br>
<p><strong>RSS feed options</strong></p>
<p>Some RSS feed readers like Bloglines will show embeded YouTube videos. Some will not and Smart YouTube allows you to display a video link and a video screenshot instead.</p>
<p>Smart YouTube will always embed the video but it can not know if the reader supports embeded video or not. So use these additional options at your own likening.</p>

<div><input id="check2" type="checkbox" name="disp_link" $disp_link />
<label for="check2">Display video link in RSS feed</label></div>

<div><input id="check1" type="checkbox" name="disp_img" $disp_img />
<label for="check1">Display video preview image in RSS feed</label></div>

<div class="submit"><input type="submit" name="Submit" value="Update options" /></div>
			</form>
		</div>
					
		<br/><br/><h3>&nbsp;</h3>	
	 </div>

	</div>
	
<h5>a plugin by <a href="http://www.prelovac.com/vladimir/">Vladimir Prelovac</a></h5>
</div>
END;
    
}

// Add Options Page
add_action('admin_menu', 'yte_add_pages');



function yte_tag($file, $high='v', $time = "", $side = 0) {
global $CustomColors;

 
	$playlist=0;	
	
	$disp_rel = get_option('smart_yt_rel');
	$disp_border = get_option('smart_yt_border');
	$disp_color = get_option('smart_yt_color');
	$autoplay = get_option('smart_yt_autoplay');
	$disp_search=(get_option('smart_yt_search')=='on') ? "1":"0";
	$disp_info=(get_option('smart_yt_info')=='on') ? "&showinfo=0":"";
	$disp_ann=(get_option('smart_yt_ann')=='on') ? "&iv_load_policy=3":"";
	$template=get_option('smart_yt_template');
	
	
	$valid=get_option('smart_yt_valid');
	

	switch ($high)
	{
		case 'v': $high=""; break;
		case 'vh': $high="&amp;ap=%2526fmt%3D18"; break;
		case 'vhd': $high="&amp;ap=%2526fmt%3D22"; break;
		case 'vp': $high=""; $playlist=1; break;		
		default : $high=""; break;
	}
	
	$width=$side ? get_option('smart_yt_widthside') : ($high ? get_option('smart_yt_widthhq') : get_option('smart_yt_width'));
	$height=$side ? get_option('smart_yt_heightside') : ($high ? get_option('smart_yt_heighthq') : get_option('smart_yt_height'));
	
	
	
	if ($width=="")
		$width=$high!="" ? "480" : "425" ;
	if ($height=="")
		$height= $high!="" ? "360" : "344";	
		
		
	if ($disp_border)
		$height+=18;		
	  

	//	if ( strpos($_SERVER['HTTP_USER_AGENT'], "iPhone") || strpos($_SERVER['HTTP_USER_AGENT'], "iPod") )	
		if ($playlist)
		{
			$yte_tag = '<!-- Smart Youtube --><span class="youtube"><object width="'.$width.'" height="'.$height.'"><param name="movie" value="'.htmlspecialchars('http://www.youtube.com/p/'.$file.'&rel='.$disp_rel.'&color1='.$CustomColors[$disp_color][0].'&color2='.$CustomColors[$disp_color][1].'&border='.$disp_border.'&fs=1&hl=en&autoplay='.$autoplay.$disp_info.$disp_ann.'&showsearch='.$disp_search, ENT_QUOTES).$high.$time.'" /><param name="allowFullScreen" value="true" /><embed wmode="transparent" src="'.htmlspecialchars('http://www.youtube.com/p/'.$file.'&rel='.$disp_rel.'&color1='.$CustomColors[$disp_color][0].'&color2='.$CustomColors[$disp_color][1].'&border='.$disp_border.'&fs=1&hl=en&autoplay='.$autoplay.$disp_info.$disp_ann.'&showsearch='.$disp_search, ENT_QUOTES).$high.$time.'" type="application/x-shockwave-flash" allowfullscreen="true" width="'.$width.'" height="'.$height.'" ></embed><param name="wmode" value="transparent" /></object></span>';		
		}
		else {
			if ($valid=="off")
				$yte_tag = '<!-- Smart Youtube --><span class="youtube"><object width="'.$width.'" height="'.$height.'"><param name="movie" value="'.htmlspecialchars('http://www.youtube.com/v/'.$file.'&rel='.$disp_rel.'&color1='.$CustomColors[$disp_color][0].'&color2='.$CustomColors[$disp_color][1].'&border='.$disp_border.'&fs=1&hl=en&autoplay='.$autoplay.$disp_info.$disp_ann.'&showsearch='.$disp_search, ENT_QUOTES).$high.$time.'" /><param name="allowFullScreen" value="true" /><embed wmode="transparent" src="'.htmlspecialchars('http://www.youtube.com/v/'.$file.'&rel='.$disp_rel.'&color1='.$CustomColors[$disp_color][0].'&color2='.$CustomColors[$disp_color][1].'&border='.$disp_border.'&fs=1&hl=en&autoplay='.$autoplay.$disp_info.$disp_ann.'&showsearch='.$disp_search, ENT_QUOTES).$high.$time.'" type="application/x-shockwave-flash" allowfullscreen="true" width="'.$width.'" height="'.$height.'" ></embed><param name="wmode" value="transparent" /></object></span>';			
			else
				$yte_tag = '<!-- Smart Youtube --><span class="youtube"><object type="application/x-shockwave-flash" width="'.$width.'" height="'.$height.'" data="'.htmlspecialchars('http://www.youtube.com/v/'.$file.'&rel='.$disp_rel.'&color1='.$CustomColors[$disp_color][0].'&color2='.$CustomColors[$disp_color][1].'&border='.$disp_border.'&fs=1&hl=en&autoplay='.$autoplay.$disp_info.$disp_ann.'&showsearch='.$disp_search, ENT_QUOTES).$high.$time.'"><param name="movie" value="'.htmlspecialchars('http://www.youtube.com/v/'.$file.'&rel='.$disp_rel.'&color1='.$CustomColors[$disp_color][0].'&color2='.$CustomColors[$disp_color][1].'&border='.$disp_border.'&fs=1&hl=en&autoplay='.$autoplay.$disp_info.$disp_ann.'&showsearch='.$disp_search, ENT_QUOTES).$high.$time.'" /><param name="allowFullScreen" value="true" /><param name="wmode" value="transparent" /></object></span>';
	  }
   

if (is_feed())
{
		if ($high)
			$high="&fmt=18";
    if (get_option('smart_yt_img')=='on')
    	$yte_tag.='<a href="http://www.youtube.com/watch?v='.$file.$high.'"><img src="http://img.youtube.com/vi/'.$file.'/default.jpg" width="130" height="97" border=0></a>';
    if (get_option('smart_yt_link')=='on')
    	$ytE_tag.='<a href="http://www.youtube.com/watch?v='.$file.$high.'">www.youtube.com/watch?v='.$file.'</a>';	
  //  if ( (get_option('smart_yt_link')=='off') && (get_option('smart_yt_img')=='off') )
    //    $yte_tag='http://www.youtube.com/watch?v='.$file;	
}
  $result= str_replace('{video}',  $yte_tag, html_entity_decode($template)); 

	return $result;
}

function yte_check($the_content, $side=0) {
	if(strpos($the_content, "httpv")!==FALSE  ) {
		
		$char_codes = array('&#215;','&#8211;');
		$replacements = array("x", "--");
	  $the_content=str_replace($char_codes, $replacements, $the_content);
	    
		preg_match_all("/http(v|vh|vhd):\/\/([a-zA-Z0-9\-\_]+\.|)youtube\.com\/watch(\?v\=|\/v\/)([a-zA-Z0-9\-\_]{11})([^<\s]*)/", $the_content, $matches, PREG_SET_ORDER); 
		foreach($matches as $match) { 
			
			$the_content = preg_replace("/http".$match[1].":\/\/([a-zA-Z0-9\-\_]+\.|)youtube\.com\/watch(\?v\=|\/v\/)([a-zA-Z0-9\-\_]{11})([^\s<]*)/", yte_tag($match[4], $match[1], $match[5], $side), $the_content, 1);	
		}
		
		preg_match_all("/http(vp):\/\/([a-zA-Z0-9\-\_]+\.|)youtube\.com\/view_play_list(\?p\=|\/v\/)([a-zA-Z0-9\-\_]{16})([^<\s]*)/", $the_content, $matches, PREG_SET_ORDER); 
		foreach($matches as $match) { 			
			$the_content = preg_replace("/http".$match[1].":\/\/([a-zA-Z0-9\-\_]+\.|)youtube\.com\/view_play_list(\?p\=|\/v\/)([a-zA-Z0-9\-\_]{16})([^\s<]*)/", yte_tag($match[4], $match[1], $match[5], $side), $the_content, 1);	
		}
		
		
	}
	
	// to work with migrated blogs from Wordpress.com replacing [youtube=youtubeadresss]
	if(strpos($the_content, "[youtube")!==FALSE ) {
		preg_match_all("/\[youtube\=http:\/\/([a-zA-Z0-9\-\_]+\.|)youtube\.com\/watch(\?v\=|\/v\/)([a-zA-Z0-9\-\_]{11})([^<\s]*)\]/", $the_content, $matches, PREG_SET_ORDER);
		foreach($matches as $match) {
			$the_content = preg_replace("/\[youtube\=http:\/\/([a-zA-Z0-9\-\_]+\.|)youtube\.com\/watch(\?v\=|\/v\/)([a-zA-Z0-9\-\_]{11})([^\s<]*)\]/", yte_tag($match[3], '', $match[4], $side), $the_content, 1);
		}
	}


    return $the_content;
}


function yte_install(){
  if(get_option('smart_yt_posts' == '') || !get_option('smart_yt_posts')){
    add_option('smart_yt_posts', 'on');
  }
  if(get_option('smart_yt_width' == '') || !get_option('smart_yt_width')){
    add_option('smart_yt_width', '425');
  }
  if(get_option('smart_yt_height' == '') || !get_option('smart_yt_height')){
    add_option('smart_yt_height', '355');
  }
  
   if(get_option('smart_yt_widthhq' == '') || !get_option('smart_yt_widthhq')){
    add_option('smart_yt_widthhq', '480');
  }
  if(get_option('smart_yt_heighthq' == '') || !get_option('smart_yt_heighthq')){
    add_option('smart_yt_heighthq', '360');
  }
  
  if(get_option('smart_yt_widthside' == '') || !get_option('smart_yt_widthside')){
    add_option('smart_yt_widthside', '150');
  }
  if(get_option('smart_yt_heightside' == '') || !get_option('smart_yt_heightside')){
    add_option('smart_yt_heightside', '125');
  }
  
  if(get_option('smart_yt_rel' == '') || !get_option('smart_yt_rel')){
    add_option('smart_yt_rel', '1');
  }
    if(get_option('smart_yt_color' == '') || !get_option('smart_yt_color')){
    add_option('smart_yt_color', 'blank');
  }
 
  if(get_option('smart_yt_link' == '') || !get_option('smart_yt_link')){
    add_option('smart_yt_link', 'on');
  } 
  
   if(get_option('smart_yt_valid' == '') || !get_option('smart_yt_valid')){
    add_option('smart_yt_valid', 'off');
  } 
  
   if(get_option('smart_yt_search' == '') || !get_option('smart_yt_search')){
    add_option('smart_yt_search', 'off');
  }   
  
    if(get_option('smart_yt_info' == '') || !get_option('smart_yt_info')){
    add_option('smart_yt_info', 'on');
  }
  
  if(get_option('smart_yt_ann' == '') || !get_option('smart_yt_ann')){
    add_option('smart_yt_ann', 'on');
  }
  
  if(get_option('smart_yt_template' == '') || !get_option('smart_yt_template')){
    add_option('smart_yt_template', '{video}');
  } 

  
  // register widget
  if (function_exists('register_sidebar_widget'))
		register_sidebar_widget('Smart YouTube', 'yte_widget');	

	if (function_exists('register_widget_control'))	
		register_widget_control('Smart YouTube', 'yte_widgetcontrol');

  
}

function yte_widgetcontrol()
{
		if ($_REQUEST['submit'])
		{
			update_option('smart_yt_wtext', stripslashes(($_REQUEST['yte_text'])));
			update_option('smart_yt_wtitle', stripslashes(($_REQUEST['yte_title'])));
		}
		$text=wp_specialchars(get_option('smart_yt_wtext'));
		$title=wp_specialchars(get_option('smart_yt_wtitle'));
		echo 'Title:<br /><input type="text" id="yte_title" name="yte_title" value="'.$title.'" /><br />';
		echo 'Insert HTML code below. In addition to normal text you may use httpv, httpvh and httpvhd links just like in your posts.<br/><textarea id="text" name="yte_text" rows="10" cols="16" class="widefat">'.$text.'</textarea>';
		echo '<input type="hidden" id="submit" name="submit" value="1" />';	
}


function yte_widget($args = array() )
{
	extract ($args);
	$text = yte_check((get_option('smart_yt_wtext')), 1);
	echo $before_widget; 	
	echo $before_title.(get_option('smart_yt_wtitle')).$after_title;
	echo $text;
	echo $after_widget; 

}

if (isset($_GET['activate']) && $_GET['activate'] == 'true') {
    yte_install();
}

if (get_option('smart_yt_posts')=='on')  {
	add_filter('the_content', 'yte_check', 100);
	add_filter('the_excerpt','yte_check', 100);
	

}
if (get_option('smart_yt_comments')=='on') {
	add_filter('comment_text','yte_check', 100);
}

add_action( 'plugins_loaded', 'yte_install' );

add_action( 'after_plugin_row', 'yte_check_plugin_version' );

function yte_getinfo()
{
		$checkfile = "http://svn.wp-plugins.org/smart-youtube/trunk/smartyoutube.chk";
		//$checkfile = "http://www.prelovac.com/plugin/smartyoutube.chk";	
		
		$status=array();
		return $status;
		$vcheck = wp_remote_fopen($checkfile);
				
		if($vcheck)
		{
			$version = $yte_localversion;
									
			$status = explode('@', $vcheck);
			return $status;				
		}					
}

function yte_check_plugin_version($plugin)
{
	global $plugindir,$yte_localversion;
	
 	if( strpos($plugin,'smartyoutube.php')!==false )
 	{
			

			$status=yte_getinfo();
			
			$theVersion = $status[1];
			$theMessage = $status[3];	
	
			if( (version_compare(strval($theVersion), strval($yte_localversion), '>') == 1) )
			{
				$msg = 'Latest version available '.' <strong>'.$theVersion.'</strong><br />'.$theMessage;				
				echo '<td colspan="5" class="plugin-update" style="line-height:1.2em;">'.$msg.'</td>';
			} else {
				return;
			}
		
	}
}





?>
