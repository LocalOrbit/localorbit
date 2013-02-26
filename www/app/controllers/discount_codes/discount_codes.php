<?php

class core_controller_discount_codes extends core_controller
{
	function rules()
	{
		global $core;
		return new core_ruleset('discForm',array(
			#array('type'=>'date_less_than','name'=>'start_date','data1'=>'end_date','msg'=>'Discount Must Start Before It Ends'),
		));
	}
	
	
	function delete()
	{
		global $core;
		core::log('trying to delete');
		core::model('discount_codes')->delete($core->data['disc_id']);
		core_datatable::js_reload('discount_codes');
		core_ui::notification('discount code deleted');
		#core::deinit();
	}
	
	function update()
	{
		global $core;
		
		$this->rules()->validate('discForm');
		
		$core->data['discount_amount'] = str_replace('%','',str_replace('$','',$core->data['discount_amount']));
		
		$core->dump_data();
		$code = core::model('discount_codes')->import_fields('disc_id','name','code','domain_id', 'start_date', 'end_date', 'discount_type','discount_amount', 'restrict_to_seller_org_id', 'restrict_to_buyer_org_id', 'min_order', 'max_order', 'nbr_uses_global', 'nbr_uses_org','restrict_to_product_id');
		$code['start_date'] = core_format::parse_date($core->data['start_date']).' 12:00:00';
		$code['end_date'] = core_format::parse_date($core->data['end_date']).' 12:00:00';
		$code['discount_amount'] = (-1 * $code['discount_amount']);
		
		if(count($core->session['domains_by_orgtype_id'][2]) == 1)
		{
			$code['domain_id'] = $core->session['domains_by_orgtype_id'][2][0];
		}
		$code->save('discForm');		
		core_ui::notification($core->i18n('messages:generic_saved','discount code'),false,($core->data['do_redirect'] != 1));
		if($core->data['do_redirect'] == 1)
			core::redirect('discount_codes','list');
	}
	
	function copy_code()
	{
		global $core;
		lo3::require_orgtype('market');
		$code = core::model('discount_codes')->load(intval($core->data['disc_id']));
		$code->__orig_data = array();
		$code->__data['disc_id'] = 0;
		#core::log(print_r($code->__data,true));
		$code['name'] = 'Copy of '.$code['name'];
		$code->save();
		core_datatable::js_reload('discount_codes');
		core_ui::notification('discount code copied');
	}
}

?>