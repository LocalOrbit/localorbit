<?php
require_once("../../../../wp-config.php");
header('Content-Type: text/javascript');
header('Cache-Control: no-cache');
header('Pragma: no-cache');
global $flickr_manager, $flickr_settings;
?>

hs.graphicsDir = '<?php $p = parse_url($flickr_manager->getAbsoluteUrl()); echo $p['path']; ?>/images/graphics/';
hs.outlineType = 'rounded-white';

function prepareWFMImages() {
	wfmJS('a[@rel*=flickr-mgr]').each(function() {
		this.onclick= function() { return expandImage(this); };
	});
}

hs.updateAnchors = function() {
	var els = document.all || document.getElementsByTagName('*'), all = [], images = [],groups = {}, re;
	
	wfmJS('a[@rel*=flickr-mgr]').each(function() {
		all.push(this);
		images.push(this);
		var gID = wfmJS(this).attr('rel').match(/flickr\-mgr\[\w*\]/g);
		var g = (gID) ? 'g' + gID.toString().match(/\[\w*\]/) : 'none';
		if (!groups[g]) groups[g] = [];
		groups[g].push(this);
	});
	
	for (var i = 0; i < els.length; i++) {
		re = hs.isHsAnchor(els[i]);
		if (re) {
			hs.push(all, els[i]);
			if (re[0] == 'hs.expand') hs.push(images, els[i]);
			var g = hs.getParam(els[i], 'slideshowGroup') || 'none';
			if (!groups[g]) groups[g] = [];
			hs.push(groups[g], els[i]);
		}
	}
	
	hs.anchors = { all: all, groups: groups, images: images };
	
	return hs.anchors;
};

function expandImage(anchor) {
	var save_url = wfmJS(anchor).attr("href");
	
	<?php $alt_tag = __('View on Flickr', 'flickr-manager'); ?>
	var caption = wfmJS(anchor).attr('title');
	if('<?php echo $flickr_settings->getSetting('flickr_link'); ?>' == 'true') caption = wfmJS(anchor).attr('title') + ' <a href="' + wfmJS(anchor).attr('href') + '" title="<?php echo $alt_tag; ?>"><img src="<?php echo $flickr_manager->getAbsoluteUrl(); ?>/images/flickr-media.gif" alt="<?php echo $alt_tag; ?>" /></a>';
	hs.captionText = caption;
	
	var image = wfmJS(anchor).children('img');
	var testClass = (image.attr("class") != '') ? image.attr("class") : 'flickr-medium';
	
	if(testClass.match("flickr-original")) {
		wfmJS(anchor).attr('href', image.attr('longdesc'));
	} else {
		var image_link = image.attr('src');
		var testResult = (testClass.match(/flickr\-small|flickr\-medium|flickr\-large/)).toString();
		var imageSize = '';
		if(testResult == 'flickr-large') imageSize = "_b";
		else if(testResult == 'flickr-small') imageSize = "_m";
		
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
		wfmJS(anchor).attr('href', image_link);
	}
	
	var gID = wfmJS(anchor).attr('rel').match(/flickr\-mgr\[\w*\]/g);
	var save_return = false;
	if(gID) {
		gID = gID.toString().match(/\[\w*\]/).toString();
		save_return = hs.expand(anchor, { slideshowGroup: 'g' + gID });
	} else save_return = hs.expand(anchor);
	
	wfmJS('#wfm-controlbar').css('display', 'block');
	wfmJS(anchor).attr('href', save_url);
	return save_return;
}

/*
 * INSERTS CODE INTO MEDIA TAB MENU SIMILAR TO:
 *		<div id="wfm-controlbar" class="highslide-overlay controlbar">
 *			<a href="#" class="previous" onclick="return hs.previous(this)" title="Previous (left arrow key)"></a>
 *			<a href="#" class="next" onclick="return hs.next(this)" title="Next (right arrow key)"></a>
 *			<a href="#" class="highslide-move" onclick="return false" title="Click and drag to move"></a>
 *			<a href="#" class="close" onclick="return hs.close(this)" title="Close"></a>
 *		</div>
 */
function addControlbar() {
	var controlBar = wfmJS('<div id="wfm-controlbar" class="highslide-overlay controlbar"></div>');
	
	var previousButton = wfmJS('<a href="#" class="previous" title="Previous (left arrow key)" onclick="return hs.previous(this);"></a>');
	controlBar.append(previousButton);
	
	var nextButton = wfmJS('<a href="#" class="next" title="Next (right arrow key)" onclick="return hs.next(this);"></a>');
	controlBar.append(nextButton);
	
	var moveButton = wfmJS('<a href="#" class="highslide-move" title="Click and drag to move" onclick="return false;"></a>');
	controlBar.append(moveButton);
	
	var closeButton = wfmJS('<a href="#" class="close" title="Close" onclick="return hs.close(this);"></a>');
	controlBar.append(closeButton);
	
	jQuery('body').append(jQuery('<div style="display: none;"></div>').append(controlBar));
}

var wfmJS = jQuery.noConflict();
wfmJS(document).ready(function() {
	addControlbar();
	
	hs.registerOverlay({
		thumbnailId: null,
		overlayId: 'wfm-controlbar',
		position: 'top right',
		hideOnMouseOut: true
	});
	
	prepareWFMImages();
	
	wfmJS('div#wfm-controlbar').css('display', 'none');
});
