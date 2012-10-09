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
		if($('#radiodiv_show_payment_paypal_value').val() == 1)
			paymentMethod = 'paypal';
		if($('#radiodiv_show_payment_authorize_value').val() == 1)
			paymentMethod = 'authorize';
		if($('#radiodiv_show_payment_purchaseorder_value').val() == 1)
			paymentMethod = 'purchaseorder';
	}else{
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
	$('#placeorder_button').show();
	$('#loading_progress').hide();
}

core.checkout.showSubmitProgress=function(){
	$('#placeorder_button').hide();
	$('#loading_progress').show();
}

core.checkout.resetSubmitProgress=function(){
	$('#placeorder_button').show();
	$('#loading_progress').hide();
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
