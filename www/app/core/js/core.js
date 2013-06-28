var core={
	doBase64:true,
	currentHash:'',
	valRules:{},
	navState:{},
	images:{},
	handlers:{
	},
	doHandlers:{
	},
	query: {},
	wysihtml5 : {
		"image": false,
		customTemplates: {
	        "lists": function(locale, options) {
	            var size = (options && options.size) ? ' btn-'+options.size : '';
	            return "<li>" +
	              "<div class='btn-group'>" +
	                "<a class='btn" + size + "' data-wysihtml5-command='insertUnorderedList' title='" + locale.lists.unordered + "' tabindex='-1'><i class='icon-list'></i></a>" +
	                "<a class='btn" + size + "' data-wysihtml5-command='insertOrderedList' title='" + locale.lists.ordered + "' tabindex='-1'><i class='icon-numbered-list'></i></a>" +
	                "<a class='btn" + size + "' data-wysihtml5-command='Outdent' title='" + locale.lists.outdent + "' tabindex='-1'><i class='icon-indent-left'></i></a>" +
	                "<a class='btn" + size + "' data-wysihtml5-command='Indent' title='" + locale.lists.indent + "' tabindex='-1'><i class='icon-indent-right'></i></a>" +
	              "</div>" +
	            "</li>";
	        },

	        "link": function(locale, options) {
	            var size = (options && options.size) ? ' btn-'+options.size : '';
	            return "<li>" +
	              "<div class='bootstrap-wysihtml5-insert-link-modal modal hide fade'>" +
	                "<div class='modal-header'>" +
	                  "<a class='close' data-dismiss='modal'>&times;</a>" +
	                  "<h3>" + locale.link.insert + "</h3>" +
	                "</div>" +
	                "<div class='modal-body'>" +
	                  "<input value='http://' class='bootstrap-wysihtml5-insert-link-url input-xlarge'>" +
	                "</div>" +
	                "<div class='modal-footer'>" +
	                  "<a href='#' class='btn' data-dismiss='modal'>" + locale.link.cancel + "</a>" +
	                  "<a href='#' class='btn btn-primary' data-dismiss='modal'>" + locale.link.insert + "</a>" +
	                "</div>" +
	              "</div>" +
	              "<a class='btn" + size + "' data-wysihtml5-command='createLink' title='" + locale.link.insert + "' tabindex='-1'><i class='icon-link'></i></a>" +
	            "</li>";
	        }
		}
	}
};

core.wysihtml5_init=function(width, height, stylesheet) {
	var options = $.extend({'stylesheets' : [stylesheet]}, core.wysihtml5);
	$('.wysihtml5').wysihtml5(options);
}

core.loadingStart=function(){
	var v1 = $('#body-start').position();
	$('#loading').css('left',v1.left).fadeIn();
}

core.addHandler=function(name,ref){
	if(typeof(core.handlers[name]) == 'undefined'){
		core.handlers[name] = [];
	}
	core.handlers[name].push(ref);
}

core.removeHandler=function(name,ref){
	if(typeof(core.handlers[name]) == 'undefined'){
		core.handlers[name] = [];
	}
	for (var i = 0; i < core.handlers[name].length; i++){
			if(core.handlers[name][i] == ref)
				core.handlers[name][i] = null;
	}
}

core.callHandler=function(name,args){
	if(typeof(core.handlers[name]) != 'undefined'){
		for (var i = 0; i < core.handlers[name].length; i++){
			if(typeof(core.handlers[name][i]) == 'string')
				eval(core.handlers[name][i]);
			else if (typeof(core.handlers[name][i]) == 'function')
				core.handlers[name][i](args);
		}
	}
}

core.loadingEnd=function(){
	$('#loading').fadeOut();
}

core.toggle=function(id){
	$('#'+id).toggle('fast');
}

core.init=function(autoredirect){
	var url = core.s(location.href);

	core.baseUrl = new String(core.baseUrl).replace(core.appPage,'')
	if(url.indexOf('#')>0){
		core.go(url);
	}else{
		if(autoredirect){
			//alert('here');
			if(core.user_id == 0)
				core.go(core.unauth_controller);
			else
				core.go(core.authed_controller);
		}
	}

	setInterval(
	function(){
		if(location.hash != core.currentHash && location.hash!=''){
			core.go(location.hash);
		}
	}, 300);
	core.jqInit();



};

core.resetNavHighlight= function () {
	$('.nav-active').removeClass('nav-active');
	$('.nav-subactive1').removeClass('nav-subactive1');
};

core.navHighlight=function(level, navHighlight) {
	var className = level <= 1 ? 'nav-active' : ('nav-subactive' + (level - 1));
	if (navHighlight) {
		core.log('navHighlight: '+navHighlight);
		$('#'+navHighlight).addClass(className);
	}
};

core.changePopoverExpandButton = function (popover, show) {
	if (core.catalog) {
		core.catalog.updatePopoverButton(popover, show);
	}
};

core.isNumberKey=function(evt) {
	var charCode = (evt.which) ? evt.which : event.keyCode;
	if (charCode < 48 || charCode > 57)
		return false;

	return true;
}

core.jqInit=function(){
	$(function() {
		$(".helpslug, [rel=popover]").each(function() {
			var pos = ($(this).attr('data-position') == 'right')?'right':'left';
			$(this).popover({
				placement : pos,
				trigger : "hover",
				html : true,
				delay: { show: 250, hide: 100 }
			});
		});
		$("[rel=tooltip]").each(function() {
			$(this).tooltip({
				placement : "left"
			});
		});
		$('.control-label i.icon-required').hover(function() { changeTooltipColorTo('#990000') });
		$("textarea.wysihtml5:visible").wysihtml5(core.wysihtml5);

		$('.natural-num-only').keypress(core.isNumberKey);
	});

}

function changeTooltipColorTo(color) {
    $('.tooltip-inner').css('background-color', color)
    $('.tooltip.top .tooltip-arrow').css('border-top-color', color);
    $('.tooltip.right .tooltip-arrow').css('border-right-color', color);
    $('.tooltip.left .tooltip-arrow').css('border-left-color', color);
    $('.tooltip.bottom .tooltip-arrow').css('border-bottom-color', color);
}




$.fn.outer = function(val){
    if(val){
        $(val).insertBefore(this);
        $(this).remove();
    }
    else{ return $("<div>").append($(this).clone()).html(); }
}


core.s=function(){
	return new String(arguments[0]);
}
core.i=function(){
	return parseInt(arguments[0]);
}
core.f=function(){
	return parseFloat(arguments[0]);
}
core.b=function(){
	return (arguments[0] === true || arguments[0]==='true' || arguments[0]===1);
}

core.getFormDataForSubmit=function(form){
	var data = '';
	for (var i = 0; i < form.elements.length; i++){
		if(form.elements[i].type !='radio')
			data += '&'+form.elements[i].name+'=';
		//alert(form.elements[i].type);
		//console.log(form.elements[i].type);
		switch(form.elements[i].type){
			case 'text':
			case 'textarea':
			case 'password':
			case 'hidden':
				try{
					//alert(encodeURIComponent(form.elements[i].value));
					data += encodeURIComponent(form.elements[i].value);
				}catch(e){
					alert(form.elements[i].name+'/'+form.elements[i].value);
				}
				break;
			case 'select-one':
				if(form.elements[i].selectedIndex >= 0)
					data += encodeURIComponent(form.elements[i].options[form.elements[i].selectedIndex].value);
				break;
			case 'checkbox':
				data += (form.elements[i].checked)?1:0;
				break;
			case 'radio':
				if(form.elements[i].checked)
					data += '&'+form.elements[i].name+'='+encodeURIComponent(form.elements[i].value);
				break;
			default:
				break;
		}
	}
	return data;
}

core.submit=function(action,form,extraData){
	var action = new String(action).split(/\//);
	var method = action.pop();
	var controller = action.pop();
	action = '/'+controller+'/'+method;

	// handle rte content that is still focused by moving the content back to the textarea
	$('textarea.rte').each(function(){
		if(document.getElementById($(this).attr('id')+'-iframe'))
			$(this).val(document.getElementById($(this).attr('id')+'-iframe').contentWindow.document.getElementsByTagName("body")[0].innerHTML);
	});
	var data = '';

	if(!core.validateForm(form)){
		return false;
	}

	data += core.getFormDataForSubmit(form);

	for(var key in extraData){
		data += '&'+key+'='+encodeURIComponent(extraData[key]);
	}

	core.doRequest(action,data);
	return false;
}

core.go=function(url){
	core.currentHash='#!'+(core.s(url).split('#!')[1]);
	var newurl = core.s(core.s(url).split('#!')[1]).split('--');
	newurl[0] = core.s(newurl[0]).split('-');
	newurl[1] = core.s(newurl[1]).split('-');
	var path = '/'+newurl[0][0]+'/'+newurl[0][1];
	var data = '';
	//alert(path);
	if(newurl[1]+'' != 'undefined'){
		for (i = 0; i < newurl[1].length; i+=2){
			data +='&'+newurl[1][i]+'='+newurl[1][i+1];
		}
	}
		
	data += '&_requestor_url='+encodeURIComponent(url);
	
	if(core.lastUrl != ('#!'+newurl[0][0]+'-'+newurl[0][1])){
		if(_gaq)
			_gaq.push(['_trackPageview', path]);
		
		core.lastUrl = '#!'+newurl[0][0]+'-'+newurl[0][1];
		core.doRequest(path,data);
	}
}

core.doRequest=function(path,data){
	if(path == '/undefined/undefined')
		return false;

	// call the handlers
	core.callHandler('onrequest',{'path':path,'data':data});


	var finalData = '';
	var winW,winH;

	// get browser width/height in a cross-browser manner
	if (document.body && document.body.offsetWidth) {
		winW = document.body.offsetWidth;
		winH = document.body.offsetHeight;
	}
	if (document.compatMode=='CSS1Compat' &&
		document.documentElement &&
		document.documentElement.offsetWidth ) {
		winW = document.documentElement.offsetWidth;
		winH = document.documentElement.offsetHeight;
	}
	if (window.innerWidth && window.innerHeight) {
		winW = window.innerWidth;
		winH = window.innerHeight;
	}

	// assemble the data sent to the server
	finalData += '?_reqtime='+ (Math.round(new Date().valueOf() / 1000).toString());
	finalData += '&_browserX='+winW;
	finalData += '&_browserY='+winH;
	finalData += '&_os='+encodeURIComponent(navigator.platform);
	
	if(!core.doBase64)
	{
		finalData += '&no_base64=true';
	}


	// prepare navState
	var finalNavState = [];
	for(var key in core.navState){
		//alert('setting state: '+key+':'+core.navState[key]);
		finalNavState.push(key+':'+core.navState[key]);
	}
	//alert(finalNavState.join('|'));
	//alert(finalNavState.join('|'));
	finalData += '&_navState='+encodeURIComponent(finalNavState.join('|'));

	var plugins = [];
	for(var i=0;i<navigator.plugins.length;i++){
		plugins.push(navigator.plugins[i].name);
	}
	finalData += '&_plugins='+encodeURIComponent(plugins.join(','));


	//add in the data
	if(typeof(data) == 'string')
		finalData += data;
	if(typeof(data) == 'object'){
		for(var key in data){
			finalData += '&'+key+'='+encodeURIComponent(data[key]);
		}
	}

	//~ jQuery.extend({
		//~ postJSON: function( url, data, callback) {
			//~ return jQuery.post(url, data, callback, "json");
		//~ }
	//~ });

	//perform the request
	//alert('abou to post: '+'app'+path);
	//alert(finalData);
	core.requestStartTime = new Date().valueOf();
	jQuery.post('/app'+path,finalData,function(jsondata){
		eval('core.jsonData = '+jsondata)
		jsondata = core.jsonData;
		core.netEndTime = new Date().valueOf();
		core.log('total network time: '+(core.netEndTime - core.requestStartTime));

		var mainChanged = false;
		// this loads the returned content into the appropriate positions
		// and executes any js sent
		var start = new Date().valueOf();
		if(jsondata.replace){
			for(var key in jsondata.replace){
				if(key == 'center')
					mainChanged=true;
				//core.log('new content for '+key);
				if(core.doBase64 == true)
					var tmp = core.base64_decode(jsondata.replace[key]);
				else
					var tmp = jsondata.replace[key];
				//var tmp = Base64.decode(jsondata.replace[key]);
				$('#'+key).html(tmp);
			}
		}
		if(jsondata.append){
			for(var key in jsondata.append){
				//core.log(core.base64_decode(jsondata.append[key]));
				if(core.doBase64 == true)
					var tmp = core.base64_decode(jsondata.append[key]);
				else
					var tmp = jsondata.append[key];
				//var tmp = Base64.decode(jsondata.append[key])
				$('#'+key).append(tmp);
			}
		}
		var end = new Date().valueOf();
		core.log('total markup parse/insert time: '+(end - start))
		//alert('replace/append complete');

		core.cleanupStartTime = new Date().valueOf();


		var title = jsondata.title;
		if(core.doBase64)
			title = Base64.decode(title);
		if(title != ''){
			//alert('trying to set title');
			document.title=title;
			//alert('title append done');
		}
		var desc = jsondata.description;
		if(core.doBase64)
			desc = Base64.decode(desc);
		if(desc != '')
			$('meta[name=description]').attr('content',desc);
		//alert('meta description append done');
		var keywords = jsondata.title;
		if(core.doBase64)
			keywords = Base64.decode(keywords);
		if(keywords != '')
			$('meta[name=keywords]').attr('keywords',keywords);
		//alert('meta keywordss append done');

		core.fixDropDown();

		//$('#loading').hide();
		//alert(Base64.decode(jsondata.js));
		//core.log(Base64.decode(jsondata.js));
		if(mainChanged){
			if(core.ui)
				core.ui.scrollTop();
		}
		try{
			if(core.doBase64 == true)
				eval(core.base64_decode(jsondata.js));
			else
				eval(jsondata.js);
		}
		catch(e){
			//alert('could not eval: '

			//~ var js = new String(core.base64_decode(jsondata.js)).split(/;/);
			//~ for (i = 0; i < js.length; i++)
			//~ {
				//~ try{
					//~ eval(js[i]+';');
				//~ }catch(e2){
					//~ if(core.ui)
						//~ core.ui.error('An error has occured. Our technical team is on it.');
					//~ else
						//~ alert('An error has occured. Our technical team is on it.');
					//~ //alert('fail 2: '+js[i]);
					//~ //core.alertHash(e);
				//~ }
			//~ }
			//~
			//~
			//~
			//~ core.alertHash(e);
		}
		core.jqInit();

		core.cleanupEndTime = new Date().valueOf();
		core.log('cleanup time: '+(core.cleanupEndTime - core.cleanupStartTime));

		core.requestEndTime = new Date().valueOf();
		core.log('total request time: '+(core.requestEndTime - core.requestStartTime))
	}, "text");
}


core.base64_encode=function(data) {
    var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
        ac = 0,
        enc = "",
        tmp_arr = [];

    if (!data) {
        return data;
    }

    do { // pack three octets into four hexets
        o1 = data.charCodeAt(i++);
        o2 = data.charCodeAt(i++);
        o3 = data.charCodeAt(i++);

        bits = o1 << 16 | o2 << 8 | o3;

        h1 = bits >> 18 & 0x3f;
        h2 = bits >> 12 & 0x3f;
        h3 = bits >> 6 & 0x3f;
        h4 = bits & 0x3f;

        // use hexets to index into b64, and append result to encoded string
        tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
    } while (i < data.length);

    enc = tmp_arr.join('');

    var r = data.length % 3;

    return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);

}

core.log=function(logString){
	if (window.console && console.log) {
		console.log(logString);
	}else{
	}
}



// the base64_encode/decode are used to escape all data sent back from the server
core.base64_decode=function(data) {

	var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,ac = 0,dec = "",tmp_arr = [];

	if (!data) {
		return data;
	}

	data += '';

	do { // unpack four hexets into three octets using index points in b64
		h1 = b64.indexOf(data.charAt(i++));
		h2 = b64.indexOf(data.charAt(i++));
		h3 = b64.indexOf(data.charAt(i++));
		h4 = b64.indexOf(data.charAt(i++));

		bits = h1 << 18 | h2 << 12 | h3 << 6 | h4;

		o1 = bits >> 16 & 0xff;
		o2 = bits >> 8 & 0xff;
		o3 = bits & 0xff;

		if (h3 == 64) {
			tmp_arr[ac++] = String.fromCharCode(o1);
		} else if (h4 == 64) {
			tmp_arr[ac++] = String.fromCharCode(o1, o2);
		} else {
			tmp_arr[ac++] = String.fromCharCode(o1, o2, o3);
		}
	} while (i < data.length);

	dec = tmp_arr.join('');
	dec = core.utf8_decode(dec);

	return dec;
}

core.utf8_decode=function(str_data) {

	var tmp_arr = [],i = 0,ac = 0,c1 = 0,c2 = 0,c3 = 0;

	str_data += '';

	while (i < str_data.length) {
		c1 = str_data.charCodeAt(i);
		if (c1 < 128) {
			tmp_arr[ac++] = String.fromCharCode(c1);
			i++;
		} else if (c1 > 191 && c1 < 224) {
			c2 = str_data.charCodeAt(i + 1);
			tmp_arr[ac++] = String.fromCharCode(((c1 & 31) << 6) | (c2 & 63));
			i += 2;
		} else {
			c2 = str_data.charCodeAt(i + 1);
			c3 = str_data.charCodeAt(i + 2);
			tmp_arr[ac++] = String.fromCharCode(((c1 & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
			i += 3;
		}
	}

	return tmp_arr.join('');
}


/*
var c64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.split('');
var l64 = {}, i, k;

for (i=0; i<64; i++)
	l64[c64[i]] = i;

core.b64=function(s) {
	var b=0, c, i, l=0, r='';
	for (i=0; i<s.length; i++) {
		c = s.charCodeAt(i) % 256;
		b = (b<<8) + c;
		l += 8;
		while (l >= 6)
			r += c64[(b>>(l-=6))%64];
	}
	if (l > 0)
		r += c64[((b%16)<<(6-l))%64];
	if (l != 0) while (l < 6)
		r += '=', l += 2;
	return r;
}

core.base64bff=function(s) {
	var b=0, c, i, l=0, r='';
	for (i=0; i<s.length; i++) {
		c = l64[s.charAt(i)];
		if (isNaN(c))
			continue;
		b = (b<<6) + c;
		l += 6;
		while (l >= 8)
			r += String.fromCharCode((b>>>(l-=8))%256);
	}
	return r;
}

core.base64_encode=function(s) {
	var r = '';
	for (var i=0; i<s.length; i+=54) {
		r += core.b64(s.substring(i, i+54)) + '\r\n';
	}
	return r;
}

core.base64_decode=function(s) {
	var r = '';
	s = s.replace(/[^A-Za-z0-9+\/]+/g, '');
	for (var i=0; i<s.length; i+=72) {
		r += core.base64bff(s.substring(i, i+72));
	}
	return r;
}
*/


jQuery.fn.outerHTML = function() {
    return $('<div>').append( this.eq(0).clone() ).html();
};

core.alertHash=function(myHash,depth,noRecurse){
	depth = parseInt(depth);
	if(isNaN(depth))
		depth = 0;
	var s='';
	var doDepth=function(numLevels){
		var r = '';
		for (var i = 0; i < numLevels; i++)
			r += '\t';
		return r;
	}
	for(var key in myHash){
		if(typeof(myHash[key]) == 'object' && noRecurse)
			s+=doDepth(depth)+key+':{object}\n';
		else if(typeof(myHash[key]) == 'object')
			s+=doDepth(depth)+key+':{\n'+core.alertHash(myHash[key],(depth+1))+doDepth(depth)+'}\n';
		else
			s+=doDepth(depth)+key+':'+myHash[key]+'\n';
	}
	if(depth == 0)
		alert(s);
	else
		return s;
}

core.preloadImages=function(){
	for (var i = 0; i < arguments.length; i++){
		var imgPath = core.baseUrl+'img/'+arguments[i];
		if(!core.images[imgPath]){
			core.images[imgPath] = new Image();
			core.images[imgPath].src = core.baseUrl+'img/'+arguments[i];
		}
	}
}

core.loadLibrary=function(filetype,filename){
	if (filetype=="js"){ //if filename is a external JavaScript file
		var fileref=document.createElement('script')
		fileref.setAttribute("type","text/javascript");
		fileref.setAttribute("src", core.baseUrl + filetype + '/'+filename+'?time='+(new Date().valueOf()))
	}
	else if (filetype=="css"){ //if filename is an external CSS file
		var fileref=document.createElement("link")
		fileref.setAttribute("rel", "stylesheet")
		fileref.setAttribute("type", "text/css")
		fileref.setAttribute("href", core.baseUrl + filetype + '/'+filename+'?time='+(new Date().valueOf()))
	}
	if (typeof fileref!="undefined")
		document.getElementsByTagName("head")[0].appendChild(fileref)
}

core.fixDropDown=function() {
	$('a.dropdown-toggle, .dropdown-menu a').on('touchstart', function(e) {
	  e.stopPropagation();
	});
};

core.loadQuery=function(){
	var parts = document.location.hash.split('?');
	if (parts && parts.length > 1) {
		$(parts[1].split('&')).each(function () {
			var value = this.split('=');
			core.query[value[0]] = value[1];
		});
	}
	
	if (core.query.temp_style && core.query.width && core.query.height) {
		
		$('#less-css').attr('href', 'css/less.php?temp=true&reload=' + new Date().getTime());
	
		if (window.resizeTo) {
			setTimeout( function () {
				//alert(parentWin.document.head.getElementsByTagName('title').innerHTML);
				//alert('' + Math.floor(parentWin.width()*0.8) +',' + Math.floor(parentWin.height()*0.8));
				window.resizeTo(core.query.width,core.query.height);
			}, 700);
		}
	}
}

/*$(document).click(function (evt){
	if (!$(evt.srcElement).hasClass('datepicker') && $(evt.srcElement).parents('.datePicker').length < 1) {
		$('#datePicker').hide();
	}
});*/

core.loadQuery();
//~ loadjscssfile("myscript.js", "js") //dynamically load and add this .js file
//~ loadjscssfile("javascript.php", "js") //dynamically load "javascript.php" as a JavaScript file
//~ loadjscssfile("mystyle.css", "css") ////dynamically load and add this .css file


/*
Copyright (c) 2008 Fred Palmer fred.palmer_at_gmail.com

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
function StringBuffer()
{
    this.buffer = [];
}

StringBuffer.prototype.append = function append(string)
{
    this.buffer.push(string);
    return this;
};

StringBuffer.prototype.toString = function toString()
{
    return this.buffer.join("");
};

var Base64 =
{
    codex : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",

    encode : function (input)
    {
        var output = new StringBuffer();

        var enumerator = new Utf8EncodeEnumerator(input);
        while (enumerator.moveNext())
        {
            var chr1 = enumerator.current;

            enumerator.moveNext();
            var chr2 = enumerator.current;

            enumerator.moveNext();
            var chr3 = enumerator.current;

            var enc1 = chr1 >> 2;
            var enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
            var enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
            var enc4 = chr3 & 63;

            if (isNaN(chr2))
            {
                enc3 = enc4 = 64;
            }
            else if (isNaN(chr3))
            {
                enc4 = 64;
            }

            output.append(this.codex.charAt(enc1) + this.codex.charAt(enc2) + this.codex.charAt(enc3) + this.codex.charAt(enc4));
        }

        return output.toString();
    },

    decode : function (input)
    {
        var output = new StringBuffer();

        var enumerator = new Base64DecodeEnumerator(input);
        while (enumerator.moveNext())
        {
            var charCode = enumerator.current;

            if (charCode < 128)
                output.append(String.fromCharCode(charCode));
            else if ((charCode > 191) && (charCode < 224))
            {
                enumerator.moveNext();
                var charCode2 = enumerator.current;

                output.append(String.fromCharCode(((charCode & 31) << 6) | (charCode2 & 63)));
            }
            else
            {
                enumerator.moveNext();
                var charCode2 = enumerator.current;

                enumerator.moveNext();
                var charCode3 = enumerator.current;

                output.append(String.fromCharCode(((charCode & 15) << 12) | ((charCode2 & 63) << 6) | (charCode3 & 63)));
            }
        }

        return output.toString();
    }
}


function Utf8EncodeEnumerator(input)
{
    this._input = input;
    this._index = -1;
    this._buffer = [];
}

Utf8EncodeEnumerator.prototype =
{
    current: Number.NaN,

    moveNext: function()
    {
        if (this._buffer.length > 0)
        {
            this.current = this._buffer.shift();
            return true;
        }
        else if (this._index >= (this._input.length - 1))
        {
            this.current = Number.NaN;
            return false;
        }
        else
        {
            var charCode = this._input.charCodeAt(++this._index);

            // "\r\n" -> "\n"
            //
            if ((charCode == 13) && (this._input.charCodeAt(this._index + 1) == 10))
            {
                charCode = 10;
                this._index += 2;
            }

            if (charCode < 128)
            {
                this.current = charCode;
            }
            else if ((charCode > 127) && (charCode < 2048))
            {
                this.current = (charCode >> 6) | 192;
                this._buffer.push((charCode & 63) | 128);
            }
            else
            {
                this.current = (charCode >> 12) | 224;
                this._buffer.push(((charCode >> 6) & 63) | 128);
                this._buffer.push((charCode & 63) | 128);
            }

            return true;
        }
    }
}

function Base64DecodeEnumerator(input)
{
    this._input = input;
    this._index = -1;
    this._buffer = [];
}

Base64DecodeEnumerator.prototype =
{
    current: 64,

    moveNext: function()
    {
        if (this._buffer.length > 0)
        {
            this.current = this._buffer.shift();
            return true;
        }
        else if (this._index >= (this._input.length - 1))
        {
            this.current = 64;
            return false;
        }
        else
        {
            var enc1 = Base64.codex.indexOf(this._input.charAt(++this._index));
            var enc2 = Base64.codex.indexOf(this._input.charAt(++this._index));
            var enc3 = Base64.codex.indexOf(this._input.charAt(++this._index));
            var enc4 = Base64.codex.indexOf(this._input.charAt(++this._index));

            var chr1 = (enc1 << 2) | (enc2 >> 4);
            var chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
            var chr3 = ((enc3 & 3) << 6) | enc4;

            this.current = chr1;

            if (enc3 != 64)
                this._buffer.push(chr2);

            if (enc4 != 64)
                this._buffer.push(chr3);

            return true;
        }
    }
};
