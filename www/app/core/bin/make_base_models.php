<?php
global $core;
define('__CORE_ERROR_OUTPUT__','exit');
define('__NO_OVERRIDE_ERROR__',true);

include(dirname(__FILE__).'/../core.php');
core::init();

core::log('here');


$tables = core_db::list_tables();
echo('<pre>');
while($table = core_db::fetch_array($tables))
{
	echo('checking '.$table[0]."<br />\n");
	#exit();	
	
	$has_array_fields = false;
	$base_file = $core->paths['base'].'/models/base/'.$table[0].'.php';
	$child_file = $core->paths['base'].'/models/'.$table[0].'.php';
	$base = "<"."?php\nclass core_model_base_".$table[0]." extends core_model\n{\n";
	$child = "<"."?php\nclass core_model_".$table[0]." extends core_model_base_".$table[0]."\n{\n";
	
	# if the base model already exists, unlink it
	if(file_exists($base_file))
		unlink($base_file);
	#if(file_exists($child_file))
	#	unlink($child_file);
		
	$base .="\tfunction init_fields()\n\t{\n";
	
	$fields = core_db::describe($table[0]);
	
	$index = 0;
	
	
	
	while($field = core_db::fetch_assoc($fields))
	{
		
		if(isset($field['type']))
			$field['Type'] = $field['type'];
		if(isset($field['field']))
			$field['Field'] = $field['field'];
		print_r($field);


		$type = '';
		$length = '';
		$extra = '';
		
		
		#exit('test: '.strpos($field['type'],'int'));
		if(strpos($field['Type'],'_int') !== false)
		{
			$type = 'int[]';
			$length = intval(str_replace('_int','',$field['Type']));
			$has_array_fields = true;
		}
		
		else if(strpos($field['Type'],'int') !== false)
		{
			$type = 'int';
			$length = $field['length'];
			$length = 8;
		}
		
		else if(strpos( $field['Type'], 'numeric' )  !== false || strpos( $field['Type'], 'decimal' )  !== false  || strpos( $field['Type'], 'float' )  !== false)
		{
			$type = 'float';
			$length = 10;
			$extra  = 2;
		}
		else if(strpos($field['Type'],'timestamp') !== false || strpos($field['Type'],'date') !== false)
		{
			$type = 'timestamp';
			$length = 4;
		}
		
		else if(strpos(strtolower($field['Type']),'text') !== false)
		{
			$type = 'string';
			$length = 8000;
			
		}
		
		else if(strpos(strtolower($field['Type']),'blob') !== false)
		{
			$type = 'blob';
			$length = 8000000;
			
		}
		else if(strpos($field['Type'],'char')  !== false || strpos($field['Type'],'enum')  !== false || strpos($field['Type'],'set(')  !== false)
		{
			$type = 'string';
			$length = $field['length_var'] - 4;
		}
		
		else
		{
			echo("<h2>UNKNOWN DATA TYPE RAWWRR</h2>\n<br />");
		}
		echo('type is: '.$type."\n<br />");

		/*
		$typelen = strlen($field['Type']);
		$pos1 = strpos($field['Type'],'(');
		$pos2 = strpos($field['Type'],')');
		
		if($pos1 > 0)
		{
			echo("orig: ".$field['Type']."\n");
			echo("pos1: $pos1 \n");
			echo("pos2: $pos2 \n");
			echo("typelen: $typelen \n");
			
			#exit();
		}
		
		if($pos1 !== false)
		{
			$type = substr($field['Type'],0,$pos1);
			$length = substr($field['Type'],$pos1+1,$pos2 - $pos1 - 1);
		}
		else
		{
			$type = $field['Type'];
			$length = 'null';
		}
		*/
		
		$base .= "\t\t$"."this->add_field(new core_model_field(";
		
			$base .= $index.',';
			$base .= '\''.$field['Field'].'\',';
			$base .= '\''.$type.'\',';
			$base .= $length.',';
			$base .= '\''.$extra.'\',';
			$base .= '\''.$table[0].'\'';
			
		$base .= "));\n";
		#print_r($field);
		$index++;
		
	}
	if($has_array_fields)
		$base .= "\t\t$"."this->__has_array_fields = true;\n";
	
	$base .= "\t\t$"."this->init_data();\n";
	$base .="\t}\n";
	
	$base .= "}\n?".'>';
	$child .= "}\n?".'>';
	
	file_put_contents($base_file,$base);
	if(!file_exists($child_file))
		file_put_contents($child_file,$child);
	
}
echo("\n");
ob_flush();
core::deinit(false);
?>
