core.address={
	addrOk:false
};


core.address.lookupLatLong=function(address,city,state,postal_code){
	var address = address+', '+city+', '+state+', '+postal_code;
	//alert('called: '+address);
	var callback = 'core.address.setLatLng(\''+address+'\',gcResult,gcStatus);';
	core.ui.getLatLng(address,callback);
}

core.address.setLatLng=function(address,gcResult,gcStatus){
	if(gcResult[0] && gcResult[0].geometry){
		$('#latitude').val(gcResult[0].geometry.location.lat());
		$('#longitude').val(gcResult[0].geometry.location.lng());
		$('#bad_address').hide();
		core.address.addrOk = true;
	}else{
		$('#bad_address').fadeIn('fast');
		$('#latitude').val(0);
		$('#longitude').val(0);
		core.address.addrOk = false;
	}
}

core.address.editAddress=function(addrType,AddressId){
	//alert('atttempting to edit address '+AddressId);
	//core.alertHash(core);
	if(!$('#addAddressButton').is(':hidden') || $('#sec_pin').length==0){
		//core.alertHash(core.addresses);
		core.address.addrOk = true;
		if(AddressId > 0){
			for(var key in core.addresses[AddressId][0]){
				$(document[addrType+'Form'][key]).val(core.addresses[AddressId][0][key]);
			}
		}else{
			core.ui.clearFields(document[addrType+'Form'],['label','region_id','address','city','postal_code','telephone','fax','delivery_instructions','latitude','longitude'],['address_id']);
			//core.ui.setCheckdiv('default_billing',0);
		}
		$('#addAddressButton,#main_save_buttons,#addressTable').hide();
		$('#editAddress').fadeIn('fast');
		document[addrType+'Form'].label.focus();
	}
}
core.address.cancelAddressChanges=function(){
	$('#editAddress').hide();
	$('#addAddressButton,#main_save_buttons,#addressTable').fadeIn('fast');
}

core.address.saveAddress=function(saveType){
	//alert('here: '+saveType+'Form');
	if(core.address.addrOk){
		core.doRequest(
			'/'+saveType+'/save_address',
			core.ui.getFieldHash(document[saveType+'Form'],['address_id','org_id','label','address','city','region_id','postal_code','telephone','fax','delivery_instructions','latitude','longitude'])
		);
		core.address.cancelAddressChanges();
	}
}

core.address.removeCheckedAddresses=function(form){
	var addresses = core.ui.getCheckallList(form,'addresses');
	var finalAddresses=[];
	var doPopup=false;
	var hasDeletes=false;
	for (var i = 0; i < addresses.length; i++){
		if(
			$('#default_billing_'+addresses[i]).prop('checked') ||
			$('#default_shipping_'+addresses[i]).prop('checked') 
		){
			doPopup = true;
		}else{
			hasDeletes = true;
			finalAddresses.push(addresses[i]);
		}
	}
	
	if(doPopup)
		core.validatePopup('You cannot delete your default shipping or billing address. <br />');
		
	if(hasDeletes)
		core.doRequest('/market/delete_addresses',{'address_ids':finalAddresses.join(',')});
}
//alert('loaded: '+address.saveAddress);

core.address.setDefaultBill=function(addr_id,org_id){
	core.doRequest(
		'/organizations/change_billing_address',
		{
			'address_id':addr_id,
			'org_id':org_id
		}
	);
}

core.address.setDefaultShip=function(addr_id,org_id){
	core.doRequest(
		'/organizations/change_shipping_address',
		{
			'address_id':addr_id,
			'org_id':org_id
		}
	);
}