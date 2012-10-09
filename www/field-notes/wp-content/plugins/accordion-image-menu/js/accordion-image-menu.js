/**************************************************************

	Script	: Image Menu
	Version	: 2.2
	Authors	: Samuel Birch
	Desc	: 
	Licence	: Open Source MIT Licence
	
	----  Modified for Accordion Image Menu Version:2.0 ----

**************************************************************/

var ImageMenu = new Class({
	
	getOptions: function(){
		return {
			onClose: Class.empty,
			openDim: 200,
			transition: Fx.Transitions.quadOut,
			duration: 400,
			open: null,
			border: 0, 
			pos: 'horizontal'
		};
	},

	initialize: function(elements, options){
		
		this.setOptions(this.getOptions(), options);
		
		this.elements = $$(elements);

		if (this.options.pos == 'vertical') this.prop = 'height';
		else this.prop = 'width';
		
		this.dimension = {};
		this.dimension.closed = this.elements[0].getStyle(this.prop).toInt();
		this.dimension.openSelected = this.options.openDim;
		this.dimension.openOthers = Math.round(((this.dimension.closed*this.elements.length) - (this.dimension.openSelected+this.options.border)) / (this.elements.length-1))
		
		
		this.fx = new Fx.Elements(this.elements, {wait: false, duration: this.options.duration, transition: this.options.transition});
		
		this.elements.each(function(el,i){
			el.addEvent('mouseenter', function(e){

				new Event(e).stop();
				this.reset(i);
				
			}.bind(this));
			
			el.addEvent('mouseleave', function(e){
				new Event(e).stop();
				this.reset(this.options.open);
				
			}.bind(this));
			
			var obj = this;		

			
		}.bind(this));
		
				this.reset(this.options.open);
		
	},
	
	reset: function(num){
		if($type(num) == 'number'){
			var dim = this.dimension.openOthers;
			if(num+1 == this.elements.length){
				dim += this.options.border;
			}
		}else{
			var dim = this.dimension.closed;
		}

		var obj = {};
		this.elements.each(function(el,i){
			var w = dim;
			if(i == this.elements.length-1){
				w = dim+5
			}

			if (this.options.pos == 'vertical') obj[i] = {'height': w};
			else obj[i] = {'width': w};

		}.bind(this));
		
		if($type(num) == 'number'){
		
			if (this.options.pos == 'vertical') obj[num] = {'height': this.dimension.openSelected};
			else obj[num] = {'width': this.dimension.openSelected};
		}
				
		this.fx.start(obj);
	}
	
});

ImageMenu.implement(new Options);
ImageMenu.implement(new Events);


/*************************************************************/