function doFeaturePopup(src,width){
	var src = '<img src="/homepage/img/features/'+src+'.png" class="thumb" />';
	src += '<div class="feature_popup_closer" style="width: '+(width - 9)+'px;">';
	src += '<input style=" margin-left: '+(Math.floor(( width - 230 ) / 2))+'px;" type="button" class="btn btn_blue" value="Close" onclick="$(\'#popup3,#overlay\').fadeOut(300);" /></div>';
	$('#popup3').html(src);$('#popup3,#overlay').fadeIn(300);
}
