<?php 

define('__core_datatable_filter_nullval__','-99999999999');

class core_datatable_filter
{
	function __construct($name,$field='',$operator='=',$type='string',$initial_val=__core_datatable_filter_nullval__)
	{
		if($field == '')
			$field = $name;
		
		$this->name = $name;
		$this->field = $field;
		$this->operator = $operator;
		$this->type = $type;
		

		$this->value = $initial_val;
		$this->has_value = false;
	}
	
	function get_value()
	{
		global $core;
		$data_index_name = str_replace('.','_',$this->parent->name.'__filter__'.$this->name);
		
		core::log('tryign to get filter value: '.$this->field);
		if(!isset($this->parent->filter_states[$data_index_name]))
		{
			core::log('no value in parent filter states');
			$this->parent->filter_states[$data_index_name] = $this->value;
		}
		else
		{
			core::log('found value in parent filter states');
		}
		
		# look for a filter value in the session from a previous loading of this table
		if(
			isset($core->session['datatables'][$this->parent->name])
			&&
			isset($core->session['datatables'][$this->parent->name]['filter_states'][$data_index_name])
		)
		{
			core::log('found a value in the session');
			$this->value = $core->session['datatables'][$this->parent->name]['filter_states'][$data_index_name];
		}
		else
		{
			core::log('no value in session');
		}
			 
		# look for a filter value in the request data
		if(
			isset($core->data[$data_index_name]) 
			&& $core->data[$data_index_name] != __core_datatable_filter_nullval__
		)
		{
			core::log('found a value in request');
			$this->value = $core->data[$data_index_name];
		}
		else
		{
			core::log('no value in request');
		}
		
		# if we found a value somewhere, then make sure we set the has_value flag
		if(!is_null($this->value) && $this->value != __core_datatable_filter_nullval__)
		{
			$this->parent->filter_states[$data_index_name] = $this->value;
			$this->has_value = true;
		}
		
		if($core->data['get_datatable_data'] == 1 and $core->data[$data_index_name] == __core_datatable_filter_nullval__)
		{
			$this->value = null;
			$this->parent->filter_states[$data_index_name] = null;
			$this->has_value = false;
		}
		
		core::log('final value for '.$this->field.': '.$this->value);
	}
	
	function apply_to_collection()
	{
		global $core;
		core::log('applying filter: '.$this->has_value.'/'.$this->value);
		if($this->has_value && $this->value != __core_datatable_filter_nullval__)
		{
			# fudging with dates a bit
			if($this->type == 'date')
			{
				if(strlen($this->value) < 11 && ($this->operator == '>' || $this->operator == '<'))
				{
					$this->value .= ($this->operator == '>')?' 00:00:00':' 23:59:59';
				}
				$this->parent->data->filter($this->field,$this->operator,$this->value);
			}
			else if($this->type == 'search')
			{
				$values = explode(' ',$this->value);
				foreach($values as $value)
				{
					$value = trim($value);
					if($value != '')
					{
						$this->parent->data->filter($this->field,$this->operator,$value);
					}
				}
			}
			else
			{
				$this->parent->data->filter($this->field,$this->operator,$this->value);
			}
		}
	}
	
	public static function make_select($tablename,$name,$value=__core_datatable_filter_nullval__,$collection=array(),$col_opt_val_field='val',$col_opt_text_field='text',$null_val_text=null,$custom_style='',$post_js='',$pre_js='')
	{
		#build the select tag
		$out  = '<select name="'.$tablename.'__filter__'.$name.'" class="pull-left"';
		$out .= ' id="'.$tablename.'__filter__'.$name.'"';
		if($custom_style != '')
		{
			$out .= ' style="'.$custom_style.'"';
		}
		$out .= ' onchange="'.$pre_js.'core.ui.dataTables[\''.$tablename.'\'].setFilterValue(\''.$name.'\',this.options[this.selectedIndex].value);'.$post_js.'">';
		
		# if theres a null val option, add it.
		if(!is_null($null_val_text))
		{
			$out .= '<option value="'.__core_datatable_filter_nullval__.'">'.$null_val_text.'</option>';
		}
		
		#echo('value is: '.$value);
		if(is_array($collection))
		{
			foreach($collection as $opt_val=>$opt_text)
			{
				$out .= '<option value="'.$opt_val.'"';
				$out .= ((($opt_val == $value)?' selected="selected"':'')).'>';
				$out .= $opt_text;
				$out .= '</option>';
			}
		}
		else if(is_object($collection))
		{
			foreach($collection as $row)
			{
				$opt_val = $row[$col_opt_val_field];
				$opt_text  = $row[$col_opt_text_field];
				$out .= '<option value="'.$opt_val.'"';
				$out .= ((($opt_val == $value)?' selected="selected"':'')).'>';
				$out .= $opt_text;
				$out .= '</option>';
			}
		}
		$out .= '</select>';
		return $out;
	}

	
	public static function make_date($tablename,$name,$value=__core_datatable_filter_nullval__,$pre_label='',$post_label='')
	{
		global $core;
		if(is_null($value))
			$value = '';
		
		if($value != '' && !isset($core->data[$tablename.'__filter__'.$name])){
			core::log('setting initial value of filter '.$tablename.'__filter__'.$name.' to '.$value);
			$core->data[$tablename.'__filter__'.$name] = core_format::parse_date($value);
		}
	
		$out  = '<div class="date-filter pull-left">';
		$out .= core_ui::date_picker($tablename.'__filter__'.$name,$value,'function(var1,var2){core.ui.dataTable.updateFilter(var1,var2);}').$post_label;
		$out .= '<br><small>'.$pre_label.'</small></div>';
		return $out;
	}
	
	public static function make_text($tablename,$name,$value=__core_datatable_filter_nullval__,$pre_label='',$post_label='',$style='')
	{
		if(is_null($value))
			$value = __core_datatable_filter_nullval__;
			
		if($value == __core_datatable_filter_nullval__)
			$value = '';
		
		$out  = $out  = '<div class="text-search pull-left"';

		$out .= '><input type="text"';		
		if (strlen(trim($style)) > 0) {
			$out .= ' style="' . $style . '"';
		}
		$out .= ' name="'.$tablename.'__filter__'.$name.'"';	
		$out .= ' id="'.$tablename.'__filter__'.$name.'"';	
		$out .= ' onkeyup="core.ui.dataTables[\''.$tablename.'\'].handleTextFilter(\''.$name.'\',this.value);"';	
		$out .= ' placeholder="' . $pre_label . '" class="span2"';
		$out .= ' value="'.$value.'" />'.$post_label;	
		$out .= '</div>';
		return $out;
			
	}
	
	public static function make_checkbox($tablename,$name,$value,$label)
	{
		core::log('filter state for checkbox: '.$value);
		$out  = $out  = '<div class="checkbox-filter pull-left">' . $pre_label;
		$out .= core_ui::checkdiv($tablename.'__filter__'.$name,$label,$value,'core.ui.dataTables[\''.$tablename.'\'].changeFilterState(\''.$name.'\',(($(\'#checkdiv_'.$tablename.'__filter__'.$name.'_value\').val()==1)?1:'.__core_datatable_filter_nullval__.'));');
		$out .= '</div>';
		return $out;
	}
	
	
	//~ public static function make_checkbox($tablename,$field,$value=__core_datatable_filter_nullval__,$pre_label='',$post_label='')
	//~ {
		//~ if(is_null($value))
			//~ $value = __core_datatable_filter_nullval__;
	//~ }
}

?>