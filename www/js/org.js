var org={};

org.setCrosssell=function(domain_id,ddList){
	if($('#checkdiv_sell_on_'+domain_id+'_value').val() == 1){
		$('.delivery_'+domain_id).fadeIn('fast');
		for (var i = 0; i < ddList.length; i++){
			core.ui.setCheckdiv('deliver_on_'+ddList[i],true);
		}
		
	}else{
		$('.delivery_'+domain_id).fadeOut('fast');
	}
}

org.makePrimaryAccount=function(orgId,opmId){
	core.doRequest('/organizations/set_primary_account',{'org_id':orgId,'opm_id':opmId});
}

org.inviteUser=function(domainId){

	if(core.validateForm(document.organizationsForm,[
		{'type':'valid_email','name':'invite_email','msg':'You must enter a valid E-mail address'}
	])){
		core.doRequest('/organizations/invite_user',{
			'email':document.organizationsForm.invite_email.value,
			'org_id':document.organizationsForm.org_id.value,
			'domain_id':domainId
		});
		//document.organizationsForm.invite_email.value='';
	}
}

org.refreshImage=function(extension){
	if(extension=='toolarge'){
		alert('image is too large');
	}else{
		var newSrc = '/img/organizations/cached/'+document.organizationsForm.org_id.value+'.320.260.'+(new Date().valueOf())+'.jpg';
		//alert(newSrc);
		//$('#orgImg').attr('src',true);
		//$('#orgImg').remove();
		$('#imgContainer').html('<img id="orgImg" src="'+newSrc+'" />');
		//location.reload();
	}
}

org.removeLogo=function(){
	document.getElementById('orgImage').setAttribute('src',document.prodForm.placeholder_image.value);
	$('#removeLogo').fadeOut('fast');
}

org.toggleNewHubTable=function(){
	$('#currentButtons,#possibleHubs,#main_save_buttons').toggle(300);
}

org.addManagedDomain=function(domainId){
	core.doRequest('/organizations/add_managed_hub',{
		'org_id':document.organizationsForm.org_id.value,
		'domain_id':domainId
	});
}

org.removeManagedHubs=function(){
	var domain_ids = core.ui.getCheckallList(document.organizationsForm,'domainids');
	
	if(domain_ids.length == 0)
		core.validatePopup('You must check at least one market to remove.<br />');
	else if(confirm('Are you sure you want to remove these markets?'))
		core.doRequest(
			'/organizations/delete_managed_hubs',
			{'org_id':document.organizationsForm.org_id.value,'domain_ids':domain_ids.join(',')}
		);
}


org.setHomeHub=function(domainId){
	core.doRequest('/organizations/set_home_hub',{
		'org_id':document.organizationsForm.org_id.value,
		'domain_id':domainId
	});
}

org.deleteOrg=function(orgId,orgName,refObj){
	if(confirm('Are you sure you want to delete organization '+orgName+'? All discounts, users, prices, products related to this organization will also be deleted. This cannot be undone.')){
		core.doRequest('/organizations/delete_org',{'org_id':orgId});
	}
}


org.deleteUser=function(userId,userName,refObj,curUserId){
	if(userId == curUserId){
		alert('You cannot delete yourself. If you wish to delete this account, login as a different user in your organization.');
	}else if(confirm('Are you sure you want to delete user '+userName+'? This cannot be undone.')){
		core.doRequest('/organizations/delete_user',{'user_id':userId});
	}
}


org.editPaymentMethod=function(opm_id,name_on_account,label,nbr1last4,nbr2last4){
	document.organizationsForm.pm_label.value=label;
	document.organizationsForm.opm_id.value=opm_id;
	document.organizationsForm.name_on_account.value=name_on_account;
	if(!isNaN(nbr1last4))
		document.organizationsForm.nbr1.value='************'+nbr1last4;
	else
		document.organizationsForm.nbr1.value = '';
	if(!isNaN(nbr2last4))
		document.organizationsForm.nbr2.value='************'+nbr2last4;
	else
		document.organizationsForm.nbr2.value = '';
	$('#paymentsTable,#main_save_buttons,#addPaymentButton,#editPaymentMethod').toggle();
}

org.deletePaymentMethods=function(formObj){
	core.doRequest('/organizations/delete_payment_methods',{'opm_ids':core.ui.getCheckallList(formObj,'opmids').join(',')});
}

org.savePaymentMethod=function(formObj){
	var account_num = $.trim(formObj.nbr1.value);
	var routing_num = $.trim(formObj.nbr2.value);

	// account number 5 digit check
	if(isNaN(account_num) || account_num.length < 5) {
		core.validatePopup("Please enter a valid Account number.");
		return false;
	}
	
	// routing number 9 digit check
	if(isNaN(routing_num) || routing_num.length != 9) {
		core.validatePopup("Please enter a valid 9 digit Routing number.");
		return false;
	}
	
	data = {
		'opm_id':formObj.opm_id.value,
		'label':formObj.pm_label.value,
		'name_on_account':formObj.name_on_account.value,
		'org_id':formObj.org_id.value
	}
	
	if(!isNaN(formObj.nbr1.value))
		data['nbr1'] = formObj.nbr1.value;
	if(!isNaN(formObj.nbr2.value))
		data['nbr2'] = formObj.nbr2.value;
		
	org.cancelPaymentChanges();
	core.doRequest('/organizations/save_payment_method',data);
}

org.cancelPaymentChanges=function(){
	$('#paymentsTable,#main_save_buttons,#addPaymentButton,#editPaymentMethod').toggle();
}