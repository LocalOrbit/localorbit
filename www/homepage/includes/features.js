function doFeaturePopup(src,width){
	var src = '<img src="/homepage/img/features/'+src+'.png" class="thumb" />';
	
	src += '<div class="feature_popup_closer">';
	src += '<img src="/homepage/img/icon_popup_close_grey.png" style="cursor: pointer;" onclick="$(\'#popup3,#overlay\').fadeOut(300);" /></div>';
	
	$('#popup3').html(src);$('#popup3,#overlay').fadeIn(300);
}
