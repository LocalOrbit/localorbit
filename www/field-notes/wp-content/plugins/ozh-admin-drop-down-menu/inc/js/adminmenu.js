/*
Part of Plugin: Ozh' Admin Drop Down Menu
http://planetozh.com/blog/my-projects/wordpress-admin-menu-drop-down-css/
*/

jQuery(document).ready(function() {
	if (oam_adminmenu) {
		// Remove unnecessary links in the top right corner
		jQuery('#user_info').css('z-index','81');
		// jQueryfication of the Son of Suckerfish Drop Down Menu for MSIE6 (die die die)
		// Original at: http://www.htmldog.com/articles/suckerfish/dropdowns/
		if (jQuery.browser.msie && jQuery.browser.version < 7) {
			jQuery('#ozhmenu li.ozhmenu_toplevel').each(function() {
				jQuery(this).mouseover(function(){
					jQuery(this).addClass('ozhmenu_over');
					if (jQuery.browser.msie) {ozhmenu_hide_selects(true);}
				}).mouseout(function(){
					jQuery(this).removeClass('ozhmenu_over');
					if (jQuery.browser.msie) {ozhmenu_hide_selects(false);}
				});
			});
		}
		// Function to hide <select> elements (display bug with MSIE)
		function ozhmenu_hide_selects(hide) {
			var hidden = (hide) ? 'hidden' : 'visible';
			jQuery('select').css('visibility',hidden);
		}

		// Dynamically float submenu elements if there are too many
		var menuresize = {};
		jQuery('.ozhmenu_toplevel span').mouseenter(
			function(){
				var target = jQuery(this).parent().parent().attr('id');
				if (!target || menuresize[target]) return; // we've hovered a speech bubble, or we've already reworked this menu
				// Make sure submenu is at least as wide as parent menu
				var parentwidth = parseInt( jQuery('#'+target ).css('width') );
				jQuery('#'+target+' ul').css('min-width', parentwidth+'px');
				// Now check if we need to split in columns
				var menulength = jQuery('#'+target+' ul li.ozhmenu_sublevel').length;
				if (menulength > oam_toomanypluygins) {
					var maxw = 0;
					// float every item to the left and get the biggest size
					jQuery('#'+target+' ul li.ozhmenu_sublevel').each(function(){
						var width = parseInt(jQuery(this).css('width')) || '180';
						maxw = Math.max( width, maxw );
					});
					// Resize the whole submenu
					if ( maxw ) {
						var cols = parseInt(menulength / oam_toomanypluygins)+1;
						jQuery('#'+target+' ul li.ozhmenu_sublevel').each(function(){
							jQuery(this).css('width', maxw+'px').css('float', 'left');
						});
						// Give the submenu a width = (max item width)*number of columns + 5px between each column
						jQuery('#'+target+' ul').css('width', ( cols*maxw + (5*(cols-1)) )+'px');
					}
					// Make sure if doesn't go off screen
					var offset = parseInt(jQuery('#'+target+' ul').position().left);
					var width = parseInt(jQuery('#'+target+' ul').css('width'));
					var wind = parseInt(jQuery(window).width());
					if( parseInt(offset+width) > wind ) {
						jQuery('#'+target+' ul').css('right', '10px');
					}

				}
				menuresize[target] = true;
			}
		);
		
		// #screen-meta move under our menu
		jQuery('#ozhmenu_wrap').after(jQuery('#screen-meta').clone(true).attr('id', 'screen-meta-ozhmenucopy')); // copy after menu and name it screen-meta-ozhmenucopy
		jQuery('#screen-meta').remove(); // delete original
		jQuery('#screen-meta-ozhmenucopy').attr('id', 'screen-meta').css('display','block'); // rename & show
		/**/
	}
})
