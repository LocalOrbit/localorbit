<?php
/*
+----------------------------------------------------------------+
|																							|
|	WordPress 2.7 Plugin: WP-EMail 2.40										|
|	Copyright (c) 2008 Lester "GaMerZ" Chan									|
|																							|
|	File Written By:																	|
|	- Lester "GaMerZ" Chan															|
|	- http://lesterchan.net															|
|																							|
|	File Information:																	|
|	- E-Mail Image Verification														|
|	- wp-content/plugins/wp-email/email-image-verify.php				|
|																							|
+----------------------------------------------------------------+
*/


### Start Session
#@session_start();

### Captial Letters And Numbers
$alphanum = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

### Generate The Verfication Code
$rand = substr(str_shuffle($alphanum), 0, 5);

### MD5 The Code And Assign It To Session
$_SESSION['email_verify'] = md5($rand);

### Create The Image (60x22)
$image = imagecreate(55, 15);

### Use White As The Background Color
$bgColor = imagecolorallocate($image, 255, 255, 255);

### Use Black As The Text Color
$textColor = imagecolorallocate($image, 0, 0, 0);

### Output The Code To The Image
imagestring($image, 5, 5, 1, $rand, $textColor);

### Date In The Past
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");

### Always Modified
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");

### HTTP 1.1
header("Cache-Control: no-store, no-cache, must-revalidate");
header("Cache-Control: post-check=0, pre-check=0", false);

### HTTP 1.0
header("Pragma: no-cache");

### Set The Header To Be JPG
header('Content-type: image/jpeg');

### Send The Image To The Browser
imagejpeg($image);

### Destroy The Image
imagedestroy($image);
?>