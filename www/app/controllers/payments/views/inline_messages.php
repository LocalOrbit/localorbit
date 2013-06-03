<?php


function get_inline_message($tab_name, $width=350) {
	global $core;
	if(lo3::is_admin()) {	
		switch(strtolower($tab_name)) {
			case 'overview':
				return core_ui::inline_message($width, $core->i18n['payments:is_admin:overview_title'], $core->i18n['payments:is_admin:overview']);
				break;
			case 'purchase_orders':	
				return core_ui::inline_message($width, $core->i18n['payments:is_admin:purchase_orders_title'], $core->i18n['payments:is_admin:purchase_orders']);
				break;
			case 'receivables':
				return core_ui::inline_message($width, $core->i18n['payments:is_admin:receivables_title'], $core->i18n['payments:is_admin:receivables']);
				break;
			case 'payables':
				return core_ui::inline_message($width, $core->i18n['payments:is_admin:payables_title'], $core->i18n['payments:is_admin:payables']);
				break;
			case 'payments':
				return core_ui::inline_message($width, $core->i18n['payments:is_admin:payments_title'], $core->i18n['payments:is_admin:payments']);
				break;
			case 'systemwide':
				return core_ui::inline_message($width, $core->i18n['payments:is_admin:systemwide_title'], $core->i18n['payments:is_admin:systemwide']);
				break;
		}
	} else if(lo3::is_market()) {	
		switch(strtolower($tab_name)) {
			case 'overview':
				return core_ui::inline_message($width, $core->i18n['payments:is_market:overview_title'], $core->i18n['payments:is_market:overview']);
				break;
			case 'purchase_orders':	
				return core_ui::inline_message($width, $core->i18n['payments:is_market:purchase_orders_title'], $core->i18n['payments:is_market:purchase_orders']);
				break;
			case 'receivables':
				return core_ui::inline_message($width, $core->i18n['payments:is_market:receivables_title'], $core->i18n['payments:is_market:receivables']);
				break;
			case 'payables':
				return core_ui::inline_message($width, $core->i18n['payments:is_market:payables_title'], $core->i18n['payments:is_market:payables']);
				break;
			case 'payments':
				return core_ui::inline_message($width, $core->i18n['payments:is_market:payments_title'], $core->i18n['payments:is_market:payments']);
				break;
		}
	} else if(lo3::is_seller()) {	
		switch(strtolower($tab_name)) {
			case 'overview':
				return core_ui::inline_message($width, $core->i18n['payments:is_seller:overview_title'], $core->i18n['payments:is_seller:overview']);
				break;
			case 'purchase_orders':	
				return core_ui::inline_message($width, $core->i18n['payments:is_seller:purchase_orders_title'], $core->i18n['payments:is_seller:purchase_orders']);
				break;
			case 'receivables':
				return core_ui::inline_message($width, $core->i18n['payments:is_seller:receivables_title'], $core->i18n['payments:is_seller:receivables']);
				break;
			case 'payables':
				return core_ui::inline_message($width, $core->i18n['payments:is_seller:payables_title'], $core->i18n['payments:is_seller:payables']);
				break;
			case 'payments':
				return core_ui::inline_message($width, $core->i18n['payments:is_seller:payments_title'], $core->i18n['payments:is_seller:payments']);
				break;
		}
	} else if(lo3::is_buyer()) {	
		switch(strtolower($tab_name)) {
			case 'overview':
				return core_ui::inline_message($width, $core->i18n['payments:is_buyer:overview_title'], $core->i18n['payments:is_buyer:overview']);
				break;
			case 'purchase_orders':	
				return core_ui::inline_message($width, $core->i18n['payments:is_buyer:purchase_orders_title'], $core->i18n['payments:is_buyer:purchase_orders']);
				break;
			case 'payables':
				return core_ui::inline_message($width, $core->i18n['payments:is_buyer:payables_title'], $core->i18n['payments:is_buyer:payables']);
				break;
			case 'payments':
				return core_ui::inline_message($width, $core->i18n['payments:is_buyer:payments_title'], $core->i18n['payments:is_buyer:payments']);
				break;
		}
	}
}

?>