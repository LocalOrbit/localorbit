core.payments={invoiceGroups:{}};

core.payments.getCreateInvoicesForm=function(){
	core.doRequest('/payments/receivables__create_invoices',{'payable_id':core.ui.getCheckallList(document.paymentsForm,'receivables').join(',')});
}


core.payments.createInvoices=function(){
	$('#invoice_create_loading_progress,#invoice_create_buttonset').toggle();
	core.doRequest('/payments/do_create_invoices',core.getFormDataForSubmit(document.paymentsForm));
	
}

core.payments.recordPayments=function(){
	core.doRequest('/payments/invoices__record_payment',{'due_invoices':core.ui.getCheckallList(document.paymentsForm,'dueinvoices').join(',')});
}

core.payments.makePayments=function(){
	//alert(core.ui.getCheckallList(document.paymentsForm,'payments').join(','));
	core.doRequest('/payments/payments__pay_payment',{'checked_invoices':core.ui.getCheckallList(document.paymentsForm,'payments').join(',')});
}

core.payments.initInvoiceGroups=function(tabName){
	//alert('called: '+tabName);
	//core.alertHash(core.payments.invoiceGroups);
	for(var key in core.payments.invoiceGroups){
		$('#'+tabName+'_amount_due_'+key).html(core.format.price(parseFloat(core.payments.invoiceGroups[key])));
		core.payments.invoiceGroups[key]=[];
		
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
	
	}
	//alert('here');
	//alert('#'+tabName+'s_pay_area,#all_all_'+tabName+'s');
	$('#'+tabName+'s_pay_area,#all_all_'+tabName+'s').toggle();
}

core.payments.applyMoneyToInvoices=function(inAmount,groupSuffix,inAmountObj){
	var inAmount = core.format.parsePrice(inAmount);
	var totalDue = 0;
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


