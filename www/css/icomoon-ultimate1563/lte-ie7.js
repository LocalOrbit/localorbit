/* Use this script if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'icomoon-ultimate\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-home' : '&#xe000;',
			'icon-home-2' : '&#xe001;',
			'icon-pencil' : '&#xe002;',
			'icon-newspaper' : '&#xe003;',
			'icon-image' : '&#xe004;',
			'icon-bullhorn' : '&#xe005;',
			'icon-file' : '&#xe006;',
			'icon-book' : '&#xe007;',
			'icon-book-2' : '&#xe008;',
			'icon-books' : '&#xe009;',
			'icon-profile' : '&#xe00a;',
			'icon-tag' : '&#xe00b;',
			'icon-cart-checkout' : '&#xe00c;',
			'icon-cart' : '&#xe00d;',
			'icon-coin' : '&#xe00e;',
			'icon-coins' : '&#xe00f;',
			'icon-credit' : '&#xe010;',
			'icon-address-book' : '&#xe011;',
			'icon-mail-send' : '&#xe012;',
			'icon-calendar' : '&#xe013;',
			'icon-print' : '&#xe014;',
			'icon-database' : '&#xe015;',
			'icon-bubbles' : '&#xe016;',
			'icon-users' : '&#xe017;',
			'icon-user' : '&#xe018;',
			'icon-busy' : '&#xe019;',
			'icon-binoculars' : '&#xe01a;',
			'icon-key' : '&#xe01b;',
			'icon-settings' : '&#xe01c;',
			'icon-cogs' : '&#xe01d;',
			'icon-bars' : '&#xe01e;',
			'icon-apple-fruit' : '&#xe01f;',
			'icon-lamp' : '&#xe020;',
			'icon-paper-plane' : '&#xe021;',
			'icon-truck' : '&#xe022;',
			'icon-list' : '&#xe023;',
			'icon-signup' : '&#xe024;',
			'icon-clipboard' : '&#xe025;',
			'icon-grid' : '&#xe026;',
			'icon-grid-2' : '&#xe027;',
			'icon-download' : '&#xe028;',
			'icon-upload' : '&#xe029;',
			'icon-flag' : '&#xe02a;',
			'icon-eye' : '&#xe02b;',
			'icon-thumbs-up' : '&#xe02c;',
			'icon-stack-checkmark' : '&#xe02d;',
			'icon-plus-circle' : '&#xe02e;',
			'icon-minus-circle' : '&#xe02f;',
			'icon-close' : '&#xe030;',
			'icon-checkmark' : '&#xe031;',
			'icon-arrow-right' : '&#xe032;',
			'icon-arrow-down' : '&#xe033;',
			'icon-checkbox-checked' : '&#xe034;',
			'icon-checkbox-unchecked' : '&#xe035;',
			'icon-filter' : '&#xe036;',
			'icon-font-size' : '&#xe03b;',
			'icon-bold' : '&#xe03c;',
			'icon-underline' : '&#xe03d;',
			'icon-italic' : '&#xe037;',
			'icon-paragraph-left' : '&#xe038;',
			'icon-paragraph-center' : '&#xe039;',
			'icon-paragraph-right' : '&#xe03a;',
			'icon-mail' : '&#xe03e;',
			'icon-mail-2' : '&#xe03f;',
			'icon-twitter' : '&#xe040;',
			'icon-feed' : '&#xe041;',
			'icon-facebook' : '&#xe042;',
			'icon-share' : '&#xe043;',
			'icon-close-2' : '&#xe044;',
			'icon-stack-list' : '&#xe045;',
			'icon-happy' : '&#xe046;',
			'icon-smiley' : '&#xe047;',
			'icon-sad' : '&#xe048;',
			'icon-shocked' : '&#xe049;',
			'icon-remove' : '&#xe04a;',
			'icon-steps' : '&#xe04b;',
			'icon-direction' : '&#xe04c;',
			'icon-compass' : '&#xe04d;',
			'icon-clock' : '&#xe04e;',
			'icon-bubble' : '&#xe04f;',
			'icon-search' : '&#xe050;',
			'icon-health' : '&#xe051;',
			'icon-pie' : '&#xe052;',
			'icon-wand' : '&#xe054;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, html, c, el;
	for (i = 0; i < els.length; i += 1) {
		el = els[i];
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};