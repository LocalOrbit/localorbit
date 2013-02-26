var market={
	background_color_picker : undefined,
	background_image_picker : undefined
};

market.togglePoDue=function(){
	//alert(document.marketForm.allow_po.value);
	$('#allow_po_row')[((document.marketForm.payment_allow_purchaseorder.value==1)?'fadeIn':'fadeOut')]('fast');
}

market.refreshLogo1=function(params){
	if(arguments[0] == 'toolarge')
		alert('image was too large :/');
	else{
		$('#removeLogo1').fadeIn('fast');
		core.doRequest('/whitelabel/get_options','');
		document.getElementById('logo1').setAttribute('src','http://'+core.hostname+'/img/'+document.marketForm.domain_id.value+'/logo-large.'+arguments[0]+'?_time_='+(new Date().valueOf()));
	}
}

market.refreshLogo2=function(params){
	if(arguments[0] == 'toolarge')
		alert('image was too large :/');
	else{
		$('#removeLogo2').fadeIn('fast');
		core.doRequest('/whitelabel/get_options','');
		document.getElementById('logo2').setAttribute('src','http://'+core.hostname+'/img/'+document.marketForm.domain_id.value+'/logo-email.'+arguments[0]+'?_time_='+(new Date().valueOf()));
	}
}

market.refreshLogo3=function(params){
	if(arguments[0] == 'toolarge')
		alert('image was too large :/');
	else{
		$('#removeLogo3').fadeIn('fast');
		core.doRequest('/whitelabel/get_options','');
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
	///core.alertHash(document.getElementById('sec_pin'));
	//alert(typeof(document.getElementById('sec_pin')));
	//alert('check: '+(typeof(document.getElementById('sec_pin'))!='object'));
	if(!$('#addDelivButton').is(':hidden') || $('#sec_pin').length==0){
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
		$('#addDelivButton,#main_save_buttons,#delivTable').hide();

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
	$('#addDelivButton,#main_save_buttons,#delivTable').fadeIn('fast');
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
	var value = document.marketForm['payment_allow_'+type].checked;
	if(value){
		$('#div_payment_allow_'+type).show(300);
	}else{
		document.marketForm['payment_default_'+type].checked = false;
		$('#div_payment_allow_'+type).hide(300);
	}

	if(type == 'purchaseorder')
		$('#po_due_option')[((value)?'show':'hide')](300);
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

market.reloadCss=function () {
	$('link.old').remove();
	var newLink = $('<link rel="stylesheet" type="text/css" href="css/less.php?reload=' + new Date().getTime() + '" media="all"/>').insertAfter($('#less-css'));
	$('#less-css').addClass('old').removeAttr('id');
	newLink.attr('id', 'less-css');
	/*
	setTimeout(function () {
		//$('#less-css').remove();
		$('#less-css').addClass('old').removeAttr('id');
		newLink.attr('id', 'less-css');
	}, 5000);
	*/
	//$('#less-css').attr('href', 'css/less.php?reload=' + new Date().getTime());
};

market.setDefaults=function(bgColor, bgImageId, fontColor, fontId) {
	$('#background_color').data('default', bgColor);
	$('#background_id').data('default', bgImageId);
	$('#font_color').data('default', fontColor);

	$('#header_font input[type=radio]').removeAttr('data-default');
	$('#header_font input[type=radio][value=' + fontId +']').data('default', true);
};

market.revertStyle=function() {
	var bgColor, bgImageId, fontColor, fontId, index;

	bgColor = $('#background_color').data('default');
	bgImageId = $('#background_id').data('default');
	fontColor = $('#font_color').data('default');
	fontId = $('#header_font input[type=radio]').filter(
		function () {
		return $(this).data('default');}
	).val();

	$('#background_color').val(bgColor);
	$('#font_color').val(fontColor);

	market['background_color_picker'].colorpicker('setValue', bgColor);
	$('#font_color_picker').colorpicker('setValue', fontColor);
	$('#header_font input[type=radio][value=' + fontId + ']').attr('checked', true);
	$('.thumbnail.selected').removeClass('selected');
	market['background_image_picker'].val(bgImageId);
	index = market['background_image_picker'].find('option:selected').index() + 1;
	market['background_image_picker_list'].find('li:nth-child(' + index + ') > div').addClass('selected');

	if (bgImageId) {
		$('#background_type_image').attr('checked', true);
	} else {
		$('#background_type_color').attr('checked', true);
	}
};

market.updateImageSelection=function(jq) {
	market.updateBackgroundType(jq.find('div').hasClass('image_picker_color')?'color':'image', true);
};

market.updateBackgroundType = function (value, imageSelected) {
	if (value === 'image')
	{
		if (!imageSelected) {
			market['background_image_picker_list'].val(1);
			market['background_image_picker_color_div'].removeClass('selected');
			market['background_image_picker_list'].find('li:nth-child(2) > div').addClass('selected');
		}
		$('.image_picker_color').parent().removeClass('selected');
		$('#background_color_picker').attr('data-disabled','data-disabled');
		$('#background_type_image').attr('checked', true);
	}
	else if (value === 'color')
	{
		$('#background_color_picker').removeAttr('data-disabled');
		market['background_image_picker'].find('option:not([value])').attr('selected', 'selected');
		$('.thumbnail.selected').removeClass('selected');
		$('.image_picker_color').parent().addClass('selected');
		$('#background_type_color').attr('checked', true);
	}
};

market.saveStyle = function () {
	var jqwindow = $(window);
	var hostname = $('[name="hostname"]').val();
	var bgColor = $('#background_color').val();
	var bgImageId = $('#background_id').val();
	var fontColor = $('#font_color').val();
	var fontId = $('input:radio[name=header_font]:checked').val();
	var domainId = $('input[name=domain_id]').val();

	core.doRequest('/market/save_temp_style', '&domain_id=' + domainId +'&background_color=' + bgColor +'&background_id=' + bgImageId +'&font_color='+fontColor+'&header_font='+fontId);
	window.open(document.location.protocol + "//" + hostname + "/app.php#!market-info?width="+jqwindow.width()*0.80+"&height="+ jqwindow.height()*0.80 + "&temp_style=true&reload=" + new Date().getTime() , "_blank", "height=0, width=0,top="+jqwindow.height()*0.10+", left="+jqwindow.width()*0.10+", status=no, toolbar=no, menubar=no, resizable=yes");
}

market.initialize=function () {
	var bgColor, images = [];

	$('select.image-picker option').each( function () {
		var image = $(this).data('img-src');
		if (image) 
		{
			$('<img/>')[0].src = image;
		}
	});

	$('.colorpicker[data-color]').each( function () {
		var jq = $(this).colorpicker();
		if (jq.attr('id') && market.hasOwnProperty(jq.attr('id'))) {
			market[jq.attr('id')] = jq;
		}
	});

	market['background_image_picker'] = $('select.image-picker');

	bgColor = market['background_image_picker'].data('color');
	market['background_image_picker_js'] =market['background_image_picker'].imagepicker();
	market['background_image_picker_list'] = market['background_image_picker_js'].next('ul');
	market['background_image_picker_color'] = $('<li><div class="thumbnail"><div class="image_picker_image image_picker_color" style="background-color: '+bgColor+';"></div></div></li>')
		.prependTo(market['background_image_picker_list']);

	market['background_image_picker_color_div'] = $('.image_picker_color').css('background-color', bgColor);

	market['background_image_picker_list'].find('li > div').click(function () {
		var jq = $(this);
		market.updateImageSelection(jq);
	});

	market['background_color_picker'].on('changeColor', function (evt) {
		market['background_image_picker_color_div'].css('background-color',  evt.color.toHex());
	});

	if (market['background_image_picker'].val() === '') {
		market['background_image_picker_color'].find('div').addClass('selected');
		market['background_color_picker'].removeAttr('data-disabled');
	}

	$('[name="background_type"]').click(function () {
		var value = $(this).val();
		market.updateBackgroundType(value);
	});

	$('#main_save_buttons').before($('#restore-defaults')).prepend($('#preview-style'));
	
	
	function hidePreviewButtons() {
		$("#restore-defaults").hide();
		$("#preview-style").hide();
	}
	function showPreviewButtons() {
		$("#restore-defaults").show();
		$("#preview-style").show();
	}
	$('a[href="#markettabs-a1"]').click(function() {
		hidePreviewButtons();
	});
	$('a[href="#markettabs-a2"]').click(function() {
		hidePreviewButtons();
	});
	$('a[href="#markettabs-a3"]').click(function() {
		hidePreviewButtons();
	});
	$('a[href="#markettabs-a5"]').click(function() {
		hidePreviewButtons();
	});
	$('a[href="#markettabs-a6"]').click(function() {
		hidePreviewButtons();
	});
	$('a[href="#markettabs-a7"]').click(function() {
		hidePreviewButtons();
	});
	$('a[href="#markettabs-a8"]').click(function() {
		hidePreviewButtons();
	});
	$('a[href="#markettabs-a9"]').click(function() {
		hidePreviewButtons();
	});
	$('a[href="#markettabs-a5"]').click(function() {
		showPreviewButtons();
	});
	hidePreviewButtons();
};

market.initialize();
