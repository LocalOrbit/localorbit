<?php
header('Content-Type: text/javascript');
header('Cache-Control: no-cache');
header('Pragma: no-cache');
require_once("../../../../wp-config.php");
global $flickr_manager, $flickr_settings;
?>

function updateFlickrHref(anchor) {
	var image = anchor.getElementsByTagName('img');
	image = image[0];
	
	var chkClass = image.getAttribute("class");
	if (chkClass === null) {
		chkClass = image.getAttribute("className");
	}
	
	if(chkClass && chkClass.match("flickr-original")) {
		anchor.setAttribute("href", image.getAttribute("longdesc"));
	} else {
		var image_link = image.getAttribute("src");
		var imageSize = "";
		
		if(chkClass) {
			var testResult = chkClass.match(/flickr\-small|flickr\-medium|flickr\-large/);
			switch(testResult.toString()) {
				case "flickr-large":
					imageSize = "_b";
					break;
				case "flickr-medium":
					imageSize = "";
					break;
				case "flickr-small":
					imageSize = "_m";
					break;
			}
		}
		
		if(image_link.match(/[s,t,m]\.jpg/)) {
			image_link = image_link.split("_");
			image_link.pop();
			image_link[image_link.length - 1] = image_link[image_link.length - 1] + imageSize + ".jpg";
			image_link = image_link.join("_");
		} else if(!image_link.match(/b\.jpg/)) {
			image_link = image_link.split(".");
			image_link.pop();
			image_link[image_link.length - 1] = image_link[image_link.length - 1] + imageSize + ".jpg";
			image_link = image_link.join(".");
		}
		anchor.setAttribute("href", image_link);
	}
}



function prepareWFMImages() {
	
	wfmJS('a[@rel*=flickr-mgr]').click(function() {
		<?php $alt_tag = __('View on Flickr', 'flickr-manager'); ?>
		var caption = wfmJS(this).attr('title');
		if('<?php echo $flickr_settings->getSetting('flickr_link'); ?>' == 'true') caption = wfmJS(this).attr('title') + ' <a href="' + wfmJS(this).attr('href') + '" title="<?php echo $alt_tag; ?>"><img src="<?php echo $flickr_manager->getAbsoluteUrl(); ?>/images/flickr-media.gif" alt="<?php echo $alt_tag; ?>" /></a>';
	
		if(wfmJS(this).attr("rel") == "flickr-mgr") {	// Individual Photo
		
			var origUrl = wfmJS(this).attr("href");
			var origTitle = wfmJS(this).attr('title');
			updateFlickrHref(this);
			wfmJS(this).attr('title', caption);
			
			wfmJS(this).lightbox({
				fixedNavigation:	true,
				fileLoadingImage:	"<?php echo $flickr_manager->getAbsoluteUrl(); ?>/images/loading-3.gif",
				fileBottomNavCloseImage:	"<?php echo $flickr_manager->getAbsoluteUrl(); ?>/images/closelabel.gif"
			});
			
			wfmJS(this).attr("rel", '');
			wfmJS(this).lightbox.start(this);
			
			var anchor = this;
			
			setTimeout(function() {
				wfmJS(anchor).attr("rel","flickr-mgr");
				wfmJS(anchor).attr("href", origUrl);
				wfmJS(anchor).attr('title', origTitle);
			}, 100);
			
		} else {	// Member of photoset
			var origUrls = [];
			var setRel = wfmJS(this).attr("rel");
			
			wfmJS('a[@rel*=flickr-mgr]').each(function(){
				if(wfmJS(this).attr('rel') == setRel){
					origUrls.push([wfmJS(this).attr("href"), wfmJS(this).attr("title")]);
					
					var caption = wfmJS(this).attr('title');
					if('<?php echo $flickr_settings->getSetting('flickr_link'); ?>' == 'true') caption = wfmJS(this).attr('title') + ' <a href="' + wfmJS(this).attr('href') + '" title="<?php echo $alt_tag; ?>"><img src="<?php echo $flickr_manager->getAbsoluteUrl(); ?>/images/flickr-media.gif" alt="<?php echo $alt_tag; ?>" /></a>';
					wfmJS(this).attr("title", caption);
					
					updateFlickrHref(this);
				}
			});
			origUrls.reverse();
			
			wfmJS(this).lightbox({
				fixedNavigation:	true,
				fileLoadingImage:	"<?php echo $flickr_manager->getAbsoluteUrl(); ?>/images/loading-3.gif",
				fileBottomNavCloseImage:	"<?php echo $flickr_manager->getAbsoluteUrl(); ?>/images/closelabel.gif"
			});
			
			wfmJS(this).lightbox.start(this);
			
			// Delay changing the URL's back because Internet Explorer doesn't wait for execution to finish
			setTimeout(function() {
				wfmJS("a").each(function(){
					if(this.href && (this.rel == setRel)){
						var url = origUrls.pop();
						wfmJS(this).attr("href", url[0]);
						wfmJS(this).attr("title", url[1]);
					}
				});
			}, 100);
			
		}
		
		return false;
	});
	
}

// Thanks go to Michael Wender for the jQuery no conflict update
var wfmJS = jQuery.noConflict();
wfmJS(document).ready(function() {
	var opacityCSS = {
		'filter' : 'alpha(opacity=60)',
		'opacity' : '0.6',
		'-moz-opacity' : '0.6'
	};
	wfmJS('#overlay').css(opacityCSS);
	
	prepareWFMImages();
});
