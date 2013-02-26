<?php

class core_ruleset
{
	function __construct($form_name='',$rules=array())
	{
		$this->form_name = $form_name;
		$this->rules = $rules;
		$this->custom_ruletypes = array();
	}

	function min_length($value,$min,$allow_blank='no')
	{
		return (strlen($value) >= $min || ($allow_blank == 'yes' && strlen($value)  == 0));
	}
	
	function is_checked($value)
	{
		return ($value == 1 || $value == 'on');
	}
		
	function value_is($value,$must_equal)
	{
		return (trim($value) == trim($must_equal));
	}
	
	function date_less_than($value,$other_value_name)
	{
		global $core;
		$value1 = core_format::parse_date($value,'timestamp');
		$value2 = core_format::parse_date($core->data[$other_value_name],'timestamp');
		return $value1 <= $value2;
	}

	function date_greater_than($value,$other_value_name)
	{
		global $core;
		$value1 = core_format::parse_date($value,'timestamp');
		$value2 = core_format::parse_date($core->data[$other_value_name],'timestamp');
		return $value1 >= $value2;
	}

	function max_length($value,$max)
	{
		return (strlen($value) <= $max);
	}
	
	function valid_email($field)
	{
		return preg_match("/^[a-zA-Z0-9\+\w\.-]*@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/", $field);
	}
	
	function match_confirm_field($field)
	{
		return true;
	}
	
	function equal_to($field1, $field2)
	{
		global $core;
		$field1 = $field1.'';
		$field2 = $core->data[$field2].'';
		return ($field1==$field2);
	}

	
	function not_equal_to($field1, $field2)
	{
		global $core;
		$field1 = $field1.'';
		$field2 = $core->data[$field2].'';
		return ($field1!=$field2);
	}
	
	function selected($field1)
	{
		return intval($field1 > 0);
	}
		
	function js()
	{
		core::js('core.valRules[\''.$this->form_name.'\'] = '.json_encode($this->rules).';');
	}
	
	function validate($formname = '')
	{
		global $core;
		$fail  = false;
		$msgs  = array();
		$fails = array();
		
		foreach($this->rules as $rule)
		{
			if(!isset($rule['data1']))
				$rule['data1'] = null;
			if(!isset($rule['data2']))
				$rule['data2'] = null;
			if(!isset($rule['data3']))
				$rule['data3'] = null;
				
			$ok = false;
			$type = $rule['type'];
			if(method_exists($this,$type))
			{
				core::log('checking rule '.$type.' on '.$rule['name']);
				$ok = $this->$type($core->data[$rule['name']],$rule['data1'],$rule['data2'],$rule['data3']);
				if(!$ok){
					core::log('failed!');
				}
			}
			else if (isset($this->custom_ruletypes[$rule['type']]))
			{
				$ok = $this->custom_ruletypes[$type]($core->data[$rule['name']],$rule['data1'],$rule['data2'],$rule['data3']);
			}
			else
			{
				core::log('unknown rule type: '.$type);
			}
			if(!$ok)
			{
				$fail = true;
				$msgs[] = $rule['msg'];
				$fails[] = $rule;
			}
		}
		
		if($fail)
		{
			core::log('validate failed, trying to pass this js: '.'core.validatePopup(\''.implode('<br />',$msgs).'\');');
			//core::js('core.validatePopup(\''.implode('<br />',$msgs).'\');');
			core::js('core.validateForm(\''.$formname.'\','.json_encode($fails).');');
			//core::js('core.validate.serverFail('.json_encode($fails).');');
			core::deinit();
		}
	}
}

?>