core.catalog={
	filters:{
		seller:0,
		cat1:0,
		cat2:0,
		priceType:0,
		cartOnly:0
	},
	addressCoords:{
	}
};

core.catalog.resetFilters=function(){
	core.catalog.filters={
		seller:0,
		cat1:0,
		cat2:0,
		priceType:0,
		cartOnly:0
	};
	$('.filtercheck').attr('checked','checked');
	$('.filter_subcat').removeClass('subheader_off');
	core.catalog.updateListing();
}

core.catalog.setFilter=function(type,id,parentId,updateListing){
	if(arguments.length <4)
		updateListing=true;
	switch(type){
		case 'cat1':
			core.catalog.filters.cat1 = (core.catalog.filters.cat1 == id)?0:id;
			// any change in cat1 state necessitates a change in the cat2 filter
			core.catalog.filters.cat2 = 0;
			$('.filter_subcat').removeClass('subheader_off');
			if(core.catalog.filters.cat1==0){
				$('.filtercheck').attr('checked',true);
			}else{
				$('.filtercheck').attr('checked',false);
				$('#filtercheck_'+core.catalog.filters.cat1).attr('checked',true);
			}
			break;
		case 'cat2':
			core.catalog.filters.cat2 = (core.catalog.filters.cat2 == id)?0:id;
			if(core.catalog.filters.cat2 > 0){
				$('.filtercheck[id!=\'filtercheck_'+parentId+'\']').attr('checked',false);
				core.catalog.filters.cat1 = parentId;
				$('.filter_subcat_of_'+parentId).addClass('subheader_off');
				$('#filter_subcat_'+id).removeClass('subheader_off');
			}else{
				$('.filter_subcat').removeClass('subheader_off');
			}
			break;
		case 'seller':
			// change filter state. if this seller filter was already set, set state to 0 (off)
			core.catalog.filters.seller = (core.catalog.filters.seller == id)?0:id;
			if(core.catalog.filters.seller == 0){
				// if we were turning off the filter, turn all on
				$('.filter_org').removeClass('subheader_off');
			}else{
				// otherwise JUST turn on this selelr filter, turn the rest off
				$('.filter_org').addClass('subheader_off');
				$('#filter_org_'+id).removeClass('subheader_off');
			}
			break;
		case 'pricetype':
			break;
		case 'cartOnly':
			core.catalog.filters.cartOnly = (core.catalog.filters.cartOnly == 1)?0:1;
			$('#continueShoppingButton1,#continueShoppingButton2')[((core.catalog.filters.cartOnly == 1)?'show':'hide')]();
			$('#showCartButton1,#showCartButton2')[((core.catalog.filters.cartOnly == 0)?'show':'hide')](300);
			break;
	}
	//core.alertHash(core.catalog.filters);
	if(updateListing)
		core.catalog.updateListing();
}


core.catalog.updateListing=function(){

	// loop through all categories and toggle off show if neceesary
	core.thingsToShow    = [];
	core.thingsToHide    = [];
	core.thingsToShowS   = [];
	core.thingsToHideS   = [];
	core.thingsToFadeIn  = [];
	core.thingsToFadeOut = [];
	var catsToShow={};

	// set all products to show
	for (var i = 0; i < core.products.length; i++){
		core.products[i].show = true;
	}
	
	// determine which products to show or hide
	prodVisible = false;
	for (var i = 0; i < core.products.length; i++){

		if(core.catalog.filters.cartOnly == 1){
			//alert(document.cartForm['prodQty_'+core.products[i].prod_id].value);
			if(document.cartForm['prodQty_'+core.products[i].prod_id]){
				if(
					parseInt(document.cartForm['prodQty_'+core.products[i].prod_id].value) == 0
					||
					document.cartForm['prodQty_'+core.products[i].prod_id].value == ''
					|| 
					isNaN(document.cartForm['prodQty_'+core.products[i].prod_id].value)
				){
					core.products[i].show = false;
					//alert('going to hide  '+core.products[i].prod_id);
				}else{
					//alert('going to keep showing '+core.products[i].prod_id);
				}
			}else{
				//alert('going to hide  '+core.products[i].prod_id);
				core.products[i].show = false;
			}
		}else{
			// apply seller filter
			if(core.catalog.filters.seller > 0 && core.products[i].org_id != core.catalog.filters.seller)
				core.products[i].show = false;
			// apply the cat1 filter if necessary
			if(core.catalog.filters.cat1 > 0 && (!core.lo3.inArray(core.products[i].category_ids,core.catalog.filters.cat1)))
				core.products[i].show = false;
			// apply the cat2 filter if necessary
			if(core.catalog.filters.cat2 > 0 && (!core.lo3.inArray(core.products[i].category_ids,core.catalog.filters.cat2)))
				core.products[i].show = false;
		}


		// add this element to the list of things to hide
		if(core.products[i].show){
			
			// remember the fact that there is at least one prod visible. Used for no product msgs
			prodVisible = true;
			
			// add this product an its catgories to the list of things to show
			core.thingsToShow.push('#product_'+core.products[i].prod_id);
			catsToShow[core.products[i].category_ids[1]] = true;
			
			// if there are many levels to this product hierarchy, use the 4th index for the sub cat
			// (0== base cat, 1 == root cat, 2 == 1st sub cat, 3 == 2nd sub cat)
			// otherwise, use the 3rd index.
			if(core.products[i].category_ids.length > 3)
				catsToShow[core.products[i].category_ids[3]] = true;
			else
				catsToShow[core.products[i].category_ids[2]] = true;
		}else{
			core.thingsToHide.push('#product_'+core.products[i].prod_id);
		}
	}
	
	// determine which categories to show or hide
	for(var key in core.categories){
		for (var i = 0; i < core.categories[key].length; i++){
			core.categories[key][i].show = true;
			if(key == 2){
				core['thingsTo'+((catsToShow[core.categories[key][i].cat_id])?'Show':'Hide')].push('#start_cat1_'+core.categories[key][i].cat_id);
				core['thingsTo'+((catsToShow[core.categories[key][i].cat_id])?'Show':'Hide')].push('#end_cat1_'+core.categories[key][i].cat_id);
			}else{
				core['thingsTo'+((catsToShow[core.categories[key][i].cat_id])?'Show':'Hide')].push('#start_cat2_'+core.categories[key][i].cat_id);
				core['thingsTo'+((catsToShow[core.categories[key][i].cat_id])?'Show':'Hide')].push('#end_cat2_'+core.categories[key][i].cat_id);
			}
			
			
			// only affect showing of subcats
			if(key != 2){
				// if this cat does NOT belong to the cat1 fitler, just hide it
				if(core.catalog.filters.cat1 > 0 && core.catalog.filters.cat1 != core.categories[key][i]['parent_id']){
					core.categories[key][i].show=false;
				}
			}
			core['thingsTo'+((core.categories[key][i].show)?'ShowS':'HideS')].push('#filter_subcat_'+core.categories[key][i].cat_id)
		}
	}

	// if there are no products at all visible,
	if(!prodVisible){
		// if its because the cart filter is on but there are no products in cart, use one msg.
		if(
			core.catalog.filters.cartOnly == 1 
			&& core.catalog.filters.seller==0
			&& core.catalog.filters.cat1==0
			&& core.catalog.filters.cat2==0
			&& core.catalog.filters.priceType==0
		){
			core.thingsToHide.push('#no_prods_msg');
			core.thingsToShow.push('#cart_empty_msg');
		}
		// otherwise, use the other msg
		else{
			core.thingsToShow.push('#no_prods_msg');
			core.thingsToHide.push('#cart_empty_msg');
		}
	}else{
		core.thingsToHide.push('#no_prods_msg');
		core.thingsToHide.push('#cart_empty_msg');
	}

	// perform all changes
	core.catalog.popupOff();
	$(core.thingsToShow.join(',')).show();
	$(core.thingsToHide.join(',')).hide();
	$(core.thingsToShowS.join(',')).show(300);
	$(core.thingsToHideS.join(',')).hide(300);
	$(core.thingsToFadeIn.join(',')).fadeIn(300);
	$(core.thingsToFadeOut.join(',')).fadeOut(100);
		

	
	core.ui.scrollTop();
}

core.catalog.initCatalog=function(){
	core.addHandler('onrequest',core.catalog.closeAllPopups);
	core.prodIndex={};
	for (var i = 0; i < core.products.length; i++){
		core.products[i].show = true;
		core.products[i].category_ids = new String(core.products[i].category_ids).split(',');
		core.prodIndex[core.products[i]['prod_id']] = core.products[i];
		core.catalog.addressCoords[core.products[i].address+', '+core.products[i].city+', '+core.products[i].code+', '+core.products[i].postal_code] = true;
	}
	
	// build a cache of all the coordinates for the addresses for each product
	for(var key in core.catalog.addressCoords){
		core.ui.getLatLng(
			key,
			'core.catalog.setAddressCache(\''+core.base64_encode(key)+'\',gcResult);'
		);
	}
	
	// set show state for all categories
	for(var key in core.categories){
		for (var i = 0; i < core.categories[key].length; i++){
			core.categories[key][i].show = true;
		}
	}
	
	$('input.total_line').val(core.format.price(core.cart.total));
	if(new String(location.href).indexOf('cart') >= 0)
		core.catalog.setFilter('cartOnly');
}

core.catalog.setAddressCache=function(address,gcResult){
	if(gcResult[0]){
		core.catalog.addressCoords[core.base64_decode(address)] = [
			gcResult[0].geometry.location.lat(),
			gcResult[0].geometry.location.lng()
		];
	}else{
		core.catalog.addressCoords[core.base64_decode(address)] = false;
	}
}

core.catalog.doWeeklySpecial=function(prodId){
	core.catalog.updateRow(prodId,1);
	$('#prodQty_'+prodId).val(1);
	$('#weekly_special').fadeOut('fast');
}

core.catalog.updateRow=function(prodId,newQty){
	if(newQty == '')
		newQty = 0;
	var newQty = parseInt(newQty);
	var rowTotal = 100000000000000;
	
	
	// check the inventory, show warning if below
	if(core.prodIndex[prodId].inventory < newQty){
		newQty = core.prodIndex[prodId].inventory;
		$('#prodQty_'+prodId).val(parseFloat(newQty));
		$('#qtyBelowInv_'+prodId).html('Only '+parseFloat(newQty)+' available').fadeIn(300);
	}else{
		$('#qtyBelowInv_'+prodId).hide();
	}


	
	// loop through all the products
	var priceId = -1;
	var lowestMin = 100000000000000;
	for (var i = 0; i < core.prices[prodId].length; i++){
		
		// reformat the min qty to zero if it came across as an object (nulls can do this)
		if(typeof(core.prices[prodId][i]['min_qty']) == 'object')
			core.prices[prodId][i]['min_qty'] = 0;

		// reformat the price if necessary
		core.prices[prodId][i]['price'] =parseFloat(new String(core.prices[prodId][i]['price']).replace('$','').replace(' ',''));

		// if this is a valid price,
		if(newQty >= parseFloat(core.prices[prodId][i]['min_qty']) &&  core.prices[prodId][i]['price'] > 0){
			//alert('examining '+core.prices[prodId][i]['price_id']+': '+core.prices[prodId][i]['price']);
			// then calculate the row total based on this price
			var possibleRow = parseFloat(core.prices[prodId][i]['price']) * newQty;

			// if this is lower than our previous best, use this price
			if(possibleRow < rowTotal){
				rowTotal = possibleRow;
				priceId = core.prices[prodId][i]['price_id'];
			}			
		}


		if(core.prices[prodId][i]['min_qty'] > 0 && core.prices[prodId][i]['min_qty'] < lowestMin){
			lowestMin = core.prices[prodId][i]['min_qty'];
		}
	}
	
	// if we we found a valid price,
	if(priceId > 0){
		//alert('lowest is: '+priceId+' / '+rowTotal);
		//alert();
		core.catalog.setQty(prodId,newQty,rowTotal);
		$('#qtyBelowMin_'+prodId).html('<br />');
		core.catalog.sendNewQtys();
	}else{
		//alert('here')
		if(newQty > 0){
			//alert('You must order '+prodId+' at least '+parseFloat(lowestMin))
			$('#qtyBelowMin_'+prodId).html('You must order at least '+parseFloat(lowestMin)).show();
		}
		$('#prodTotal_'+prodId).val(0);
		core.catalog.setQty(prodId,0,0);
		core.catalog.sendNewQtys();
	}
}

core.catalog.setQty=function(prodId,newQty,rowTotal){
	var found=false;	
	//loop through the cart products
	for (var i = 0; i < core.cart.items.length; i++){
		// if we found it, then update its row total and quantity
		if(core.cart.items[i].prod_id == prodId){
			core.cart.items[i].qty_ordered = newQty;
			core.cart.items[i].row_total = rowTotal;
			found = true;
		}
	}

	// if we never found it in the above loop, then it's a new product
	// to the cart. Just push it on.
	if(!found){
		core.cart.items.push({
			'prod_id':prodId,
			'qty_ordered':newQty
		});
	}
	
	
	// show the total
	$('#prodTotal_'+prodId).val(core.format.price(rowTotal));
}

core.catalog.sendNewQtys=function(){
	var items=[];
	var data = '';
	for (var i = 0; i < core.cart.items.length; i++){
		data += '&prod_'+core.cart.items[i].prod_id+'='+core.cart.items[i].qty_ordered;
		items.push(core.cart.items[i].prod_id);
	}
	data += '&items='+items.join('_');
	core.doRequest('/cart/update_quantity',data);
}

core.catalog.handleCartResponse=function(itemHash){
	core.cart = itemHash;
	$('input.total_line').val(core.format.price(core.cart.total));
}


core.catalog.popupWho=function(prodId,refObj){
	var seller = core.sellers[core.prodIndex[prodId]['org_id']][0];
	var p_who  = core.prodIndex[prodId]['product_who'];
	var html = '<table><tr><td>';
	if(seller.has_image){
		html += '<img style="float:left;margin: 0px 8px 8px 0px;" src="/img/organizations/cached/'+seller.org_id+'.120.100.jpg" />';
	}
	html += '<span class="product_name">'+seller['name']+'</span><br />&nbsp;<br />';
	if(p_who != null && p_who != '')
		html += '<span class="farm_name">Who:</span> '+ p_who
		;
	else if(seller['profile']+'' != 'undefined' && seller['profile']+'' != 'null' && seller['profile']+'' != '')
		html += '<span class="farm_name">Who:</span> '+ seller['profile'];
	html += '<br />&nbsp;<br /></td></tr></table>';
	core.catalog.popupShow(refObj,html);
}

core.catalog.popupWhat=function(prodId,refObj){
	var seller = core.sellers[core.prodIndex[prodId]['org_id']][0];
	var prod = core.prodIndex[prodId];
	var html = '<table><tr><td>';
	if(typeof(prod.pimg_id) != 'object'){
		html += '<img class="catalog" style="float:left;margin: 0px 8px 8px 0px;" src="/img/products/cache/'+prod.pimg_id+'.'+prod.width+'.'+prod.height+'.200.150.'+prod.extension+'" />';		
	}
	html += '<span class="product_name">'+prod['name'];
	if(prod['single_unit'] != ''){
		html += ' ('+prod['single_unit']+')'
	}
	html += '</span><br />';
	html += '<span class="farm_name">from '+prod['org_name']+'</span><br />&nbsp;<br />';
	html += '<span class="what_section">What: </span>'+prod['description']+'<br />&nbsp;<br />';
	html += '<span class="what_section">How: </span>'+((prod['how'] == '')?seller['product_how']:prod['how']);
	html += '</td></tr></table>';
	
	core.catalog.popupShow(refObj,html);
}

core.catalog.popupWhere=function(prodId,refObj){
	var seller = core.sellers[core.prodIndex[prodId]['org_id']][0];
	//core.alertHash(core.prodIndex[prodId]);
	var latitude = parseFloat(core.prodIndex[prodId]['latitude']);
	var longitude = parseFloat(core.prodIndex[prodId]['longitude']);
	//core.alertHash(core.prodIndex[prodId]);
	
	core.ui.map('whereMap','#shop_popup_content',440,300,8);
	// look for the address in our cache
	if(!isNaN(latitude) && !isNaN(longitude)){
		//alert('got coords: '+latitude+'/'+longitude);
		core.ui.mapCenterByCoord('whereMap',latitude,longitude);
		core.ui.mapAddMarkerByCoord('whereMap',latitude,longitude,core.base64_encode('<h1>'+seller.name+'</h1>'),'/img/default/farm_bubble.png');
	}else{
		console.log('no coords');
		// if we dont' find it, set the map to the city
		core.ui.mapCenterByAddress('whereMap',core.prodIndex[prodId].city);
		core.ui.mapAddMarkerByAddress('whereMap',core.prodIndex[prodId].city,core.base64_encode('<h1>'+seller.name+'</h1>'));
	}
	var pos = $(refObj).offset();
	$('#shop_popup').hide().css('top',(pos.top + 15)+'px').css('left',(pos.left - 340)+'px').mouseleave(core.catalog.popupOff).fadeIn('fast');
}

core.catalog.popupShow=function(refObj,content){
	var pos = $(refObj).offset();
	$('#shop_popup_content').html(content);
	//
	$('#shop_popup').hide().css('top',(pos.top + 15)+'px').css('left',(pos.left - 340)+'px').mouseleave(core.catalog.popupOff).fadeIn('fast');
}

core.catalog.popupOff=function(refObj){
	$('#shop_popup').fadeOut('fast');
}

core.catalog.closeAllPopups=function(args){
	core.catalog.popupOff();
}


core.catalog.popupLoginRegister=function(idx){
	var refObj = document.getElementById(((core.catalog.filters.cartOnly==1)?'continueShoppingButton':'showCartButton')+idx);
	var pos = $(refObj).offset(); 
	$('#edit_popup').css( { 
		'left': (pos.left - 100)+'px', 
		'top': (pos.top - 30)+'px'
	});
	core.doRequest('/catalog/popup_login_register',{});
}

core.catalog.initCatalog();