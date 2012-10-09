<?php
/*
Plugin Name: Cleaner Dashboard
Plugin URI: http://wordpress.org/extend/plugins/cleaner-dashboard/
Description: Cleans up your dashboard by removing the WordPress news and making the "zeitgeist" more horizontal.
Author: rob1n
Author URI: http://robinadr.com/
Version: 1.1

	Copyright 2007 Robin Adrianse a.k.a. rob1n

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

*/

function cd_remove()
{
	remove_action( 'admin_head', 'index_js' );
}

/*
	A note on the choice of 'admin_print_scripts as the action hook: There are no other hooks between the 
	add_action in index.php and admin_head in admin-header.php. So it had to be this one.
*/
add_action( 'admin_print_scripts', 'cd_remove' );

function cd_incoming_links()
{
?>
<script type="text/javascript">
	jQuery(function() {
		jQuery('#incominglinks').load('index-extra.php?jax=incominglinks');
	});
</script>
<?php
}

if ( basename( $_SERVER['SCRIPT_FILENAME'] ) == 'index.php' ) {
	add_action( 'admin_head', 'cd_incoming_links' );
}

function cd_css()
{
?>
<style type="text/css" media="screen">
	#zeitgeist { float: right; width: 70%; }
	#zeitgeist div { float: left; width: 31%; margin-bottom: 20px; margin-right: 3%; }
	#zeitgeist div + div + div { margin-right: 0; }
	#zeitgeist div + div + div + div { float: none; width: 100%; margin-bottom: 0; }
	#zeitgeist h3 { font-size: 14px; }
	#zeitgeist li { list-style: none; }
	#zeitgeist ul { margin-left: 0; padding-left: 0; }
	#zeitgeist h3 { clear: both; }
</style>
<?php
}

add_action( 'admin_head', 'cd_css' );

?>