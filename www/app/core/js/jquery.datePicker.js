(function($) {
	$.fn.dateParse=function(d,f){
		d = new String(d).replace(/\s/,'-').replace(':','-').replace(',','-').replace('--','-').split('-');
		f = new String(f).replace(/\s/,'').replace(',','-').replace('-','').replace(':','');
		var p = ['y','m','d','h','i','s','M'];
		var m = {'Jan':0,'Feb':1,'Mar':2,'Apr':3,'May':4,'Jun':5,'Jul':6,'Aug':7,'Sep':8,'Oct':9,'Nov':10,'Dec':11};
		var r = [];
		for (var i = 0; i < p.length; i++){
			var v = new String(d[f.indexOf(p[i])]).trim();
			if(i<6)	v = parseInt(v);
			if(p[i] == 'm')
				v--;
				
			if(i<6)
				r[i] = (v >=0)?v:0;
			else
				r[i] = v;
		}
	
		if(f.indexOf('M') >= 0)
			r[1] = m[r[6]];
		
		if(r[0]==0 && (d = new Date()))
			r=[d.getFullYear(),(d.getMonth()),d.getDate(),d.getHours(),d.getMinutes(),d.getSeconds()];
		return r;
	};
	
	$.fn.datePickerOnChanges={};
	
	$.fn.datePicker = function(onChange) {
		if(!document.getElementById('datePicker'))
			$.fn.datePicker.addPicker();
		this.each(function() {
			$(this).click(function(){
				var pos = $(this).offset();
				$.fn.datePicker.lastElem = $(this);
				$.fn.datePicker.showPicker(pos.top,pos.left,$(this).width(),$(this).val(),$(this).attr('format'));
				
				$.fn.datePickerOnChanges[$(this).attr('id')] = onChange;
			});
		});
	};
	
	
	
	$.fn.datePicker.addPicker=function(){
		var d=['Su','Mo','Tu','We','Th','Fr','Sa'];
		var h = '';
		h+='<div id="datePicker" style="position: absolute;display:none;">';
		h+='<table class="datePicker" style="width:100%;">';
		h+='<col width="20" />';
		h+='<col width="20" />';
		h+='<col width="" />';
		h+='<col width="20" />';
		h+='<col width="20" />';

		h+='<tr>';
			h+='<th onclick="$.fn.datePicker.change(0,-1);" class="datePicker datePickerButton">&laquo;</td>';
			h+='<th onclick="$.fn.datePicker.change(1,-1);" class="datePicker datePickerButton">&lt;</td>';
			h+='<th id="datePicker_cur" class="datePicker">April, 2011</td>';
			h+='<th onclick="$.fn.datePicker.change(1,1);" class="datePicker datePickerButton">&gt;</td>';
			h+='<th onclick="$.fn.datePicker.change(0,1);" class="datePicker datePickerButton">&raquo;</td>';
		h+='</tr></table>';
		h+='<table class="datePicker" style="width:100%;">';
		h+='<tr>'
		for (var i = 0; i < d.length; i++)
			h+='<th class="datePicker">'+d[i]+'</td>';
		h+='</tr>';
		
		var d = 0;
		for (var i = 0; i < 7; i++){
			h+='<tr id="datePicker_'+i+'">';
			for (var j = 0; j < 7; j++,d++)
				h+='<td id="datePicker_d'+d+'" class="datePicker" onclick="$.fn.datePicker.set('+d+');">&nbsp;</td>';
			h+='</tr>';
		}
		h+='</div>';
		$('body').append(h);
	};
	
	$.fn.datePicker.change=function(p,v){
		$.fn.datePicker.current[p] += (v);
		if(p==1 && $.fn.datePicker.current[1]>11){	$.fn.datePicker.current[1]=0;$.fn.datePicker.current[0]++;};
		if(p==1 && $.fn.datePicker.current[1]<0){	$.fn.datePicker.current[1]=11;$.fn.datePicker.current[0]--;};
		$.fn.datePicker.updatePicker();
	}
	
	$.fn.datePicker.getStartDay=function(){
		var c = $.fn.datePicker.current;
		var d = new Date(c[0],c[1],1);
		d = new Date(d.valueOf() - (86400000 * d.getDay()));
		return [d.getFullYear(),(d.getMonth()),d.getDate(),d.getHours(),d.getMinutes(),d.getSeconds(),d.getDay()];
	}
	
	$.fn.datePicker.getEndDay=function(){
		var c = $.fn.datePicker.current;
		var d = new Date(new Date(c[0],c[1]+1,1).valueOf() - 86400000);
		d = new Date(d.valueOf() + ((6 - d.getDay()) * 86400000));
		return [d.getFullYear(),(d.getMonth()),d.getDate(),d.getHours(),d.getMinutes(),d.getSeconds(),d.getDay()];
	}
	
	$.fn.datePicker.daysInMonth=function(d){
		return new Date(new Date(d[0],d[1]+1,1).valueOf() - 86400000).getDate();
	}
	
	$.fn.datePicker.updatePicker=function(){
		var c = $.fn.datePicker.current;
		var m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
		var idx=[];
		
		
		var s = $.fn.datePicker.getStartDay();
		var e = $.fn.datePicker.getEndDay();
		var dims = $.fn.datePicker.daysInMonth(s);
		var dimc = $.fn.datePicker.daysInMonth(c);
		//var dime = $.fn.datePicker.daysInMonth(e);
		
		// build the index here
		// if the start month isn't the same as teh current month
		var d=0;
		if(s[1] != c[1])
			for (var i = s[2]; i <= dims; i++,d++)
				idx.push([s[0],s[1],i,d]);

		// the main index
		for (i = 1; i <= dimc; i++,d++){
			idx.push([c[0],c[1],i,d]);
			if(d==7)	d=0;
		}
		
		// if the end month isn't the same as teh current month
		if(e[1] != c[1])
			for (var i = 1; i <= e[2]; i++,d++){
				idx.push([e[0],e[1],i,d]);
			}
		
		for (var i = 0; i < idx.length; i++){
			$('#datePicker_d'+i).html(idx[i][2]).toggleClass('datePicker_curMonth',(idx[i][1] == c[1]));;
		}
		
		$('#datePicker_6')[((i<43)?'hide':'show')]();	
		$('#datePicker_5')[((i<36)?'hide':'show')]();	
		
		$.fn.datePicker.index = idx;

		$('#datePicker_cur').html(m[c[1]]+', '+c[0]);		
	}
	$.fn.datePicker.showPicker=function(top,left,width,val,format){
		if(format+'' == '' || format+'' == 'undefined')	format='ymdhis';
		val = $.fn.dateParse(val,format);
		$.fn.datePicker.current = val;
		$.fn.datePicker.format = format;
		$.fn.datePicker.updatePicker();
		$('#datePicker').css('top',top+'px').css('left',left+'px').css('width',width+'px').show('fast');
	};
	$.fn.datePicker.set=function(idx){
		var v = $.fn.datePicker.index[idx];
		var d = new Date(v[0],v[1],v[2]);
		var m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
		
		switch($.fn.datePicker.format){
			case 'ymdhis':	v = d.getFullYear()+'-'+$.fn.datePicker.zPad((d.getMonth()+1))+'-'+$.fn.datePicker.zPad((d.getDate())); break;
			case 'M j, y':	v = m[(d.getMonth())]+' '+(d.getDate())+', '+d.getFullYear(); break;
		}
		$.fn.datePicker.lastElem.val(v);
		var id = $.fn.datePicker.lastElem.attr('id');
		if(typeof($.fn.datePickerOnChanges[id]) == 'function')
			$.fn.datePickerOnChanges[id](id+'',v+'','mike');
		$('#datePicker').hide('fast');
	}
	$.fn.datePicker.zPad=function(s){
		s = new String(s);
		return (s.length == 1)?'0'+s:s;
	};
	$.fn.datePicker.trim=function(s){
		s = new String(s);
		return (s.length == 1)?'0'+s:s;
	};
})(jQuery);

String.prototype.trim=function(){return this.replace(/^\s\s*/, '').replace(/\s\s*$/, '');};