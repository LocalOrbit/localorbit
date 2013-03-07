core.ui={
	'maps':{},
	'closeHandle':0,
	'closeTime':3000,
	facebook : {
		id : '543819475652932',
		secret : 'e95944096d2ca36ae56593f509625cdd'
	}
}

core.ui.scrollTop=function(){
	$('body').scrollTop(0);
	$('html').scrollTop(0);
}

core.ui.error=function(content){

	var errorbox = bootbox.dialog(content, [{
        "label" : "Close",
        "icon"  : "icon-remove icon-white"
    }], { 'animate' : false });

	/*
	setTimeout(function() {
        errorbox.modal('hide');
    }, 3000);

	$('#notification_content').html(content);
	$('#notification').fadeIn('fast');
	core.ui.scrollTop();
	window.clearTimeout(core.ui.closeHandle);
	core.ui.closeHandle = core.ui.setCloseTimout('core.ui.errorClose();');
	*/
}

core.ui.hidesocial=function() {
	$('#facebook, #tweets').hide();
}

core.ui.twitterfeed=function (name) {
	var tweets = new jqTweet(name, "#tweets div.twitter-feed", 10);	
	tweets.loadTweets(function() { 
		$("#tweets div.twitter-header iframe").remove();
		$("#tweets div.twitter-header").append('<iframe allowtransparency="true" frameborder="0" scrolling="no" src="//platform.twitter.com/widgets/follow_button.html?show_screen_name=false&show_count=false&screen_name='+name+'" style="width:60px; height:20px;"></iframe>');
		$("#tweets").fadeIn(); 
	});	
}

core.ui.facebookfeed=function (name) {
	if (core.ui.facebook.token) {
		core.ui.pullfacebookfeed(name);
	} else {
		$.get('https://graph.facebook.com/oauth/access_token?client_id=' + core.ui.facebook.id + '&client_secret=' + core.ui.facebook.secret + '&grant_type=client_credentials' , function (data) {
			core.ui.facebook.token = data.split('=')[1];
			core.ui.pullfacebookfeed(name);
		});
	}
	$('.fb-follow').attr('data-href',"https://www.facebook.com/" + name)
}

core.ui.pullfacebookfeed = function (name) {
	$('#facebook > ol').facebookfeed({access_token : core.ui.facebook.token, id : name}, function () {
		$('#facebook').fadeIn();
	});
}

core.ui.errorClose=function(){
	$('#notification').fadeOut('slow');
	window.clearTimeout(core.ui.closeHandle);
	core.ui.closeHandle = 0;
}

core.ui.setCloseTimout=function(cmd){
	if(core.ui.closeHandle != 0){
		window.clearTimeout(core.ui.closeHandle);
		core.ui.closeHandle = 0;
	}
	window.setTimeout(cmd,core.ui.closeTime);
}

core.ui.notification=function(content){

	var modalbox = bootbox.dialog(content, [{
        "label" : "Ok!",
        "icon"  : "icon-ok-sign icon-white"
    }], { 'animate' : false });

	setTimeout(function() {
        modalbox.modal('hide');
    }, 2000);

	/*
	core.ui.scrollTop();
	$('#notification_content').html(content);
	$('#notification').fadeIn('fast');
	window.clearTimeout(core.ui.closeHandle);
	core.ui.closeHandle = core.ui.setCloseTimout('core.ui.notificationClose();');
	*/
}

core.ui.notificationClose=function(){
	$('#notification').fadeOut('slow');
	window.clearTimeout(core.ui.closeHandle);
	core.ui.closeHandle = 0;
}

core.ui.popup=function(icon,title,content,buttonSet){

	//$('#popup_content').html(content);
	switch(buttonSet){
		case 'cancel':

			var modalbox = bootbox.dialog(content, [{
		        "label" : "Cancel",
		        "icon"  : "icon-remove icon-white"
		    }], { 'animate' : false });

			setTimeout(function() {
		        modalbox.modal('hide');
		    }, 3000);

			//$('#popup_foot').html('<input type="button" class="button_primary" value="Cancel" onclick="core.ui.popupClose();" />');
			break;
		case 'close':

			var modalbox = bootbox.dialog(content, [{
		        "label" : "Close",
		        "icon"  : "icon-remove icon-white"
		    }], { 'animate' : false });

			setTimeout(function() {
		        modalbox.modal('hide');
		    }, 3000);

			//$('#popup_foot').html('<input type="button" class="button_primary" value="Close" onclick="core.ui.popupClose();" />');
			break;
		default:

			var modalbox = bootbox.dialog(content, { 'animate' : false });

			setTimeout(function() {
		        modalbox.modal('hide');
		    }, 3000);

			//$('#popup_foot').html(buttonSet);
			break;
	}

	//core.ui.scrollTop();
	//$('#overlay').fadeIn('fast');
	//$('#popup').fadeIn('fast');
}

core.ui.popupClose=function(){
	$('#overlay').fadeOut('fast');
	$('#popup').fadeOut('fast');
}

core.ui.dataTables={};
core.ui.dataTable=function(name,colCount,url,sortCol,sortDir,page,maxPage,size,displaySize,filterStates){
	this.name=name;
	this.colCount = colCount;
	this.url=url;
	this.sortCol = sortCol;
	this.sortDir=sortDir;
	this.page=page;
	this.maxPage = maxPage;
	this.size=size;
	this.renderedSize = displaySize;
	this.displaySize = displaySize;
	this.filterStates=filterStates;
	//alert('initing datatable: '+name+'. sizes: '+this.renderedSize+'/'+this.displaySize);
}

core.ui.dataTable.construct=function(name,colCount,url,sortCol,sortDir,page,maxPage,size,displaySize,filterStates){

	var dt = new core.ui.dataTable(name,colCount,url,sortCol,sortDir,page,maxPage,size,displaySize,filterStates);
	core.ui.dataTables[name] = dt;
}

core.ui.dataTable.prototype.changeFilterState=function(filter,value){
	//
	this.filterStates[filter] = value;
	this.page = 0;
	this.loadData();

}

core.ui.dataTable.prototype.changeSize=function(newSize){
	//alert('resizing to '+newSize);
	this.size = newSize;
	this.page = 0;
	this.loadData();
}

core.ui.dataTable.prototype.changeSort=function(column){
	this.page = 0;
	if(this.sortCol == column){
		this.sortDir = (this.sortDir == 'asc')?'desc':'asc';
	}else{
		this.sortCol = column;
		this.sortDir = 'asc';
	}
	for (var i = 0; i < 12; i++){
		var obj = $('#dt_'+this.name+'_col'+i);
		if(obj.length>0){
			obj.removeClass('dt_sort_asc');
			obj.removeClass('dt_sort_desc');
			if(i==this.sortCol){
				obj.addClass('dt_sort_'+this.sortDir);
				obj.addClass('dt_sortable');
			}else{
				obj.addClass('dt_sortable');
			}
		}else{
			i = 12;
		}
	}
	this.loadData();
}



core.ui.dataTable.prototype.changePage=function(dir){
	//alert('moving to '+dir);
	if(dir == 'first'){
		this.page = 0;
	}
	else if(dir == 'next'){
		this.page++;
	}
	else if(dir == 'previous'){
		this.page--;
	}
	else if(dir == 'last'){
		this.page = (this.maxPage - 1);
	}
	else{
		this.page = dir;
	}

	if(this.maxPage == 0){
		this.page = 0;
		alert('Already showing all rows');
		return;
	}

	if(this.page < 0){
		this.page = 0;
		alert('already on first page');
		return;
	}
	if(this.page == (this.maxPage )){
		this.page = (this.maxPage -1);
		alert('already on last page');
		return;
	}

	this.loadData();
}

core.ui.dataTable.prototype.loadData=function(format){
	var url = 'app/'+this.url;

	//core.alertHash(this);

	if(new String(this.url).indexOf('?') <= 0)
	{
		url += '?__hasparam=true';
	}else{
		url += '&__hasparam=true';
	}

	url += '&_reqtime='+ (Math.round(new Date().valueOf() / 1000).toString());
	url += '&get_datatable_data=1';
	url += '&'+this.name+'_sort_column='+this.sortCol;
	url += '&'+this.name+'_sort_direction='+this.sortDir;

	for(var key in this.filterStates){
		//alert(this.name+'__filter__'+key+': '+encodeURIComponent(this.filterStates[key]));
		url += '&'+this.name+'__filter__'+key+'='+encodeURIComponent(this.filterStates[key]);
	}
	if(format == 'csv' || format == 'pdf'){
		url += '&'+this.name+'_page=0';
		url += '&'+this.name+'_size=-1';
		url += '&format='+format;
		location.href=url;
	}else{
		url += '&'+this.name+'_page='+this.page;
		url += '&'+this.name+'_size='+this.size;
		$.getJSON(url,function(jsondata){
			core.ui.dataTables[jsondata.datatable.name].insertData(jsondata.datatable);
			var js = core.base64_decode(jsondata.js);
			if(js != '' && js+''!='undefined')
				eval(js);
			//eval();
		});
	}
	//alert('loading data: '+url);
}

core.ui.dataTable.prototype.insertData=function(jsondata){
	//alert('inserting data');
	this.adjustRows(jsondata.size,jsondata.data.length);
	this.adjustPager(jsondata.page,jsondata.max_page);
	for (var i = 0; i < jsondata.data.length; i++){
		for (var j = 0; j < jsondata.data[i].length; j++){
			//alert('trying to set '+'#dt_'+this.name+'_'+i+'_'+j);
			$('#dt_'+this.name+'_'+i+'_'+j).html(core.base64_decode(jsondata.data[i][j]));
		}
		//alert(core.base64_decode(jsondata.data[i][1]));
	}
	if(jsondata.data.length>0){
		$('#dt_'+this.name+'_nodata').hide();
		$('#dt_'+this.name+'_columns').show();
	}else{
		$('#dt_'+this.name+'_nodata').show();
		$('#dt_'+this.name+'_columns').hide();
	}
}



core.ui.dataTable.prototype.adjustRows=function(newsize,newLength){
	//alert('need to show '+newsize+'.\nthe new data length is '+newLength+'.\nwe have '+this.renderedSize+' rows rendered.\n we have '+this.displaySize+' displayed');
	if(this.displaySize > (newLength)){
		//alert('gotta turn rows off');
		for (var i = (this.displaySize); i > newLength; i--){
			//alert('turning off '+'#dt_'+this.name+'_'+(i - 1));
			$('#dt_'+this.name+'_'+(new String(i - 1))).hide();
			$('#dt_'+this.name+'_'+(new String(i - 1))+'_0').html('&nbsp;');
			this.displaySize--;
		}
	}
	if (this.renderedSize < newLength){
		var html = '';
		for (var i = (this.renderedSize); i < newLength; i++)
		{
			html += '<tr id="dt_'+this.name+'_'+i+'" class="dt'+(i%2)+'">';
			for (var j= 0; j < this.colCount; j++)
				html += '<td class="dt" id="dt_'+this.name+'_'+i+'_'+j+'">&nbsp;</td>';
			html += '</tr>';
			this.displaySize++;
		}
		this.renderedSize = newLength;
		$('#dt_'+this.name+' tr:last').before(html);
		// add more rows
	}
	//alert('need to show '+newsize+'.\nthe new data length is '+newLength+'.\nwe have '+this.renderedSize+' rows rendered.\n we have '+this.displaySize+' displayed');

	if(this.displaySize < newLength)
	{
		for (var i = this.displaySize; i < newLength; i++)
			$('#dt_'+this.name+'_'+(i)).show();
		this.displaySize = (newLength);
	}
}

core.ui.dataTable.prototype.adjustPager=function(page,maxPage){
	var selector = $('#dt_'+this.name+'_pager');
	if(this.maxPage == maxPage)
		selector.val(page);
	else{
		this.maxPage = maxPage;
		selector.children().remove().end();
		for (i = 0; i < maxPage; i++){
			selector.append($('<option>', { 'value' : i }).text('Page '+(i+1)+' of '+maxPage));
		}
	}
}

core.ui.dataTable.prototype.setFilterValue=function(filterName,newValue){
	//alert('new filter value set: '+filterName+'/'+newValue);
	this.filterStates[filterName] = newValue;
	this.page = 0;
	this.loadData();
}

core.ui.dataTable.updateFilter=function(dtFilterName,filtValue,testingVar){
	filterInfo = new String(dtFilterName).split('__filter__');
	core.ui.dataTables[filterInfo[0]].setFilterValue(filterInfo[1],filtValue);
	//alert('updating '+dtFilterName+' to '+filtValue+': '+testingVar);
}

core.ui.dataTable.prototype.handleTextFilter=function(dtFilterName,filtValue){
	this.filterStates[dtFilterName] = filtValue;
	this.page = 0;
	this.loadData();
	//alert('new val: '+filtValue);
}

core.ui.dataTable.filterToggle=function(baseId){
	var obj=$('#dt_'+baseId+'_filters');
	if(obj.css('overflow') == 'visible'){
		obj.css('overflow','hidden');
		obj.css('height','26px');
	}else{
		obj.css('overflow','visible');
		obj.css('height','auto');
	}
}

core.ui.map=function(newId,refObj,width,height,zoom){
	$(refObj).html('<div class="google_map" id="'+newId+'" style="width: '+width+'px;height: '+height+'px;"></div>');
	core.ui.maps[newId] = new google.maps.Map(document.getElementById(newId),{'zoom':zoom, 'mapTypeId': google.maps.MapTypeId.ROADMAP});
}

core.ui.mapCenterByCoord=function(id,latitude,longitude){
	core.log('centering map '+id+' on '+latitude+'/'+longitude);
	core.ui.maps[id].setCenter(new google.maps.LatLng(latitude,longitude));
}

core.ui.getLatLng=function(address,callbackSrc){
	var geocoder = new google.maps.Geocoder();
	geocoder.geocode(
		{'address':address},
		new Function('gcResult,gcStatus',callbackSrc)
	);
}

core.ui.mapCenterByAddress=function(id,address){
	var geocoder = new google.maps.Geocoder();
	var callbackSrc = '';
	callbackSrc += 'if(gcResult[0]){';
		callbackSrc += 'core.ui.mapCenterByCoord(\''+id+'\',gcResult[0].geometry.location.lat(),gcResult[0].geometry.location.lng());';
	callbackSrc += '}else{alert(\'Could not find coords for address\');}';
	core.ui.getLatLng(address,callbackSrc);
	//core.ui.maps[id].setCenter(new google.maps.LatLng(latitude,longitude));
}


core.ui.mapAddMarkerByAddress=function(id,address,content,imgPath){
	var geocoder = new google.maps.Geocoder();
	var callbackSrc = 'core.ui.mapAddMarkerByCoord(\''+id+'\',gcResult[0].geometry.location.lat(),gcResult[0].geometry.location.lng(),\''+content+'\',\''+imgPath+'\');';
	core.ui.getLatLng(address,callbackSrc);
}

core.ui.getLatLong=function(form,prefix){
	if(form[prefix+'address'].value != '' && form[prefix+'city'].value != '' && form[prefix+'postal_code'].value != ''){
		var address = form[prefix+'address'].value;
		address += ', '+form[prefix+'city'].value;
		address += ', '+form[prefix+'region_id'].options[form[prefix+'region_id'].selectedIndex].value;
		address += ' '+form[prefix+'postal_code'].value;
		var geocoder = new google.maps.Geocoder();

		geocoder.geocode(
			{'address':address},
			new Function('gcResult,gcStatus','core.ui.setLatLong(\''+form.name+'\',\''+prefix+'\',gcResult[0].geometry.location.lat(),gcResult[0].geometry.location.lng(),\''+content+'\');')
		);
	}
}

core.ui.setLatLong=function(form,prefix,lat,longitude){
	document[form][prefix+'latitude'].value = lat;
	document[form][prefix+'longitude'].value = longitude;
}

core.ui.mapAddMarkerByCoord=function(id,lat,lng,content,imgPath){
	console.log(lat+'/'+lng+'/'+core.base64_decode(content));
	var mapOpts = {
		'position': new google.maps.LatLng(lat,lng),
		'map': core.ui.maps[id],
		'title':core.base64_decode(content)
	}

	if(imgPath != '' && imgPath+'' != 'undefined'){
		mapOpts['icon'] = new google.maps.MarkerImage(imgPath);
		core.log('using custom marker image: '+imgPath);
	}

	var marker = new google.maps.Marker(mapOpts);
	//console.log('ready to apply content '+core.base64_decode(content)+' to '+core.ui.maps[id]);
	var infowindow = new google.maps.InfoWindow({
		 'content': core.base64_decode(content)
	});

	google.maps.event.addListener(marker, 'click', function() {
	  infowindow.open(core.ui.maps[id],marker);
	});

}

core.ui.checkDiv=function(name){
	var valField = $('#checkdiv_'+name+'_value');
	if(valField.val() == 0){
		core.ui.setCheckdiv(name,true);
	}else{
		core.ui.setCheckdiv(name,false);
	}
}

core.ui.setCheckdiv=function(name,newVal){
	var chkField = $('#checkdiv_'+name);
	var valField = $('#checkdiv_'+name+'_value');
	if(newVal){
		chkField.addClass('checkdiv_checked');
		valField.val(1);
	}else{
		chkField.removeClass('checkdiv_checked');
		valField.val(0);
	}
}

core.ui.radioDiv=function(name,radioGroup,allowRadioUnselect){
	var chkField = $('#radiodiv_'+name);
	var valField = $('#radiodiv_'+name+'_value');
	if(valField.val() == 0){
		//alert('trying to set '+name+' to true');
		core.ui.setRadiodiv(name,radioGroup,true);
	}else if(allowRadioUnselect==1) {
		core.ui.setRadiodiv(name,radioGroup,false);
	}
}

core.ui.setRadiodiv=function(name,radioGroup,newVal){
	var chkField = $('#radiodiv_'+name);
	var valField = $('#radiodiv_'+name+'_value');
	if(newVal){
		$('.radiodiv_group_'+radioGroup).each(function(){
			var id = $(this).attr('id');
			//alert(id);
			$(this).removeClass('radiodiv_checked');
			$('#'+id+'_value').val(0);
		});
		chkField.addClass('radiodiv_checked');
		valField.val(1);
	}else{
		chkField.removeClass('radiodiv_checked');
		valField.val(0);
	}
}

core.ui.checkAll=function(suffix,state){
	$('.checkall_'+suffix)[((state)?'attr':'removeAttr')]('checked','checked');
}

core.ui.getCheckallList=function(form,suffix){
	var checkedList = [];
	for (var i = 0; i < form.elements.length; i++){
		var elem = form.elements[i];
		if(elem.type == 'checkbox'){
			//console.log('checking '+elem.name);
			var name = new String(elem.name).split(/_/);
			//console.log('name parts: '+name.join('-----'));
			if(name[0] == 'checkall' && name[1] == suffix && name.length == 3){
				//console.log('got one. is it checked? '+((form.elements[i].checked)?'yes':'no'));
				if(form.elements[i].checked)
					checkedList.push(name[2]);
			}
		}
	}
	return checkedList;
}

core.ui.setSelect=function(obj,newVal){
	for (var i = 0; i < obj.options.length; i++){
		if(obj.options[i].value == newVal){
			obj.selectedIndex = i;
			i = obj.options.length;
		}
	}
}

core.ui.uploadFrame=function(formObj,newTarget,callback,newAction,idToCheck){
	if($('#'+idToCheck)){
		if($('#'+idToCheck).val() == ''){
			core.ui.error('no file selected');
			return;
		}
	}

	formObj.target=newTarget;
	var oldAction = formObj.action;
	if(newAction)
		formObj.action=newAction;

	//alert(formObj.action+'/'+formObj.target);
	core.watcherHandle = window.setInterval('core.ui.uploadWatcher(\''+newTarget+'\',\''+callback+'\');',500);
	formObj.submit();
	formObj.action = oldAction;
}

core.ui.uploadWatcher=function(iframeId,callback){
	var content = new String($('#'+iframeId).contents().find('html body').html());
	if(content.indexOf('done') > 0 ){
		window.clearInterval(core.watcherHandle);
		var id = content.split(':');
		//alert(id);
		//core.alertHash(id);
		id.pop();
		for (var i = 0; i < id.length; i++){
			if(typeof(id[i]) == 'string')
				id[i] = "'"+id[i]+"'";
		}

		callback = new String(callback).replace('{params}',id.join(','));
		$('#'+iframeId).contents().find('html body').html('&nbsp;')

		//alert(callback);
		eval(callback);
	}
}

core.ui.tagSet={'sets':{}};
core.ui.tagSet.init=function(name,mode){
	core.ui.tagSet.sets[name] = {'mode':mode,'filters':{}};
}

core.ui.tagSet.toggleFilter=function(setName,newId){
	var obj = $('#tagset_'+setName+'_'+newId);
	//alert(setName+': '+obj.hasClass('tagset_on'));
	if(obj.hasClass('tagset_link_on')){
		obj.removeClass('tagset_link_on');
	}else{
		obj.addClass('tagset_link_on')
	}
	core.ui.tagSet.sets[setName].filters[newId] = (!core.ui.tagSet.sets[setName].filters[newId]);
	//core.ui.tagSet.updateLinks(setName);
	core.ui.tagSet.apply(setName);
}



core.ui.tagSet.apply=function(setName){
	var hasFilters = false;
	var requiredClasses = [];
	for(var key in core.ui.tagSet.sets[setName].filters){
		if(core.ui.tagSet.sets[setName].filters[key])
			requiredClasses.push(key)
	}
	if(requiredClasses.length > 0){
		$('.tagset_'+setName).each(function(){
			var show = true;
			for (var i = 0; i < requiredClasses.length; i++){
				if(!$(this).hasClass('tagset_'+setName+'_'+requiredClasses[i]))
					show=false;
			}
			$(this)[((show)?'removeClass':'addClass')]('tagset_hide');
		});
	}else{
		$('.tagset_'+setName).each(function(){
			$(this).removeClass('tagset_hide');
		});
	}
}

core.ui.getFieldHash=function(formObj,fieldList){
	returnVal={};
	for (var i = 0; i < fieldList.length; i++){
		returnVal[fieldList[i]]=$(formObj[fieldList[i]]).val();
	}
	return returnVal;
}

core.ui.clearFields=function(formObj,clearFields,zeroFields,checkedFields){
	if(typeof(zeroFields) != 'object')
		zeroFields = [];
	if(typeof(checkedFields) != 'object')
		checkedFields = [];
	for (var i = 0; i < clearFields.length; i++){
		switch(formObj[clearFields[i]].type){
			case 'text':
				formObj[clearFields[i]].value = '';
				break;
			case 'checkbox':
				formObj[clearFields[i]].checked=false
				break;
			case 'select-one':
				formObj[clearFields[i]].selectedIndex=0;
				break;
			default:
				//alert('cant reset type: '+formObj[clearFields[i]].type);
				break;
		}
	}
	for (var i = 0; i < zeroFields.length; i++){
		formObj[zeroFields[i]].value = 0;
	}
	for (var i = 0; i < checkedFields.length; i++){
		formObj[checkedFields[i]].checked=true;
	}
}

core.ui.fullWidth=function () {
	$(document).ready(function () {
		$('#left').hide();
		$('#center').toggleClass('span9', false);
		$('#center').toggleClass('span12', true);
	});
}

core.ui.showLeftNav=function () {
	$(document).ready(function () {
		$('#left').show();
		$('#center').toggleClass('span9', true);
		$('#center').toggleClass('span12', false);
	});
}

core.ui.integerOnBlur= function (elem) {
	var jq = $(elem);
	var value = parseInt(jq.val());
	jq.val(value || 0);
};

core.ui.onFocusQty = function (elem) {
	var jq = $(elem);
	if (jq.val().toString().replace(/^\s+|\s+$/g, '') === '0') {
		jq.val('');
	}
};

core.ui.updateSelect=function(id,opts){
	var mySelect = $("#"+id);
	var curVal = mySelect.val();
	mySelect.empty();
	$.each(opts, function(key, value) {
		mySelect.append($("<option></option>").attr("value", value).text(key));
	});
	$("#"+id+" option[value=" + curVal +"]").attr("selected","selected") ;
}