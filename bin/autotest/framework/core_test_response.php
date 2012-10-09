<?

class core_test_response
{
	function __construct($text)
	{
		global $core;
		$this->original_response = $text;
		$this->has_json = false;
		$this->headers  = array();
		
		if (strpos($text, "\r\n") > 0)
		{
			$headers = explode("\r\n", $text);
			$text = array_pop($headers);
			$this->headers = $headers;
		}
		
	
		
		$this->text = json_decode($text,true);
		if(!is_null($this->text))
		{
			$this->has_json=true;
			
			foreach($this->text['replace'] as $key=>$value)
			{
				$this->text['replace'][$key] = base64_decode($value);
			}
			foreach($this->text['append'] as $key=>$value)
			{
				$this->text['replace'][$key] = base64_decode($value);
			}
			$this->text['js'] = base64_decode($this->text['js']);
		}
		else
		{
			$this->text = $text;
		}
	}

	function dump()
	{
		var_dump($this->text);
	}
	
	function headers_contains($text)
	{
		$found = false;
		foreach($this->headers as $header)
		{
			if($header.'' == $text.'')
				$found = true;
		}
		return $found;
	}
	
	function headers_fuzzy_contains($text)
	{
		$found = false;
		foreach($this->headers as $header)
		{
			if(strpos($header,$text) !== false)
				$found = true;
		}
		return $found;
	}
	
	function contains()
	{
		
		$does_contain=true;
		$text_to_check = func_get_args();
		
		foreach($text_to_check as $text)
		{
			if($this->has_json)
			{
				$item_does_contain = false;
				foreach($this->text['replace'] as $position=>$content)
					if(strpos($content,$text) !== false)
						$item_does_contain = true;
				foreach($this->text['append'] as $position=>$content)
					if(strpos($content,$text) !== false)
						$item_does_contain = true;
				if(strpos($this->text['js'],$text) !== false)
						$item_does_contain = true;
				
				if(!$item_does_contain)
					$does_contain = false;
			}
			else
			{
				$does_contain = false;
				if(strpos($this->text,$text) !== false)
					$does_contain = true;
			}	
		}
		
		return $does_contain;
	}
		
	function not_contains($text='')
	{
		return (!$this->contains($text));
	}
	
	function notified($note_string)
	{
		return $this->contains('core.ui.notification(\''.$note_string.'\');');
	}
	
	function validation_failed()
	{
		#echo($this->text['js']);
		return (strpos($this->text['js'],'core.validateForm(') !== false);
	}
}
?>