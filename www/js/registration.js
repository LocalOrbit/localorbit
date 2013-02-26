core.registration={};


core.registration.toggleForm=function(){
	if(document.regform.domain_id.options[document.regform.domain_id.selectedIndex].value == (-1)){
		$('#email_signupform').fadeIn('fast');
	}else if(document.regform.domain_id.selectedIndex > 0){
		$('#reg_pickgroup,#reg_mainform').fadeIn('fast');
		$('#email_signupform').hide();
	}else{
		$('#reg_pickgroup,#reg_mainform').fadeOut('fast');
	}
}


core.registration.tosModalPopup=function(){
	$('#tosModal').modal();
}

core.registration.fakeInviteFill=function(){
	document.regform.first_name.value = 'Mike';
	document.regform.last_name.value = 'Thorn';
	document.regform.password.value = 'password';
	document.regform.password_confirm.value = 'password';
	document.regform.tos_approve.value = 1;
	$('#checkdiv_tos_approve').addClass('checkdiv_checked');
}

core.registration.fakeFill=function(spamResult,realField){
	var fakeemail = 'localorbit.testing+'+Math.floor((Math.random() * 100000))+'@gmail.com';
	document.regform.email.value= fakeemail;
	document.regform.email_confirm.value= fakeemail;
	document.regform.password.value = 'password';
	document.regform.password_confirm.value = 'password';
	document.regform.first_name.value = 'Mike';
	document.regform.last_name.value = 'Thorn';
	document.regform.company_name.value = 'company_name '+(new Date().valueOf());
	document.regform.address.value = '100 main st';
	document.regform.city.value = 'Ann Arbor';
	document.regform.postal_code.value = '23423';
	document.regform.telephone.value = '2342323223';
	//document.regform.fax.value = '23422324233';
	document.regform.region_id.selectedIndex = 5;
	if(typeof(document.regform.domain_id) == 'object'){
		document.regform.domain_id.selectedIndex = 1;
	}
	document.regform[realField].value=spamResult;
	
	document.regform.tos_approve.value = 1;
	document.regform.subscribe_mailchimp.value = 1;
	$('#checkdiv_subscribe_mailchimp').addClass('checkdiv_checked');
	$('#checkdiv_tos_approve').addClass('checkdiv_checked');
	core.registration.toggleForm();
}