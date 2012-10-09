<?
list($data_id,$maxwidth,$maxheight,$extension) = explode('.',$_REQUEST['thumb']);

try
{
	$allowed_ratios = array(
		'120:100','200:160','320:260','600:480',
	);

	if(!in_array($maxwidth.':'.$maxheight,$allowed_ratios))
		die('this ratio is not allowed');


	//~ $maxwidth = 120;
	//~ $maxheight = 150;

	if(file_exists(dirname(__FILE__).'/../'.$data_id.'.jpg'))
		$img = dirname(__FILE__).'/../'.$data_id.'.jpg'; 
	else if(file_exists(dirname(__FILE__).'/../'.$data_id.'.gif'))
		$img = dirname(__FILE__).'/../'.$data_id.'.gif'; 
	else if(file_exists(dirname(__FILE__).'/../'.$data_id.'.png'))
		$img = dirname(__FILE__).'/../'.$data_id.'.png'; 
	else
		exit('could not find image');
		
	$type = exif_imagetype($img);
	switch($type)
	{
		case 1:
			$img = imagecreatefromgif($img);
			break;
		case 2:
			$img = imagecreatefromjpeg($img);
			break;
		case 3:
			$img = imagecreatefrompng($img);
			break;
	}
	
	//or imagecreatefrompng,imagecreatefromgif,etc. depending on user's uploaded file extension

	$width = imagesx($img); //get width and height of original image
	$height = imagesy($img);

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

	#exit('new dimens: '.$newwidth.'/'.$newheight);
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
	imagejpeg($newimg,dirname(__FILE__).'/'.$data_id.'.'.$maxwidth.'.'.$maxheight.'.jpg'); //$output file is the path/filename where you wish to save the file.  
	header('Pragma: no-cache');
	header('Expires: Thu, 19 Nov 1981 08:52:00 GMT');
	header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
	header('Cache-Control: no-store, no-cache, must-revalidate');
	header("Content-Type: image/jpeg"); 
	header("Content-Disposition: inline; filename=\"".$_REQUEST['thumb']."\";" ); 
	header("Content-Transfer-Encoding: binary"); 
	echo(file_get_contents(dirname(__FILE__).'/'.$data_id.'.'.$maxwidth.'.'.$maxheight.'.jpg'));
	//Have to figure that one out yourself using whatever rules you want.  Can use imagegif() or imagepng() or whatever.
}
catch(Exception $e)
{
	exit('did not succeed');
}
?>