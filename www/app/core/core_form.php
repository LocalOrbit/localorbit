<?
# this library is used to draw form elements

class core_form
{
	public static function tab_switchers($tabset_name,$tab_list)
	{
		global $core;
		core_ui::tabset($tabset_name);
		$html = '<ul class="nav nav-tabs" id="'.$tabset_name.'">';
		for ($i = 0; $i < count($tab_list); $i++)
		{
			if ($i == 0): $default_active = 'active'; else: $default_active = ''; endif; # Picks first tab as default active
			$html .= '<li class="' . $default_active . '"><a href="#'.$tabset_name.'-a'.($i + 1).'" class="tabswitch" data-toggle="tab">'.$tab_list[$i].'</a></li>';
		}
		$html .= '</ul>';
		return $html;
	}

	public static function tab($tabset_name)
	{
		global $core;

		if(!is_numeric($core->config['tab_index_cache'][$tabset_name]))
		{
			$core->config['tab_index_cache'][$tabset_name] = 0;
		}
		$core->config['tab_index_cache'][$tabset_name]++;

		# get the final content list for this div
		$items = func_get_args();
		$tabset_class = $items[2]; # Grab 3rd argument for active tab pane
		unset($items[2]);
		
		array_shift($items);

		$out = '<div class="tab-pane tabarea ' . $tabset_class . '" id="'.$tabset_name.'-a'.$core->config['tab_index_cache'][$tabset_name].'">';
		$out .= core_form::render_items($items).'</div>';
		return $out;
	}

	public static function table_nv()
	{
		$items = func_get_args();
		#$out = '<table class="form">'.core_form::render_items($items).'</table>';
		$out = '<fieldset>'.core_form::render_items($items).'</fieldset>';
		return $out;
	}

	public static function table_2col($col1='',$col2='')
	{
		$out = '<table>'.core_form::column_widths('48%','4%','48%').'<tr>';
		$out .= '<td>'.$col1.'</td>';
		$out .= '<td>&nbsp;&nbsp;</td>';
		$out .= '<td>'.$col2.'</td>';
		return $out .= '</tr></table>';
	}

	public static function form($name,$url,$options=null)
	{
		$options = core_form::finalize_options($options,array(
			'style'=>'',
			'render'=>true,
		));
		if($options['render'] != true)	return '';

		$out = '<form name="'.$name.'" class="form-horizontal" action="'.$url.'" method="post" id="'.$name.'" onsubmit="return core.submit(\''.$url.'\',this);" enctype="multipart/form-data"';

		if($options['style'] != '')
		{
			$out .= ' style="'.$options['style'].'"';
		}
		$out .= '>';
		$items = func_get_args();
		array_shift($items);
		array_shift($items);
		array_shift($items);
		$out .= core_form::render_items($items);
		return $out .= '</form>';
	}

	public static function page_header($title, $extrafunction='', $function_text='', $link_style='link', $button_icon='', $title_icon = '')
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
				$link_class = 'btn-link cancel_link'; #simple link
			elseif($link_style == 'cancel'):
				$function_text = '<i class="icon icon-remove" /> '.ucfirst($function_text);
				$link_class = 'pull-right'; #button floated right
			else:
				$link_class = 'btn btn-primary pull-right'; #button floated right
			endif;

			# Make link/button
			$out .= '<a class="' . $link_class . '" href="'.$extrafunction.'" onclick="core.go(this.href);">';
			if ($button_icon != ''): $out .= '<i class="icon icon-' . $button_icon . '" /> '; endif; # Button icon
			$out .= $function_text . '</a>';

		endif;

		$out .= '</div><div class="clearfix"></div>';
		echo $out;
		
	}


	public static function header($label,$options=null)
	{
		$options = core_form::finalize_options($options,array(
			'level'=>2,
			'render'=>true,
		));
		if($options['render'] != true)	return '';
		return '<h'.$options['level'].'>'.$label.'</h'.$options['level'].'>';
	}

	public static function header_nv($label,$options=null)
	{
		$options = core_form::finalize_options($options,array(
			'level'=>3,
			'render'=>true,
		));
		if($options['render'] != true)	return '';
		$html = '<h'.$options['level'].'>' . $label . '</h'.$options['level'].'>';
		
		#$html .= (isset($options['info'])  && $options['info'] != '')?
		#core_form::info($options['info'],$options['info_icon'],$options['info_show']):'';
		
		if (isset($options['info']) && ($options['info'] != '')):
			$html .= '<div class="alert">' . $options['info'] . '</div>';
		endif;
		
		return $html;
	}
	
	public static function spacer_nv($lines=1)
	{
		$html = '<br />';
		for($i=1;$i<$lines;$i++)
			$html .= '&nbsp;<br />';
		return '<tr><td colspan="2">'.$html.'</td></tr>';
	}

	public static function column_widths()
	{
		$widths = func_get_args();
		$out = '';
		foreach($widths as $width)
			$out .= '<col width="'.$width.'" />';
		return $out;
	}

	public static function required()
	{
		return ' <i class="icon-asterisk icon-required tooltipper" rel="tooltip" title="Required" /> ';
	}

	public static function tr_nv($label,$value,$options)
	{
		#$label .= ($label != '&nbsp;')?':':'';
		#$label .= (isset($options['sublabel']) && $options['sublabel'] !='')?
		#	'<div class="sublabel">'.$options['sublabel'].'</div>':'';
		if($label == '&nbsp;')
		{
			$value .= (isset($options['required']) && $options['required'] == true)?
				core_form::required():'';
		}
		else
		{
			$label = ((isset($options['required']) && $options['required'] == true)?core_form::required():'').$label;
		}
		$value .= (isset($options['info'])  && $options['info'] != '')?
			core_form::info($options['info'],$options['info_icon'],$options['info_show']):'';

		$html = '<div class="control-group"';
		$html .= ($options['display_row'])?'':' style="display: none;"';
		$html .= ($options['row_id'] == '')?'':' id="'.$options['row_id'].'"';
		$html .='><label class="control-label" for="' . $options['field_name'] . '">'.$label;
		if ($options['sublabel']): $html .= '<span class="help-block">' . $options['sublabel'] . '</span>'; endif;
			
		if(isset($options['popover']) && $options['popover']!='')
		{
			$html .=' <i class="helpslug icon-question-sign" rel="popover" data-title="' . $label . '" data-content="' . $options['popover'] . '" />';
		}
		
		$html .='</label><div class="controls"';
		if(isset($options['value_area_id']) && $options['value_area_id'] != '')
			$html .= ' id="'.$options['value_area_id'].'"';
		$html .= '>'. $value;

		$html .= '</div></div>';
		return $html;
	}

	public static function get_final_value($name,$value)
	{
		if(is_object($value) || is_array($value))
			$value = $value[$name];
		return $value;
	}

	public static function finalize_options($passed,$defaults)
	{
		if($passed == null)
			return $defaults;

		$final = $defaults;
		foreach($passed as $name=>$value)
			$final[$name] = $value;
		return $final;
	}

	public static function render_items($items)
	{
		$out = '';
		foreach($items as $item)
		{
			if(is_array($item))
				$out .= implode('',$item);
			else
				$out .= $item;
		}
		return $out;
	}

	public static function input_button($name,$value,$onclick='',$options=null)
	{
		$options = core_form::finalize_options($options,array(
			'class'=>'primary',
			'type'=>'button',
			'render'=>true,
		));
		if($options['render'] != true)	return '';
		return '<input type="'.$options['type'].'" class="button_'.$options['class'].'" name="'.$name.'" value="'.$value.'" onclick="'.$onclick.'" />';
	}


	public static function input_hidden($name,$value)
	{
		$value = core_form::get_final_value($name,$value);
		return '<input type="hidden" name="'.$name.'" value="'.$value.'" />';
	}

	public static function value($label,$value,$options=null)
	{
		$options = core_form::finalize_options($options,array(
			'sublabel'=>'',
			'row_id'=>'',
			'display_row'=>true,
			'required'=>false,
			'info'=>'',
			'info_icon'=>null,
			'info_show'=>false,
			'render'=>true,
			'required'=>false,
			'id'=>'',
		));
		if($options['id'] != '')
		{
			$options['value_area_id'] = $options['id'];
			unset($options['id']);
		}
		if($options['render'] != true)	return '';
		return core_form::tr_nv($label,$value,$options);
	}


	public static function input_image_upload($label,$ul_path,$options=null)
	{
		$options = core_form::finalize_options($options,array(
			'sublabel'=>'',
			'row_id'=>'',
			'display_row'=>true,
			'required'=>false,
			'info'=>'',
			'info_icon'=>null,
			'info_show'=>false,
			'render'=>true,

			'src'=>'',
			'img_id'=>'',
			'img_style'=>'',
			'remove_js'=>'',
			'upload_js'=>'',
		));
		if($options['render'] != true)	return '';

		if($options['src'] == '')
			$options['img_style'] .= 'display:none;';


		$out = '<img id="'.$options['img_id'].'" src="'.$options['src'].'"';
		$out .= (isset($options['img_style']) && $options['img_style'] !='')?' style="'.$options['img_style'].'"':'';
		$out .= ' /><br />';
		$out .= '<input type="file" name="new_image" value="" />';
		$out .= '<input type="button" id="removenlimage" class="button_secondary" value="Remove Image" onclick="'.$options['remove_js'].'" />';

		return core_form::tr_nv($label,$out,$options);
	}

	public static function input_text($label,$name,$value='',$options=null)
	{
		$value   = core_form::get_final_value($name,$value);
		$options = core_form::finalize_options($options,array(
			'sublabel'=>'',
			'row_id'=>'',
			'display_row'=>true,
			'required'=>false,
			'info'=>'',
			'info_icon'=>null,
			'info_show'=>false,
			'size'=>'input-large',
			'render'=>true,
			'onkeyup'=>'',
			'onblur'=>'',
			'natural_numbers'=>false
		));

		$natural_class = ($options['natural_numbers'])?' natural-num-only':'';

		if($options['render'] != true)	return '';
		if ($options['required'] == true): $required = core_form::required(); endif;
		#return core_form::tr_nv($label,'<input type="text" name="'.$name.'" value="'.$value.'" />',$options);
		
		$html = '<div class="control-group"';
		$html .= ($options['display_row'])?'':' style="display: none;"';
		$html .= ($options['row_id'] == '')?'':' id="'.$options['row_id'].'"';
		$html .='><label class="control-label" for="' . $options['field_name'] . '">'.$label;
				
		if ($options['sublabel']): $html .= '<span class="help-block">' . $options['sublabel'] . '</span>'; endif;

		if ($options['popover']):
			$html .=' <i class="helpslug icon-question-sign" rel="popover" data-title="' . $label . '" data-content="' . $options['popover'] . '" />';
		endif;
		
		$html .= '</label>';
		$html .= '<div class="controls">';
		
		$html .= '<input type="text" name="'.$name.'" class="' . $options['size'] . $natural_class . '" value="'.$value.'"';
		
		if($options['onkeyup'] != '')
			$html .= ' onkeyup="'.$options['onkeyup'].'"';
		if($options['onblur'] != '')
			$html .= ' onblur="'.$options['onblur'].'"';
		
		$html .= ' />';
		
		#if ($options['sublabel']): $html .= '<span class="help-block">' . $options['sublabel'] . '</span>'; endif;

		$html .= '</div>
		</div>';
		
		return $html;
	}

	public static function input_datepicker($label,$name,$value,$options=null)
	{
		$value = core_form::get_final_value($name,$value);
		$options = core_form::finalize_options($options,array(
			'sublabel'=>'',
			'row_id'=>'',
			'display_row'=>true,
			'required'=>false,
			'info'=>'',
			'info_icon'=>null,
			'info_show'=>false,
			'render'=>true,
		));
		if($options['render'] != true)	return '';
		
		
		return core_form::tr_nv($label,core_ui::date_picker($name,$value),$options);
	}

	public static function input_check($label,$name,$value,$options=null)
	{
		$value = core_form::get_final_value($name,$value);
		$options = core_form::finalize_options($options,array(
			'sublabel'=>'',
			'row_id'=>'',
			'display_row'=>true,
			'required'=>false,
			'info'=>'',
			'info_icon'=>null,
			'info_show'=>false,
			'render'=>true,
			'field_name' => $name
		));
		if($options['render'] != true)	return '';
		core::log('final input check options: '.print_r($options,true));
		return core_form::tr_nv($label,core_ui::checkdiv($name,'',$value,$options['onclick']),$options);
	}

	public static function input_password($label,$name,$value='',$options=null)
	{
		$value   = core_form::get_final_value($name,$value);
		$options = core_form::finalize_options($options,array(
			'sublabel'=>'',
			'row_id'=>'',
			'display_row'=>true,
			'required'=>false,
			'info'=>'',
			'info_icon'=>null,
			'info_show'=>false,
			'size'=>'input-large',
			'render'=>true,
		));
		if($options['render'] != true)	return '';
		if ($options['required'] == true): $required = core_form::required(); endif;
		#return core_form::tr_nv($label,'<input type="text" name="'.$name.'" value="'.$value.'" />',$options);
		
		$html = '<div class="control-group">';
		$html .= '<label class="control-label" for="' . $name . '">' . $required . $label;
		
		if ($options['sublabel']): $html .= '<span class="help-block">' . $options['sublabel'] . '</span>'; endif;

		if ($options['popover']):
			$html .=' <i class="helpslug icon-question-sign" rel="popover" data-title="' . $label . '" data-content="' . $options['popover'] . '" />';
		endif;
		
		$html .= '</label>';
		$html .= '<div class="controls"><input type="password" name="'.$name.'" class="' . $options['size'] . '" value="'.$value.'" />';
		
		#if ($options['sublabel']): $html .= '<span class="help-block">' . $options['sublabel'] . '</span>'; endif;

		$html .= '</div>
		</div>';
		
		return $html;
	}

	public static function input_select($label,$name,$value,$source,$options=null)
	{
		$value = core_form::get_final_value($name,$value);
		$options = core_form::finalize_options($options,array(
			'sublabel'=>'',
			'rowid'=>'',
			'display_row'=>true,
			'required'=>false,
			'info'=>'',
			'info_icon'=>null,
			'info_show'=>false,
			'render'=>true,
			'select_style'=>'',
			'option_prefix'=>'',
			'option_suffix'=>'',

			'text_column'=>'text',
			'value_column'=>'value',

			'default_show'=>false,
			'default_text'=>'',
			'default_value'=>0,
			'onchange'=>'',
		));
		if($options['render'] != true)	return '';

		$out = '<select name="'.$name.'"';
		$out .= (isset($options['select_style']) && $options['select_style'] != '')?' style="'.$options['select_style'].'"':'';
		$out .= (isset($options['onchange']) && $options['onchange'] != '')?' onchange="'.$options['onchange'].'"':'';
		$out .='>';

		if($options['default_show'] == true)
		{
			$out .= '<option value="'.$options['default_value'].'"';
			$out .= ($value==$options['default_value'])?' selected="selected"':'';
			$out .= '>'.$options['default_text'].'</option>';
		}

		if(is_array($source))
		{
			foreach($source as $opt_value=>$opt_text)
			{
				$out .= '<option value="'.$opt_value.'"';
				$out .= ($value==$opt_value)?' selected="selected"':'';
				$out .= '>'.$options['option_prefix'].$opt_text.$options['option_suffix'].'</option>';
			}
		}
		else if(is_object($source))
		{
			foreach($source as $source_row)
			{
				$out .= '<option value="'.$source_row[$options['value_column']].'"';
				$out .= ($value==$source_row[$options['value_column']])?' selected="selected"':'';
				$out .= '>'.$options['option_prefix'].$source_row[$options['text_column']].$options['option_suffix'].'</option>';
			}
		}
		else if(is_string($source))
		{
			$out .= $source;
		}

		$out .= '</select>';

		return core_form::tr_nv($label,$out,$options);
	}

	public static function input_textarea($label,$name,$value,$options=null)
	{
		$value = core_form::get_final_value($name,$value);
		$options = core_form::finalize_options($options,array(
			'sublabel'=>'',
			'rowid'=>'',
			'display_row'=>true,
			'required'=>false,
			'info'=>'',
			'info_icon'=>null,
			'info_show'=>false,
			'rows'=>7,
			'cols'=>50,
			'size'=>'input-xlarge',
			'render'=>true,
			'maxlength'=>null
		));

		if ($options['render'] != true)	return '';
		if ($options['required'] == true): $required = core_form::required(); endif;

		#return core_form::tr_nv($label,'<textarea name="'.$name.'" rows="'.$options['rows'].'" cols="'.$options['cols'].'">'.$value.'</textarea>',$options);
			
		$html = '<div class="control-group">';
		$html .= '<label class="control-label" for="' . $name . '">' . $required . $label;
	
		if ($options['sublabel']): $html .= '<span class="help-block">' . $options['sublabel'] . '</span>'; endif;

		if ($options['popover']):
			$html .=' <i class="helpslug icon-question-sign" rel="popover" data-title="' . $label . '" data-content="' . $options['popover'] . '" />';
		endif;
		
		$html .= '</label>';
		$html .= '<div class="controls"><textarea name="'.$name.'" class="' . $options['size'] . '" rows="'.$options['rows'].'" cols="'.$options['cols'].'"';

		if ($options['maxlength']) {
			$html .= ' maxlength="' . $options['maxlength'] . '"';
		}

		$html .= '>'.$value.'</textarea>';
		
		#if ($options['sublabel']): $html .= '<span class="help-block">' . $options['sublabel'] . '</span>'; endif;

		$html .= '</div>
		</div>';
		
		return $html;
	}

	public static function input_rte($label,$name,$value,$options=null)
	{
		$value = core_form::get_final_value($name,$value);
		$options = core_form::finalize_options($options,array(
			'sublabel'=>'',
			'rowid'=>'',
			'display_row'=>true,
			'required'=>false,
			'info'=>'',
			'info_icon'=>null,
			'info_show'=>false,
			'rows'=>7,
			'cols'=>73,
			'render'=>true,
		));
		if($options['render'] != true)	return '';
		core_ui::rte();
		return core_form::tr_nv($label,'<textarea class="rte" id="'.$name.'" name="'.$name.'" rows="'.$options['rows'].'" cols="'.$options['rows'].'">'.$value.'</textarea>',$options);
	}

	public static function info($msg,$icon='speech',$show=false)
	{
		global $core;
		# take care of a situation where this is called by one of the form generator functions
		if(is_null($icon))
			$icon = 'speech';

		$rand_id = strtr('f'.microtime(),' .','__');
		$out  = '<div class="info_toggle" onclick="$(\'#'.$rand_id.'\').toggle(\'fast\');">&nbsp;</div>';
		$out .= '<div class="info_area info_area_'.$icon.'" id="'.$rand_id.'"';
		if($show === true)
		{
			$out .= ' style="display: block;"';
		}
		$out .= '>'.$msg.'</div>';
		return $out;
	}


	public static function save_buttons($options=null)
	{
		global $core;
		$options = core_form::finalize_options($options,array(
			'require_pin' => false,
		));

		if($core->session['sec_pin'] == 1)
		{
			$options['require_pin'] = false;
		}

		if($options['require_pin'])
		{
			$out = '
				<div class="form-actions unlock_area pull-right" id="unlock_area">
					<input type="password" name="sec_pin" id="sec_pin" class="input-small" placeholder="4 Digit Pin" value="" />
					<input type="button" class="btn btn-primary" value="Unlock to Save" onclick="core.doRequest(\'/auth/unlock_pin\',{\'formname\':this.form.getAttribute(\'name\'),\'sec_pin\':$(\'#sec_pin\').val()});" />
				</div>
			';
		}
		else
		{
			$out = '
				<div class="form-actions pull-right" id="main_save_buttons"'.(($options['require_pin'])?' style="display:none;"':'').'>
					<input type="'.(($require_pin)?'button':'submit').'" class="btn" name="save" value="'.$core->i18n['button:save_and_continue'].'" />
					<input type="button" onclick="core.submit(this.form.action,this.form,{\'do_redirect\':1});" class="btn btn-primary" value="'.$core->i18n['button:save_and_go_back'].'" />
				</div>
			';
		}
		return $out;
	}

	public static function save_only_button($options=null)
	{
		global $core;
		$options = core_form::finalize_options($options,array(
			'cancel_button'=>false,
			'on_cancel'=>'',
			'on_save'=>'',
			'require_pin' => false,
		));
		$out = '<div class="form-actions pull-right" id="main_save_buttons">';
		if ($options['cancel_button']):
			$out .= '<input type="button" class="btn" name="cancel" onclick="'.$options['on_cancel'].'" value="'.$core->i18n['button:cancel'].'" /> ';
		endif;
		$out .= '<input type="submit" class="btn btn-primary" onclick="'.$options['on_save'].' name="save" value="'.$core->i18n['button:save'].'" /> ';
		$out .= '</div>';

		return $out;
	}
}

?>