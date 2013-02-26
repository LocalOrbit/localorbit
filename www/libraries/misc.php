<?php 

function custom_image()
{
	# first look for a domain specific version
	$override = $core->paths['base'].'/../img/'.$core->config['domain']['domain_id'].'/'.$name;
	$url      = $core->paths['web'].'/../img/'.$core->config['domain']['domain_id'].'/'.$name;
	#core::log('override path is: '.$override);
	if(file_exists($override.'.png'))
		return $url.'.png';
	if(file_exists($override.'.jpg'))
		return $url.'.jpg';
	if(file_exists($override.'.gif'))
		return $url.'.gif';
	return false;
}


function subform_buttons($saveaction='',$save_label='',$cancelaction='',$cancel_label='cancel')
{
	?>
	<div class="form-actions pull-right">
		<input type="button" class="btn btn-warning" value="<?=$cancel_label?>" onclick="<?=$cancelaction?>" />
		<input type="button" class="btn btn-primary" value="<?=$save_label?>" onclick="<?=$saveaction?>" />
	</div>
	<?
}

function save_buttons($require_pin = false,$save_continue='',$save_go_back='')
{
	global $core;

	if($save_continue == '')
	{
		$save_continue = 'core.submit(this.form.action,this.form);';
	}
	
	if($save_go_back == '')
	{
		$save_go_back = 'core.submit(this.form.action,this.form,{\'do_redirect\':1});';
	}
	
	if($core->session['sec_pin'] == 1)
	{
		$require_pin = false;
	}
	
	if($require_pin)
	{
		?>
	<div class="form-actions unlock_area" id="unlock_area">
		<input type="password" name="sec_pin" id="sec_pin" class="input-small" placeholder="4 Digit Pin" value="" />
		<input type="button" class="btn btn-primary" value="Unlock to Save" onclick="core.doRequest('/auth/unlock_pin',{'formname':this.form.getAttribute('name'),'sec_pin':$('#sec_pin').val()});" />
	</div>	
	<?}?>
	<div class="form-actions pull-right" id="main_save_buttons"<?=(($require_pin)?' style="display:none;"':'')?>>
		<input type="button" onclick="<?=$save_go_back?>" class="btn btn-primary" value="<?=$core->i18n['button:save_and_go_back']?>" />
		<input type="button" onclick="<?=$save_continue?>" class="btn btn-primary" name="save" value="<?=$core->i18n['button:save_and_continue']?>" />
	</div>
	<?
}
function save_only_button($cancel_button=false,$oncancel_js='',$require_pin = false)
{
	global $core;
	?>
	<div class="form-actions buttonset pull-right" id="main_save_buttons">
		<?if($cancel_button){?>
		<input type="button" class="btn" name="cancel" onclick="<?=$oncancel_js?>" value="<?=$core->i18n['button:cancel']?>" />
		<?}?>
		<input type="submit" class="btn btn-primary" name="save" value="<?=$core->i18n['button:save']?>" />
	</div>
	<?
}

function image($name,$domain_id=null)
{
	global $core;
	
	if(is_null($domain_id))
	{
		$domain_id = $core->config['domain']['domain_id'];
	}
	
	#core::log('trying to find image using '.$core->config['domain']['domain_id']);

	# first look for a domain specific version
	$override = $core->paths['base'].'/../img/'.$domain_id.'/'.$name;
	$url      = $core->paths['web'].'/../img/'.$domain_id.'/'.$name;
	#core::log('override path is: '.$override);
	if(file_exists($override.'.png'))
		return $url.'.png';
	if(file_exists($override.'.jpg'))
		return $url.'.jpg';
	if(file_exists($override.'.gif'))
		return $url.'.gif';
	
	# if none is found, then use the default version
	$default  = $core->paths['base'].'/../img/default/'.$name;
	$url      = $core->paths['web'].'/../img/default/'.$name;
	#core::log('default path is: '.$default);
	if(file_exists($default.'.png'))
		return $url.'.png';
	if(file_exists($default.'.jpg'))
		return $url.'.jpg';
	if(file_exists($default.'.gif'))
		return $url.'.gif';
		
	return $name;
}

function remove_image($name,$domain_id=null)
{
	global $core;
	
	if(is_null($domain_id))
	{
		$domain_id = $core->config['domain']['domain_id'];
	}
	
	$override = $core->paths['base'].'/../img/'.$domain_id.'/'.$name;
	core::log('override path is: '.$override);
	if(file_exists($override.'.png'))
		unlink($override.'.png');
	if(file_exists($override.'.jpg'))
		unlink($override.'.jpg');
	if(file_exists($override.'.gif'))
		unlink($override.'.gif');
}

function info($msg,$icon='speech',$show=false)
{
	global $core;
	$rand_id = strtr('f'.microtime(),' .','__');
	#$event = ($core->session['platform'] == 'tablet' || $core->session['platform'] == 'phone')?'onclick':'onmouseover';
	$out  = '<div class="info_toggle" onclick="$(\'#'.$rand_id.'\').toggle(\'fast\');">&nbsp;</div>';
	$out .= '<div class="info_area info_area_'.$icon.'" id="'.$rand_id.'"';
	if($show)
	{
		$out .= ' style="display: block;"';
	}
	$out .= '>'.$msg.'</div>';
	return $out;
}

function plus()
{
}

function address($formname='',$data=array(),$prefix='')
{
	global $core;
	
	if(!isset($data[$prefix.'address']))
		$data[$prefix.'address'] = '';
	if(!isset($data[$prefix.'city']))
		$data[$prefix.'city'] = '';
	if(!isset($data[$prefix.'postal_code']))
		$data[$prefix.'postal_code'] = '';
	if(!isset($data[$prefix.'region_id']))
		$data[$prefix.'region_id'] = '';
	if(!isset($data[$prefix.'telephone']))
		$data[$prefix.'telephone'] = '';
	if(!isset($data[$prefix.'fax']))
		$data[$prefix.'fax'] = '';
	if(!isset($data[$prefix.'latitude']))
		$data[$prefix.'latitude'] = '';
	if(!isset($data[$prefix.'longitude']))
		$data[$prefix.'longitude'] = '';

	$out = '';
	$out .= '<tr><td class="label">'.$core->i18n['field:address:street'].'<span class="required">*</span></td><td class="value">';
	$out .= '<input onblur="core.ui.getLatLong(this.form,\''.$prefix.'\');" type="text" name="'.$prefix.'address" value="'.$data[$prefix.'address'].'" /></td></tr>';
	$out .= '<tr><td class="label">'.$core->i18n['field:address:city'].'<span class="required">*</span></td><td class="value">';
	$out .= '<input onblur="core.ui.getLatLong(this.form,\''.$prefix.'\');" type="text" name="'.$prefix.'city" value="'.$data[$prefix.'city'].'" /></td></tr>';
	$out .= '<tr><td class="label">'.$core->i18n['field:address:state'].'<span class="required">*</span></td><td class="value">';
	$out .= '<select name="'.$prefix.'region_id" onchange="core.ui.getLatLong(this.form,\''.$prefix.'\');">';
	$states = core::model('directory_country_region')->collection();
	foreach($states as $state)
	{
		$out .= '<option value="'.$state['region_id'].'"';
		$out .= ($state['region_id'] == $data[$prefix.'region_id'])?' selected="selected"':'';
		$out .= '>'.$state['default_name'].'</option>';
	}
	$out .= '</select></td></tr>';
	$out .= '<tr><td class="label">'.$core->i18n['field:address:postalcode'].'<span class="required">*</span></td><td class="value">';
	$out .= '<input onblur="core.ui.getLatLong(this.form,\''.$prefix.'\');" type="text" name="'.$prefix.'postal_code"  value="'.$data[$prefix.'postal_code'].'" /></td></tr>';
	$out .= '<tr><td class="label">'.$core->i18n['field:address:telephone'].'<span class="required">*</span></td><td class="value">';
	$out .= '<input type="text" name="'.$prefix.'telephone" value="'.$data[$prefix.'telephone'].'" /></td></tr>';
	$out .= '<tr><td class="label">'.$core->i18n['field:address:fax'].' </td><td class="value">';
	$out .= '<input type="text" name="'.$prefix.'fax" value="'.$data[$prefix.'fax'].'" /></td></tr>';
	


	
	$out .= '<input type="hidden" name="'.$prefix.'latitude" value="'.$data[$prefix.'latitude'].'" />';
	$out .= '<input type="hidden" name="'.$prefix.'longitude" value="'.$data[$prefix.'longitude'].'" />';
	
	
	return $out;
}

function page_header($title,$extrafunction='',$function_text='',$link_style='link',$button_icon='', $title_icon = '')
{
	# Start div
	$out = '<div class="form_header clearfix">';
	
	# Make title, with or without icon
	if ($title_icon != ''):
		$out .= '<h2 class="pull-left"><i class="icon icon-' . $title_icon . '" /> '.$title.'</h2>';
	else:
		$out .= '<h2 class="pull-left">'.$title.'</h2>';
	endif;
	
	# If more than just the title
	if($extrafunction!=''):
		
		# Get link style (link or button)
		if($link_style == 'link'):
			$link_class = 'btn-link pull-right'; #simple link
		elseif($link_style == 'cancel'):
			$function_text = '<i class="icon icon-remove" /> '.ucfirst($function_text);
			$link_class = 'pull-right'; #button floated right
		else:
			$link_class = 'btn btn-primary pull-right'; #button floated right
		endif;

		# Make link/button
		$out .= '<a style="margin-top: 10px;" class="' . $link_class . '" href="'.$extrafunction.'" onclick="core.go(this.href);">';
		if ($button_icon != ''): $out .= '<i class="icon icon-' . $button_icon . '" /> '; endif; # Button icon
		$out .= $function_text . '</a>';

	endif;

	$out .= '</div><div class="clearfix"></div>';
	echo $out;
}

function log_event($event_type,$obj_id1=0,$obj_id2=0,$varchar1='',$varchar2='')
{
	core_db::query('
		insert into events (
			(event_type_id,customer_id,obj_id1,obj_id2,varchar1,varchar2,ip_address)
		values
			(
				(select event_type_id from event_types where name=\''.$event_type.'\'),
				'.$core->session['user_id'].',
				'.intval($obj_id1).',
				'.intval($obj_id2).',
				\''.core_db::escape_string($varchar1).'\',
				\''.core_db::escape_string($varchar2).'\'
			)	
	');
}


function phpmailer_onsend($obj)
{
	global $core;
	core::log('hook successfully called!');
	$to = $obj->get_tos();
	
	$email = core::model('sent_emails');
	$email['subject'] = $obj->Subject;
	$email['body'] = $obj->Body;
	$email['to_address'] = $to[0][0];
	$email->save();
	
	#core::log(print_r($obj,true));
	
}

?>