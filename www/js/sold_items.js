core.sold_items={};

core.sold_items.applyAction=function(){
	var params = {};
	params['ldstat_id'] = document.itemForm.actions_1.options[document.itemForm.actions_1.selectedIndex].value.split(':')[1];
	//params['lsps_id'] = document.itemForm.actions_2.options[document.itemForm.actions_2.selectedIndex].value.split(':')[1];
	if(document.itemForm.actions_3){
		params['lbps_id'] = document.itemForm.actions_3.options[document.itemForm.actions_3.selectedIndex].value.split(':')[1];
	}
	var notNone = false;
	$('#statusErrors').hide(300);
	
	for (var key in params) {
		if (notNone = (params[key] !== 'none'))
			break;
	}
	
	var items  = core.ui.getCheckallList(document.itemForm,'solditem');
	
	if(!notNone || items.length == 0){
		core.ui.error('you must check at least one item and select an action');
	}else{
		params.items = items.join(',');
		core.doRequest('/sold_items/change_status',params);
	}
}

core.sold_items.resetActions=function() {
	document.itemForm.actions_1.selectedIndex = 0;
	document.itemForm.actions_2.selectedIndex = 0;
	document.itemForm.actions_3.selectedIndex = 0;
	document.itemForm.actions_4.selectedIndex = 0;
	document.itemForm.actions_5.selectedIndex = 0;
	document.itemForm.actions_6.selectedIndex = 0;
}

core.sold_items.checkErrored=function(){
	for(var i=0;i<arguments.length;i++){
		document.itemForm['checkall_solditem_'+arguments[i]].checked = true;
	}
}

core.sold_items.editAdminNotes=function(lo_oid, refObj){
	var pos = $(refObj).offset(); 
	$('#edit_popup').css( { 
		'left': (pos.left - 100)+'px', 
		'top': (pos.top - 30)+'px'
	});
	//core.alertHash(pos); 
	core.doRequest('/orders/admin_notes',{'lo_oid':lo_oid,'load_popup':'yes'});
	//core.doRequest('/products/popup_edit_price',{'prod_id':prodId,'price_id':priceId});
}