core.weeklySpecials={};

core.weeklySpecials.refreshImage=function(msg){
	if(msg == 'toolarge'){
		alert('image was too large, pick another');
	}
	else{
		document.getElementById('specimage').setAttribute('src','/img/weeklyspec/'+document.specialsForm.spec_id.value+'.'+msg+'?time='+(new Date().valueOf()));
		$('#removeLogo').fadeIn('fast');
	}
}

core.weeklySpecials.removeLogo=function(){
	document.getElementById('specimage').setAttribute('src',document.specialsForm.placeholder_image.value);
	$('#removeLogo').fadeOut('fast');
}

core.weeklySpecials.filterProducts=function(domain_id){	
	core.doRequest('/products/get_catalog',{
		'domain_id':domain_id?domain_id:0,
		'js_function':'weeklySpecials_updateProductsList'
	});
}

weeklySpecials_updateProductsList=function(prods){
	
	//core.alertHash(orgs);
	var opts = $('name="product_id"');
	opts.children().remove().end();
	opts.append($('<option>', { 'value' : (-99999999999)}).text('Show from all products')); 
	for(var key in prods) {
		opts.append($('<option>', { 'value' : key }).text(prods[key])); 
	}
}