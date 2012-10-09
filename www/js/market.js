var market={};

market.togglePoDue=function(){
	//alert(document.marketForm.allow_po.value);
	$('#allow_po_row')[((document.marketForm.payment_allow_purchaseorder.value==1)?'fadeIn':'fadeOut')]('fast');
}

market.refreshLogo1=function(params){
	if(arguments[0] == 'toolarge')
		alert('image was too large :/');
	else{
		$('#removeLogo1').fadeIn('fast');
		document.getElementById('logo1').setAttribute('src','http://'+core.hostname+'/img/'+document.marketForm.domain_id.value+'/logo-large.'+arguments[0]+'?_time_='+(new Date().valueOf()));
	}
}

market.refreshLogo2=function(params){
	if(arguments[0] == 'toolarge')
		alert('image was too large :/');
	else{
		$('#removeLogo2').fadeIn('fast');
		document.getElementById('logo2').setAttribute('src','http://'+core.hostname+'/img/'+document.marketForm.domain_id.value+'/logo-email.'+arguments[0]+'?_time_='+(new Date().valueOf()));
	}
}

market.refreshLogo3=function(params){
	if(arguments[0] == 'toolarge')
		alert('image was too large :/');
	else{
		$('#removeLogo3').fadeIn('fast');
		document.getElementById('logo3').setAttribute('src','http://'+core.hostname+'/img/'+document.marketForm.domain_id.value+'/profile.'+arguments[0]+'?_time_='+(new Date().valueOf()));
	}
}

market.updateCycleView=function(newVal){
	$('#cycle_weekly,#cycle_monthly_by_day,#cycle_monthly_by_day_nbr').hide();
	$('.cycle').each(function(){
		if($(this).attr('id') == 'cycle_'+newVal)
			$(this).fadeIn('fast');
	});
}

market.showWeeklySellOn=function(dayNbr){
}

market.editDeliv=function(DelivId){
	//core.alertHash(core.delivery_days[DelivId][0]);
	//alert();
	if(!$('#addDelivButton').is(':hidden') || typeof(document.getElementById('sec_pin'))!='object'){
		if(DelivId > 0){
			//core.alertHash(core.delivery_days[DelivId][0]);
			for(var key in core.delivery_days[DelivId][0]){
				core.delivery_days[DelivId][0]['delivery_start_time'] = parseFloat(core.delivery_days[DelivId][0]['delivery_start_time']);
				core.delivery_days[DelivId][0]['delivery_end_time'] = parseFloat(core.delivery_days[DelivId][0]['delivery_end_time']);
				core.delivery_days[DelivId][0]['pickup_start_time'] = parseFloat(core.delivery_days[DelivId][0]['pickup_start_time']);
				core.delivery_days[DelivId][0]['pickup_end_time'] = parseFloat(core.delivery_days[DelivId][0]['pickup_end_time']);
				$(document.marketForm[key]).val(core.delivery_days[DelivId][0][key]);
			}
		}else{
			core.ui.clearFields(document.marketForm,['day_ordinal','day_nbr','cycle','hours_due_before','delivery_start_time','delivery_end_time','pickup_start_time','pickup_end_time','fee_calc_type_id'],['deliv_address_id','hours_due_before','dd_id','pickup_address_id','devfee_id','amount']);
		}
		market.setOrdinalOptions();
		if(DelivId > 0){
			for(var key in core.delivery_days[DelivId][0]){
				$(document.marketForm[key]).val(core.delivery_days[DelivId][0][key]);
			}
		}else{
			core.ui.clearFields(document.marketForm,['day_ordinal','day_nbr','cycle','hours_due_before','delivery_start_time','delivery_end_time','pickup_start_time','pickup_end_time','fee_calc_type_id'],['deliv_address_id','hours_due_before','dd_id','pickup_address_id','devfee_id','amount']);
		}
		market.setPickupLabel();
		$('#addDelivButton,#main_save_buttons').hide();
		$('#editDeliv').fadeIn('fast');
		document.marketForm.label.focus();
	}
}

market.setPickupLabel=function(){
	$('#pickup_label1,#pickup_label2,#pickup_label3,#pickup_header')[((document.marketForm.deliv_address_id.selectedIndex == 0)?'hide':'show')]();
}

market.setOrdinalOptions=function(){
	var addOptions=function(numOpts){
		var ordinals = ['','1st','2nd','3rd'];
		var obj = $('#day_ordinal');
		for (var i = 1; i <= numOpts; i++){
			if(i < ordinals.length){
				obj.append(
				  $('<option></option>').val(i).html(ordinals[i])
				);
			}else{
				obj.append(
				  $('<option></option>').val(i).html(i+'th')
				);
			}
		}
		
	}
	switch(document.marketForm.cycle.selectedIndex){
		case 0:
			// weekly
			$('#day_ordinal').children().remove();
			$('#delivery_ordinal_selector').hide();
			$('#day_selector').show();
			break;
		case 1:
			$('#day_ordinal').children().remove();
			addOptions(2);
			$('#delivery_ordinal_selector').show();
			$('#day_selector').show();
			// bi-weekly
			break;
		case 2:
			$('#day_ordinal').children().remove();
			addOptions(5);
			$('#delivery_ordinal_selector').show();
			$('#day_selector').show();
			// monthly
			break;
		case 3:
			$('#day_ordinal').children().remove();
			addOptions(31);
			$('#delivery_ordinal_selector').show();
			$('#day_selector').hide();
			// monthly
			break;
		default:
			alert('unknown cycle');
			break;
	}
}

market.cancelDelivChanges=function(){
	$('#editDeliv').hide();
	$('#addDelivButton,#main_save_buttons').fadeIn('fast');
}

market.saveDeliv=function(){
	core.doRequest(
		'/market/save_delivery',
		core.ui.getFieldHash(document.marketForm,['dd_id','domain_id','cycle','hours_due_before','day_ordinal','day_nbr','deliv_address_id','delivery_start_time','delivery_end_time','pickup_start_time','pickup_end_time','pickup_address_id', 'allproducts', 'allcrosssellproducts', 'fee_calc_type_id', 'amount', 'minimum_order', 'devfee_id'])
	);
	market.cancelDelivChanges();
}

market.removeCheckedDelives=function(form){
	core.doRequest('/market/delete_deliveries',{'dd_ids':core.ui.getCheckallList(form,'deliverydays').join(',')});
}

market.defaultPaymentChanged=function(type){
	//var value = $('#checkdiv_payment_allow_'+type+'_value').val();
}

market.allowPaymentChanged=function(type){
	var value = $('#checkdiv_payment_allow_'+type+'_value').val();
	if(value == 0){
		core.ui.setCheckdiv('payment_default_'+type,false);
		$('#div_payment_allow_'+type).hide(300);
	}else{
		$('#div_payment_allow_'+type).show(300);
	}
	
	if(type == 'purchaseorder')
		$('.buyer_invoicer_options')[((value == 1)?'show':'hide')](300);
	//alert(value);
	//core.ui.setCheckdiv('',false)
	//alert('called: '+type);
}

market.toggleAnon=function(){
	$('#default_homepage_selector').toggle(300);
	var allow_anon = ($('#checkdiv_feature_allow_anonymous_shopping_value').val() == 1);
	if(allow_anon){
		core.ui.setCheckdiv('autoactivate_organization',true);
		core.ui.setCheckdiv('payment_allow_paypal',true);
		core.ui.setCheckdiv('payment_default_paypal',true);
		core.ui.setCheckdiv('payment_default_purchaseorder',false);
		market.allowPaymentChanged('paypal');
	}
}
