function doFeaturePopup(src,width){
	var src = '<img src="/homepage/img/features/'+src+'.png" class="thumb" />';
	
	

	src += '<div class="feature_popup_closer">';
	src += '<img src="/homepage/img/icon_popup_close_grey.png?__updated=true" style="cursor: pointer;" onclick="$(\'#popup3,#overlay\').fadeOut(300);" /></div>';
	var pos = (new String(Math.floor(($('body').width() - width) / 2 )) + 'px');
	//alert(pos);
	$('#popup3').css({'margin-left':'0px','top':'40px','left':pos}).html(src);$('#popup3,#overlay').fadeIn(300);
	$('#overlay').click(function(){$('#popup3,#overlay').fadeOut(300);});
}
