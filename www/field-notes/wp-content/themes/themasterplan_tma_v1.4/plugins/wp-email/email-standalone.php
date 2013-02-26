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
|	- E-Mail Post/Page To A Friend												|
|	- wp-content/plugins/wp-email/email-standalone.php					|
|																							|
+----------------------------------------------------------------+
*/


### Session Start
#@session_start();

### Filters
add_filter('wp_title', 'email_pagetitle');
add_action('loop_start', 'email_addfilters');

### We Use Page Template
if(file_exists(TEMPLATEPATH.'/email.php')) {
	include(TEMPLATEPATH.'/email.php');
} elseif(file_exists(TEMPLATEPATH.'/page.php')) {
	include(get_page_template());
} elseif(file_exists(TEMPLATEPATH.'/single.php')) {
	include(get_single_template());
} else {
	include(TEMPLATEPATH.'/index.php');
}
?>