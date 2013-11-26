core.checkout={delivGroups:0};


core.checkout.addDelivOptions=function(){
	if(core.checkout.delivGroups === 0){
		core.checkout.delivGroups = {};
		var options = $('input.deliv_options');
		options.each(function(){
			var parts = new String($(this).attr('value')).split('----');
			//alert(typeof(core.checkout.delivGroups[parts[0]]));
			if(typeof(core.checkout.delivGroups[parts[0]]) != 'object')
				core.checkout.delivGroups[parts[0]] = [];
			core.checkout.delivGroups[parts[0]].push(parts[1])
		});
	}
}

core.checkout.process=function(){
	core.checkout.showSubmitProgress();

	// figure out how we're checking out
	var paymentMethod = '';
	if(document.getElementById('payment_selector')){
		//~ alert($('#radiodiv_show_payment_paypal_value').val())
		//~ alert($('#radiodiv_show_payment_authorize_value').val())
		//~ alert($('#radiodiv_show_payment_purchaseorder_value').val())
		paymentMethod = 'cash';
		if($('#radiodiv_show_payment_paypal_value').val() == 1)
			paymentMethod = 'paypal';
		if($('#radiodiv_show_payment_authorize_value').val() == 1)
			paymentMethod = 'authorize';
		if($('#radiodiv_show_payment_purchaseorder_value').val() == 1)
			paymentMethod = 'purchaseorder';

	}else{
		paymentMethod = 'cash';
		if(document.getElementById('payment_authorize'))	
			paymentMethod='authorize';
		if(document.getElementById('payment_paypal'))	
			paymentMethod='paypal';
		if(document.getElementById('payment_purchaseorder'))	
			paymentMethod='purchaseorder';
	}
	
	// copy over the necessary rules
	//alert('here: '+paymentMethod);
	core.valRules['checkoutForm'] = core.valRules[paymentMethod];
	//core.alertHash(core.valRules['checkoutForm']);
	if(core.validateForm(document.checkoutForm)){
		
		// this order allows a user to select which delivery day
		// check each delivery option group to make sure one is selected.
		core.checkout.addDelivOptions();

		
		//core.alertHash(core.checkout.delivGroups);
		try{

			if(core.checkout.delivGroups){
				
				var okForCheckout = true;
				for(var key in core.checkout.delivGroups){
					var okForGroup = false;
					for (var i = core.checkout.delivGroups[key].length - 1; i >= 0; i--) {
						if($('#radiodiv_'+core.checkout.delivGroups[key][i]+'_value').val() == 1)
							okForGroup = true;
					}
					if(!okForGroup)
						okForCheckout = false;
				}
				
				if(!okForCheckout){
					core.validatePopup('You must select a delivery option to continue.<br />');
					core.checkout.resetSubmitProgress();
					return false;
				}else{
					//core.ui.notification('good to go!')
				}
			}
		}
		catch(e){

		}
		//return false;
		core.checkout.showSubmitProgress();
		core.submit('/catalog/order_confirmation',document.checkoutForm);
	}
	else
	{
		core.checkout.resetSubmitProgress();
	}
	return false;
}

core.checkout.fakeFill=function(){
	var form=document.checkoutForm;
	form.pp_cc_number.value = '4996014203540108';
	form.pp_cvv2.value = '123';
	form.pp_exp_month.selectedIndex = 2;
	form.pp_exp_year.selectedIndex = 5;
	form.pp_first_name.value = 'Mike';
	form.pp_last_name.value = 'Thorn';
	form.pp_street.value = '100 main st';
	form.pp_city.value = 'Ann Arbor';
	form.pp_state.selectedIndex = 19;
	form.pp_zip.value = 22322;
}

core.checkout.hideSubmitProgress=function(){
	$('#checkout_buttons').show(200);
	$('#checkout_progress').hide();
	window.clearInterval(core.checkout.animateHandler);
	$('#progress_bar').css('width','0%');
}

core.checkout.showSubmitProgress=function(){
	$('#checkout_buttons').hide();
	$('#checkout_progress').show();
	window.clearInterval(core.checkout.animateHandler);
	core.checkout.animateHandler = window.setInterval(core.checkout.animateCheckout,300);
}

core.checkout.animateCheckout=function(){
	var obj = $('#progress_bar');
	var width = parseFloat(obj.css('width'));
	if(width < 100){
		width++;
		obj.css('width',width+'%');
	}else{
		window.clearInterval(core.checkout.animateHandler);
	}
}

core.checkout.resetSubmitProgress=function(){
	$('#checkout_buttons').show();
	$('#checkout_progress').hide();
	window.clearInterval(core.checkout.animateHandler);
	$('#progress_bar').css('width','0%');
}

core.checkout.requestUpdatedFees=function(){
	// to perform an update, we need to pass along 
	// all of the delivery choices the user has made,
	// as well as the discount code
	var valsToPass = {'discount_code':$('#discount_code').val()};
	$('.radiodiv').each(function(){
		var id = $(this).attr('id');
		if($('#'+id+'_value').val() == 1){
			var parts = new String(id).split('--');
			parts[0] = new String(parts[0]).replace('radiodiv_delivgroup-','').replace('radiodiv_group_delivgroup-','');
			valsToPass['group_'+parts[0]] = parts[1]+'-'+parts[2];
		}
	});
	$('#total_table').hide();
	$('#totals_loading').show();
	core.doRequest('/catalog/update_fees',valsToPass);
}

core.checkout.showNoPayment=function(){
	$('.payment_option').hide();
	$('#payment_none').show();
	var obj = $('#radio_payment_method_none');
	if(obj.length == 0) {
		// there's only one payment option, so use the hidden input field
		$('#payment_method').val('cash');
	}else{
		// there are multiple payment options, show the radio buttons
		obj.attr('checked', 'checked');
		$('#payment_selector_div').hide();
	}
}

core.checkout.hideNoPayment=function(){
	$('#payment_none').hide();
	$('#payment_selector_div').show();
	
}

core.checkout.updateDelivery=function(oid,ddId,addrId,prefix,doAlert){
	core.doRequest('/catalog/update_checkout_delivery',{
		'lo_oid':oid,
		'dd_id':ddId,
		'address_id':addrId,
		'prefix':prefix,
		'do_alert':doAlert
	});
}


core.checkout.addItemToOrder=function(loOid,ddId){
	core.checkout.progressHtml = $('#new_item_dd_id_'+ddId).html();
	$('#new_item_button_dd_id_'+ddId+',#new_item_dd_id_'+ddId).toggle(300);
	core.doRequest('/orders/add_item_table',{'lo_oid':loOid,'dd_id':ddId});
	
}

core.checkout.cancelAddItemToOrder=function(loOid,ddId){
	$('#new_item_button_dd_id_'+ddId+',#new_item_dd_id_'+ddId).toggle(300);
}

core.checkout.changeItemAmountInOrder=function(lo_oid,dd_id,prod_id,amount){
	var inputfield = $('#item_'+lo_oid+'_'+dd_id+'_'+prod_id);
	var currentAmount = parseFloat(inputfield.val());
	if(isNaN(currentAmount))
		currentAmount = 0;
	if(amount == 0)
		currentAmount = 0;
	else
		currentAmount += amount;
	if(currentAmount < 0)
		currentAmount = 0;
	inputfield.val(currentAmount);
	core.checkout.verifyValidAmount(lo_oid,dd_id,prod_id,currentAmount);
		
}

core.checkout.sendQty=function(lo_oid,dd_id,prod_id,currentAmount){
	core.doRequest('/orders/save_edit_updates_to_session',{
		'lo_oid':lo_oid,
		'dd_id':dd_id,
		'prod_id':prod_id,
		'qty':currentAmount
	});
}


core.checkout.verifyValidAmount=function(lo_oid,dd_id,prod_id,amount){
	core.log('verifying valid amount for '+prod_id+': '+amount);
	
	if(amount == 0){
		core.checkout.hideInvError(lo_oid,dd_id,prod_id);
		core.checkout.hidePriceError(lo_oid,dd_id,prod_id);
		core.checkout.sendQty(lo_oid,dd_id,prod_id,amount);
		return true;
	}else{
	
		var hasPrice  = false;
		var hasInv = false;
		var lowest = 9999999999999;
		
		// first, check to see if there's a price for this amount.
		//core.alertHash(core.checkout.allPrices['prod_'+prod_id]);
		for(var key in core.checkout.allPrices['prod_'+prod_id]){
			var priceData = new String(key).split('-');
			if(lowest > priceData[1])
				lowest = priceData[1];
			if(priceData[1] <= amount)
				hasPrice = true;
		}
		
		// next, check to make sure there's enough inventory for this amount
		if(amount <= core.checkout.allInventory['prod_'+prod_id])
			hasInv = true;
		
		if(!hasPrice)
			core.checkout.showPriceError(lo_oid,dd_id,prod_id,lowest);
		else
			core.checkout.hidePriceError(lo_oid,dd_id,prod_id);

		if(!hasInv)
			core.checkout.showInvError(lo_oid,dd_id,prod_id,core.checkout.allInventory['prod_'+prod_id]);
		else
			core.checkout.hideInvError(lo_oid,dd_id,prod_id);
		
		if(hasPrice && hasInv)
			core.checkout.sendQty(lo_oid,dd_id,prod_id,amount);
		return (hasPrice && hasInv);
	}
}

core.checkout.showPriceError=function(lo_oid,dd_id,prod_id,data){
	$('#priceError-'+dd_id+'-'+prod_id).html('You must order at least '+data).show();
}
core.checkout.hidePriceError=function(lo_oid,dd_id,prod_id,data){
	$('#priceError-'+dd_id+'-'+prod_id).hide();
}
core.checkout.showInvError=function(lo_oid,dd_id,prod_id,data){
	$('#invError-'+dd_id+'-'+prod_id).html('Only '+data+' are available').show();
}
core.checkout.hideInvError=function(lo_oid,dd_id,prod_id,data){
	$('#invError-'+dd_id+'-'+prod_id).hide();
}

core.checkout.saveNewItems=function(lo_oid,dd_id){
	$('#confirm_buttons_1,#confirm_buttons_2,#confirm_progress_1,#confirm_progress_2').toggle();
	
	var data = {};
	data['dd_id'] = dd_id;
	data['lo_oid'] = lo_oid;
	core.doRequest('/orders/add_items_to_existing_order',data);
	
	/*
	var itemObjs = $('input.items_for_dd_id_'+dd_id);
	var prod_ids = [];
	var hasProducts = false;
	
	for(var i=0;i<itemObjs.length;i++){
		var itemObj = $(itemObjs[i]);
		var ids = new String(itemObj.attr('id')).split('_');
		var amt = parseFloat(itemObj.val());
		if(isNaN(amt))
			amt = 0;
		if(amt > 0){
			
			var isValid = core.checkout.verifyValidAmount(lo_oid,dd_id,ids[3],amt);
			if(isValid){
				hasProducts = true
				data['prod_'+ids[3]] = amt;
				prod_ids.push(ids[3]);
			}
		}
	}

	if(hasProducts){
		data['prod_ids'] = prod_ids.join('_');
		data['dd_id'] = dd_id;
		data['lo_oid'] = lo_oid;
		//$('#new_item_dd_id_'+dd_id).html(core.checkout.progressHtml);
		core.doRequest('/orders/add_items_to_existing_order',data);
	}else{
		core.validatePopup('You must add at least one product.');
	}
	*/
}