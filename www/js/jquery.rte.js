/*
* jQuery RTE plugin 0.5.1 - create a rich text form for Mozilla, Opera, Safari and Internet Explorer
*
* Copyright (c) 2009 Batiste Bieler
* Distributed under the GPL Licenses.
* Distributed under the MIT License.
*/

// define the rte light plugin
(function($) {

if(typeof $.fn.rte === "undefined") {

    var defaults = {
        media_url: "",
        useImagePicker:true,
        content_css_url: "rte.css",
        dot_net_button_class: null,
			max_height: 350,
			width:300,
			height:200
        
    };

    $.fn.rte = function(options) {

    $.fn.rte.html = function(iframe) {
        return iframe.contentWindow.document.getElementsByTagName("body")[0].innerHTML;
    };

    // build main options before element iteration
    var opts = $.extend(defaults, options);

    // iterate and construct the RTEs
    return this.each( function() {
        var textarea = $(this);
        var iframe;
        var element_id = textarea.attr("id");
			
        // enable design mode
        function enableDesignMode() {
			   var content = textarea.val();

            // Mozilla needs this to display caret
            if($.trim(content)=='') {
                content = '<br />';
            }

            // already created? show/hide
            if(iframe) {
                console.log("already created");
                textarea.hide();
                $(iframe).contents().find("body").html(content);
                $(iframe).show();
                $("#toolbar-" + element_id).remove();
                textarea.before(toolbar());
                return true;
            }

            // for compatibility reasons, need to be created this way
            iframe = document.createElement("iframe");
            iframe.name='rteEditor';
            iframe.setAttribute('id','rteEditor-id');
            iframe.frameBorder=0;
            iframe.frameMargin=0;
            iframe.framePadding=0;
            iframe.height=parseInt(opts.height)+5;
            iframe.width=parseInt(opts.width)+5;
            if(textarea.attr('class'))
                iframe.className = textarea.attr('class');
            if(textarea.attr('id')){
                iframe.id = element_id+'-iframe';
                //alert(element_id+'-iframe');
				 }
            if(textarea.attr('name'))
                iframe.title = textarea.attr('name');

            textarea.after(iframe);

            var css = "";
            if(opts.content_css_url) {
                css = "<link type='text/css' rel='stylesheet' href='" + opts.content_css_url + "' />";
            }

            var doc = "<html><head>"+css+"</head><body class='frameBody'>"+content+"</body></html>";
            tryEnableDesignMode(doc, function() {
                $("#toolbar-" + element_id).remove();
                textarea.before(toolbar());
                // hide textarea
                textarea.hide();

            });

        }

        function tryEnableDesignMode(doc, callback) {
            if(!iframe) { return false; }

            try {
                iframe.contentWindow.document.open();
                iframe.contentWindow.document.write(doc);
                iframe.contentWindow.document.close();
            } catch(error) {
                //console.log(error);
            }
            if (document.contentEditable) {
                iframe.contentWindow.document.designMode = "On";
                callback();
                return true;
            }
            else if (document.designMode != null) {
                try {
                    iframe.contentWindow.document.designMode = "on";
                    callback();
                    return true;
                } catch (error) {
                    //console.log(error);
                }
            }
            setTimeout(function(){tryEnableDesignMode(doc, callback)}, 500);
            return false;
        }

        function disableDesignMode(submit) {
				$('#image_area').hide();
				var content = $(iframe).contents().find("body").html();

				if($(iframe).is(":visible")) {
					textarea.val(content);
				}

				if(submit !== true) {
					textarea.show();
					$(iframe).hide();
				}
        }

        // create toolbar and bind events to it's elements
        function toolbar() {
			  var imageButton = '';
			 // alert(opts.useImagePicker);
			  if(opts.useImagePicker){
				  imageButton = "<a href='#' class='image' title='Add an image'><img src='"+opts.media_url+"/image_small.png'	 alt='image' /></a>";
			  }
            var tb = $("<div class='rte-toolbar' id='toolbar-"+ element_id +"'><div>\
                <p>\
                    <select>\
                        <option value=''>Block style</option>\
                        <option value='p'>Paragraph</option>\
                        <option value='h3'>Title</option>\
                        <option value='address'>Address</option>\
                    </select>\
                    <a href='#' class='bold' title='Bold font'><img src='"+opts.media_url+"/bold.png?time=23' alt='bold' /></a>\
                    <a href='#' class='italic' title='Italic font'><img src='"+opts.media_url+"/italic.png?time=23' alt='italic' /></a>\
                    <a href='#' class='unorderedlist' title='Make a list'><img src='"+opts.media_url+"/unordered.png' alt='unordered list' /></a>\
                    <a href='#' class='link' title='Make a link'><img src='"+opts.media_url+"/link.png' alt='link' /></a>\
                    "+imageButton+"\
                    <a href='#' class='disable' id='codeEditLink' title='Edit the code'>HTML</a>\
                </p></div></div>");
            //<img src='"+opts.media_url+"new/edit.png' width='26' height='26' alt='close rte' />

            $('select', tb).change(function(){
                var index = this.selectedIndex;
                if( index!=0 ) {
                    var selected = this.options[index].value;
                    formatText("formatblock", '<'+selected+'>');
                }
            });
            $('.bold', tb).click(function(){ formatText('bold');return false; });
            $('.italic', tb).click(function(){ formatText('italic');return false; });
            $('.unorderedlist', tb).click(function(){ formatText('insertunorderedlist');return false; });
            $('.link', tb).click(function(){
                var p=prompt("URL:");
                if(p){
						 
						if(new String(p).toLowerCase().indexOf('http') < 0)
                    formatText('CreateLink',  'http://'+p);
                  else
							formatText('CreateLink',p);
					  }
                return false; });

            $('.image', tb).click(function(){
					$('#image_area').toggle();
                //~ var p=prompt("image URL:");
                //~ if(p){
						 //~ // style="float:left;"
						//~ var html = '<img style="float:left;margin: 15px;" src="'+p+'">';
						//~ //alert(html);
						//~ if (document.all) {
							//~ 
							//~ var obj = window.frames.rteEditor;
							//~ window.frames.rteEditor.focus();
//~ 
							//~ var oRng = window.frames.rteEditor.document.selection.createRange( );
							//~ 
							//~ oRng.pasteHTML(html);
							//~ oRng.collapse(false);
							//~ oRng.select();
						//~ } else {
							//~ //alert('execCommant');
							//~ iframe.contentWindow.document.execCommand('insertHTML', false, html);
						//~ }
					//~ }
                //if(p)
                //    formatText('InsertImage',  p+"" + '"' + " ID=myGif border=1");
                    
                    //p+" style=float:left;");
                return false; });

            $('.disable', tb).click(function() {
                disableDesignMode();
                var edm = $('<a class="rte-edm" id="previewLink" href="#">Preview</a>');
                tb.empty().append(edm);
                edm.click(function(e){
                    e.preventDefault();
                    enableDesignMode();
                    // remove, for good measure
                    $(this).remove();
                });
                return false;
            });

            // .NET compatability
            if(opts.dot_net_button_class) {
                var dot_net_button = $(iframe).parents('form').find(opts.dot_net_button_class);
                dot_net_button.click(function() {
                    disableDesignMode(true);
                });
            // Regular forms
            } else {
                $(iframe).parents('form').submit(function(){
                    disableDesignMode(true);
                });
            }

            var iframeDoc = $(iframe.contentWindow.document);

            var select = $('select', tb)[0];
            iframeDoc.mouseup(function(){
                setSelectedType(getSelectionElement(), select);
                return true;
            });

            iframeDoc.keyup(function() {
                setSelectedType(getSelectionElement(), select);
                var body = $('body', iframeDoc);
                if(body.scrollTop() > 0) {
                    var iframe_height = parseInt(iframe.style['height'])
                    if(isNaN(iframe_height))
                        iframe_height = 0;
                    var h = Math.min(opts.max_height, iframe_height+body.scrollTop()) + 'px';
                    iframe.style['height'] = h;
                }
                return true;
            });

            return tb;
        };

        function formatText(command, option) {
            iframe.contentWindow.focus();
            try{
                iframe.contentWindow.document.execCommand(command, false, option);
            }catch(e){
                //console.log(e)
            }
            iframe.contentWindow.focus();
        };

        function setSelectedType(node, select) {
            while(node.parentNode) {
                var nName = node.nodeName.toLowerCase();
                for(var i=0;i<select.options.length;i++) {
                    if(nName==select.options[i].value){
                        select.selectedIndex=i;
                        return true;
                    }
                }
                node = node.parentNode;
            }
            select.selectedIndex=0;
            return true;
        };

        function getSelectionElement() {
            if (iframe.contentWindow.document.selection) {
                // IE selections
                selection = iframe.contentWindow.document.selection;
                range = selection.createRange();
                try {
                    node = range.parentElement();
                }
                catch (e) {
                    return false;
                }
            } else {
                // Mozilla selections
                try {
                    selection = iframe.contentWindow.getSelection();
                    range = selection.getRangeAt(0);
                }
                catch(e){
                    return false;
                }
                node = range.commonAncestorContainer;
            }
            return node;
        };
        
        // enable design mode now
        enableDesignMode();

    }); //return this.each
    
    }; // rte

} // if

})(jQuery);

/*
lo2.addImageToRTE=function(p,direction){
	var iframe = lo2('rte-iframe');
	//alert(iframe);
	 // style="float:left;"
	 //<div style="float:'+direction+';margin: 15px;">
	if(direction == 'center'){
		var html = '<center><img src="http://'+location.hostname+'/'+p+'" /></center>';
	}else{
		var html = '<img style="float:'+direction+';margin: 15px;" src="http://'+location.hostname+'/'+p+'" />';
	}
	
	if(document.newsletterForm){
		if(document.newsletterForm.image_header){
			document.newsletterForm.image_header.value=html;
			document.getElementById('image_preview').innerHTML = '\
				<br /><b>This image will be placed at the top of the newsletter email: </b><br />\
				'+html+' \
				<div style="clear:both;">&nbsp;</div><a href="Javascript:$(\'#image_area\').toggle();">Change photo</a>';
				
		}
	}
	//alert(html);
	if (document.all) {
		
		var obj = window.frames.rteEditor;
		window.frames.rteEditor.focus();

		var oRng = window.frames.rteEditor.document.selection.createRange( );
		
		oRng.pasteHTML(html);
		oRng.collapse(false);
		oRng.select();
	} else {
		//alert('execCommant');
		iframe.contentWindow.document.execCommand('insertHTML', false, html);
	}
	$('#image_area').hide();
}
*/

function addUrlImage(formObj){
	var p = formObj.imageUrl.value;
	if(p){
		 // style="float:left;"
		var html = '<img style="float:left;margin: 15px;" src="'+p+'">';
		//alert(html);
		if (document.all) {
			
			var obj = window.frames.rteEditor;
			window.frames.rteEditor.focus();

			var oRng = window.frames.rteEditor.document.selection.createRange( );
			
			oRng.pasteHTML(html);
			oRng.collapse(false);
			oRng.select();
		} else {
			//alert('execCommant');
			window.frames.rteEditor.focus();
			document.getElementById('rte-iframe').contentWindow.document.execCommand('insertHTML', false, html);
		}
	}
	$('#image_area').hide();
}