/*
	Script to make ordinary <INPUT type="text"/> act like a slider control.
	Use with JQuerySlider.css to provide the look of simple slider control.
	(Requires a reference to the JQuery library found at http://jquery.com/src/latest/)
	(Hats-off to John Resig for creating the excellent JQuery library. It is fab.)

	This control is achieved with no extra html markup whatsoever and uses unobtrusive javascript.

	Written by George Adamson, Software Unity, 2006 (george.jquery@softwareunity.com).

	Do contact me with comments and suggestions but please don't ask for support.
	As much as I'd love to help with specific problems I have plenty to get on with already!

	Go ahead and use it in your own projects. This code is provided 'as is'.
	Sure I've tested in heaps of ways. Its good for me, but you use it at your own risk.
	SoftwareUnity and I are certainly not responsible if your computer sets fire to the sofa,
	hacks into the pentagon, hijacks a plane or gives you any kind of hassle whatsoever.

	Apologies for the blatent use of company initials on class names etc, but I find them
	very helpful in preventing conflicts with other class names in other stylesheets.
*/

var suSLIDER_BTN_IMG_WIDTH = 20;

var options = {
	min:0,
	max:100,
	step:5,
	widthBtnImg:20,
	isSliding:false
}

$(document).ready(function(){

	// Convert every <input> text element with class="suSlider" to a Slider control:

	// Note the use of .filter() to test for presence of a class before removing it.
	// This is not strictly necessary but in my tests it did seem to noticably reduce cpu load.

	$("INPUT[@type='text'].suSlider").each(function(){	// Sadly $("TEXT.suSpinButton") does not work, though it is described at http://jquery.com/docs/CustomExpressions.

		// Init custom attributes:
		this.suIsSliding	= false;												// Flag used to see whether slider is currently being dragged.
		this.suBtnImgWidth	= suSLIDER_BTN_IMG_WIDTH;								// With of img used to represent the slider button.
		if(isNaN(this.suValStep)) this.suValStep = (isNaN(this.stepvalue) ? 1	: this.stepvalue);	// Read html minvalue attribute if provided.
		if(isNaN(this.suValMin))  this.suValMin	 = (isNaN(this.minvalue)  ? 0	: this.minvalue);	// Read html minvalue attribute if provided.
		if(isNaN(this.suValMax))  this.suValMax  = (isNaN(this.maxvalue)  ? 100	: this.maxvalue);	// Read html maxvalue attribute if provided.
		if(Number(this.suValMin) > Number(this.suValMax)){var t=this.suValMin; this.suValMin=this.suValMax; this.suValMax=t;}
		if(isNaN(this.value)) this.value = this.suValMin;							// Set default value if not provided.
		this.value = Math.min(Math.max(this.value, this.suValMin), this.suValMax);	// Ensure Value is within Min/Max limits.
		this.suPtrL = (this.maxLength || 3) * 10;									// px from left of element where slider range begins. TODO: Devise way to measure width of n characters in current font.
		this.suPtrR = this.offsetWidth - this.suBtnImgWidth;						// px from left of element where slider range ends.
		this.style.backgroundPositionX = getBtnPosFromVal({target:this});			// Position slider button to represent current Value. (Function would normally expect to receive event param so we spoof it so it has a .target property to read!)
		this.setVal = setVal;														// Add method that will validate new values before setting this.value.

		$(this).mousedown(function(e){
			this.suIsSliding	= isMouseOverSliderBtn(e);
			e.suSliderEl		= this;									// Ensure event object includes reference to element (in case mouse has dragged off it).
			this.style.backgroundPositionX = getBtnPosFromVal(e);
		});

		$(this).mouseup(function(e){
			this.suIsSliding	= false;
			e.suSliderEl		= this;									// Ensure event object includes reference to element (in case mouse has dragged off it).
			this.style.backgroundPositionX = getBtnPosFromVal(e);
		});

		$(this).mousemove(function(e){
		// Style up/down buttons according to whether mouse is over one or neither:
			e.suSliderEl	= this;										// Ensure event object includes reference to element (in case mouse has dragged off it).
			if(this.suIsSliding) {										// Mouse button is down so react to mouse movement.
				setValFromPtrPos(e);									// Change Value according to slider position.
				this.style.backgroundPositionX = getBtnPosFromVal(e);	// Ensure slider img remains under pointer.
			}
			if(isMouseOverSliderBtn(e)){
				$(this).not(".suHilite").addClass("suHilite");
			}else{
				$(this).filter(".suHilite").removeClass("suHilite");
			}
		});

		$(this).mouseout(function(){
		// Reset up/down buttons to their normal appearance when mouse moves away:
			$(this).filter(".suHilite").removeClass("suHilite");
		});

		$(this).keyup(function(e){
		// Respond to typing in the slider textbox:
			this.style.backgroundPositionX = getBtnPosFromVal(e);
		});

		$(this).change(function(e){
		// Respond to value changes (to handle changes other than those caused by typing)
			this.style.backgroundPositionX = getBtnPosFromVal(e);
		});

		$(this).bind("mousewheel", function(e){
		// Respond to mouse wheel. (It returns up/dn motion in multiples of 120)
			var d=0;

			if(e.wheelDelta >= 120){
				d = +1;
			}else if(e.wheelDelta <= -120){
				d = -1;
			}

			this.setVal(this.value, this.suValStep * d)
			this.style.backgroundPositionX = getBtnPosFromVal(e);
			e.preventDefault();
		});

	});
});

function isMouseOverSliderBtn(e){
// Return true/false to indicate position of mouse over specified element.
// Called by mousemove/over/out events on Slider elements.
// Ideally we'd use event.offsetX/Y here but it is not available in all browsers,
// so we have to derive offset from element's position on the page compared to event.x/y.

	var el		= e.suSliderEl || e.target || e.srcElement;	// Textbox element in question. (The calling function should have set custom .suSliderEl property for us.)
	el.X		= elemX(el);								// X-coord of element. (This only reason we reset this every time this function is called is to allow for scenarios where the textbox might get repositioned)
	var	x	= e.pageX || e.x;
	var p		= getBtnPosFromVal(e);

	return ( (x > p + el.X) && (x < p + el.X + el.suBtnImgWidth) );
}

function setValFromPtrPos(e){
// Work out what the Value should be according to the current mouse position.
	var v;
	var el	= e.suSliderEl || e.target || e.srcElement;		// Element in question (textbox). (The calling function should have set custom .suSliderEl property for us.)
	el.X	= elemX(el);									// X-coord of element. (This only reason we reset this every time this function is called is to allow for scenarios where the textbox might get repositioned)
	var x	= (e.pageX || e.x) - el.X - el.suPtrL - (el.suBtnImgWidth / 2);			// Mouse Pointer x-coord from left edge of textbox.
	var ValRange = Math.abs(Number(el.suValMax) - Number(el.suValMin));				// Difference between Min and Max Value.
	var PtrRange = Number(el.suPtrR) - Number(el.suPtrL);					// Difference between Min and Max Button x-coord.

	if(x <= 0){
		v = el.suValMin;									// Pointer is beyond left-most btn position so default to Min Value.
	}else if(x >= PtrRange){
		v = el.suValMax;									// Pointer is beyond right-most btn position so default to Max Value.
	}else if(PtrRange == 0){
		v = el.suValMin;									// Avoid divide by zero error on next line and default to Min Value.
	}else{
		v = Number(el.suValMin) + (ValRange * (x / PtrRange));						// Convert position in Pointer range to Value in Value range.
	}

	return el.setVal(v);
}

function getBtnPosFromVal(e){
// Work out where the slider button should be to represent the current value.

	var el	= e.suSliderEl || e.target || e.srcElement;		// Element in question (textbox).

	if(isNaN(el.value)) el.value = el.suValMin;				// Use default value if not valid.
	var v = el.value - el.suValMin;							// Value relative to zero.
	var ValRange = el.suValMax - el.suValMin;				// MaxValue limit relative to zero.
	var PtrRange = el.suPtrR - el.suPtrL;					// BtnPos limit relative to zero.

	return el.suPtrL + Math.round( (v > 0) ? (v / ValRange) * PtrRange : 0 );
}

function setVal(v,inc){
// Set textbox.value to v after validating v (and add increment if provided)
// This is used as a custom method of the slider element (hence references to 'this')
	var v = Number(isNaN(v) ? this.suValMin : v)			// Ensure v is actually a number.
	v += (isNaN(inc) ? 0 : Number(inc));					// Add +/- increment if provided.
	v = Math.round(v / this.suValStep) * this.suValStep;	// Round v to nearest whole step.
	v = Math.min(Math.max(v, this.suValMin), this.suValMax);// Ensure v lies between min/max limits.
	this.value = v;
	return v;
}

function elemX(el,p) {
// Return x-coordinate of Element el.
// (Relative to Parent Element p, which defaults to page body if ommitted)

	var x		= el.offsetLeft, b = document.body; p = p || b;
	var ua		= navigator.userAgent.toLowerCase();
	var isIE	= ((ua.indexOf("msie") != -1) && (ua.indexOf("opera") == -1));

	while((el = el.offsetParent) && (el != p) && (el != b)) {
		if(!isIE || (el.currentStyle.position != 'relative') )
			x += el.offsetLeft;
	}

	return(x);
}

function elemY(el,p) {
// Return Y-coordinate of Element el.
// (Relative to Parent Element p, which defaults to page body if ommitted)

	var y		= el.offsetTop, b = document.body; p = p || b;
	var ua		= navigator.userAgent.toLowerCase();
	var isIE	= ((ua.indexOf("msie") != -1) && (ua.indexOf("opera") == -1));

	while((el = el.offsetParent) && (el != p) && (el != b)) {
		if(!isIE || (el.currentStyle.position != 'relative') )
			y += el.offsetTop;
	}

	return(y);
}
