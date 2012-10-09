/**
 * Handle: UmapperAjax
 * Version: 1.0.1
 * Deps: sack
 * Enqueue: true
 */

var UmapperAjax = function() // constructor
{
    this.sack = new sack();
    this.sack.method = 'POST';
	this.sack.onLoading = this.whenLoading;
	this.sack.onLoaded = this.whenLoaded; 
	this.sack.onInteractive = this.whenInteractive;
	this.sack.onCompletion = this.whenCompleted;
	
	this.sack.setVar("ajax", 1);
}

UmapperAjax.prototype = {
    options             : {},
    
    /**
     * Post rpc hook functions (could be assigned on per call basis)
     */
    postHookSuccess     : '', // function to be executed on success
    postHookFailure     : '', // function to be executed on failure
    
    /**
     * Optional parameter, holds the current base uri
     */
    baseUri             : '',
    
    /**
     * API-KEY to access Umapper servers
     */
    apiKey             : '',
    
    /**
     * AJAX method call
     */
    call                : function(method, requestFile)
    {
        this.sack.setVar("method", method);
        
        if(requestFile) {
            this.sack.requestFile = requestFile;
        }
        this.sack.runAJAX();
        
    },
    
    verifyApiKey        : function(apiKey)
    {
        if(!apiKey) {
            alert("Please enter API key!");
            return false;
        }
        this.sack.setVar("key", apiKey);
        this.sack.element = "umapper-ajax-messages";
        this.call('verifyApiKey');
        return true;
    },
    testConnection        : function(user, pass, apiKey)
    {
        if(!apiKey) {
            alert("Please enter API key!");
            return false;
        }
        if(!user) {
            alert("Please enter Integrator's username!");
            return false;
        }
        if(!pass) {
            alert("Please enter valid password!");
            return false;
        }
        this.sack.setVar("user", user);
        this.sack.setVar("pass", pass);
        this.sack.setVar("key", apiKey);
        this.sack.element = "umapper-ajax-messages";
        this.call('testConnection');
        return true;
    },
    saveMapMeta         : function(baseUri, mapId, apiKey, mapTitle, mapDesc, providerId)
    {
        if(!mapTitle) {
            alert("Please enter map title!");
            return false;
        }
        
        if(!mapDesc){
            alert("Please enter map description!");
            return false;
        }

        if(!providerId){
            alert("Please select map provider!");
            return false;
        }
        
        // show msgbox
        document.getElementById('msg_box_dialog').innerHTML = document.getElementById('msg_box_save_map').innerHTML;
        document.getElementById('msg_box_background').style.display = 'block';
        document.getElementById('msg_box_dialog').style.display = 'block';
        
        this.sack.setVar("key", apiKey);
        this.sack.setVar("mapId", mapId);
        this.sack.setVar("mapTitle", mapTitle);
        this.sack.setVar("mapDesc", mapDesc);
        this.sack.setVar("providerId", providerId);
        this.sack.element = "umapper-ajax-messages";
        this.call('saveMapMeta');
        
        return true;
        
    },
    createMap           : function(baseUri, apiKey, mapTitle, mapDesc, providerId)
    {
        if(!mapTitle) {
            alert("Please enter map title!");
            return false;
        }
        
        if(!mapDesc){
            alert("Please enter map description!");
            return false;
        }
        
        if(!providerId){
            alert("Please select map provider!");
            return false;
        }
        
        // show msgbox
        document.getElementById('msg_box_dialog').innerHTML = document.getElementById('msg_box_create_map').innerHTML;
        document.getElementById('msg_box_background').style.display = 'block';
        document.getElementById('msg_box_dialog').style.display = 'block';
        
        this.apiKey = apiKey;
        this.baseUri = baseUri;
        this.postHookSuccess = 'createMapSuccess'; // make sure that post processing is done
        
        this.sack.setVar("key", apiKey);
        this.sack.setVar("mapTitle", mapTitle);
        this.sack.setVar("mapDesc", mapDesc);
        this.sack.setVar("providerId", providerId);
        this.sack.element = "umapper-ajax-messages";
        this.call('createMap');
        
        return true;
    },
    
    createMapSuccess    : function(mapId, baseUri)
    {
        mapId = Number(mapId);
        
        var e = document.getElementById(this.sack.element);
        if((mapId!=0) && (mapId>0)){
            document.getElementById('msg_box_dialog').innerHTML = document.getElementById('msg_box_redirect_editor').innerHTML;
            //var divBtnSubmit = document.getElementById('divBtnSubmit');
            //var divBtnEditor = document.getElementById('divBtnEditor');
            //var btnEditor = document.getElementById('mapBtnEditor');
            
            //divBtnSubmit.style.display = 'none';
            //divBtnEditor.style.display = 'block';
            //btnEditor.onclick = function(){document.location = baseUri + 'tab=umapper_editor&map_id=' + mapId;};
            e.innerHTML = '';
            document.location = baseUri + 'tab=umapper_editor&map_id=' + mapId;
        } else {
            e.innerHTML = '<div class="error">Unexpected error occured..</div>';
            // hide msgbox
            document.getElementById('msg_box_background').style.display = 'none';
            document.getElementById('msg_box_dialog').style.display = 'none';
            document.getElementById('msg_box_dialog').innerHTML = '';
        }
        
    },
    deleteMap           : function(baseUri, apiKey, mapId)
    {
        if(!mapId) {
            alert("Map not found!");
            return false;
        }
        
        // show msgbox
        document.getElementById('msg_box_dialog').innerHTML = document.getElementById('msg_box_delete_map').innerHTML;
        document.getElementById('msg_box_background').style.display = 'block';
        document.getElementById('msg_box_dialog').style.display = 'block';
        
        this.apiKey = apiKey;
        this.baseUri = baseUri;
        this.postHookSuccess = 'deleteMapSuccess'; // make sure that post processing is done
        
        this.sack.setVar("key", apiKey);
        this.sack.setVar("mapId", mapId);
        this.sack.element = "umapper-ajax-messages";
        this.call('deleteMap');
        
        return true;
    
    },
    deleteMapSuccess    : function(numDeleted, baseUri)
    {
        numDeleted = Number(numDeleted);
        
        var e = document.getElementById(this.sack.element);
        if((numDeleted!=0) && (numDeleted>0)){
            document.getElementById('msg_box_dialog').innerHTML = document.getElementById('msg_box_redirect_maps').innerHTML;
            e.innerHTML = '';
            document.location = baseUri + 'tab=umapper_maps&refresh=1';
        } else {
            e.innerHTML = '<div class="error">Unexpected error occured..</div>';
            // hide msgbox
            document.getElementById('msg_box_background').style.display = 'none';
            document.getElementById('msg_box_dialog').style.display = 'none';
            document.getElementById('msg_box_dialog').innerHTML = '';
        }
    },
    whenLoading         : function()
    {
        var e = document.getElementById(umapperAjax.sack.element); 
        e.innerHTML = "<div>"
                    + "<div style='float:left;padding-top:1px;width:20px;'><img src='" + umapper.pluginUri + "content/img/indicator.gif' height='16' widht='16' alt=''/></div>"
                    + "<div style='float:left;margin-left:4px;'>sending request..</div>"
                    + "<div class='clear'></div></div>";
    },
    
    whenLoaded          : function()
    {
        var e = document.getElementById(umapperAjax.sack.element); 
        e.innerHTML = "<div>"
                    + "<div style='float:left;padding-top:1px;width:20px;'><img src='" + umapper.pluginUri + "content/img/indicator.gif' height='16' widht='16' alt=''/></div>"
                    + "<div style='float:left;margin-left:4px;'>request completed..</div>"
                    + "<div class='clear'></div></div>";
    },
    
    whenInteractive     : function()
    {
        var e = document.getElementById(umapperAjax.sack.element); 
        e.innerHTML = "<div>"
                    + "<div style='float:left;padding-top:1px;width:20px;'><img src='" + umapper.pluginUri + "content/img/indicator.gif' height='16' widht='16' alt=''/></div>"
                    + "<div style='float:left;margin-left:4px;'>waiting for response..</div>"
                    + "<div class='clear'></div></div>";
    },
    
    whenCompleted       : function()
    {
        var e = document.getElementById(umapperAjax.sack.element); 
        if(umapperAjax.postHookSuccess != ''){
            eval('umapperAjax.' + umapperAjax.postHookSuccess + '("' + this.response + '", "' + umapperAjax.baseUri + '")');
        }else{
            // hide msgbox
            document.getElementById('msg_box_background').style.display = 'none';
            document.getElementById('msg_box_dialog').style.display = 'none';
            document.getElementById('msg_box_dialog').innerHTML = '';
        }
        
        
        // intentionally blank - as we simply output the payload comming from rpc server
        /*
    	var e = document.getElementById(umapperAjax.sack.element); 
    	if (umapperAjax.sack.responseStatus){
    		var string = "<p>Status Code: " + umapperAjax.sack.responseStatus[0] + "</p><p>Status Message: " + umapperAjax.sack.responseStatus[1] + "</p><p>URLString Sent: " + umapperAjax.sack.URLString + "</p>";
    	} else {
    		var string = "<p>URLString Sent: " + umapperAjax.sack.URLString + "</p>";
    	}
    	e.innerHTML = string;	
    	*/
    }         
}

var umapperAjax = new UmapperAjax();

