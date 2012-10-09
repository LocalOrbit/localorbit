/**
 * Handle: Umapper
 * Version: 0.8.0
 * Deps: UmapperAjax, jquery, gettext
 * Enqueue: true
 */

var Umapper = function(){}

Umapper.prototype = {
    pluginUri : '',
    options           : {},
    
    showInsertDialog        : function(sizeSelected, alignSelected, sizeWSelected, sizeHSelected)
    {
        if(!umapper.pluginUri) return false; // do not allow to load dialog till prepareInsertDialog is run
        umapper.checkUmapperMapSave();
        sizeSelected = sizeSelected ? sizeSelected : 'size_s';
        alignSelected = alignSelected ? alignSelected : 'alignment_center';
        
        if(document.getElementById(sizeSelected)){
            document.getElementById(sizeSelected).checked = true;
        }
        if(document.getElementById(alignSelected)){
            document.getElementById(alignSelected).checked = true;
        }
        
        // update custom dimentsions
        if(sizeSelected == 'size_c') {
            if(sizeWSelected) {
                document.getElementById('w').value = sizeWSelected;
            }
            document.getElementById('w').disabled = false;
            if(sizeHSelected) {
                document.getElementById('h').value = sizeHSelected;
            }
            document.getElementById('h').disabled = false;
        }
        
        document.getElementById('put_dialog').style.display = 'block';
        document.getElementById('put_background').style.display = 'block';
    },
    
    prepareInsertDialog     : function(pluginUri)
    {
        this.pluginUri = pluginUri;
        
        // assign size/alignment onChange functions
        var alignments = ['alignment_none', 'alignment_left', 'alignment_center', 'alignment_right'];
        for(var i=0;i<alignments.length;i++) {
        	document.getElementById(alignments[i]).onchange = umapper.changeMapAlignment;
        	document.getElementById(alignments[i]).onchange = umapper.changeMapAlignment;
        	document.getElementById(alignments[i]).onchange = umapper.changeMapAlignment;
        	document.getElementById(alignments[i]).onchange = umapper.changeMapAlignment;
        }
        
        var sizes = ['size_sq', 'size_t', 'size_s', 'size_m', 'size_l', 'size_c'];
        for(var i=0;i<sizes.length;i++) {
        	document.getElementById(sizes[i]).onchange = umapper.changeMapSize;
        	document.getElementById(sizes[i]).onchange = umapper.changeMapSize;
        	document.getElementById(sizes[i]).onchange = umapper.changeMapSize;
        	document.getElementById(sizes[i]).onchange = umapper.changeMapSize;
        }
        
        // pre-load necessary images
        new Image().src = pluginUri+'/content/img/alignment_none.png';
        new Image().src = pluginUri+'/content/img/alignment_left.png';
        new Image().src = pluginUri+'/content/img/alignment_center.png';
        new Image().src = pluginUri+'/content/img/alignment_right.png';
        
        new Image().src = pluginUri+'/content/img/size_sq.png';
        new Image().src = pluginUri+'/content/img/size_t.png';
        new Image().src = pluginUri+'/content/img/size_s.png';
        new Image().src = pluginUri+'/content/img/size_m.png';
        new Image().src = pluginUri+'/content/img/size_l.png';
        new Image().src = pluginUri+'/content/img/size_c.png';
        
        
    },
    
    changeMapSize           : function () 
    {
        var sizes = document.getElementsByName('size');
        var size = null;
        for(var i=0;i<sizes.length;i++) {
            if(sizes[i].checked) {
                size = sizes[i].value;
                break;
            }
        }

        // make sure that size dims are availalbe only in custom size maps
        document.getElementById('w').disabled = (size == 'c') ? false : true;  
        document.getElementById('h').disabled = (size == 'c') ? false : true;  
        
        if(size && document.getElementById('size_image').getAttribute('rel') != size) {
            document.getElementById('size_preview').innerHTML = '<img id="size_image" rel="'+size+'" src="'+umapper.pluginUri+'/content/img/size_'+size+'.png" alt=""/>';
        }
    },
    
    changeMapAlignment         : function() 
    {
        var alignments = document.getElementsByName('alignment');
        var alignment = null;
        for(var i=0;i<alignments.length;i++) {
            if(alignments[i].checked) {
                alignment = alignments[i].value;
                break;
            }
        }
        if(alignment && document.getElementById('alignment_image').getAttribute('rel') != alignment) {
            document.getElementById('alignment_preview').innerHTML = '<img id="alignment_image" rel="'+alignment+'" src="'+umapper.pluginUri+'/content/img/alignment_'+alignment+'.png" alt=""/>';
        }
    },
    
    cancelMapInsert         : function()
    {
        document.getElementById('put_dialog').style.display = 'none';
        document.getElementById('put_background').style.display = 'none';
    },
    
    insertMapTag            : function(frm)
    {
        var collection = jQuery(frm).find("input:not(input:button):not(input:submit):not(input:radio):not(input:disabled),input:radio:checked");
        var $this = this;
        collection.each(function () {
            $this['options'][this.name] = this.value;
        });
        top.send_to_editor(this.insertTagGenerator());
        top.tb_remove();
    },
    
    insertTagGenerator      : function()
    {
        var content = this['options']['content'];
        delete this['options']['content'];
        
        var attrs = '';
        jQuery.each(this['options'], function(name, value){
            if (value != '') {
                attrs += ' ' + name + '="' + value + '"';
            }
        });
        return '[umap' + attrs + ']';    
        //return '[umap' + attrs + ']' + content + '[/umap]'    
    },
    getCheckedValue         : function(radioObj) 
    {
    	if(!radioObj)
    		return "";
    	var radioLength = radioObj.length;
    	if(radioLength == undefined)
    		if(radioObj.checked)
    			return radioObj.value;
    		else
    			return "";
    	for(var i = 0; i < radioLength; i++) {
    		if(radioObj[i].checked) {
    			return radioObj[i].value;
    		}
    	}
    	return "";
    },
    parseShortTag           : function(tag)
    {
        var shortTag = new UmapperString(tag);
        qs = '';
        qs += shortTag.contains("id") ? '&map_id=' + shortTag.get("id") : '';
        qs += shortTag.contains("size") ? '&map_size=' +  shortTag.get("size") : '';
        qs += shortTag.contains("alignment") ? '&map_alignment=' +  shortTag.get("alignment") : '';
        qs += shortTag.contains("w") ? '&map_w=' +  shortTag.get("w") : '';
        qs += shortTag.contains("h") ? '&map_h=' +  shortTag.get("h") : '';
        return qs;        
    },
    redirect                : function(uri, box)
    {
        // show msgbox
        document.getElementById('msg_box_dialog').innerHTML = document.getElementById('msg_box_' + box).innerHTML;
        document.getElementById('msg_box_background').style.display = 'block';
        document.getElementById('msg_box_dialog').style.display = 'block';
        
        document.location = uri;    
    },
    getFlashMovie           : function(movieName)
    {
    	var isIE = navigator.appName.indexOf("Microsoft") != -1;
    	return (isIE) ? window[movieName] : document[movieName];
    },
    checkUmapperMapSave     : function()
    {
    	var saved = umapper.getFlashMovie("editor").isMapSaved();
    	
    	if(!saved)
    	{
    		if(confirm("Map is not saved, any chages you made will be lost!\n\nPress [OK] to save your changes or [CANCEL] to continue."))
    		{
    			umapper.getFlashMovie("editor").saveMap();
    		}
    	}
    }
}
umapper = new Umapper();

// UMapper Map editor configuration
// Major version of Flash required
var umap_requiredMajorVersion = 9;
// Minor version of Flash required
var umap_requiredMinorVersion = 0;
// Minor version of Flash required
var umap_requiredRevision = 28;