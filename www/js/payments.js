core.payments={invoiceGroups:{}};

core.payments.getCreateInvoicesForm=function(){
	core.doRequest('/payments/receivables__create_invoices',{'payable_id':core.ui.getCheckallList(document.paymentsForm,'receivables').join(',')});
}


core.payments.createInvoices=function(){
	$('#invoice_create_loading_progress,#invoice_create_buttonset').toggle();
	core.doRequest('/payments/do_create_invoices',core.getFormDataForSubmit(document.paymentsForm));
	
}
core.payments.makePayments=function(tabName){
	//alert(core.ui.getCheckallList(document.paymentsForm,'payments').join(','));
	core.doRequest('/payments/payables__enter_payments',{'tab_name':tabName,'checked_invoices':core.ui.getCheckallList(document.paymentsForm,tabName).join(',')});
}

core.payments.enterInvoices=function(tabName){
	//alert(core.ui.getCheckallList(document.paymentsForm,'payments').join(','));
	core.doRequest('/payments/receivables__enter_invoices',{'tab_name':tabName,'checked_invoices':core.ui.getCheckallList(document.paymentsForm,tabName).join(',')});
}

core.payments.updateDueDates=function(identifier,newInterval){
	var epoch = parseInt(new Date().valueOf()) + parseInt((newInterval * 86400000));
	var newDate = new Date(epoch);
	var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
	var out = months[newDate.getMonth()]+' '+newDate.getDate()+', '+newDate.getFullYear();
	$('#due_date_'+identifier).html(out);
}

core.payments.initInvoiceGroups=function(tabName){
	//alert('called: '+tabName);
	//core.alertHash(core.payments.invoiceGroups);
	for(var key in core.payments.invoiceGroups){
		$('#'+tabName+'_amount_due_'+key).html(core.format.price(parseFloat(core.payments.invoiceGroups[key])));
		core.payments.invoiceGroups[key]=[];
		
		invoiceList = new String(document.paymentsForm[tabName+'_group_'+key+'_invoices'].value).split(/,/gi);
		
		for(var i=0;i<invoiceList.length;i++)
		{
			var amountDueObj = document.paymentsForm[tabName+'_invoice_'+invoiceList[i]+'_amount_due'];
			var allocObj = document.paymentsForm[tabName+'_invoice_'+invoiceList[i]];
			var info = {
				'invoiceId':invoiceList[i],
				'amountDue':parseFloat(amountDueObj.value),
				'invAllocObj':allocObj,
				'invAllocAmt':0
			};
			core.payments.invoiceGroups[key].push(info);
		}
		
		/*
		
		var i=0;
		var val = document.paymentsForm[tabName+'_pay_group_'+key+'__'+i].value;
		//alert(val);
		while(val !='' && val+'' != 'undefined'){
			var invoiceId = val.replace(tabName+'_pay_','');
			var amountDue = document.paymentsForm[tabName+'_pay_group_due_'+key+'__'+i].value;
			var invAllocObj  = document.paymentsForm[tabName+'_pay_group_id_'+invoiceId];
			var invAllocAmt  = core.format.parsePrice(invAllocObj.value);
			if(isNaN(invAllocAmt))	invAllocAmt = 0;
		
			//alert('call group info ready');
			var info = {
				'invoiceId':invoiceId,
				'amountDue':amountDue,
				'invAllocObj':invAllocObj,
				'invAllocAmt':invAllocAmt
			};
			
			//core.alertHash(info);
		
			core.payments.invoiceGroups[key].push(info);
			
			i++;
			var val = document.paymentsForm[tabName+'_pay_group_'+key+'__'+i];
			//alert(typeof(val));
			if(typeof(val) == 'object')
				val = val.value;
		}
		//alert('done with group '+key);
		
		*/
		//core.alertHash(core.payments.invoiceGroups[key]);
	}
	
	//alert('here');
	//alert('#'+tabName+'s_pay_area,#all_all_'+tabName+'s');
	//$('#'+tabName+'s_pay_area,#all_all_'+tabName+'s').toggle();
}

core.payments.applyMoneyToInvoices=function(tabName,inAmount,groupSuffix,inAmountObj){
	var inAmount = core.format.parsePrice(inAmount);
	var totalDue = 0;
	//alert(inAmount);
	//core.alertHash(core.payments.invoiceGroups[groupSuffix]);
	for(var i=0;i<core.payments.invoiceGroups[groupSuffix].length;i++){
		var obj = core.payments.invoiceGroups[groupSuffix][i];
		totalDue += parseFloat(obj.amountDue);
		if(inAmount > 0){
			if(inAmount > obj.amountDue){
				inAmount -= obj.amountDue;
				obj.invAllocObj.value = core.format.price(obj.amountDue)
				
			}else{
				obj.invAllocObj.value = core.format.price(inAmount);
				inAmount = 0;
			}
		}else{
			obj.invAllocObj.value = core.format.price(0);
		}
		
		//alert(i+': '+core.payments.invoiceGroups[groupSuffix][i].amountDue);
	}
	
	if(inAmount > 0)
		inAmountObj.value = core.format.price(totalDue);
	
	//alert(groupSuffix+': '+core.format.parsePrice(inAmount));
	/*
	var i=0;
	var groupedInvoices={};
	
	var val = document.paymentsForm['invoice_pay_group_'+groupSuffix+'__'+i].value;
	while(val !='' && val != 'undefined'){
		var invoiceId = val.replace('invoice_pay_','');
		var amountDue = document.paymentsForm['invoice_pay_group_due_'+groupSuffix+'__'+i].value;
		var invAllocObj  = document.paymentsForm['invoice_pay_group_id_'+invoiceId];
		var invAllocAmt  = core.format.parsePrice(invAllocObj.value);
		if(isNaN(invAllocAmt))	invAllocAmt = 0;
		
		alert(invoiceId + ' / '+amountDue + ' / '+invAllocAmt);
		i++;
		
		groupedInvoices[invoiceId] = {};
		
		var val = document.paymentsForm['invoice_pay_group_'+groupSuffix+'__'+i].value;
	}
	*/
	
}


core.payments.saveInvoicePayments=function(tabName){
	document.paymentsForm.payment_from_tab.value=tabName;
	core.doRequest('/payments/record_payments',core.getFormDataForSubmit(document.paymentsForm));
}

core.payments.newAccount=function(refObj){
	var pos = $(refObj).offset(); 
	$('#edit_popup').css( { 
		'left': (pos.left - 100)+'px', 
		'top': (pos.top - 30)+'px'
	});
	core.doRequest('/payments/new_bank_account',{});
}

core.payments.newRecordPayments=function(tabName){
	document.paymentsForm.payment_from_tab.value=tabName;
	core.doRequest('/payments/new_record_payments',core.getFormDataForSubmit(document.paymentsForm));
}


core.payments.setPaymentOptions=function(curGroup,val){
	//alert('called: '+val+'/'+curGroup);
	$('#area_check_nbr_'+curGroup+',#area_ach_'+curGroup).hide();
	switch(val+'')
	{
		case '3':
			//alert('here: '+'#area_ach_'+curGroup);
			$('#area_ach_'+curGroup).show(300);
			break;
		case '4':
			//alert('here: '+'#area_check_nbr_'+curGroup);
			$('#area_check_nbr_'+curGroup).show(300);
			break;
		case '5':
			break;
	}
}

/* DELETE ALL ABOVE */

core.payments.sendInvoices=function(){
	//alert('in progress');
	var receivables = core.ui.getCheckallList(document.paymentsForm,'receivables');
	if(receivables.length == 0){
		alert('please check at least one receivable.');
	}else{
		core.doRequest('/payments/send_invoices',{'checked_receivables':receivables.join(',')});
	}
}

core.payments.makePayments=function(tab){
	var payables = core.ui.getCheckallList(document.paymentsForm,tab);
	if(payables.length == 0){
		alert('please check at least one '+tab+'.');
	}else{
		core.doRequest('/payments/make_payments',{'tab':tab,'checked_payables':payables.join(',')});
	}
}

core.payments.savePayment=function(tab,group){
	var data = {};
	data['tab'] = tab;
	data['payment_method'] = $('input[name='+tab+'__group_method__'+group+']:checked').val();
	data['ref_nbr'] = $(document.paymentsForm[tab+'__group_ref_nbr__'+group]).val();
	data['opm_id'] = $(document.paymentsForm[tab+'__group_opm_id__'+group]).val();
	data['amount'] = $(document.paymentsForm[tab+'__group_total__'+group]).val();
	data['payable_ids'] = $(document.paymentsForm[tab+'__payable_ids__'+group]).val();
	data['group'] = group;
	//core.alertHash(data);
	
	core.doRequest('/payments/save_new_payment',data);
}

core.payments.markItemsDelivered=function(){
	var receivables = core.ui.getCheckallList(document.paymentsForm,'receivables');
	if(receivables.length == 0){
		alert('please check at least one item.');
	}else{
		core.doRequest('/payments/mark_items_delivered',{'checked_receivables':receivables.join(',')});
	}
}

core.payments.doSendInvoices=function(){
	//alert(core.getFormDataForSubmit(document.paymentsForm));
	//alert(document.paymentsForm.payables_to_send.value);
	document.paymentsForm.has_sendables.value = 0;
	core.doRequest('/payments/do_send_invoices',core.getFormDataForSubmit(document.paymentsForm));
	if(document.paymentsForm.has_resendables.value == 0){
		core.payments.resetInvoiceSending();
	}else{
		$('#sendable_payables').hide(300);
	}
}

core.payments.doResendInvoices=function(){
	//alert(core.getFormDataForSubmit(document.paymentsForm));
	//alert(document.paymentsForm.payables_to_send.value);
	document.paymentsForm.has_resendables.value = 0;
	core.doRequest('/payments/do_resend_invoices',core.getFormDataForSubmit(document.paymentsForm));
	if(document.paymentsForm.has_sendables.value == 0){
		core.payments.resetInvoiceSending();
	}else{
		$('#resendable_payables').hide(300);
	}
}

core.payments.resetInvoiceSending=function(){
	$('#receivables_list,#receivables_actions').toggle(300);
}

core.payments.checkAllPaymentsMade=function(tab){
	if($('div.'+tab+'_row:visible').length == 0){
		$('#'+tab+'_list,#'+tab+'_actions').toggle(300);
	}
}

core.payments.setPayFields=function(tab,group){
	var val = $('form[name=paymentsForm] input[name='+tab+'__group_method__'+group+']:checked').val();
	$('.'+tab+'__group__'+group+'__pay_field').hide();
	$('#'+tab+'__group__'+group+'__pay_fields_'+val).show(300);
}


core.payments.toggle=function(typeName,id,refObj){
	refObj = $(refObj);
	var state = refObj.attr('data-expanded');
	refObj.attr('data-expanded',((state==0)?1:0));
	$('#'+typeName+'_'+id).toggle();
	refObj[((state==0)?'removeClass':'addClass')]('icon-plus-circle');
	refObj[((state==1)?'removeClass':'addClass')]('icon-minus-circle');
};
