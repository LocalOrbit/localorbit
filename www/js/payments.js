core.payments={};

core.payments.getCreateInvoicesForm=function(){
	core.doRequest('/payments/receivables__create_invoices',{'payable_id':core.ui.getCheckallList(document.paymentsForm,'receivables').join(',')});
}


core.payments.createInvoices=function(){
	$('#invoice_create_loading_progress,#invoice_create_buttonset').toggle();
	core.doRequest('/payments/do_create_invoices',core.getFormDataForSubmit(document.paymentsForm));
	
}