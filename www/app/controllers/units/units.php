<?php 

class core_controller_units extends core_controller 
{
	function rules()
	{
		global $core;
		return new core_ruleset('unitsForm',array(
			array('type'=>'min_length','name'=>'single','data1'=>3,'msg'=>$core->i18n['error:units:single_length']),
			array('type'=>'min_length','name'=>'plural','data1'=>3,'msg'=>$core->i18n['error:units:plural_length']),
		));
	}
	
	function save_rules()
	{
		global $core;
		return new core_ruleset('unitsForm',array(
			array('type'=>'min_length','name'=>'NAME','data1'=>3,'msg'=>$core->i18n['error:units:single_length']),
			array('type'=>'min_length','name'=>'PLURAL','data1'=>3,'msg'=>$core->i18n['error:units:plural_length']),
		));
	}
	
	function do_request()
	{
		global $core;
		$this->rules()->validate();
		core::process_command('emails/unit_request',false,
			$core->session['first_name'].' '.$core->session['last_name'],
			$core->data['single'],
			$core->data['plural'],
			$core->data['additional_notes'],
			$core->data['prod_id'],
			$core->data['product_name']
		);
		
		core::js("location.href='#!products-edit--prod_id-".$core->data['prod_id']."';");
		core_ui::notification('request sent');
		core::deinit();
	}
	
	function update()
	{
		global $core;
		lo3::require_orgtype('admin');
		
		$this->save_rules()->validate();
		$code = core::model('Unit')->import_fields('UNIT_ID','NAME','PLURAL');
		$code->save('unitsForm');
		
		core_ui::notification($core->i18n('messages:generic_saved','unit'),false,($core->data['do_redirect'] != 1));
		if($core->data['do_redirect'] == 1)
			core::redirect('units','list');
	}
	
	function delete()
	{
		global $core;
		lo3::require_orgtype('admin');
		$unit = intval($core->data['UNIT_ID']);
		core_db::query('update products set unit_id=null where unit_id='.$unit);
		core_db::query('delete from Unit where UNIT_ID='.$unit);
		core_datatable::js_reload('units');
		core_ui::notification('unit deleted');
	}
	
}

?>