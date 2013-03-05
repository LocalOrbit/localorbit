var product = {};
product.switchToAdvancedInventory=function(){
	$('#inventory_basic').hide();
	document.prodForm.inventory_mode.value = 'advanced';
	$('#inventory_advanced').fadeIn('fast');
}


core.handleCatSearch=function(newVal){
	
	newVal = new String(newVal);
	var showNoMatch = false;
	
	if(newVal == '' || newVal.length <= 2){
		$('.prodcreate_category').hide();
		$('#no_prods_msg').hide();
	}else if (newVal.length > 2){ 
		newVal = newVal.toLowerCase().split(' ');
		var turnOff=[];
		var turnOn=[];
		var matches = 0;
		
		for (var i = 0; i < core.finalCats.length; i++){
			var show = true;
			for (var j = 0; j < newVal.length; j++){
				if(new String(core.finalCats[i].search).indexOf(newVal[j]) >= 0){
				}else{
					show=false;
				}
			}
			if(show)
				matches++;
			if(show && core.finalCats[i].displayed==0){
				core.finalCats[i].displayed = 1;
				turnOn.push('#cat_'+core.finalCats[i].cat_id);
			}
			if(!show && core.finalCats[i].displayed==1){
				core.finalCats[i].displayed = 0;
				turnOff.push('#cat_'+core.finalCats[i].cat_id);
			}		
		}
		$(turnOn.join(',')).show(500);
		$(turnOff.join(',')).hide(500);
		
		$('#no_prods_msg')[((matches == 0)?'show':'hide')](500);	
	}	
}

product.editPopupPrice=function(prodId,priceId,refObj){
	var pos = $(refObj).offset(); 
	$('#edit_popup').css( { 
		'left': (pos.left - 100)+'px', 
		'top': (pos.top - 30)+'px'
	});
	//core.alertHash(pos); 
	core.doRequest('/products/popup_edit_price',{'prod_id':prodId,'price_id':priceId});
}

product.editPopupInventory=function(prodId,refObj){
	var pos = $(refObj).offset(); 
	$('#edit_popup').css( { 
		'left': (pos.left - 160)+'px', 
		'top': (pos.top - 60)+'px'
	});
	//core.alertHash(pos); 
	core.doRequest('/products/popup_edit_inventory',{'prod_id':prodId});
}

product.selectCat=function(level,catId){
	newLevel = level+1;
	//hide all higher levels
	for (var i = (newLevel+1); i < 10; i++){
		$('#cat_col'+i).hide();
	}
	
	// wipe the options from all higher levels
	for (var i = newLevel; i < 10; i++){
		$('#cats'+i).html('');
	}
	
	// get the object we're trying to add to
	
	var obj = $('#cats'+newLevel);
	var total = 0;
	for (var i = 0; i < core.allCats.length; i++){
		// if this cat is a child, add it
		if(core.allCats[i].parent_id == catId){
			if(document.catform.is_testing.value == 1){
				var label = core.allCats[i]['cat_id']+'-'+core.allCats[i]['cat_name'];
			}else{
				var label = core.allCats[i]['cat_name'];
			}
			var opt = new Option(label,core.allCats[i]['cat_id']);
			opt.text = label;
			obj.append(opt);
			document.catform['cats'+newLevel].options[total].text = label;
			total++;
		}
	}
	
	if(total == 0){
		$('#add_product').fadeIn(300);
		var ids = '2';
		for (var i = 1; i < newLevel; i++){
			ids += ','+$('#cats'+i).val();
		}
		document.catform.category_ids.value = ids;
	}else{
		obj.attr('size',total);
		$('#add_product').hide();
	}
	var toShow=[];
	var toHide=[];
	for (var i = 1; i < 10; i++){
		if( (i) == (newLevel - 2) || (i) == (newLevel -1) || (i) == (newLevel )){
			if((i) == newLevel && total== 0)
				toHide.push('#cat_col'+i);
			else
				toShow.push('#cat_col'+i);
		}else{
			if(!((i) == (newLevel-3) && total== 0))
				toHide.push('#cat_col'+i);
		}
	}
	$(toShow.join(',')).fadeIn(500);
	$(toHide.join(',')).fadeOut(500);	
}

product.requestNewProduct=function(){
	if(core.validateForm(document.catform)){
		$('#newProdRequestLink,#newProdRequest,#picker_button,#picker_cols').toggle();
		core.submit('/products/request_new',document.catform);
	}
}

product.requestNewCategory=function(){
	if(core.validateForm(document.catRequest)){
		$('#newCategorySetLink,#newProdCategory,#picker_button,#picker_cols').toggle();
		core.submit('/products/request_new_cat',document.catRequest);
		$('#parent_category,#new_category').val('');
	}
}

core.showProdCats={1:true,2:false,3:false,4:false,5:false,6:false};
core.productInitCols=function(){
	
	var obj = $('#cats1');
	var total = 0;
	for (var i = 0; i < core.allCats.length; i++){
		if(core.allCats[i].parent_id == 2){
			if(document.catform.is_testing.value == 1){	
				var label = core.allCats[i]['cat_id']+'-'+core.allCats[i]['cat_name'];
			}else{
				var label = core.allCats[i]['cat_name'];
			}
			var opt = new Option(label,core.allCats[i].cat_id);
			opt.text = label;
			obj.append(opt);
			document.catform.cats1.options[total].text = label;
			total++;
		}
	}
	obj.attr('size',total);
	$('#cat_col1').show();
}


core.createProduct=function(formObj,catIds){
	var data = {};
	if(formObj.org_id){
		if(formObj.org_id.selectedIndex == 0){
			$('#select_org_msg').show();
			core.validatePopup('Please select an organization.<br />	');
		}else{
			$('#select_org_msg,#add_product').hide();
			data['org_id'] = formObj.org_id.options[formObj.org_id.selectedIndex].value;
			data['category_ids'] = catIds;

			core.doRequest('/products/create_new',data);
		}
	}else{
		data['category_ids'] = catIds;
		$('#add_product').hide();
		core.doRequest('/products/create_new',data);
	}
}


product.editLot=function(invId,lotId,goodFrom,expiresOn,qty){
	if(invId > 0){
		document.prodForm.inv_id.value = invId;
		document.prodForm.lot_id.value = lotId;
		document.prodForm.good_from.value = (goodFrom != 'NA')?goodFrom:'';
		document.prodForm.expires_on.value = (expiresOn != 'NA')?expiresOn:'';
		document.prodForm.lot_qty.value = qty;
	}else{
		document.prodForm.inv_id.value = '';
		document.prodForm.lot_id.value = '';
		document.prodForm.good_from.value = '';
		document.prodForm.expires_on.value = '';
		document.prodForm.lot_qty.value = 0;
	}
	$('#addLotButton,#main_save_buttons,#inventory_advanced').hide();
	$('#editLot').fadeIn('fast');
	document.prodForm.lot_id.focus();
}

product.cancelLotChanges=function(){
	$('#editLot').hide();
	$('#addLotButton,#main_save_buttons,#inventory_advanced').fadeIn('fast');
}

product.saveLot=function(){
	core.doRequest('/products/save_lot',{
		'prod_id':document.prodForm.prod_id.value,
		'lot_id':document.prodForm.lot_id.value,
		'inv_id':document.prodForm.inv_id.value,
		'good_from':document.prodForm.good_from.value,
		'expires_on':document.prodForm.expires_on.value,
		'qty':document.prodForm.lot_qty.value
	});
	product.cancelLotChanges();
}

product.removeCheckedLots=function(form){
	core.doRequest('/products/delete_lots',{'inv_ids':core.ui.getCheckallList(form,'inventory').join(',')});
}

product.switchToAdvancedPricing=function(){
	$('#pricing_basic').hide();
	$('#pricing_advanced').fadeIn('fast');
	document.prodForm.pricing_mode.value='advanced';
}

product.editPrice=function(priceId,domainId,orgId,price,min_qty,totalFees,priceMinusFeesFeature){
	if(priceId > 0){
		document.prodForm.price_id.value = priceId;
		core.ui.setSelect(document.prodForm.domain_id,domainId);
		core.ui.setSelect(document.prodForm.org_id,orgId);
		document.prodForm.price.value = price;
		document.prodForm.min_qty.value = parseInt(min_qty);
	}else{
		document.prodForm.price_id.value = '';
		document.prodForm.domain_id.selectedIndex = 0;
		document.prodForm.org_id.selectedIndex = 0;
		document.prodForm.price.value = '';
		document.prodForm.min_qty.value = 0;
		if(typeof(document.prodForm.seller_net_price) == 'object'){
			document.prodForm.seller_net_price.value = '';
		}
	}
	
	totalFees = parseFloat(totalFees);
	
	if(typeof(document.prodForm.seller_net_price) == 'object')
	{
		var sellerNetPrice = core.format.parsePrice(price) - (core.format.parsePrice(price) * (totalFees/100));
		if(isNaN(sellerNetPrice) || sellerNetPrice < 0)
			sellerNetPrice = 0;
		document.prodForm.seller_net_price.value = core.format.price(sellerNetPrice);
		//product.syncPrices(document.prodForm.price,'seller_net_price');
		if(typeof(document.prodForm.total_fees) == 'object' && !isNaN(totalFees))
			document.prodForm.total_fees.value = totalFees;
	}
	
	$('#addPriceButton,#main_save_buttons,#pricing_advanced').hide();
	$('#editPrice').fadeIn('fast');
	document.prodForm.price.focus();
}

product.syncPrices=function(formField,moveTo){
	//alert(moveTo);
	if(typeof(formField.form['total_fees']) =='object'){
		var form = formField.form;
		var fees = parseFloat(form.total_fees.value);
		var newVal = core.format.parsePrice(formField.value);
		if(isNaN(newVal)){
			form[moveTo].value = '';
		}else{
			var fee_percen = ((100 - fees)/100);
			if(moveTo == 'price' || moveTo == 'wholesale' || moveTo == 'retail'){
				//alert('moving price to real field');
				var nbr = (newVal / fee_percen);	
			}else{
				//alert("moving price to seller field");
				var nbr = (newVal * fee_percen);	
			}
			if(isNaN(nbr))
				nbr=0;
	
			form[moveTo].value = core.format.price(nbr);
		}
	}
}

product.cancelPriceChanges=function(){
	$('#editPrice').hide();
	$('#addPriceButton,#main_save_buttons,#pricing_advanced').fadeIn('fast');
}

product.savePrice=function(){
	core.valRules['prodForm'] = [];
	for (var i = 0; i < core.valRules['pricing_advanced_rules'].length; i++){
		core.valRules['prodForm'].push(core.valRules['pricing_advanced_rules'][i]);
	}
	var data = {
			'prod_id':document.prodForm.prod_id.value,
			'price_id':document.prodForm.price_id.value,
			'domain_id':document.prodForm.domain_id.options[document.prodForm.domain_id.selectedIndex].value,
			'org_id':document.prodForm.org_id.options[document.prodForm.org_id.selectedIndex].value,
			'price':document.prodForm.price.value,
			'min_qty':document.prodForm.min_qty.value
	};
	if(core.validateForm(document.prodForm)){
		core.doRequest('/products/save_price',data);
	}
	core.valRules['prodForm'] = [];
}

product.removeCheckedPrices=function(form){
	core.doRequest('/products/delete_prices',{'price_ids':core.ui.getCheckallList(form,'pricing').join(',')});
}

product.refreshImage=function(oldId,newId,newWidth,newHeight,ext){
	document.prodForm.old_pimg_id.value = newId;
	$('#prod_image').attr('src','/img/products/cache/'+newId+'.'+newWidth+'.'+newHeight+'.400.300.'+ext).fadeIn();
}

product.removeLogo=function(){
	document.getElementById('prod_image').setAttribute('src',document.prodForm.placeholder_image.value);
	$('#removeLogo').fadeOut('fast');
}


product.doSubmit=function(do_redirect){
	//alert('here');
	core.valRules['prodForm'] = [];
	for (var i = 0; i < core.valRules['prodForm_prodinfo'].length; i++){
		core.valRules['prodForm'].push(core.valRules['prodForm_prodinfo'][i]);
	}
	
	// if we're in basic inventory mode, add the necessary validation rules
	if(document.prodForm.pricing_mode.value == 'basic'){
		if(document.prodForm.retail.value != ''){
			//alert('not blank');
			core.valRules['prodForm'].push({"type":"is_valid_price","name":"retail","msg":"Please enter a retail price"});
			core.valRules['prodForm'].push({"type":"is_positive","name":"retail","msg":"Please enter a retail price"});
		}
		if(document.prodForm.wholesale.value != '' || (document.prodForm.basic_wholesale_qty.value != '' && document.prodForm.basic_wholesale_qty.value != 0)){
			core.valRules['prodForm'].push({"type":"is_valid_price","name":"wholesale","msg":"Please enter a wholesale price"});
			core.valRules['prodForm'].push({"type":"is_positive","name":"wholesale","msg":"Please enter a wholesale price"});
			core.valRules['prodForm'].push({"type":"is_int","name":"basic_wholesale_qty","msg":"Please enter a wholesale minimum"});
			core.valRules['prodForm'].push({"type":"is_positive","name":"basic_wholesale_qty","msg":"Please enter a wholesale minimum"});
		}
	}
	//core.alertHash(core.valRules['prodForm']);
	if(do_redirect)
		core.submit('/products/update',document.prodForm,{'do_redirect':1});
	else
		core.submit('/products/update',document.prodForm);
	// determine necessary validation rules
	//core.submit('/products/update',this);
	return false;
}

product.filterOrganizations=function(domain_id){
	core.ui.dataTables['products'].filterStates['products.org_id'] = "-99999999999"; 
	if(domain_id > 0){
		core.doRequest('/organizations/get_filtered_orgs',{
			'domain_id':domain_id,
			'js_function':'product_updateOrgList',
			'sellers_only':1
		});
	}else{
		core.doRequest('/organizations/get_filtered_orgs',{
			'domain_id':0,
			'js_function':'product_updateOrgList',
			'sellers_only':1
		});
	}
}

product_updateOrgList=function(orgs){
	//core.alertHash(orgs);
	var opts = $(document.prodTable['products__filter__products.org_id']);
	opts.children().remove().end();
	opts.append($('<option>', { 'value' : (-99999999999)}).text('Show from all organizations')); 
	for(var i =0;i<orgs.length;i++){
		opts.append($('<option>', { 'value' : orgs[i].org_id }).text(orgs[i].name)); 
	}
/*
		core.doRequest('/organizations/get_filtered_orgs',{
			'domain_id':0,
			'js_function':'product_updateOrgList',
			'sellers_only':1
		});
*/
}


product.deleteProduct=function(prodId){
	if(confirm('Are you sure you want to delete this product? All featured deals and discounts related to this product will also be deleted. This cannot be undone.')){
		core.doRequest('/products/delete_product',{'prod_id':prodId});
	}
}