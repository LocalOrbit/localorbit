/**
 * Handle: UmapperAjax
 * Version: 1.0.0
 * Deps: jquery, UmapperRpc, UmapperInit
 * Enqueue: true
 */
UmapperAjax = function(){};
UmapperAjax.prototype = {
    loadingMsg : function(status, msg)
    {
        msg = typeof(msg) != 'undefined' ? msg : umaptxt.REQ_BEING_PROCESSED;
        jQuery('#umapper-ajax-messages').html(msg);
        if(status) {
            jQuery('#umapper-ajax-messages').show('slow');
        } else {
            jQuery('#umapper-ajax-messages').hide('slow');
        }

    },
    createMap : function(mapTitle, mapDesc, providerId, embedTemplateId, callback, reconnect)
    {
        reconnect = typeof(reconnect) != 'undefined' ? reconnect : 1;
        umapperAjax.loadingMsg(true);
        jQuery.umap.rpc(umapperOptions.rpcUri, 'maps.createMap', [umapperOptions.rpcToken, umapperOptions.rpcKey, {
            'mapTitle' : mapTitle,
            'mapDesc' : mapDesc,
            'providerId' : parseInt(providerId),
            'embedTemplateId' : parseInt(embedTemplateId)
        }], function(resp){
            if((!resp.error) && resp.result) {
                umapperAjax.loadingMsg(false);
                callback(resp.result);
            } else if(resp.error.faultString == 'Expired session used..'){
                // try to reconnect
                if(reconnect == 1) { // to avoid recursion
                    umapperAjax.reconnect(function(){
                        umapperAjax.createMap(mapTitle, mapDesc, providerId, embedTemplateId, callback, 0);
                    });
                }
            }

        });
    },
    saveMapMeta : function(mapId, mapTitle, mapDesc, providerId, embedTemplateId, callback, reconnect)
    {
        reconnect = typeof(reconnect) != 'undefined' ? reconnect : 1;
        umapperAjax.loadingMsg(true);
        jQuery.umap.rpc(umapperOptions.rpcUri, 'maps.saveMapMeta', [umapperOptions.rpcToken, umapperOptions.rpcKey, parseInt(mapId), {
            'mapTitle' : mapTitle,
            'mapDesc' : mapDesc,
            'providerId' : parseInt(providerId),
            'embedTemplateId' : parseInt(embedTemplateId)
        }], function(resp){
            if((!resp.error) && resp.result) {
                umapperAjax.loadingMsg(false);
                callback(resp.result);
            } else if(resp.error.faultString == 'Expired session used..'){
                // try to reconnect
                if(reconnect == 1) { // to avoid recursion
                    umapperAjax.reconnect(function(){
                        umapperAjax.saveMapMeta(mapId, mapTitle, mapDesc, providerId, embedTemplateId, callback, 0);
                    });
                }
            }

        });
    },
    deleteMap : function(mapId, callback)
    {
        jQuery.umap.rpc(umapperOptions.rpcUri, 'maps.deleteMap', [umapperOptions.rpcToken, umapperOptions.rpcKey, parseInt(mapId)], function(resp){
            if((!resp.error) && resp.result) {
                callback(resp.result);
            }
        });
        return false;
    },
    getToken : function(apiKey, callback)
    {
        jQuery.umap.rpc(umapperOptions.rpcUri, 'maps.connectByKey', [apiKey], function(resp){
            if((!resp.error) && resp.result) {
                callback(resp.result);
            }
        });
        return false;
    },
    reconnect : function(callback) {

        umapperAjax.loadingMsg(true, umaptxt.OBTAIN_SESSION);
        umapperAjax.getToken(umapperOptions.rpcKey, function(token){
            // save token
            jQuery.ajax({
                "url": umapperOptions.rpcUri + '?update_option=umapper_token',
                "dataType": 'json',
                "type": "POST",
                "data": token,
                "success": function(resp) {
                    umapperOptions.rpcToken = token;
                    callback();
                },
                "processData": false,
                "contentType": "application/json"
            });
        });

    },
    getMapsCount : function(callback, reconnect)
    {
        reconnect = typeof(reconnect) != 'undefined' ? reconnect : 1;
        jQuery.umap.rpc(umapperOptions.rpcUri, 'maps.getMapsCount', [umapperOptions.rpcToken, umapperOptions.rpcKey], function(resp){
            if((!resp.error) && resp.result) {
                callback(resp.result);
            } else if(resp.error.faultString == 'Expired session used..'){
                // try to reconnect
                if(reconnect == 1) { // to avoid recursion
                    umapperAjax.reconnect(function(){
                        umapperAjax.getMapsCount(callback, 0);
                    });
                }
            }
        });
        return false;
    },
    getMapMeta : function(mapId, callback, reconnect)
    {
        reconnect = typeof(reconnect) != 'undefined' ? reconnect : 1;
        umapperAjax.loadingMsg(true);
        jQuery.umap.rpc(umapperOptions.rpcUri, 'maps.getMapMeta', [umapperOptions.rpcToken, umapperOptions.rpcKey, parseInt(mapId)], function(resp){
            if((!resp.error) && resp.result) {
                umapperAjax.loadingMsg(false);
                callback(resp.result);
            } else if(resp.error.faultString == 'Expired session used..'){
                // try to reconnect
                if(reconnect == 1) { // to avoid recursion
                    umapperAjax.reconnect(function(){
                        umapperAjax.getMapMeta(mapId, callback, 0);
                    });
                }
            }
        });
        return false;
        
    },
    getMaps : function(start, limit, callback)
    {
        umapperAjax.loadingMsg(true);
        umapperAjax.getMapsCount(function(count){
            jQuery.umap.rpc(umapperOptions.rpcUri, 'maps.getMaps', [umapperOptions.rpcToken, umapperOptions.rpcKey, start, limit], function(resp){
                if((!resp.error) && resp.result) {
                    umapperAjax.loadingMsg(false);
                    callback(count, resp.result);
                } else {
                    console.log(resp);
                }
            });
        });
        return false;
    }
};
var umapperAjax = new UmapperAjax();