<?php

class core_model_field
{
	function __construct($index,$name,$type,$length=null,$extra=null,$table=null)
	{
		$this->index = $index;
		$this->name = $name;
		$this->type = $type;
		$this->length = $length;
		$this->extra = $extra;
		$this->table = $table;
	}
	
	function escape_value($value)
	{
		if(is_null($value))
		{
			return 'null';
		}
		else
		{
			
			switch($this->type)
			{
				case 'int[]':
					#echo('trying to escape: '.$value.'<br />');
					#return '';
					return '\'{'.implode(',',$value).'}\'';
					break;
				case 'int':
					return intval($value);
					break;
				case 'float':
					return floatval($value);
					break;
				case 'timestamp':
					if(is_numeric($value))
						return '\''.core_format::date($value,'db').'\'';
					else
						return '\''.core_db::escape_string($value).'\'';
					break;
				default:
					return '\''.core_db::escape_string($value).'\'';
					break;
			}
		}
	}
}

?>