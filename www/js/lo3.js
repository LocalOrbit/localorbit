core.lo3={}

core.lo3.rollOver=function(img){
	var src=new String(img.getAttribute('src'));
	img.setAttribute('src',src.replace('_off.','_over.'));
}
core.lo3.rollOut=function(img){
	var src=new String(img.getAttribute('src'));
	img.setAttribute('src',src.replace('_over.','_off.'));
}

core.lo3.inArray = function(thisArray,value){
	for (var i=0; i < thisArray.length; i++) 
		if (thisArray[i] == value) 
			return true;
	return false;
};

core.lo3.animateContentLoad=function(effectSelector1,effectSelector2){
	$(effectSelector1).slideDown(900);
	$(effectSelector2).fadeIn(800);
}


core.lo3.homepageStartup=function(){
	window.clearInterval(core.ui.playInterval);
	window.clearTimeout(core.ui.slideshowTimeout);
	core.log('timeouts cleared by new slideshow (homepage)');
	
	$(function(){
		$('#slides_homepage').slides({
			'preload': true,
			'preloadImage': 'img/default/loading-progress.gif',
			'play': 6500,
			'next':'slideshow_next',
			'prev':'slideshow_prev',
			'pause': 5500,
			'hoverPause': false,
			'animationStart': function(current){
				$('.caption,.slideshow_next,.slideshow_prev').hide();
				if(!document.getElementById('slides_homepage')){
					window.clearInterval(core.ui.playInterval);
					window.clearTimeout(core.ui.slideshowTimeout);
					core.log('timeouts cleared by page change');
				}
				core.log('animationStart on slide: '+current);
			},
			'animationComplete': function(current){
				$('.caption,.slideshow_next,.slideshow_prev').fadeIn(300);
				core.log('animationComplete on slide: '+current);
			},
			'slidesLoaded': function() {
				$('.caption,.slideshow_next,.slideshow_prev').fadeIn(300);
			}
		});
	});
}

core.lo3.tours = {};
core.lo3.tourPopup=function(id){
	if(!core.lo3.tours[id]){
		window.clearInterval(core.ui.playInterval);
		window.clearTimeout(core.ui.slideshowTimeout);
		core.log('timeouts cleared by new slideshow');

		core.lo3.tours[id] = $('#slides_tour_'+id).slides({
			'preload': true,
			'preloadImage': 'img/default/loading-progress.gif',
			'play': 9700,
			'next':'slideshow_next',
			'prev':'slideshow_prev',
			'paginationClass':'pagination_tour',
			'pause': 8500,
			'hoverPause': false,
			'animationStart': function(current){
				$('.caption,.slideshow_next,.slideshow_prev').hide();
				core.log('animationStart on slide: '+current);
			},
			'animationComplete': function(current){
				$('.caption,.slideshow_next,.slideshow_prev').fadeIn(100);
				core.log('animationComplete on slide: '+current);
			},
			'slidesLoaded': function() {
				$('.caption,.slideshow_next,.slideshow_prev').fadeIn(100);
			}
		});
	}else{
		$('#slides_tour_'+id+' > ul > li').children(":first").click();
	}
	$('#tour_div_'+id).lightbox_me({
		'centered': true,
		'closeClick':true,
		'lightboxSpeed':'fast',
		'onClose':function(){
			//alert('clearing timeouts');
			//alert(core.ui.slideshowTimeout);
			window.clearInterval(core.ui.playInterval);
			window.clearTimeout(core.ui.slideshowTimeout);
			core.log('timeouts cleared by close');
		}
	}).trigger('reposition');
}


core.lo3.getUpdatedDataForSelector=function(dataMethod,paramValue,resultSelector,defaultText){
	var dataHash = {
		'filterParam':paramValue,
		'formName':resultSelector.form.getAttribute('name'),
		'selectorName':resultSelector.getAttribute('name'),
		'defaultText':defaultText
	};
	//core.alertHash(dataHash);
	core.doRequest('/options/'+dataMethod,dataHash);
}

core.lo3.insertUpdatedDataForSelector=function(data,formName,selectorName,defaultText){
	var field = $(document.forms[formName][selectorName]);
	field.children().remove().end();
	field.append($('<option>', { 'value' : (-99999999999)}).text(defaultText)); 
	for(var key in data) {
		field.append($('<option>', { 'value' : key }).text(data[key])); 
	}
}