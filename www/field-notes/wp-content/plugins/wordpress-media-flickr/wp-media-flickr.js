String.prototype.htmlspecialchars = function() {
	var str = this;
    str = str.replace(/&/g,"&amp;");
    str = str.replace(/"/g,"&quot;");
    str = str.replace(/'/g,"&#039;");
    str = str.replace(/</g,"&lt;");
    str = str.replace(/>/g,"&gt;");
    return str;
}

String.prototype.unhtmlspecialchars = function() {
	var str = this;
    str = str.replace(/&amp;/g, "&");
    str = str.replace(/&quot;/g, "\"");
    str = str.replace(/&#039;/g, "'");
    str = str.replace(/&lt;/g, "<");
    str = str.replace(/&gt;/g, ">");
    return str;
}

function photo_search (params) {
    params.per_page = 18;
    params.sort     = 'date-posted-desc';
    params.format   = 'json';
    params.jsoncallback = 'jsonFlickrPhoto';

    if(!params.text && !params.user_id) {
		params.method   = 'flickr.photos.getRecent';
	}else{
		params.method   = 'flickr.photos.search';
	}

    remove_children('items');
    document.getElementById('items').innerHTML = '<img src="'+plugin_uri+'/loading.gif" />';

    var url = 'http://www.flickr.com/services/rest/?'+
               obj2query(params) + '&time='+(new Date()).getTime();

    var script  = document.createElement('script');
    script.type = 'text/javascript';
    script.src  = url;
    document.body.appendChild(script);
}

function remove_children (id) {
    var div = document.getElementById(id);
    while (div.firstChild) { 
        div.removeChild(div.lastChild);
    }
	document.getElementById('next_page').style.display = 'none';
	document.getElementById('prev_page').style.display = 'none';
}

function obj2query (obj) {
    var list = [];
    for(var key in obj) {
        var k = encodeURIComponent(key);
        var v = encodeURIComponent(obj[key]);
        list[list.length] = k+'='+v;
    }
    var query = list.join('&');
    return query;
}

function jsonFlickrPhoto (data) {
    if (! data) return photo_search_error(data);
    if (! data.photos) return photo_search_error(data);
    var list = data.photos.photo;
    if (! list) return photo_search_error(data);
    if (! list.length) return photo_search_error(data);

    remove_children('items');
    
    document.getElementById('pages').innerHTML = msg_pages.replace(/%1\$s/, data.photos.page).replace(/%2\$s/, data.photos.pages).replace(/%3\$s/, data.photos.total);
    
    if(data.photos.page > 1) {
		document.getElementById('prev_page').style.display = 'block';
	}
    if(data.photos.page < data.photos.pages) {
		document.getElementById('next_page').style.display = 'block';
	}
	
    var items = document.getElementById('items');
    
    for(var i=0; i<list.length; i++) {
        var photo = list[i];

        photo.short_title = photo.title.replace(/^(.{17}).*$/, '$1...');
        photo.title = photo.title;

        var image_s_url = 'http://static.flickr.com/'+photo.server+
                        '/'+photo.id+'_'+photo.secret+'_s.jpg';

        var image_m_url = 'http://static.flickr.com/'+photo.server+
                        '/'+photo.id+'_'+photo.secret+'.jpg';

        var flickr_url = 'http://www.flickr.com/photos/'+
                         photo.owner+'/'+photo.id+'/';
		if(setting_photo_link) {
			flickr_url = 'http://static.flickr.com/'+photo.server+
                        '/'+photo.id+'_'+photo.secret+'.jpg';
		}
		
		if(is_msie) {
			var onclickEvent = new Function("showInsertImageDialog('"+image_m_url+"', '"+flickr_url+"', '"+photo.title.replace(/'/, '\\\'')+"')");
		}else{
			var onclickEvent = "showInsertImageDialog('"+image_m_url+"', '"+flickr_url+"', '"+photo.title.replace(/'/, '\\\'')+"')";
		}

		var div = document.createElement('div');
		div.setAttribute('class', 'flickr_photo');
		div.setAttribute('className', 'flickr_photo');

        var img = document.createElement('img');
        img.src = image_s_url;
		img.alt = photo.title;
		img.title = photo.title;
		img.setAttribute('class', 'flickr_image');
		img.setAttribute('className', 'flickr_image');
		img.setAttribute('onclick', onclickEvent);
        
        var atag = document.createElement('a');
        atag.href = flickr_url;
		atag.title = atag.tip = "show on Flickr";
        atag.target = '_blank';
        atag.innerHTML = '<img src="'+plugin_uri+'/show-flickr.gif" alt="show on Flickr"/>';
        
        var title = document.createElement('div');
		title.setAttribute('class', 'flickr_title');
		title.setAttribute('className', 'flickr_title');
		
		var span = document.createElement('span');
		span.innerHTML = photo.short_title.replace(/(.{3})/g, '$1&wbr;').htmlspecialchars().replace(/&amp;wbr;/g, '<wbr/>');
		span.title = photo.title;
		span.setAttribute('onclick', onclickEvent);
		
		title.appendChild(atag);
		title.innerHTML += '&nbsp;';
		title.appendChild(span);
        
        div.appendChild(img);
        div.appendChild(title);
        
        items.appendChild(div);
    }
}

function photo_search_error(data) {
	remove_children('items');
	
	if(data && data.photos && data.photos.photo) {
		document.getElementById('items').innerHTML = flickr_errors[0];
	}else{
		var code = data.code;
		if(!flickr_errors[code]) {
			code = 999;
		}
		alert(flickr_errors[code]);
	}
}
