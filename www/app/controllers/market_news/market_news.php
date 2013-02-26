<?php

class core_controller_market_news extends core_controller
{
	function delete()
	{
		global $core;
		core::log('trying to delete');
		core::model('market_news')->delete($core->data['mnews_id']);
		core_datatable::js_reload('market_news');
		core_ui::notification('market news deleted');
		#core::deinit();
	}
	
	function rules()
	{
		global $core;
		return new core_ruleset('marketnewsform',array(
			array('type'=>'min_length','name'=>'title','data1'=>4,'msg'=>'You must enter a title for your news story'),
		));

	}
	
	function update()
	{
		global $core;
		$core->dump_data();
		$this->rules()->validate('marketnewsform');
		$code = core::model('market_news')->import_fields('mnews_id','title','content','user_id', 'domain_id');
		$code->save('marketnewsform');		
		
		core_ui::notification($core->i18n('messages:generic_saved','news item'),false,($core->data['do_redirect'] != 1));
		if($core->data['do_redirect'] == 1)
			core::redirect('market_news','list');
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
		if($new->width < 400 && $new->height < 400)
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
