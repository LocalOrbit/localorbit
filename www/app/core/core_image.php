<?php 
# this library contains image manipulation functions. 
# NOTE this library is NOT auto-loaded (as it might be big, but is only used by a few pages),
# so you need to manually load it by calling core::load_library('image');


class core_image
{
	# you can pass one of these 3 things to initialize the object:
	#   1: a $_FILES array value
	#   2: JUST the path to a file, which means the extension must be the correct one
	#   3: both the path and the filename. extension info will be derived only from filename
	function __construct($path_or_file_array,$filename=null)
	{
		$this->data   = null;
		$this->width  = null;
		$this->height = null;
		
		# situation 1
		if(is_array($path_or_file_array))
		{
			$this->path = $path_or_file_array['tmp_name'];
			$this->name = $path_or_file_array['name'];
			$this->size = $path_or_file_array['size'];
		
		}
		else
		{
			# situation 2
			if(is_null($filename))
			{
				$this->path = $path_or_file_array;
				$this->name = basename($path_or_file_array);
			}
			# situation 3
			else
			{
				$this->path = $path_or_file_array;
				$this->name = $filename;
			}
			$this->size = filesize($this->path);
		}
		
		#print_r($this);
		$extension = explode('.',strtolower($this->name));
		$extension = array_pop($extension);
		if($extension == 'jpeg')
			$extension = 'jpg';
			
		$this->extension = $extension;

	}
	
	function load_image()
	{
		$type = exif_imagetype($this->path);
		switch($type)
		{
			case IMAGETYPE_JPEG:
				$this->extension = 'jpg';
				$this->data = imagecreatefromjpeg($this->path);
				break;
			case IMAGETYPE_GIF:
				$this->extension = 'gif';
				$this->data = imagecreatefromgif($this->path);
				break;
			case IMAGETYPE_PNG:
				$this->extension = 'png';
				$this->data = imagecreatefrompng($this->path);
				break;
			
		}
		//~ switch($this->extension)
		//~ {
			//~ case 'gif':
				//~ $this->data = imagecreatefromgif($this->path);
				//~ break;
			//~ case 'jpg':
				//~ $this->data = imagecreatefromjpeg($this->path);
				//~ break;
			//~ case 'png':
				//~ $this->data = imagecreatefrompng($this->path);
				//~ break;
			//~ default:
				//~ exit('unknown extension: '.$this->extension);
				//~ break;
		//~ }
		
		$this->width  = imagesx($this->data);
		$this->height = imagesy($this->data);
		return $this;
	}
	
	function determine_new_dimens($max_width,$max_height)
	{
		
		$ratio = $this->width / $this->height;

		if(($ratio / $max_width) > $max_height)
		{
			# use height to determine final width
			$max_width = $max_height / $ratio;
		}
		else
		{
			# use width
			$max_height = $max_width / $ratio;
		}
		return array($max_width,$max_height);
	}
	
	function resize_to($new_width=0,$new_height=0)
	{
		if(is_null($this->data))
		{
			$this->load_image();
		}
		$new = imagecreatetruecolor($new_width,$new_height);
		imagecopyresized($new,$this->data,0,0,0,0,$new_width,$new_height,$this->width,$this->height);
		$this->data = $new;
		return $this;
	}
	
	function convert_to($new_format)
	{
		$this->load_image();
		$this->extension = $new_format;
		return $this;
	}
	
	function save_as($new_filename,$quality=90)
	{
		if(is_null($this->data))
		{
			copy($this->path,$new_filename);
		}
		else
		{
			switch($this->extension)
			{
				case 'gif':
					imagegif($this->data,$new_filename);
					break;
				case 'jpg':
					imagejpeg($this->data,$new_filename,$quality);
					break;
				case 'png':
					imagepng($this->data,$new_filename,$quality);
					break;
				default:
					exit('unknown extension');
					break;
			}

		}
		return $this;
	}
}

?>
