<?php

class core_ui
{
	public static function rte($width=610,$height=350,$stylesheet='')
	{
		global $core;
		#content_css_url: "css/loader.php?time='.$core->config['microtime'].'",

		core::js('
		$(".rte").rte({
			'.(($stylesheet != '')?'content_css_url:\''.$stylesheet.'\',':'').'
			useImagePicker:false,
			media_url: "img/default/rte",
			height: '.$height.',
			width: '.$width.'
		});');
	}
	
	public static function update_select($id,$opts)
	{
		core::js('core.ui.updateSelect(\''.$id.'\','.json_encode($opts).');');
	}

	public static function alert($string)
	{
		global $core;
		core::js("alert('".$string."');");
		core::deinit();
	}

	public static function notification($string,$clear_response=false,$deinit=true)
	{
		global $core;
		if($clear_response)
			core::clear_response();
		core::js("core.ui.notification('".$string."');");
		if($deinit)
			core::deinit();
	}

	public static function validate_error($string,$form='',$field='none')
	{
		core::js('core.validateForm(\''.$form.'\','.json_encode(
			array(
				array(
					'type'=>'autofail',
					'name'=>$field,
					'msg'=>$string
				)
			)
		).');');
		///core::js('core.validatePopup(\''.addslashes($string).'<br />\');');
		core::deinit();
	}

	public static function error($string,$js='')
	{
		global $core;
		$string = str_replace("\n",'<br />',$string);
		core::clear_response();
		core::js($js);
		core::js("core.ui.error('".$string."');");
		core::deinit();
	}

	public static function popup($icon,$title,$content,$button_set)
	{
		global $core;
		core::clear_response();
		$content = str_replace("\n",'<br />',$content);
		core::js("core.ui.popup('".$icon."','".$title."','".addslashes($content)."','".$button_set."');");
		core::deinit();
	}

	public static function map($id,$width,$height,$zoom)
	{

		core::js('
			core.ui.maps[\''.$id.'\'] = new google.maps.Map(document.getElementById("'.$id.'"),{zoom:'.intval($zoom).', scaleControl: false, panControl: false, streetViewControl: false, scrollwheel: false, mapTypeControl: false, mapTypeId: google.maps.MapTypeId.TERRAIN});
		');
		return '<div class="google_map" id="'.$id.'" style="width: '.$width.';height: '.$height.';"></div>';
	}

	public static function map_center($id,$address,$long=null)
	{
		if(!is_null($long))
		{
			$lat = $address;
			core::js('core.ui.mapCenterByCoord(\''.$id.'\','.$lat.','.$long.');');
		}
		else
		{
			core::js('core.ui.mapCenterByAddress(\''.$id.'\',\''.core_format::remove_newlines($address).'\');');
		}
	}

	# this function can work in two different ways:
	# pass id,lat,long,content. In this case you need 4 parameters
	# pass id,address,content. In this case, you only need 3 parameters. Avoid this if possible
	public static function map_add_point($id,$lat,$long,$content=null,$img_path='')
	{
		# trying to use an address
		if(is_null($content))
		{
			$content = $long;
			$address = $lat;
			$js = '
				core.ui.mapAddMarkerByAddress(\''.$id.'\',\''.addslashes(core_format::remove_newlines($address)).'\',\''.base64_encode($content).'\',\''.($img_path).'\');
			';
		}
		else
		{
			$js = '
				core.ui.mapAddMarkerByCoord(\''.$id.'\','.$lat.','.$long.',\''.base64_encode($content).'\',\''.($img_path).'\');
			';
		}
		core::js($js);
	}


	/* Standard HTML checkbox */
	public static function checkdiv($name, $text, $checked = false, $onclick='')
	{
		$html = '<input type="checkbox" id="'.$name.'" name="'.$name.'"';
		if($checked)
			$html .= ' checked="checked"';
		if($onclick !='')
			$html .= ' onclick="'.$onclick.'"';
			
		$html .= ' /><span class="help-inline">'.$text . '</span>';
		return $html;
		
		
		/*
		$html = '<div class="control-group">';
		$html .= '	<label class="control-label">' . $text;
		
		if ($popover != ''):
			$html .= '<i class="helpslug icon-question-sign" rel="popover" 
					data-title="' . $text . '" 
					data-content="' . $popover . '" />';
		endif;
		
		$html .= '</label>';
		$html .= '	<div class="controls">';
		$html .= '		<input type="checkbox" id="checkdiv_'.$name.'_value" name="'.$name.'" checked="'.(($checked)?1:0).'"> <span class="help-inline">' . $label . '</span>';
		$html .= '	</div>';
		$html .= '</div>';

		return $html;
		*/
	}

	/* Old Image-Based Method
	public static function checkdiv($name,$text,$checked=false,$onclick='',$clickable=true)
	{
		$html = '<div id="checkdiv_'.$name.'" class="checkdiv';
		if($checked)
			$html .= ' checkdiv_checked';
		$html .= '"';

		if($clickable)
			$html .= ' onclick="core.ui.checkDiv(\''.$name.'\');'.$onclick.'"';

		$html .= '>';

		$html .= $text.'</div>';
		$html .= '<input type="hidden" id="checkdiv_'.$name.'_value"';
		$html .= ' name="'.$name.'" value="'.(($checked)?1:0).'" />';
		core::js('core.preloadImages(\'default/checkdiv_checked.png\',\'default/checkdiv_unchecked.png\');');
		return $html;
	}*/

	public static function radiodiv($value,$text,$checked=false,$radiogroup='',$allow_radio_unselect=false,$onclick='')
	{
		global $core;
		$unselectable_value = ($allow_radio_unselect)?1:0;
		$checked_attr =($checked)?' checked="checked"':'';
		$html = '';
		$html .= '<label class="radio">';
			$html .= '<input type="radio" name="'.$radiogroup.'" value="'.$value.'" id="radiodiv_'.$name.'_radio" onclick="'.$onclick.'"'.$checked_attr.' />';
			$html .= $text;
		$html .= '</label>';
		return $html;
		
		
		# old code, pre lo 3.8
		$html = '<div id="radiodiv_'.$name.'" class="radiodiv';
		if($radiogroup != '')
			$html .= ' radiodiv_group_'.$radiogroup;
		if($checked)
			$html .= ' radiodiv_checked';
		$html .= '" onclick="core.ui.radioDiv(\''.$name.'\',\''.$radiogroup.'\','.(($allow_radio_unselect)?1:0).');'.$onclick.'">';
		$html .= $text.'</div>';
		$html .= '<input type="hidden" id="radiodiv_'.$name.'_value"';
		$html .= ' name="'.$name.'" value="'.(($checked)?1:0).'" />';
		core::js('core.preloadImages(\'default/radiodiv_checked.png\',\'default/radiodiv_unchecked.png\');');
		return $html;
	}

	public static function radio_value($prefix,$values=array())
	{
		global $core;

		# loop through the possible values. if one of them
		# is in the submitted data, return that value.
		foreach($values as $value)
		{
			#core::log('checking '.$value);
			if($core->data[$prefix] == $prefix.'_'.$value)
			{
				#core::log('found!');
				return $value;
			} 
			else if($core->data[$prefix] == $prefix.'_'.$value)
			{
				#core::log('found!');
				return $value;
			}
		}
		return null;
	}

	public static function time_picker($field_name,$value=0,$start=0,$end=24,$increment='quarter',$onchange_js='')
	{
		global $core;
		$out = '<select name="'.$field_name.'"';
		if($onchange_js != '')
		{
			$out .= ' onchange="'.$onchange.'"';
		}
		$out .= '>';

		for ($i = $start; $i < $end; $i++)
		{
			$suffix = ($i >= 12)?'pm':'am';
			$time = ($i > 12)?($i - 12):$i;
			if($time == 0)
				$time = '12';

			switch($increment)
			{

				case 'quarter':
					$out .= '<option value="'.$i.'">'.$time.':00 '.$suffix.'</option>';
					$out .= '<option value="'.$i.'.25">'.$time.':15 '.$suffix.'</option>';
					$out .= '<option value="'.$i.'.5">'.$time.':30 '.$suffix.'</option>';
					$out .= '<option value="'.$i.'.75">'.$time.':45 '.$suffix.'</option>';
					break;
				case 'half':
					$out .= '<option value="'.$i.'">'.$time.':00 '.$suffix.'</option>';
					$out .= '<option value="'.$i.'.5">'.$time.':30 '.$suffix.'</option>';
					break;
				case 'hour':
					$out .= '<option value="'.$i.'">'.$time.' '.$suffix.'</option>';
					break;
			}
		}


		$out .= '</select>';

		return $out;
	}

	public static function date_picker_blur_setup ()
	{
		return '<script type="text/javascript">
		$(document).ready(function ()  {
			$(document).mouseup(function (e)
			{
			    var container = $("#datePicker");
			    if (container.has(e.target).length === 0)
			    {
			      container.hide();
			    }
			});
		});
		</script>';
	}

	public static function date_picker($field_name_id,$value='',$onchange_js='')
	{
		global $core;

		if(is_numeric($value))
		{
			$value = core_format::date($value,'short');
		}

		if(is_numeric($value) && $value < 0)
			$value = '';

		core::js('$(\'#'.$field_name_id.'\').datePicker('.$onchange_js.');');
		return '<input type="text" format="'.$core->config['formats']['dates']['jsshort'].'" class="datepicker input-small" name="'.$field_name_id.'" id="'.$field_name_id.'" value="'.$value.'" />';
	}


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

	public static function tabset($name)
	{
		global $core;
		#core::js('$.fn.tabset(\''.$name.'\');');
		if(is_numeric($core->data['tabautoswitch_'.$name]))
		{
			#core::Log("$('#".$name."-s".$core->data['tabautoswitch_'.$name]."').click();");
			#core::js("$('#".$name."-a".$core->data['tabautoswitch_'.$name]."').click();");
		}
	}

	public static function load_library($type,$src)
	{
		core::js('core.loadLibrary(\''.$type.'\',\''.$src.'\');');
	}

	public static function options($source,$current_value,$valuefield=null,$textfield=null)
	{
		$out = '';
		if(is_array($source))
		{
			foreach($source as $valuefield=>$textfield)
			{
				$out .= '<option value="'.$valuefield.'"';
				$out .= (($current_value == $valuefield)?' selected="selected"':'');
				$out .= '>'.$textfield.'</option>';
			}
		}
		else if(is_object($source))
		{
			foreach($source as $row)
			{
				$out .= '<option value="'.$row[$valuefield].'"';
				$out .= (($current_value == $row[$valuefield])?' selected="selected"':'');
				$out .= '>'.$row[$textfield].'</option>';
			}
		}
		else
		{
			throw new Exception(100,'Cannot create options from this data type, not an object or array');
		}
		return $out;
	}

	public static function options_seq($type='',$value='',$start='',$end='',$prefix='',$suffix='')
	{
		$out = '';
		switch($type)
		{
			case 'numbers':
				for ($i = $start; $i <= $end; $i++)
				{
					$out .= '<option value="'.$i.'"';
					$out .= ($i == $value)?' selected="selected"':'';
					$out .= '>'.$prefix.$i.$suffix.'</option>';
				}

				break;
		}
		return $out;
	}

	public static function check_all($class_suffix,$id_col='')
	{
		# this is the header column, so setup the checkall box
		if($id_col == '')
		{
			return '<input type="checkbox" name="checkall_'.$class_suffix.'" onclick="core.ui.checkAll(\''.$class_suffix.'\',this.checked);" />';
		}
		# this is the individual line
		else
		{
			return '<input type="checkbox" class="checkall_'.$class_suffix.'" name="checkall_'.$class_suffix.'_{'.$id_col.'}" />';
		}
	}

	public static function fullWidth()
	{
		core::js('core.ui.fullWidth();');
	}

	public static function showLeftNav()
	{
		core::js('core.ui.showLeftNav();');
	}

	public function tagset_link($name,$value)
	{
		return '<span id="tagset_'.$name.'_'.$value.'" class="tagset_link" onclick="core.ui.tagSet.toggleFilter(\''.$name.'\',\''.$value.'\')">'.$value.'</span>';
	}

	public function tagset_init($name,$mode='exclusive')
	{
		core::js('core.ui.tagSet.init(\''.$name.'\',\''.$mode.'\');');
	}

	public function tagset_classes($name,$values=null,$do_class=true)
	{
		# we're setting the tagset attributes on an element
		$classes = ' tagset_'.$name;
		foreach($values as $value)
		{
			$classes .= ' tagset_'.$name.'_'.$value;
		}

		if($do_class)
		{
			return ' class="'.$classes.'"';
		}
		else
		{
			return $classes;
		}
	}
}

?>