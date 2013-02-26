<?php

class core_controller_dictionaries extends core_controller
{
	function load_into_session()
	{
		global $core;
		core::log('loading into session');
		if($core->config['db']['connected'])
			$core->session['i18n'] = core::model('phrases')->get_phrases();
		
	}
	
	function update()
	{
		global $core;
		#core::log(print_r($core->data,true));
		$phrases = core::model('phrases')->collection();
		foreach($phrases as $phrase)
		{
			$core->data['phrase_'.$phrase['phrase_id']] = str_replace('%7Blink%7D','{link}',$core->data['phrase_'.$phrase['phrase_id']]);
			$core->data['phrase_'.$phrase['phrase_id']] = str_replace('%7Bactivate%7D','{activate}',$core->data['phrase_'.$phrase['phrase_id']]);
			if($phrase['default_value'] != $core->data['phrase_'.$phrase['phrase_id']])
			{
				$phrase['default_value'] = $core->data['phrase_'.$phrase['phrase_id']];
				$phrase->save();
			}
		}
		core_ui::notification('updated');
	}
}


?>