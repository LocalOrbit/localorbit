<?php

class core_controller_weekly_specials extends core_controller
{
	
	function remove_special()
	{
		global $core;
		
		if(!in_array($core->data['domain_id'],$core->session['domains_by_orgtype_id'][2]))
		{
			lo3::require_orgtype('admin');
		}
		
		core_db::query('update weekly_specials set is_active=0 where domain_id='.intval($core->data['domain_id']));
		if($core->data['refresh_table'] == 1)
		{
			core_datatable::js_reload('weekly_specials');
		}
	}
	
	function toggle_special()
	{
		global $core;
		
		if(!in_array($core->data['domain_id'],$core->session['domains_by_orgtype_id'][2]))
		{
			lo3::require_orgtype('admin');
		}
		
		# load the current special
		$current = core::model('weekly_specials')
			->collection()
			->filter('weekly_specials.domain_id',$core->data['domain_id'])
			->filter('weekly_specials.is_active',1)
			->load()
			->row();
		
		# always remove the current special
		core_db::query('update weekly_specials set is_active=0 where domain_id='.intval($core->data['domain_id']));
		
		# if the special sent was NOT the current special, then toggle it on
		if($current['spec_id'] != intval($core->data['spec_id']))
		{
			core_db::query('update weekly_specials set is_active=1 where spec_id='.intval($core->data['spec_id']));
			core_ui::notification('promotion activated');
		}
		else
		{
			core_ui::notification('promotion deactivated');
		}
	}
	
	function delete()
	{
		global $core;
		core::log('trying to delete');
		core::model('weekly_specials')->delete($core->data['spec_id']);
		core_datatable::js_reload('weekly_specials');
		core_ui::notification('featured deal deleted');
		#core::deinit();
	}
	
	function update()
	{
		global $core;
		$core->dump_data();
		if(lo3::is_market())
		{
			$code = core::model('weekly_specials')->import_fields('spec_id','domain_id','name','product_id','title','body');
		}
		else if(lo3::is_admin())
		{
			$code = core::model('weekly_specials')->import_fields('spec_id','domain_id','name','product_id','title','body');
		}
		else
		{
			lo3::require_orgtype('admin');
		}
		
		$code->save('specialsForm');		
		core_ui::notification($core->i18n('messages:generic_saved','weekly special'),false,($core->data['do_redirect'] != 1));
		if($core->data['do_redirect'] == 1)
			core::redirect('weekly_specials','list');
	}
	
	function save_spec1()
	{
		global $core;
		core::load_library('image');
		define('__CORE_ERROR_OUTPUT__','exit');
		
		#echo $core->paths['base'].'/../img/'.$core->data['spec_id'];
		
		#echo('prod_id: '.$core->data['prod_id'].'<br />');
		$new = new core_image($_FILES['spec_image']);
		$new->load_image();
		
		# check the sizes
		if($new->width <= 400 && $new->height <= 400)
		{
			# save this with the correct special
			#if(!is_dir($core->paths['base'].'/../img/weeklyspec/'.$core::model('weekly_specials')->data['spec_id']))
			#	mkdir($core->paths['base'].'/../img/weeklyspec/'.$core::model('weekly_specials')->data['spec_id']);

			# move the new file
			move_uploaded_file($new->path,$core->paths['base'].'/../img/weeklyspec/'.$core->data['spec_id'].'.'.$new->extension);
			echo('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">'.$new->extension.':done</body></html>');
			core::deinit(false);
		}
		else
		{
			exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">toolarge:done</body></html>');
		}
	}
	
	function remove_logo()
	{
		global $core;
		$fs_path  = $core->paths['base'].'/../img/weeklyspec/'.$core->data['spec_id'].'.';
		if(file_exists($fs_path.'png'))	
			unlink($fs_path.'png');
		else if(file_exists($fs_path.'jpg'))	
			unlink($fs_path.'jpg');
		else if(file_exists($fs_path.'gif'))	
			unlink($fs_path.'gif');
		core::js('core.weeklySpecials.removeLogo();');
	}
}

?>
