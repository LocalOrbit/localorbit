/*
Part of Plugin: Ozh' Admin Drop Down Menu
http://planetozh.com/blog/my-projects/wordpress-admin-menu-drop-down-css/
*/

jQuery(document).ready(function() {
	if (oam_adminmenu) {
		// Remove unnecessary links in the top right corner
		var ozhmenu_uselesslinks = jQuery('#user_info p').html();
		ozhmenu_uselesslinks = ozhmenu_uselesslinks.replace(/<span id="gears-menu"><a href="tools.php">Turbo<\/a><\/span> \|/i, ''); // remove Turbo link
		jQuery('#user_info p').html(ozhmenu_uselesslinks);
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
		jQuery('.ozhmenu_toplevel span').mouseover(
			function(){
				var target = jQuery(this).parent().parent().attr('id');
				if (!target || menuresize[target]) return; // we've hovered a speech bubble, or we've already reworked this menu
				var menulength = jQuery('#'+target+' ul li').length;
				if (menulength > oam_toomanypluygins) {
					var maxw = 0;
					// float every item to the left and get the biggest size
					jQuery('#'+target+' ul li').each(function(){
						jQuery(this).css('float', 'left');
						maxw = Math.max(parseInt(jQuery(this).css('width')), maxw);
					});
					// Resize the whole submenu
					if (maxw) {
						var cols = parseInt(menulength / oam_toomanypluygins)+1;
						jQuery('#'+target+' ul li').each(function(){
							jQuery(this).css('width', maxw+'px');
						});
						// Give the submenu a width = (max item width)*number of columns + 20px between each column
						jQuery('#'+target+' ul').css('width', ( cols*maxw + (20*(cols-1)) )+'px');
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

		// WPMU : behavior for the "All my blogs" link
		jQuery( function($) {
			var form = $( '#all-my-blogs' ).submit( function() { document.location = form.find( 'select' ).val(); return false;} );
			var tab = $('#all-my-blogs-tab a');
			var head = $('#wphead');
			$('.blog-picker-toggle').click( function() {
				form.toggle();
				tab.toggleClass( 'current' );
				return false;
			});
		} );
	}
})
