core.validate = {};

if(typeof(core)=='undefined')	core={};
core.valRules=new Object();
core.valFuncs=new Object();

core.valFuncs['autofail']=function(form,item_obj){
	return false;
}


core.valFuncs['at_least_one_checked']=function(form,item_obj){
	var val = 0;
	for(var i in item_obj['data1']){
		val += ($('#'+item_obj['data1'][i]).val()=='on')?1:0;
	}
	return (val > 0);
}

core.valFuncs['date_less_than']=function(form,item_obj){
	var date1 = core.format.parseDate(form[item_obj['name']].value,'timestamp');
	var date2 = core.format.parseDate(form[item_obj['data1']].value,'timestamp');
	return (date1 <= date2);
}

core.valFuncs['date_greater_than']=function(form,item_obj){
	var date1 = core.format.parseDate(form[item_obj['name']].value,'timestamp');
	var date2 = core.format.parseDate(form[item_obj['data1']].value,'timestamp');
	return (date1 >= date2);
}

core.valFuncs['is_checked']=function(form,item_obj){
	return form[item_obj['name']].checked;
}

core.valFuncs['value_is']=function(form,item_obj){
	return (form[item_obj.name].value  == item_obj.data1)
}

core.valFuncs['is_int']=function(form,item_obj){
	var testVal = form[item_obj.name].value;
	return (!isNaN(testVal) && (testVal.toString().indexOf('.')==-1) && testVal !='')
	
}

core.valFuncs['is_positive']=function(form,item_obj){
	var testVal = new String(form[item_obj.name].value);
	testVal = testVal.replace('$','');
	testVal = parseFloat(testVal);
	return (!isNaN(testVal) && testVal >= 0)
}

core.valFuncs['is_valid_price']=function(form,item_obj){
	var testVal = form[item_obj.name].value;
	testVal = testVal.replace('$','');
	//alert(testVal);
	//alert(!isNaN(testVal));
	//alert((testVal.toString().length - testVal.toString().lastIndexOf('.') === 3));
	//alert((parseInt(testVal) == testVal));
	//alert((!isNaN(testVal) && ((testVal.toString().length - testVal.toString().lastIndexOf('.') === 3) || (parseInt(testVal) == testVal))));
	return (!isNaN(testVal) && ((testVal.toString().length - testVal.toString().lastIndexOf('.') === 3) || (parseInt(testVal) == testVal)))
}

core.valFuncs['selected']=function(form,item_obj){
	return (form[item_obj.name].selectedIndex > 0)
}

core.valFuncs['min_length']=function(form,item_obj){
	//alert(form[item_obj['name']].value);
	arguments[2]=new String(form[item_obj['name']].value);
	if(item_obj.data2 == 'yes' && arguments[2].length == 0)
		return true;
	if(arguments[2].length<item_obj.data1){
		return false;
	}
	return true;
}

core.valFuncs['radio_checked']=function(form,item_obj){
	toReturn=false;
	for(arguments[2]=0;arguments[2]<form[item_obj.name].length;arguments[2]++){
		if(form[item_obj.name][arguments[2]].checked)
			toReturn=true;
	}
	return toReturn;
}

core.valFuncs['valid_email']=function(form,item_obj){
	arguments[2]=new String(form[item_obj['name']].value);
	var result =  /^[a-zA-Z0-9\+\w\.-]*@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/.test(arguments[2]);
	return result;
}

core.valFuncs['contains_nbrs_letters']=function(form,item_obj){
	arguments[2]=new String(form[item_obj['name']].value);
	return /^\w*(?=\w*\d)(?=\w*[a-zA-Z])\w*$/.test(arguments[2]);
}

core.valFuncs['match_confirm_field']=function(form,item_obj){
	return (form[item_obj.name].value == form[item_obj.data1].value);
}

core.valFuncs['max_length']=function(form,item_obj){
	arguments[2]=new String(form[item_obj['name']].value);
	if(arguments[2].length>item_obj.data1)
	{
		return false;
	}
	return true;
}

core.valFuncs['equal_to']=function(form,item_obj){
	arguments[2]='';
	arguments[3]='';
	arguments[2]=new String(form[item_obj['name']].value)+'';
	arguments[3]=new String(form[item_obj['data1']].value)+'';
	return (arguments[2]==arguments[3]);
}

core.valFuncs['not_equal_to']=function(form,item_obj){
	arguments[2]='';
	arguments[3]='';
	arguments[2]=new String(form[item_obj['name']].value)+'';
	arguments[3]=new String(form[item_obj['data1']].value)+'';
	return (arguments[2]!=arguments[3]);
}

core.valFuncs['length_range']=function(form,item_obj){
	arguments[2]=new String(form[item_obj['name']].value);
	if(arguments[2].length<item_obj.data1){
		//alert('too short');
		return false;
	}
	if(arguments[2].length>item_obj.data2){
		//alert('too long');
		return false;
	}
	//alert('just right');
	return true;
}

core.valFuncs['list_not_equal_to']=function(form,item_obj){	
	arguments[2]=form[item_obj['name']].options[form[item_obj['name']].selectedIndex].value;
	if(arguments[2]==item_obj['data1']){
		return false;
	}
	return true;
}


core.valFuncs['valid_date']=function(form,item_obj){	
	//alert(form[item_obj['name']].value);
	return /(19|20)\d\d[- /](0[1-9]|1[012])[- /](0[1-9]|[12][0-9]|3[01])/.test(form[item_obj['name']].value);
}

core.validateForm=function(){
	$('div.error').hide();
	$('.invalid').removeClass('invalid');
	
	if(typeof(arguments[0])=='object'){
		var form=arguments[0];
	}else{
		var form=document.forms[arguments[0]];
	}
	
	if(typeof(form) != 'object'){
		//core.ui.error('Could not find a form to validate.');
		return false;
	}
	
	if(typeof(arguments[1]) == 'object'){
		var items=arguments[1];
	}else{
		var items=core.valRules[form.getAttribute('name')];
	}
	
	var notFocused=true;
	//alert('has rules: '+(typeof(core.valRules[form.name])));
	if(typeof(items)!='object')
		return true;

	var has_errors=false;
	var previousErrors={};
	
	error_string='';
	
	
	for(var a=0;a<items.length;a++){
		var item = $(form.elements.namedItem([items[a]['name']]));
		
		if(typeof(item) == 'undefined'){
			alert('Unable to find form field: '+items[a]['name']);
			return false;
		}
		if(!core.valFuncs[items[a]['type']](form,items[a])){
			if(!previousErrors[items[a].name]){
				has_errors=true;
				error_string+=items[a]['msg']+'<br />\n';
				if(notFocused){
					form[items[a].name].focus();
					notFocused=false;
				}
				core.setErrorEffect(form.elements.namedItem([items[a]['name']]),items[a]['msg']);
				previousErrors[items[a].name]=true;
			}
		}else{
			if(!previousErrors[items[a].name]){
				core.unsetErrorEffect(form[items[a].name]);
				$(item).removeClass('invalid');
			}
		}
	}
	if(has_errors){
		
		core.validatePopup(error_string);
		return false;
	}
	return true;
}


core.validatorSetupField=function(obj){
	var obj = $(obj);
	var id = obj.attr('id');
	// there's no id on this field, so there's also no error area. create them.
	if(id+'' == 'undefined' || !document.getElementById(id+'_error')){
		if(id+'' == 'undefined'){
			var id = 'f'+(new Date().valueOf());
			obj.attr('id',id);
		}
		obj.parent().append('<div class="error" id="'+id+'_error"></div>');
	}
	return id;	
}

core.setErrorEffect=function(objectToSet,msg){
	var obj = $(objectToSet);
	obj.addClass('invalid');
	var id = core.validatorSetupField(objectToSet);
	//alert('#'+id+'_error');
	$('#'+id+'_error').html(msg).show();
}

core.unsetErrorEffect=function(objectToUnset){
	var id = core.validatorSetupField(objectToUnset);
	$('#'+id+'_error').hide();
	$(objectToUnset).removeClass('invalid');
}

core.validatePopup=function(errorString){
	$('body').scrollTop(0);
	$('html').scrollTop(0);
	//core.ui.popup('','','errors have occurred');
	core.ui.popup('','','<strong>Error: '+errorString+'</strong><br />Please correct these errors and try again.','close');
}

core.validate.showFails=function(form,fails){
	core.alertHash(fails);
	alert('called: '+fails.length);
	for (i = 0; i < fails.length; i++){
		core.alertHash(fails[i]);
	}
}

