<?php
header('Content-Type: text/javascript');
header('Cache-Control: no-cache');
header('Pragma: no-cache');
require_once("../../../../wp-config.php");
?>
var wfm_plugin = '<?php global $flickr_manager; echo $flickr_manager->getAbsoluteUrl(); ?>';
var cancelAction = false;
 
jQuery(document).ready(function() {
	jQuery("#flickr-form").submit(function() { return insertUpload(); });
	jQuery("#flickr-insert").click(function() { cancelAction = true; });
	jQuery("#flickr-save").click(function() { cancelAction = false; });
	
	jQuery("#wfm-insert-set").change(function() {
		if (jQuery('#wfm-insert-set').is(':checked')) {
			jQuery("#wfm-set-name").focus();
		}
	});
	
	jQuery("#wfm-photoset").change(function() {
		mediaRequest();
	});
	
	jQuery("#wfm-filter").keypress(function(e) {
		var evt = (e) ? e : window.event;
		var type = evt.type;
		var pK = e ? e.which : window.event.keyCode;
		if (pK == 13) {
			mediaRequest();
			return false;
		}
	});
	
	jQuery("#wfm-lightbox").change(function() {
		if(jQuery(this).is(':checked')) jQuery("#wfm-overlay>div.settings").show();
		else jQuery("#wfm-overlay>div.settings").hide();
	});
	
	if(jQuery("#wfm-lightbox").is(':checked')) jQuery("#wfm-overlay>div.settings").show();
	else jQuery("#wfm-overlay>div.settings").hide();
	
	prepareNavigation();
	
});


function prepareNavigation() {
	jQuery("#wfm-filter-submit").click(function() {
		mediaRequest();
		return false;
	});

	jQuery("#wfm-navigation>a").click(function() {
		var uri = jQuery(this).attr("href").split("?");
		mediaRequest(uri[uri.length-1]);
		return false;
	});
}

function mediaRequest(params) {
	url = jQuery("#flickr-form").attr('action');
	
	if(params) url = url + '&' + params;
	
	url = url + "&wfm-filter=" + jQuery("#wfm-filter").val();
	
	if(jQuery("select#wfm-photoset").val()) {
		url = url + "&wfm-photoset=" + jQuery("select#wfm-photoset").val();
	}
	
	var saveHeight = jQuery('#wfm-browse-content').height() + 'px';
	jQuery('#wfm-browse-content').css('min-height', saveHeight);
	jQuery('#wfm-browse-content').css('height', saveHeight);
	
	var loadingImage = jQuery("#wfm-ajax-url").attr("value") + "/images/loading.gif";
	jQuery("#wfm-browse-content").html(jQuery('<img src="' + loadingImage + '" alt="<?php _e('Loading...', 'flickr-manager'); ?>" />'));
	
	jQuery.get( url, function(data){
		jQuery('#wfm-browse-content').html(jQuery('<div>'+data+'</div>').find('#wfm-browse-content').html());
		jQuery('#wfm-navigation').html(jQuery('<div>'+data+'</div>').find('#wfm-navigation').html());
		
		prepareNavigation();
	});
}

function insertUpload() {
	if(!cancelAction) return true;
	
	var token = jQuery("#wfm-auth_token").val();
	var id = jQuery("input[@name='photo_id']").val();
	var wrapBefore = decodeURIComponent(jQuery("#wfm-insert-before").attr("value")).replace(/\\([\\'"])/g, '$1');
	var wrapAfter = decodeURIComponent(jQuery("#wfm-insert-after").attr("value")).replace(/\\([\\'"])/g, '$1');
	var target = ' ';
	if(jQuery("#wfm-blank").val() == "true") target = ' target="_blank" ';
	var longdesc = '';
	var rel = ' rel="flickr-mgr" ';
	if(jQuery("#wfm-insert-set").is(":checked")) {
		rel = ' rel="flickr-mgr[' + jQuery("#wfm-set-name").val() + ']" ';
	}
	var classStr = ' class="';
	if(jQuery("#wfm-lightbox").is(":checked")) {
		classStr = classStr + 'flickr-' + jQuery("select[@name='wfm-lbsize']").val();
	} else {
		rel = '';
	}
	classStr = classStr + '" ';
	
	var size = jQuery("input[@name='flickr-size']:checked").val();
	if(jQuery("select[@name='wfm-lbsize']").val() == 'original')
		longdesc = ' longdesc="' + jQuery('#original-url').val() + '" ';
	
	var imgHTML = '<a href="' + jQuery('#flickr-link').val() + '" title="' + jQuery('#flickr-title').val() + '"' + target + 'class="flickr-image align'+jQuery("input[@name='flickr-align']:checked").val()+'"' + rel + '>';
	imgHTML = imgHTML + '<img src="' + jQuery('#'+size+'-url').val() + '" alt="' + jQuery('#flickr-title').val() + '"' + classStr + longdesc + ' /></a>';
	
	if(jQuery('#licence').size() > 0) {
		imgHTML = imgHTML + "<br /><small><a href='" + jQuery('#licence').attr("href") + "' title='" + 
			jQuery('#licence').html() + "' rel='license' " + target + "><img src='" + wfm_plugin + 
			"/images/creative_commons_bw.gif' alt='" + jQuery('#licence').html() + "'/></a> by <a href='http://www.flickr.com/people/"+jQuery('#owner').val().split("|")[0]+"/'"+ target +">"+jQuery('#owner').val().split("|")[1]+"</a></small>";
	}
	
	if(typeof wrapBefore != 'undefined' && wrapBefore !== 'undefined') {
		imgHTML = wrapBefore + imgHTML;
	}
	if(typeof wrapAfter != 'undefined' && wrapAfter !== 'undefined') {
		imgHTML = imgHTML + wrapAfter;
	}
	
	if(jQuery("#wfm-close").size() > 0) {
		sendToEditor(imgHTML);
	} else {
		top.send_to_editor(imgHTML);
	}
	
	return false;
}

function insertSet() {
	var wrapBefore = decodeURIComponent(jQuery("#wfm-insert-before").attr("value")).replace(/\\([\\'"])/g, '$1');
	var wrapAfter = decodeURIComponent(jQuery("#wfm-insert-after").attr("value")).replace(/\\([\\'"])/g, '$1');
	
	var id = jQuery("#wfm-photoset").val();
	var imgHTML = '[flickrset id="' + id + '" thumbnail="' + jQuery("input[@name='flickr-size']").val() + '"';
	if(jQuery("#wfm-lightbox").is(':checked')) { 
		imgHTML = imgHTML + ' overlay="true" size="' + jQuery('#wfm-lbsize').val() + '"';
	}
	imgHTML = imgHTML + ']';
	
	if(typeof wrapBefore != 'undefined' && wrapBefore !== 'undefined') {
		imgHTML = wrapBefore + imgHTML;
	}
	if(typeof wrapAfter != 'undefined' && wrapAfter !== 'undefined') {
		imgHTML = imgHTML + wrapAfter;
	}
	
	sendToEditor(imgHTML);
}

function sendToEditor(html) {
	if(jQuery("#wfm-close").is(":checked")) {
		top.send_to_editor(html);
	} else {
		var win = window.opener ? window.opener : window.dialogArguments;
		if ( !win ) win = top;
		tinyMCE = win.tinyMCE;
		var edCanvas = win.document.getElementById('content');
		
		if ( typeof tinyMCE != 'undefined' && ( ed = tinyMCE.activeEditor ) && !ed.isHidden() ) {
			ed.focus();
			if (tinyMCE.isIE)
				ed.selection.moveToBookmark(tinyMCE.EditorManager.activeEditor.windowManager.bookmark);
	
			ed.execCommand('mceInsertContent', false, html);
		} else if ( typeof edInsertContent == 'function' ) {
			edInsertContent(edCanvas, html);
		} else {
			jQuery( edCanvas ).val( jQuery( edCanvas ).val() + html );
		}
	}
}
