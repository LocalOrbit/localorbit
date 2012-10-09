$.fn.tabset = function(name) {
	$('#'+name+'-s1').addClass('tabswitch_on');
	$('#'+name+'-a1').show();
	for (var i = 1; i < 20; i++){
		var obj = document.getElementById(name+'-s'+i);
		if(obj){
			$(obj).click(Function('','$.fn.tabsetSwitch(\''+name+'\','+i+');'));
		}
	}
};

$.fn.tabsetSwitch=function(name,newOffset){
	var old;
	for (var i = 1; i < 20; i++){
		if(document.getElementById(name+'-s'+i)){
			if($('#'+name+'-s'+i).hasClass('tabswitch_on')){
				//alert('turning off
				$('#'+name+'-s'+i).removeClass('tabswitch_on')
				$('#'+name+'-a'+i).hide();
			}
		}
	}
	$('#'+name+'-s'+newOffset).addClass('tabswitch_on');
	$('#'+name+'-a'+newOffset).show();
}
	
