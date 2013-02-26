/**
 * Handle: UmapperRpc
 * Version: 1.0.0
 * Deps: jquery, gettext
 * Enqueue: true
 */

window.jQuery = window.jQuery || {};

jQuery.umap = {
    /**
     * Sends XML-RPC calls and returns parsed responses
     *
     * @param   {string}    uri         RPC-server URI
     * @param   {method}    method      Method to call
     * @param   {array}     params      Method parameters
     * @param   {function}  callback    Callback function
     */
    rpc : function(uri, method, params, callback) {
        var that = this;

        /**
         * Serializes and return value wrapped in xml-rpc tags
         * @param   {mixed} data    Value to serialize
         */
        var serialize = function(data) {
            switch (typeof data) {
                case 'boolean':
                    return '<boolean>'+ ((data) ? '1' : '0') +'</boolean>';
                case 'number':
                    var parsed = parseInt(data);
                    if(parsed == data) {
                        return '<int>'+ data +'</int>';
                    }
                    return '<double>'+ data +'</double>';
                case 'string':
                    return '<string><![CDATA['+ data +']]></string>';
                case 'object':
                    if(data instanceof Date) {
                        return '<dateTime.iso8601>'+ data.getFullYear() + data.getMonth() + data.getDate() +'T'+ data.getHours() +':'+ data.getMinutes() +':'+ data.getSeconds() +'</dateTime.iso8601>';
                    } else if(data instanceof Array) {
                        var ret = '<array><data>'+"\n";
                        for (var i=0; i < data.length; i++) {
                            ret += '  <value>'+ serialize(data[i]) +"</value>\n";
                        }
                        ret += '</data></array>';
                        return ret;
                    } else {
                        var ret = '<struct>'+"\n";
                        jQuery.each(data, function(key, value) {
                            ret += "  <member><name>"+ key +"</name><value>";
                            ret += serialize(value) +"</value></member>\n";
                        });
                        ret += '</struct>';
                        return ret;
                    }
            }
        };

        /**
         * Deserializes XML-RPC value
         * @param   {string}    node    XML-RPC representation of value
         */
        var unserialize = function(node) {
            childs = jQuery(node).children();
            for(var i=0; i < childs.length; i++) {
                switch(childs[i].tagName) {
                    case 'boolean':
                        return (jQuery(childs[i]).text() == 1);
                    case 'int':
                        return parseInt(jQuery(childs[i]).text());
                    case 'double':
                        return parseFloat(jQuery(childs[i]).text());
                    case "string":
                        return jQuery(childs[i]).text();
                    case "array":
                        var ret = [];
                        jQuery("> data > value", childs[i]).each(
                        function() {
                            ret.push(unserialize(this));
                        }
                    );
                        return ret;
                    case "struct":
                        var ret = {};
                        jQuery("> member", childs[i]).each(
                        function() {
                            ret[jQuery( "> name", this).text()] = unserialize(jQuery("value", this));
                        }
                    );
                        return ret;
                    case "dateTime.iso8601":
                        /* TODO: fill me :( */
                        return NULL;
                }
            }
        };

        /**
         * Creates XML-RPC source xml
         * @param   {string}    method  Method to call
         * @param   {array}     params  Method parameters
         */
        var rpcBody = function(method, params) {
            var ret = '<?xml version="1.0"?><methodCall><methodName>'+method+'</methodName><params>';
            for(var i=0; i<params.length; i++) {
                ret += "<param><value>"+serialize(params[i])+"</value></param>";
            }
            ret += "</params></methodCall>";
            return ret;
        };

        /**
         * Parses XML-RPC response
         * @param   {string}    data    Raw XML response
         * @param   {object}    Parsed response object
         */
        var parseXmlResponse = function(data) {
            var ret = {};
            jQuery("methodResponse params param > value", data).each(
            function(index) {
                ret.result = unserialize(this);
            }
        );
            jQuery("methodResponse fault > value", data).each(
            function(index) {
                ret.error = unserialize(this);
            }
        );
            return ret;
        }

        /**
         * Issues actual XML-RCP AJAX call
         * @param   {string}    method      RPC method to call
         * @param   {array}     params      Method parameters
         * @param   {function}  callback    Callback function
         * @return  {object}    Response object
         */
        var call = function(method, params, callback) {
            var data = rpcBody(method, params);

            jQuery.ajax({
                "url": uri,
                "dataType": 'xml',
                "type": "POST",
                "data": data,
                "success": function(xml) {
                    var response = parseXmlResponse(xml);
                    callback(response);
                },
                "processData": false,
                "contentType": "text/xml"
            });

        };

        call(method, params, callback);

        return false;
    },
    /**
     * Converts the given data structure to a JSON string.
     * Argument: arr - The data structure that must be converted to JSON
     * Example: var json_string = this.array2json(['e', {pluribus: 'unum'}]);
     * 			var json = this.array2json({"success":"Sweet","failure":false,"empty_array":[],"numbers":[1,2,3],"info":{"name":"Binny","site":"http:\/\/www.openjs.com\/"}});
     * http://www.openjs.com/scripts/data/json_encode.php
     */
    array2json : function (arr) {
        var parts = [];
        var is_list = (Object.prototype.toString.apply(arr) === '[object Array]');

        for(var key in arr) {
            var value = arr[key];
            if(typeof value == "object") { //Custom handling for arrays
                if(is_list) parts.push(this.array2json(value)); /* :RECURSION: */
                else parts[key] = this.array2json(value); /* :RECURSION: */
            } else {
                var str = "";
                if(!is_list) str = '"' + key + '":';

                //Custom handling for multiple data types
                if(typeof value == "number") str += value; //Numbers
                else if(value === false) str += 'false'; //The booleans
                else if(value === true) str += 'true';
                else str += '"' + value + '"'; //All other things
                // :TODO: Is there any more datatype we should be in the lookout for? (Functions?)

                parts.push(str);
            }
        }
        var json = parts.join(",");

        if(is_list) return '[' + json + ']';//Return numerical JSON
        return '{' + json + '}';//Return associative JSON
    }
};