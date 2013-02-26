<?php
/*
Part of Plugin: Ozh' Admin Drop Down Menu
http://planetozh.com/blog/my-projects/wordpress-admin-menu-drop-down-css/
*/

global $wp_ozh_adminmenu;

function wp_ozh_adminmenu_checkbox($chk) {
	global $wp_ozh_adminmenu;
	$checked = ($wp_ozh_adminmenu[$chk] == 1) ? 'checked="checked"' : '' ;
	echo <<<CHK
</label><input type="hidden" value="0" name="oam_$chk"/><label><input type="checkbox" id="oam_check_$chk" $checked name="oam_$chk" value="1">
CHK;

}

function wp_ozh_adminmenu_options_page() {
	global $wp_ozh_adminmenu, $text_direction;
	
	/**
	echo "<pre>".wp_ozh_adminmenu_sanitize(print_r($_POST,true))."</pre>";
	echo "<pre>".wp_ozh_adminmenu_sanitize(print_r($wp_ozh_adminmenu,true))."</pre>";
	/**/
	
	$too_many_plugins = intval($wp_ozh_adminmenu['too_many_plugins']);
	$grad = $wp_ozh_adminmenu['grad'];
	$align = ($text_direction == 'rtl' ? 'right' : 'left');
	
	echo '
	<style type="text/css">
	.wrap {margin-bottom:2em}
	.wrap ul {list-style-type:disc;padding-'.$align.':3em;}
	input {border:0}
	#oam_cp_wrap {overflow:hidden;}
	#oam_cp_toggle {vertical-align:-2px;cursor:pointer}
	.oam_cp_preset {cursor:pointer;float:'.$align.';width:30px;height:30px;-moz-border-radius:30px;-webkit-border-radius:30px;margin:4px 5px 2px 5px;}
	#oam_colorpicker {float:'.$align.';}
	
	</style>
    <div class="wrap">
    <div class="icon32" id="icon-options-general"><br/></div><h2>Admin Drop Down Menu</h2>
    <form method="post" action="">
	';
	wp_nonce_field('ozh-adminmenu');
?>
	<h3><?php echo wp_ozh_adminmenu__('Icons and Colors'); ?></h3>
	<table class="form-table"><tbody>
	<input type="hidden" name="ozh_adminmenu" value="1"/>
    <input type="hidden" name="action" value="update_options">
	
    <tr><th scope="row"><?php echo wp_ozh_adminmenu__('Top Level Icons'); ?></th>
	<td><label><?php wp_ozh_adminmenu_checkbox('wpicons'); ?> <?php echo wp_ozh_adminmenu__('Display original menu icons in top level links');?></label><br/>
	<?php printf(wp_ozh_adminmenu__('Checking this enables Compact Mode &darr;')); ?>
	</td></tr>

    <tr id="oam_compact_row" <?php echo ($wp_ozh_adminmenu['wpicons'] ? '' : 'style="display:none"') ?>><th scope="row"><?php echo wp_ozh_adminmenu__('Compact Mode'); ?></th>
	<td><label><?php wp_ozh_adminmenu_checkbox('compact'); ?> <?php echo wp_ozh_adminmenu__('Shrink top level links down to their icons');?></label><br/>
	<?php printf(wp_ozh_adminmenu__('That was a cool WordPress feature, so I stole it :)')); ?>
	</td></tr>

    <tr><th scope="row"><?php echo wp_ozh_adminmenu__('Sublevel Icons'); ?></th>
	<td><label><?php wp_ozh_adminmenu_checkbox('icons'); ?>  <?php echo wp_ozh_adminmenu__('Display icons in drop down menus');?></label><br/>
	<?php printf(wp_ozh_adminmenu__("They're so cute (and they're from %s)"),'<a href="http://www.famfamfam.com/">famfamfam</a>'); ?>
	</td></tr>

    <tr><th scope="row"><?php echo wp_ozh_adminmenu__('Color Scheme'); ?></th>
	<td><input type="text" id="oam_grad" name="oam_grad" size="7" value="<?php echo $grad ?>" /><img id="oam_cp_toggle" src="<?php echo wp_ozh_adminmenu_pluginurl().'inc/images/'; ?>color_wheel.png" /> <label for="oam_grad"><?php printf(wp_ozh_adminmenu__("Pick a color for your menu bar, using the color wheel or one of the presets")); ?><br/>
	<label><?php wp_ozh_adminmenu_checkbox('nograd'); ?>  <?php echo wp_ozh_adminmenu__('No subtle gradient, just plain color.');?></label>
	<div id="oam_cp_wrap">
	<div id="oam_colorpicker" style="display:none"></div>
	<?php
	$colors = $wp_ozh_adminmenu['nograd'] ? 
	array(
	// colors for solid menu
		'#616161',
		'#9a109d',
		'#3838a3',
		'#c91313',
		'#057979',
		'#078208',
		'#023b79',
		'#9c5654',
		'#854700',
		'#406a2f',
	) : array(
	// colors for gradient menu
		'#cad2da',
		'#e61fea',
		'#6969ce',
		'#c91313',
		'#057979',
		'#078208',
		'#676768',
		'#81b7ee',
		'#ee8c81',
		'#eb8d19',
		'#6cd440',
	);
	$bgurl = $wp_ozh_adminmenu['nograd'] ? '' : wp_ozh_adminmenu_pluginurl().'inc/images/grad-trans.png';
	foreach ($colors as $color) {
		echo '
		<div class="oam_cp_preset" title="'.$color.'" style="background:'.$color.' url('.$bgurl.') repeat-x left top;"></div>
		';
	} ?>
	</div>
	
	</td></tr>

	</tbody></table>
	<h3><?php echo wp_ozh_adminmenu__('Advanced Settings'); ?></h3>
	<table class="form-table"><tbody>

    <tr><th scope="row"><?php echo wp_ozh_adminmenu__('Minimal Mode'); ?></th>
	<td><label><?php wp_ozh_adminmenu_checkbox('minimode'); ?>  <?php echo wp_ozh_adminmenu__('Hide header'); ?></label><br/>
	<?php echo wp_ozh_adminmenu__("Remove the whole header bar for maximum screen real estate. Note: The quick link to your blog will be added to the menu, the Logout link in the Users sub-menu."); ?>
	</td></tr>

    <tr><th scope="row"><?php echo wp_ozh_adminmenu__('Break Long Lists'); ?></th>
	<td><label><?php printf(wp_ozh_adminmenu__('Break if more than %s menu entries'), "<input type=\"text\" value=\"$too_many_plugins\" size=\"2\" name=\"oam_too_many_plugins\">"); ?></label><br/>
	<?php echo wp_ozh_adminmenu__('If a dropdown gets longer than this value, it will switch to horizontal mode so that it will hopefully fit in your screen (requires javascript)'); ?>
	</td></tr>

    <tr><th scope="row"><?php echo wp_ozh_adminmenu__('Top Links'); ?></th>
	<td><label><?php wp_ozh_adminmenu_checkbox('toplinks'); ?>  <?php echo wp_ozh_adminmenu__('Make top links clickable'); ?></label><br/>
	<?php echo wp_ozh_adminmenu__('Uncheck this option to improve compatibility with browsers that cannot handle the "hover" event (<em>ie</em> most handheld devices)'); ?>
	</td></tr>
	
    <tr><th scope="row"><?php echo wp_ozh_adminmenu__('Hide "0" Bubbles'); ?></th>
	<td><label><?php wp_ozh_adminmenu_checkbox('hidebubble'); ?> <?php echo wp_ozh_adminmenu__('Hide speech bubbles when no awaiting comments or outdated plugins'); ?></label><br/>
	<?php echo wp_ozh_adminmenu__('Check if those tiny "0" speech bubble are too distracting for your taste'); ?>
	</td></tr>

    <tr><th scope="row"><?php echo wp_ozh_adminmenu__('Give Some &hearts;'); ?></th>
	<td><?php printf(wp_ozh_adminmenu__('Do you like this plugin? Then <a href="%s">rate it 5 Stars</a> on the official Plugin Directory!'),'http://wordpress.org/extend/plugins/ozh-admin-drop-down-menu/'); ?><br/>
	<?php printf(wp_ozh_adminmenu__('Do you DIG this plugin? Please <a href="%s">tweet about it</a>! (oh, and <a href="http://twitter.com/ozh">follow me</a> by the way&nbsp;:'),"http://twitter.com/?status=I%20love%20Ozh's%20Admin%20Drop%20Down%20Menu%20for%20WordPress%20http://ozh.in/kl"); ?>)<br/>
	<?php printf(wp_ozh_adminmenu__('Do you <em>love</em> this plugin? Please <a href="%s">blog about it</a>! Tell your readers you like it so they will discover, try and hopefully like it too&nbsp;:)'),'post-new.php'); ?><br/>
	<?php printf(wp_ozh_adminmenu__('Are you <span id="totallycrazy">crazy</span> about this plugin? <a href="%s">Paypal me a beer</a>! Every donation warms my heart and motivates me to release free stuff!'),'http://planetozh.com/exit/donate'); ?>
	</td></tr>

	</tbody></table>
	
	
	<script type="text/javascript">
	var wpicons = <?php echo $wp_ozh_adminmenu['wpicons']; ?>;

	// Top level icons
	jQuery('#oam_check_wpicons').click(function(){
		oam_toggle_row('#oam_compact_row');
		if (jQuery(this).attr('checked')) {
			jQuery('#ozhmenu .ozhmenu_toplevel a.menu-top').css('padding', '0 5px 0 1px');
		} else {
			if (jQuery('#oam_check_compact').attr('checked')) {
				jQuery('#oam_check_compact').click();
			}
			jQuery('#ozhmenu .ozhmenu_toplevel a.menu-top').css('padding', '0px 10px');
		}
		jQuery('li.ozhmenu_toplevel div.wp-menu-image, li.ozhmenu_toplevel img').toggle();
	});

	// Compact mode
	jQuery('#oam_check_compact').click(function(){
		jQuery('.ozhmenu_toplevel span.compact').toggle();
		jQuery('.ozhmenu_toplevel span.full').toggle();
		jQuery('.toplevel_label').toggle();
	});
	
	// Sublevel icons
	// TODO
		
	// Color picking
	var f;
	jQuery(document).ready(function(){
		f = jQuery.farbtastic('#oam_colorpicker', function(){oam_gradient()});
		f.linkTo(jQuery('#oam_grad')).setColor(jQuery('#oam_grad').val());
		f.linkTo(function(col){oam_gradient(col)});
	});
	function oam_gradient(col) {
		jQuery('#ozhmenu, #ozhmenu li.ozhmenu_over, #ozhmenu li .wp-has-current-submenu').css('backgroundColor', col);
		f.linkTo(jQuery('#oam_grad')).setColor(col);
		f.linkTo(function(col){oam_gradient(col)});
	}
	jQuery('#oam_cp_toggle').click(function(){
		jQuery('#oam_colorpicker').toggle(300);
	});
	jQuery('.oam_cp_preset').click(function(){
		oam_gradient(jQuery(this).attr('title'));
	});
	
	
	
	// Minimode
	jQuery('#oam_check_minimode').click(function(){
		jQuery('#wphead').slideToggle();
		oam_toggle_row('#oam_fav_row');
	});
	
	// Display favs
	jQuery('#oam_check_displayfav').click(function(){
		jQuery('#favorite-actions').toggle(200);
	});

	// Hide bubbles
	jQuery('#oam_check_hidebubble').click(function(){
		var display = (jQuery(this).attr('checked')) ? 'none' : 'inline';
		jQuery('li.ozhmenu_toplevel span.count-0').css('display', display);
	});

	/* functions */

	
	// Row toggling on checkbox change
	function oam_toggle_row(row) {
		var row = jQuery(row);
		if (row.css('display') == 'none') {
			var bg = row.css('backgroundColor');
			row.fadeIn(900);
		} else {
			row.fadeOut(600);
		}
	}

	// Preset div styling
	function oam_label_border(color) {
		jQuery('.oam_label').css({'border':'0px','margin':'2px 10px 0 2px'});
		jQuery('#oam_label_'+color).css({'border':'2px solid #111','margin':'0 8px 0 0'});
	}

	// The silly dancing word
	function oam_dance() {
		var fontstyle, delay;
		if (jQuery('#totallycrazy').css('font-style') == 'italic') {
			fontstyle = 'normal'; delay = 500;
		} else {
			fontstyle = 'italic'; delay = 200;
		}
		jQuery('#totallycrazy').css('font-style',fontstyle);
		oam_danceagain(delay);
	}
	function oam_danceagain(delay) {setTimeout(function(){oam_dance();}, delay);}
	oam_danceagain(100);
	</script>

	<p class="submit">
	<input name="submit" class="button-primary" value="<?php echo wp_ozh_adminmenu__('Save Changes');?>" type="submit" />
	</p>

	</form>
	</div>
	
	<div class="wrap"><h2><?php echo wp_ozh_adminmenu__('Reset Settings');?></h2>
	<form method="post" action="">

<?php
	wp_nonce_field('ozh-adminmenu');
?>
	<input type="hidden" name="ozh_adminmenu" value="1"/>
    <input type="hidden" name="action" value="reset_options">

	<p><?php echo wp_ozh_adminmenu__('Clicking the following button will remove all the settings for this plugin from your database. You might want to do so in the following cases:');?></p>
	<ul>
	<li><?php echo wp_ozh_adminmenu__('you want to uninstall the plugin and leave no unnecessary entries in your database.');?></li>
	<li><?php echo wp_ozh_adminmenu__('you want all settings to be reverted to their default values');?></li>
	</ul>
	<p class="submit" style="border-top:0px;padding:0;"><input style="color:red" name="submit" value="<?php echo wp_ozh_adminmenu__('Reset Settings');?>" onclick="return(confirm('<?php echo esc_js(wp_ozh_adminmenu__('Really do?'));?>'))" type="submit" /></p>
	<p><?php echo wp_ozh_adminmenu__('There is no undo, so be very sure you want to click the button!');?></p>
	
	</form>
	</div>
<?php

}

// Sanitize string for display: escape HTML but preserve UTF8 (or whatever)
function wp_ozh_adminmenu_sanitize( $string ) {
	return stripslashes( esc_attr( $string ) );
	//return stripslashes(htmlentities($string, ENT_COMPAT, get_bloginfo('charset')));
}

?>