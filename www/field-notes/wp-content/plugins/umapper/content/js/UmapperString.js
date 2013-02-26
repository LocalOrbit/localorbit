/**
 * Handle: UmapperString
 * Version: 1.0.0
 * Deps: UmapperInit
 * Enqueue: true
 */

function UmapperString(qs)
{
    this.params = {};

    if(qs.length == 0) return;

    // remove unecessary tags
    qs = qs.replace('[umap ', '');
    qs = qs.replace('%', '_');
    qs = qs.replace(']', '');
    qs = qs.replace('[', '      ');
    qs = qs.replace(/\"/g, '');
    qs = qs.replace(/ +/g, ' ');

    var args = qs.split(' '); // parse out name/value pairs separated via &

    // split out each name=value pair
    for (var i = 0; i < args.length; i++) {
    	var pair = args[i].split('=');
    	var name = decodeURIComponent(pair[0]);

    	var value = (pair.length==2)
    		? decodeURIComponent(pair[1])
    		: name;

    	this.params[name] = value;
    }

}

UmapperString.prototype.get = function(key, default_) {
	var value = this.params[key];
	return (value != null) ? value : default_;
}

UmapperString.prototype.contains = function(key) {
	var value = this.params[key];
	return (value != null);
}