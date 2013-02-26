<?php

$allowed_resolutions = array(
	'100x75'=>true,
	'200x150'=>true,
	'400x300'=>true,
	'800x600'=>true,
);

$path = dirname(__FILE__);
$info = explode('.',$_REQUEST['thumb']);

$data_id   = intval($info[0]);
$width     = intval($info[1]);
$height    = intval($info[2]);
$maxwidth  = intval($info[3]);
$maxheight = intval($info[4]);
$ext   = $info[5];


# make sure someone isn't just accessing random resolutions
if(!isset($allowed_resolutions[$max_x.'x'.$max_y]) || !$allowed_resolutions[$max_x.'x'.$max_y])
{
	#exit('This ratio is not available');
}
//determine which side is the longest to use in calculating length of the shorter side, since the longest will be the max size for whichever side is longest.    
	if ($height > $width) 
	{   
		$ratio = $maxheight / $height;  
		$newheight = $maxheight;
		$newwidth = $width * $ratio; 
		$writex = round(($maxwidth - $newwidth) / 2);
		$writey = 0;
	}
	else 
	{
		$ratio = $maxwidth / $width;   
		$newwidth = $maxwidth;  
		$newheight = $height * $ratio;   
		$writex = 0;
		$writey = round(($maxheight - $newheight) / 2);
	}




# load the image, using the right format
switch(exif_imagetype($path.'/raws/'.$data_id.'.dat'))
{
	case 2:
		$img = imagecreatefromjpeg($path.'/raws/'.$data_id.'.dat');
		break;
	case 1:
		$img = imagecreatefromgif($path.'/raws/'.$data_id.'.dat');
		break;
	case 3:
		$img = imagecreatefrompng($path.'/raws/'.$data_id.'.dat');
		break;
	default:
		exit('unknown format');	
		break;
}

	$newimg = imagecreatetruecolor($newwidth,$newheight);
	
	//Since you probably will want to set a color for the letter box do this
	//Assign a color for the letterbox to the new image, 
	//since this is the first call, for imagecolorallocate, it will set the background color
	//in this case, black rgb(0,0,0)
	#imagecolorallocate($newimg,0,0,0);

	//Loop Palette assignment stuff here
	imagecopyresampled($newimg,$img,0,0,0,0,$newwidth,$newheight, $width, $height);
	#imagecopyresized($newimg, $img, $writex, $writey, 0, 0, $newwidth, $newheight, $width, $height);e
	#exit('output to '.dirname(__FILE__).'/'.$_REQUEST['thumb']);
	imagejpeg($newimg,dirname(__FILE__).'/cache/'.$data_id.'.'.$width.'.'.$height.'.'.$maxwidth.'.'.$maxheight.'.jpg',95);
	//$output file is the path/filename where you wish to save the file.  
	header('Pragma: no-cache');
	header('Expires: Thu, 19 Nov 1981 08:52:00 GMT');
	header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
	header('Cache-Control: no-store, no-cache, must-revalidate');
	header("Content-Type: image/jpeg"); 
	header("Content-Disposition: inline; filename=\"".$_REQUEST['thumb']."\";" ); 
	header("Content-Transfer-Encoding: binary"); 
	echo(file_get_contents(dirname(__FILE__).'/cache/'.$data_id.'.'.$width.'.'.$height.'.'.$maxwidth.'.'.$maxheight.'.jpg'));
	//Have to figure that one out yourself using whatever rules you want.  Can use imagegif() or imagepng() or whatever.
	
?>