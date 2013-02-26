if (!window.console || !console.firebug) {
	var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml", "group", "groupEnd",
				 "time", "timeEnd", "count", "trace", "profile", "profileEnd"];
	window.console = {};
	for (var i = 0; i < names.length; ++i) window.console[names[i]] = function() {};
}


var startPos=1;
var defaultServices = '"facebook","twitter","linkedin","email","sharethis"';
// Do not make tags on page load. call Make Tags once the user changes any settings.
var makeTagsEnabled = false;

function st_log() {
	if ($('#st_copynshare').attr('checked')) {
		var pubkey = $('#st_pkey').val();
		if (pubkey == "") {
			if ($('#st_pkey_hidden').val() != "")
				pubkey = $('#st_pkey_hidden').val();		
		}
		_gaq.push(['_trackEvent', 'WordPressPlugin', 'ClosedLoopBetaPublishers', pubkey]);
	}
	_gaq.push(['_trackEvent', 'WordPressPlugin', 'ConfigOptionsUpdated']);
	_gaq.push(['_trackEvent', 'WordPressPlugin', "Type_" + $("#st_current_type").val()]);
	if ($("#get5x").attr("checked")) {
		_gaq.push(['_trackEvent', 'WordPressPlugin', "Version_5x"]);
	} else if ($("#get4x").attr("checked")) {
		_gaq.push(['_trackEvent', 'WordPressPlugin', "Version_4x"]);
	}
}

function getStartPos(){
	var arr=[];
	arr['_large']=1;
	arr['_hcount']=2;
	arr['_vcount']=3;
	arr['classic']=4;
	arr['chicklet']=5;
	arr['chicklet2']=6;
	arr['_buttons']=7;
	if(typeof(arr[st_current_type])!=="undefined"){
		startPos=arr[st_current_type];
	}
}


jQuery(document).ready(function() {
	getStartPos();
	if(/updated=true/.test(document.location.href)){
		$('#st_updated').show();
	}
    jQuery("#carousel").jcarousel({
		size:7,
		scroll:1,
		visible:1,
		start:startPos,
		wrap:"both",
		itemFirstInCallback: {
		  onAfterAnimation: carDoneCB
		},
		itemFallbackDimension:460
	});

	$('#st_services').bind('keyup', function(){
		clearTimeout(stkeytimeout);
		stkeytimeout=setTimeout(function(){makeTags();},500);
	})
	
	$('#st_pkey').bind('keyup', function(){
		clearTimeout(stpkeytimeout);
		stpkeytimeout=setTimeout(function(){makeHeadTag();},500);
	})

	$('#st_widget').bind('keyup', function(){
		checkCopyNShare();
	})

	var services=$('#st_services').val();
	svc=services.split(",");
	for(var i=0;i<svc.length;i++){
		if (svc[i]=="fblike"){
			$('#st_fblike').attr('checked','checked');
		} else if (svc[i]=="plusone"){
			$('#st_plusone').attr('checked','checked');
		} else if (svc[i]=="pinterest"){
			$('#st_pinterest').attr('checked','checked');
		}
	}
	
	var tag=$('#st_widget').val();
	if (tag.match(/new sharethis\.widgets\.serviceWidget/)){
		$('#st_sharenow').attr('checked','checked');
	}
	if (tag.match(/new sharethis\.widgets\.hoverbuttons/)){
		$('#st_hoverbar').attr('checked','checked');
	}
	checkCopyNShare();
	var matches3 = tag.match(/"style": "(\d)*"/); 
	if (matches3!=null && typeof(matches3[1])!="undefined"){
		$('ul#themeList').find('li.selected').removeClass('selected');
		$.each($('ul#themeList').find('li'), function(index, value) {
			if ($(value).attr('data-value') == matches3[1]) {
				$(value).addClass('selected');
			}
		}); 
	}
	
	var markup=$('#st_tags').val();
	var matches=markup.match(/st_via='(\w*)'/); 
	if (matches!=null && typeof(matches[1])!="undefined"){
		$('#st_via').val(matches[1]);
	} 
	
	var matches2=markup.match(/st_username='(\w*)'/); 
	if (matches2!=null && typeof(matches2[1])!="undefined"){
		$('#st_related').val(matches2[1]);
	} 
	
	$('#st_fblike').bind('click', function(){
		if ($('#st_fblike').attr('checked')) {
			if ($('#st_services').val().indexOf("fblike")==-1) {
				var pos=$('#st_services').val().indexOf("plusone");
				if (pos==-1)
					$('#st_services').val($('#st_services').val()+",fblike");
				else {
					var str=$('#st_services').val();
					if (pos==0)
						$('#st_services').val("fblike,"+str.substr(pos));
					else
						$('#st_services').val(str.substr(0,pos-1)+",fblike"+str.substr(pos-1));
				}
			}
		}
		else {
			var pos=$('#st_services').val().indexOf("fblike");
			if (pos!=-1) {
				var str=$('#st_services').val();
				if (pos==0)
					$('#st_services').val(str.substr(pos+7));
				else
					$('#st_services').val(str.substr(0,pos-1)+str.substr(pos+6));
			}
		}
		clearTimeout(stpkeytimeout);
		stpkeytimeout=setTimeout(function(){makeTags();},500);
	})
	
	$('#st_plusone').bind('click', function(){
		if ($('#st_plusone').attr('checked')) {
			if ($('#st_services').val().indexOf("plusone")==-1) {
				$('#st_services').val($('#st_services').val()+",plusone");
			}
		}
		else {
			var pos=$('#st_services').val().indexOf("plusone");
			if (pos!=-1) {
				var str=$('#st_services').val();
				if (pos==0)
					$('#st_services').val(str.substr(pos+8));
				else
					$('#st_services').val(str.substr(0,pos-1)+str.substr(pos+7));
			}
		}
		clearTimeout(stpkeytimeout);
		stpkeytimeout=setTimeout(function(){makeTags();},500);
	})
	
	$('#st_pinterest').bind('click', function(){
		if ($('#st_pinterest').attr('checked')) {
			if ($('#st_services').val().indexOf("pinterest")==-1) {
				$('#st_services').val($('#st_services').val()+",pinterest");
			}
		}
		else {
			var pos=$('#st_services').val().indexOf("pinterest");
			if (pos!=-1) {
				var str=$('#st_services').val();
				if (pos==0)
					$('#st_services').val(str.substr(pos+10));
				else
					$('#st_services').val(str.substr(0,pos-1)+str.substr(pos+9));
			}
		}
		clearTimeout(stpkeytimeout);
		stpkeytimeout=setTimeout(function(){makeTags();},500);
	})
	
	$('#st_hoverbar').bind('click', function(){
		generateHoverbar("left");
	});
	
	$('#st_sharenow').bind('click', function(){
		generateShareNow();
	});
	
	$('#st_copynshare').bind('click', function(){
		generateCopyNShare();
	});

	$('#st_via').bind('keyup', function(){
		makeTags();
	})
	
	$('#st_related').bind('keyup', function(){
		makeTags();
	})
	
	$(".registerLink").live('click',function() {
		createOverlay();
	});
	
	$('ul#themeList li').click(function(){
		$('ul#themeList').find('li.selected').removeClass('selected');
		$(this).addClass('selected');
		updateShareNowStyle($(this).attr('data-value'));
	});
});

var stkeytimeout=null;
var stpkeytimeout=null;

function checkCopyNShare(){
	var tag=$('#st_widget').val();
	var pubkey = $('#st_pkey').val();
	if (pubkey == "") {
		if ($('#st_pkey_hidden').val() != "")
			pubkey = $('#st_pkey_hidden').val();		
	}
	if (tag.match(/doNotHash:(\s)?false/)){
		$('#st_copynshare').attr('checked','checked');
		$(".cnsRegister").hide();
		$(".cnsCheck").show();
	} else {
		if ((/[^rp\.\-]\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/).test(pubkey) || (/[^rp\.\-]\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/).test(tag)) {
			$(".cnsRegister").hide();
			$(".cnsCheck").show();
		} else {
			$(".cnsRegister").show();
			$(".cnsCheck").hide();
		}
	}
}

function getCopyNShare(){
	if ($('#st_copynshare').attr('checked')) {
		return ", hashAddressBar: true, doNotCopy: false, doNotHash: false";
	} else {
		return "";
	}
}

function generateCopyNShare(){
	var pubkey = $('#st_pkey').val();
	if (pubkey == "") {
		if ($('#st_pkey_hidden').val() != "")
			pubkey = $('#st_pkey_hidden').val();
	}

	var tag=$('#st_widget').val();
	tag = tag.replace(/stLight.options\({.*}\);/, 'stLight.options({publisher:"'+pubkey+'"'+getCopyNShare()+'});');
	$('#st_widget').val(tag);
	checkCopyNShare();
}

function generateShareNow(){
	var pubkey = $('#st_pkey').val();
	if (pubkey == "") {
		if ($('#st_pkey_hidden').val() != "")
			pubkey = $('#st_pkey_hidden').val();
	}
	
	var switchTo5x = "true";
	if($("#get4x").attr('checked')){
		switchTo5x = "false";
	}
	
	var tag='<script charset="utf-8" type="text/javascript">var switchTo5x='+switchTo5x+';</script>';
	
	//var tag='<script charset="utf-8" type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>';
	tag+='<script charset="utf-8" type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>';
	tag+='<script type="text/javascript">stLight.options({publisher:"'+pubkey+'"'+getCopyNShare()+'});</script>';
	if ($('#st_sharenow').attr('checked')) {
	
		if($('#st_hoverbar').attr('checked')){
		 
		 // Hoverbar already present and ShareNow Checked, need to move the hoverbar to right
		 $('#st_widget').val("");
		tag+='<script charset="utf-8" type="text/javascript" src="http://s.sharethis.com/loader.js"></script>';
		 $('#st_widget').val(tag);
		 defaultPosition = "right";
		 generateHoverbar(defaultPosition); 
		 
		 tag = $('#st_widget').val(); // get the present tag and append ShareNow option
		 
		}else{		
			// simple sharenow
			tag+='<script charset="utf-8" type="text/javascript" src="http://s.sharethis.com/loader.js"></script>';
		}
		tag+='<script charset="utf-8" type="text/javascript">var options={ "service": "facebook", "timer": { "countdown": 30, "interval": 10, "enable": false}, "frictionlessShare": false, "style": "3", publisher:"'+pubkey+'"};var st_service_widget = new sharethis.widgets.serviceWidget(options);</script>';
		
	$('#st_widget').val(tag);
		
	$.each($('ul#themeList').find('li'), function(index, value) {
		if ($(value).hasClass("selected")) {
			updateShareNowStyle($(value).attr('data-value'));
		}
	}); 
	
	}else{
		if($('#st_hoverbar').attr('checked')){			
			// ShareNow unchecked so move the HoverBar to left
			defaultPosition = "left";
			generateHoverbar(defaultPosition);		 
		}else{
			// Simple buttons with NO sharenow and NO hoverbar
			var tag='<script charset="utf-8" type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>';
			tag+='<script type="text/javascript">stLight.options({publisher:"'+pubkey+'"'+getCopyNShare()+'});</script>';
			$('#st_widget').val(tag);
		}
	}
	
}

function updateHoverBarServices(){
	
	if($('#st_hoverbar').attr('checked')){
		var defaultPosition = "left";
		if($('#st_sharenow').attr('checked')){		
				defaultPosition = "right";
		}
		generateShareNow();
	}
}

String.prototype.trim=function(){return this.replace(/^\s\s*/, '').replace(/\s\s*$/, '');};

function generateHoverbar(defaultPosition) {

	// In case of button style = sharethis (4/7) default. 
	// Remove FBLike, Google+,Pinterest from hoverbar services
	
	if($('.services').is(":visible")){		
		// Adding double quotes for each service separated by comma
		var chickletServices = $('#st_services').val();
		var chickletServicesArray = chickletServices.split(','); 
		var newchickletServicesArray = new Array();
		var jCounter = 0;
		for(var i=0; i<chickletServicesArray.length; i++){
			// Skip FbLike and PlusOne in HoverBar
			if(chickletServicesArray[i].trim() != 'plusone' && chickletServicesArray[i].trim() != 'fblike') {
				newchickletServicesArray[jCounter] = '"'+chickletServicesArray[i].trim()+'"';
				jCounter++;
			}
		}
		chickletServices = newchickletServicesArray.join(',');
	}else{
		chickletServices = defaultServices;
	}
	
	var pubkey = $('#st_pkey').val();
	if (pubkey == "") {
		if ($('#st_pkey_hidden').val() != "")
			pubkey = $('#st_pkey_hidden').val();
		else
			pubkey = generatePublisherKey();
	}
	
	var switchTo5x = "true";
	if($("#get4x").attr('checked')){
		switchTo5x = "false";
	}
	
	var tag='<script charset="utf-8" type="text/javascript">var switchTo5x='+switchTo5x+';</script>';
	
	//var tag='<script charset="utf-8" type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>';
	tag +='<script charset="utf-8" type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>';
	tag+='<script type="text/javascript">stLight.options({publisher:"'+pubkey+'"'+getCopyNShare()+'});</script>';	
	if ($('#st_hoverbar').attr('checked')) {
		
		if($('#st_sharenow').attr('checked')){		
			defaultPosition = "right";
			tag = $('#st_widget').val(); // get the present tag and append HoverBar option			
		}else{
			tag+='<script charset="utf-8" type="text/javascript" src="http://s.sharethis.com/loader.js"></script>';
		}	
		
		tag+='<script charset="utf-8" type="text/javascript">var options={ publisher:"'+pubkey+'", "position": "'+defaultPosition+'", "chicklets": { "items": ['+chickletServices+'] } }; var st_hover_widget = new sharethis.widgets.hoverbuttons(options);</script>';		
		
		$('#st_widget').val(tag);
		
	}else {
		if($('#st_sharenow').attr('checked')){
			// generating simple sharenow - hoverbar unchecked
			/*defaultPosition = "left";*/
			generateShareNow();
		}else{
			// Simple buttons with NO sharenow and NO hoverbar
			var tag='<script charset="utf-8" type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>';
			tag+='<script type="text/javascript">stLight.options({publisher:"'+pubkey+'"'+getCopyNShare()+'});</script>';
			$('#st_widget').val(tag);
		}	
	}
	
	
}

function updateShareNowStyle(themeid){
	var tag=$('#st_widget').val();
	tag=tag.replace(/"style": "\d*"/, "\"style\": \""+themeid+"\"");
	$('#st_widget').val(tag);
}

function makeHeadTag(){
	var val=$('#st_pkey').val();
	var tag=$('#st_widget').val();
	var reg=new RegExp("(publisher:)('|\")(.*?)('|\")",'gim');
	var b=tag.replace(reg,'$1$2'+val+'$4');
	$('#st_widget').val(b);
	checkCopyNShare();
}


function makeTags(){
	var services=$('#st_services').val();
	var type=$('#curr_type').html();
	svc=services.split(",");
	var tags=""
	var dt="displayText='share'";
	if(type=="chicklet2"){
		dt="";
	}else if(type=="classic"){
		tags="<span class='st_sharethis' st_title='<?php the_title(); ?>' st_url='<?php the_permalink(); ?>' displayText='ShareThis'></span>";
		$('#st_tags').val(tags);
		return true;
	}
	if(type=="chicklet" || type=="classic"){
		type="";
	}
	for(var i=0;i<svc.length;i++){
		if(svc[i].length>2){
			var via = "";
			var related = "";
			
			if (svc[i]=="twitter") {
				via=$('#st_via').val();
				related=$('#st_related').val();
				if (via!='') {
					via=" st_via='"+via+"'";
				}
				if (related!='') {
					related=" st_username='"+related+"'";
				}
			}
			if(type =="chicklet2")
				tags+="<span"+via+""+related+" class='st_"+svc[i]+"' st_title='<?php the_title(); ?>' st_url='<?php the_permalink(); ?>'></span>";
			else
				tags+="<span"+via+""+related+" class='st_"+svc[i]+type+"' st_title='<?php the_title(); ?>' st_url='<?php the_permalink(); ?>' displayText='"+svc[i]+"'></span>";
		}
	}
	$('#st_tags').val(tags);
	// If hover Bar is already selected
	updateHoverBarServices();
}


function carDoneCB(a,elem){
	var type=elem.getAttribute("st_type");
	$('.services').show()
	$('.fblikeplusone').show();
	if(type=="vcount"){
		$('#curr_type').html("_vcount");$("#st_current_type").val("_vcount");
		$('#currentType').html("<span class='type_name'>Vertical Count</span>");
	}else if(type=="hcount"){
			$('#curr_type').html("_hcount");$("#st_current_type").val("_hcount");
			$('#currentType').html("<span class='type_name'>Horizontal Count</span>");
	}else if(type=="buttons"){
			$('#curr_type').html("_buttons");$("#st_current_type").val("_buttons");
			$('#currentType').html("<span class='type_name'>Buttons</span>");
	}else if(type=="large"){
			$('#curr_type').html("_large");$("#st_current_type").val("_large");
			$('#currentType').html("<span class='type_name'>Large Icons</span>");
	}else if(type=="chicklet"){
			$('#curr_type').html("chicklet");$("#st_current_type").val("chicklet");
			$('#currentType').html("<span class='type_name'>Regular Buttons</span>");
	}else if(type=="chicklet2"){
			$('#curr_type').html("chicklet2");$("#st_current_type").val("chicklet2");
			$('#currentType').html("<span class='type_name'>Regular Buttons No-Text</span>");
	}else if(type=="sharethis"){
			$('.services').hide();
			$('.fblikeplusone').hide();
			$('#curr_type').html("classic");$("#st_current_type").val("classic");
			$('#currentType').html("<span class='type_name'>Classic</span>");
			
			// In case of button style = sharethis (4/7) default. 
			// Remove FBLike, Google+,Pinterest from hoverbar services
			updateHoverBarServices();
	}	
	if(makeTagsEnabled == true) {
	makeTags();	
}
	makeTagsEnabled = true;
}

$(".versionItem").click(function() {
	$(".versionItem").removeClass("versionSelect");
	$(this).addClass("versionSelect");	
});

var container = null;
function createOverlay () {
		container = $('<div id="registratorCodeModal" class="registratorCodeModal"></div><div class="registratorModalWindowContainer"><div id="registratorModalWindow"></div></div>');
		$("body").append(container);

		var div = container.find("#registratorModalWindow");
		var html = "<div class='registratorContainer'>";
		html += "<div onclick=javascript:container.remove(); class='registratorCloser'></div>";
		html += "<iframe height='390px' width='641px' src='http://sharethis.com/external-login' frameborder='0' />";
		div.append(html);
}

$(document).keydown(function(e) {
		if (e.keyCode == 27 && container!=null) { 
			container.remove(); 
		}
});
