(function($) {
	$.fn.tabs = function() {
		this.each(function() {
			var index = 0;
			$(this).children('ul').children('li').each(function(){
				$(this).addClass('tab');
				if(index==0)
					$(this).addClass('tab_active');
				$(this).click(index,function(newIndex){
					var newTab = newIndex.data;
					var par = $(this).parent().parent();
					var counter = 0;
					par.children('ul').children('li').each(function(){
						if(counter == newTab){
							$(this).addClass('tab_active');
						}else{
							$(this).removeClass('tab_active');
						}
						counter++;
					});
					var counter = 0;
					par.children('div').each(function(){
						if(counter == newTab){
							$(this).addClass('tab_active').fadeIn();
						}else{
							$(this).removeClass('tab_active').hide();
						}
						counter++;
					});
				});
				index++;
			});
			var index = 0;
			$(this).children('div').each(function(){
				$(this).addClass('tab');
				if(index==0)
					$(this).addClass('tab_active').show();;
				index++;
			});
		});
	}
})(jQuery);