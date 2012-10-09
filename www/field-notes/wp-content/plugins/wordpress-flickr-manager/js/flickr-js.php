<?php
ini_set('display_errors', 0);
require_once("../../../../wp-config.php");
header('Content-Type: text/javascript');
header('Cache-Control: no-cache');
header('Pragma: no-cache');
global $flickr_manager;
?>

/*global document, window, Ajax, tinyMCE, jQuery */

var plugin_dir = "<?php echo $flickr_manager->getAbsoluteUrl(); ?>/";

function displayLoading(destId) {
	var element = document.getElementById(destId);
	if(!element) {
		return;
	}
	var image = document.createElement("img");
	image.setAttribute("alt", "loading...");
	image.setAttribute("src", plugin_dir + "images/loading.gif");
	image.className = "loading";
	element.innerHTML = "";
	element.appendChild(image);
}

function returnError(destId) {
	var element = document.getElementById(destId);
	if(!element) {
		return;
	}
	element.innerHTML = "Unexpected error occured while performing an AJAX request";
}

function executeLink(link, destId) {
	var query_array = link.getAttribute("href").split("?");
	var scope = document.getElementById("flickr-public").value;
	var lightbox = document.getElementById("flickr-lightbox");
	if(document.getElementById("flickr-personal").checked === true) {
		scope = document.getElementById("flickr-personal").value;
	}
	var query = query_array[query_array.length - 1] + "&fscope=" + scope;
	if(lightbox) {
		 query = query + "&flightbox=" + lightbox.checked;
	}
	var usePset = document.getElementById("lbox-photoset");
	var insertSet = "false";
	var psetname = "";
	if(usePset) {
		if(usePset.checked === true) {
			insertSet = "true";
		}
		psetname = document.getElementById("fphotoset-name").value;
		query = query + "&flbox-photoset=" + insertSet + "&fphotoset-name=" + psetname;
	}
	var jurl = plugin_dir + "flickr-ajax.php";
	displayLoading(destId);
	
	if(typeof(jQuery) != "undefined") {
		// jQuery request
		var flickr_ajax = jQuery.ajax({
			type: "POST",
			url: jurl,
			data: query,
			error: function() {
				returnError(destId);
			},
			success: function(msg) {
				document.getElementById(destId).innerHTML = msg;
			}
		});
	} else {
		// Prototype Alternative
		var flickr_ajax = new Ajax.Updater({success: destId}, jurl, {method: 'get', parameters: query, onFailure: function(){ returnError(destId); }});
	}
		
	return false;
}

function performFilter(destId) {
	var filter = document.getElementById("flickr-filter").value;
	var size = document.getElementById("flickr-size");
	var scope = document.getElementById("flickr-public").value;
	var page = document.getElementById("flickr-page").value;
	var lightbox = document.getElementById("flickr-lightbox").checked;
	var photoset = "";
	var insertSet = "false";
	var psetname = document.getElementById("fphotoset-name").value;
	
	if(document.getElementById("lbox-photoset").checked === true) {
		insertSet = "true";
	}
	if(filter != document.getElementById("flickr-old-filter").value) {
		page = 1;
	}
	if(document.getElementById("flickr-personal").checked === true) {
		scope = document.getElementById("flickr-personal").value;
		photoset = document.getElementById("flickr-photosets").value;
	}
	var query = "faction=" + document.getElementById("flickr-action").value + "&photoSize=" + size.options[size.selectedIndex].value + "&filter=" + filter + "&fpage=" + page + "&fscope=" + scope + "&flightbox=" + lightbox + "&fphotoset=" + photoset + "&flbox-photoset=" + insertSet + "&fphotoset-name=" + psetname;
	var jurl = plugin_dir + "flickr-ajax.php";
	displayLoading(destId);
	
	if(typeof(jQuery) != "undefined") {
		// jQuery request
		var flickr_ajax = jQuery.ajax({
			type: "POST",
			url: jurl,
			data: query,
			error: function() {
				returnError(destId);
			},
			success: function(msg) {
				document.getElementById(destId).innerHTML = msg;
			}
		});
	} else {
		// Prototype Alternative
		var flickr_ajax = new Ajax.Updater({success: destId}, jurl, {method: 'get', parameters: query, onFailure: function(){ returnError(destId); }});
	}
	
	return false;
}

function prepareLinks(containId, destId) {
	if (!document.getElementById || !document.getElementsByTagName) {
		return;
	}
	if (!document.getElementById(containId)) {
		return;
	}
	var list = document.getElementById(containId);
	var links = list.getElementsByTagName("a");
	for (var i=0; i < links.length; i++) {
		links[i].onclick = function() {
			return executeLink(this, destId);
		};
	}
}

function addLoadEvent(func) {
	var oldonload = window.onload;
	if (typeof window.onload != 'function') {
		window.onload = func;
	} else {
		window.onload = function() {
			oldonload();
			func();
		};
	}
}

addLoadEvent(function () {
	prepareLinks('flickr-content','flickr-ajax');
});

function insertAtCursor(myField, myValue) {
	// IE support
	if (document.selection) {
		myField.focus();
		var sel = document.selection.createRange();
		sel.text = myValue;
	}
	// MOZILLA/NETSCAPE support
	else if (myField.selectionStart || myField.selectionStart === 0) {
		var startPos = myField.selectionStart;
		var endPos = myField.selectionEnd;
		myField.value = myField.value.substring(0, startPos) + myValue + myField.value.substring(endPos, myField.value.length);
	} else {
		myField.value += myValue;
	}
}

function isDefined(variable) {
    return (typeof(variable) == "undefined") ? false : true;
}

function insertImage(image,owner,id,name) {
	var imgHTML = "";
	var target = "";
	var relation = ' rel="flickr-mgr"';
	var image_url = document.getElementById("url-" + id).value;
	var wrapBefore = decodeURIComponent(document.getElementById("wfm-insert-before").getAttribute("value"));
	var wrapAfter = decodeURIComponent(document.getElementById("wfm-insert-after").getAttribute("value"));
	
	if(document.getElementById("flickr_blank") && document.getElementById("flickr_blank").value == "true") {
		target = ' target="_blank" ';
	}
	var lightbox_size = document.getElementById("flickr-lbsize");
	if(document.getElementById("flickr-lightbox").checked) {
		if(document.getElementById("lbox-photoset").checked === true) {
			var psetname = document.getElementById("fphotoset-name").value;
			relation = ' rel="flickr-mgr[' + psetname + ']"';
		} 
		imgHTML = '<a href="http://www.flickr.com/photos/' + owner + "/" + id + '/" class="flickr-image" ' + target + ' title="' + image.alt + '"';
		imgHTML = imgHTML + relation + '><img src="' + image_url + '" alt="' + image.alt + '" class="' + lightbox_size.options[lightbox_size.selectedIndex].value + '" /></a>';
	} else {
		imgHTML = '<a href="http://www.flickr.com/photos/' + owner + "/" + id + '/" class="flickr-image" title="' + image.alt + '"' + target + 'title="' + image.alt + '"' + '>';
		imgHTML = imgHTML + '<img src="' + image_url + '" alt="' + image.alt + '" /></a>';
	}
	var license = document.getElementById("license-" + id);
	if(license) {
		imgHTML = imgHTML + "<br /><small><a href='" + license.href + "' title='" + license.title + "' rel='license' " + target + ">" + license.innerHTML + "</a> by <a href='http://www.flickr.com/people/"+owner+"/'"+ target +">"+name+"</a></small>";
	}
	
	if(isDefined(wrapBefore) && wrapBefore !== 'undefined') {
		imgHTML = wrapBefore + imgHTML;
	}
	if(isDefined(wrapAfter) && wrapAfter !== 'undefined') {
		imgHTML = imgHTML + wrapAfter;
	}
	
	imgHTML = imgHTML + "&nbsp;";
	
	
	
	var i = document.getElementById("content");
	if(i.style.display != "none") {
		insertAtCursor(i, imgHTML);
	} else {
		if ( typeof tinyMCE != 'undefined' ) {
			tinyMCE.execCommand('mceFocus',false,'content');
			tinyMCE.execCommand('mceInsertContent',false,imgHTML);
		}
	}

	return false;
}

function insertSet(id) {
	var lightbox = document.getElementById("flickr-lightbox");
	var size = document.getElementById("flickr-size");
	if(size) {
		size = size.options[size.selectedIndex].value;
	} else {
		size = "thumbnail";
	}
	var setHTML;
	if(lightbox) {
		if(lightbox.checked) {
			lightbox = "true";
		} else {
			lightbox = "false";
		}
	}
	setHTML = "[imgset:" + id + "," + size + "," + lightbox + "]";
	
	var i = document.getElementById("content");
	if(i.style.display != "none") {
		insertAtCursor(i, setHTML);
	} else {
		if ( typeof tinyMCE != 'undefined' ) {
			tinyMCE.execCommand('mceFocus',false,'content');
			tinyMCE.execCommand('mceInsertContent',false,setHTML);
		}
	}

	return false;
}

function kH(e) {
	var evt = (e) ? e : window.event;
	var type = evt.type;
	var pK = e ? e.which : window.event.keyCode;
	if (pK == 13) {
		return performFilter('flickr-ajax');
	}
}
