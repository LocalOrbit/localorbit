core.newsletters={customerCheckboxes:[]};

core.newsletters.sendNewsletter=function(errorMsg){
	if(core.newsletters.customerCheckboxes.filter(':checked').length  <= 0){
		//alert('you must select either buyers, sellers, or both');
		//core.ui.popup('','','<h2>The following errors have occurred</h2>You must check at least one group that will receive this newsletter.<br /><br />Please correct these errors and try again.','close');
		core.ui.popup('','',errorMsg,'close');
		$('#checkMsg').show();
	}else{
		$('#sendCustomers,#showTest,#checkMsg').hide();
		document.nlForm.do_send.value=1;
		core.submit('/newsletters/update',document.nlForm);
		document.nlForm.do_send.value=0;
	}
}

core.newsletters.sendTest=function(){
	$('#testLabel,#testEmail,#showTest,#sendTest,#cancelTest,#sendCustomers').toggle(100);
	document.nlForm.do_test.value=1;
	document.nlForm.test_email.value=$('#testEmail').val();
	core.submit('/newsletters/update',document.nlForm);
	document.nlForm.do_test.value=0;
	document.nlForm.test_email.value='';
}

core.newsletters.toggleTestEmail=function(){
	$('#testLabel,#testEmail,#showTest,#sendTest,#cancelTest,#sendCustomers').toggle(100);
}

core.newsletters.refreshImage=function(extension){
	if(extension=='toolarge'){
		alert('image is too large');
	}else{
		$('#removenlimage').fadeIn('fast');
		document.getElementById('newsletterImage').setAttribute('src','/img/newsletters/'+document.nlForm.cont_id.value+'.'+extension+'?_time_='+(new Date().valueOf()));
		$('#newsletterImage').fadeIn('fast');
	}
}

core.newsletters.updateSendButton = function () {
	core.newsletters.sendButton.toggleClass('disabled', core.newsletters.customerCheckboxes.filter(':checked').length <= 0);
};

core.newsletters.initializeCheckBoxes=function () {
	core.newsletters.customerCheckboxes = $('#send_seller,#send_buyer');
	core.newsletters.sendButton = $('#sendCustomers');

	core.newsletters.customerCheckboxes.change(core.newsletters.updateSendButton);
	core.newsletters.updateSendButton();
};

core.newsletters.initializeCheckBoxes();