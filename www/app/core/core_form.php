<?
# this library is used to draw form elements

class core_form
{
	
	public static function required()
	{
		return '<span class="required">*</span>';
	}

	public static function value($label,$value,$required=false,$info='',$info_icon=null,$info_show=false)
	{
		$html = '
		<tr>
			<td class="label">'.$label.(($required)?core_form::required():'').'</td>
			<td class="value">'.$value;
		
		if($info != '')
			$html .= core_form::info($info,$info_icon,$info_show);
		
		$html .= '</td></tr>';
		return $html;
	}
	
	public static function input_text($label,$name,$value,$required=false,$info='',$info_icon=null,$info_show=false)
	{
		if(is_object($value))
			$value = $value[$name];
		$html = '
		<tr>
			<td class="label">'.$label.(($required)?core_form::required():'').'</td>
			<td class="value"><input type="text" name="'.$name.'" value="'.$value.'" />';
		
		if($info != '')
			$html .= core_form::info($info,$info_icon,$info_show);
		
		$html .= '</td></tr>';
		return $html;
	}
	
	public static function input_check($label,$name,$value,$required=false,$info='',$info_icon=null,$info_show=false,$onclick='')
	{
		if(is_object($value))
			$value = $value[$name];
		$html = '
		<tr>
			<td class="label">&nbsp;</td>
			<td class="value">'.core_ui::checkdiv($name,$label,$value,$onclick);
		
		if($info != '')
			$html .= core_form::info($info,$info_icon,$info_show);
		
		$html .= '</td></tr>';
		return $html;
	}
	
	public static function input_password($label,$name,$value,$required=false,$info='',$info_icon=null,$info_show=false)
	{
		if(is_object($value))
			$value = $value[$name];
		$html = '
		<tr>
			<td class="label">'.$label.(($required)?core_form::required():'').'</td>
			<td class="value"><input type="password" name="'.$name.'" value="'.$value.'" />';
		
		if($info != '')
			$html .= core_form::info($info,$info_icon,$info_show);
		
		$html .= '</td></tr>';
		return $html;
	}
	
	public static function input_textarea($label,$sublabel,$name,$value,$required=false,$rows=7,$cols=50,$info='',$info_icon=null,$info_show=false)
	{
		if(is_object($value))
			$value = $value[$name];
		$html = '
		<tr>
			<td class="label">'.$label;
		
		$html .= (($required)?core_form::required():'');
		$html .= (($sublabel!='')?'<div class="sublabel">'.$sublabel.'</div>':'').'</td>';
		$html .=	'<td class="value"><textarea name="'.$name.'" rows="'.$rows.'" cols="'.$cols.'">'.$value.'</textarea>';
		
		if($info != '')
			$html .= core_form::info($info,$info_icon,$info_show);
		
		$html .= '</td></tr>';
		return $html;
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
		if($show)
		{
			$out .= ' style="display: block;"';
		}
		$out .= '>'.$msg.'</div>';
		return $out;
	}
}

?>