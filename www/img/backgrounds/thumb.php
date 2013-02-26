<?
list($dir, $filename) = explode('/', $_SERVER['PATH_INFO']);

$filename = getcwd().'/'.$filename;

if (file_exists($filename)) 
{
	session_start(); 
	header("Cache-Control: private, max-age=10800, pre-check=10800");
	header("Pragma: private");
	header("Expires: " . date(DATE_RFC822,strtotime(" 2 day")));
	header('Content-Type: image/jpeg');
	list($width, $height) = getimagesize($filename);
	$thumb = imagecreatetruecolor(140, 140);
	$image = imagecreatefromjpeg($filename);
	$new_size = min($width,$height)/2;
	imagecopyresampled($thumb, $image, 0, 0, ($width-$new_size)/2, ($height-$new_size)/2, 140, 140, $new_size, $new_size);
	imagejpeg($thumb, null, 100);
	imagedestroy($image);
}
else 
{
	header($_SERVER["SERVER_PROTOCOL"]." 404 Not Found"); 
}
?>