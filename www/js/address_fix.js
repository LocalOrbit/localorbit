
core.addressFix = {
	'cache':{}
};

core.addressFix.doIt = function(){

	var ids = new String($('#ids').val()).split(/,/);
	
	// change 5 to ids.length
	for (var i = 0; i < ids.length; i++){
		window.setTimeout('core.addressFix.doLookup('+ids[i]+');',(2000 * i));
	}
}

core.addressFix.doLookup=function(id){
	var address = $('#address_'+id).val()+', '+$('#city_'+id).val()+', '+$('#state_'+id).val()+', '+$('#postal_code_'+id).val();
	core.addressFix.log('looking up '+address);
	
	if(core.addressFix.cache[address])
	{
		core.addressFix.saveCoords(address,id);
	}
	else
	{
		var callback = 'core.addressFix.setVals(\''+address+'\','+id+',gcResult,gcStatus);';
		core.ui.getLatLng(address,callback);	
	}
}

core.addressFix.setVals=function(address,id,gcResult,gcStatus){
	if(gcResult[0] && gcResult[0].geometry){
		core.addressFix.cache[address] = {
			'lat':gcResult[0].geometry.location.lat(),
			'long':gcResult[0].geometry.location.lng()
		}
		$('#lat_'+id).val(gcResult[0].geometry.location.lat());
		$('#long_'+id).val(gcResult[0].geometry.location.lng());
		core.addressFix.log('got coords for '+id);
		core.addressFix.saveCoords(address,id);
	}else{
		core.addressFix.log('unable to get coords for '+id);
	}
}

core.addressFix.saveCoords=function(address,id){
	core.doRequest('/market/save_lat_long',{
		'address_id':id,
		'latitude':core.addressFix.cache[address]['lat'],
		'longitude':core.addressFix.cache[address]['long']
	});
}

core.addressFix.log=function(newmsg){
	$('#output_log').val($('#output_log').val()+'\n'+newmsg);
}


core.addressFix.doIt();