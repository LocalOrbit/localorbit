<div id="insert_map_dialog" title="<?php _e('Generate map code..', 'umapper')?>">
<form onsubmit="return false" id="insert_map_frm">
    <input type="hidden" name="tp" id="tp" value="" />
	<div id="select_size">
	    <div>1. <?php _e('Select map size', 'umapper') ?></div>
	    <div id="size_preview"><img id="size_image" rel="none" src="<?php echo Umapper_Plugin::getPluginUri() ?>/content/img/size_s.png" alt=""/></div>
	    <div id="sizes">
            <input type="radio" id="size_sq" name="size" value="sq" /> <label for="size_sq"><?php _e('Square', 'umapper') ?> (<?php echo Umapper_Shortcode::$mapSizes['sq'][0] . ' x ' . Umapper_Shortcode::$mapSizes['sq'][1];?>)</label><br />
            <input type="radio" id="size_t" name="size" value="t" /> <label for="size_t"><?php _e('Thumbnail', 'umapper') ?> (<?php echo Umapper_Shortcode::$mapSizes['t'][0] . ' x ' . Umapper_Shortcode::$mapSizes['t'][1];?>)</label><br />
            <input type="radio" id="size_s" name="size" value="s" checked="checked" /> <label for="size_s"><?php _e('Small', 'umapper') ?> (<?php echo Umapper_Shortcode::$mapSizes['s'][0] . ' x ' . Umapper_Shortcode::$mapSizes['s'][1];?>)</label><br />
            <input type="radio" id="size_m" name="size" value="m" /> <label for="size_m"><?php _e('Medium', 'umapper') ?> (<?php echo Umapper_Shortcode::$mapSizes['m'][0] . ' x ' . Umapper_Shortcode::$mapSizes['m'][1];?>)</label><br />
            <input type="radio" id="size_l" name="size" value="l" /> <label for="size_l"><?php _e('Large', 'umapper') ?> (<?php echo Umapper_Shortcode::$mapSizes['l'][0] . ' x ' . Umapper_Shortcode::$mapSizes['l'][1];?>)</label><br />
            <input type="radio" id="size_c" name="size" value="c" /> <label for="size_c"><?php _e('Custom', 'umapper') ?></label><br />
            <div style="margin:0px; padding:0px;margin-left:20px;">
                <input type="text" name="w" id="w" value="<?php echo Umapper_Shortcode::$mapSizes['s'][0];?>px" style="width:45px;font-size:8pt;padding:0px;" maxlength="6" disabled>x<input type="text" name="h" id="h" value="<?php echo Umapper_Shortcode::$mapSizes['s'][1];?>px" style="width:45px;font-size:8pt;padding:0px;" maxlength="6" disabled>
            </div>
            <br />
	    </div>
	</div>
	<div id="select_alignment">
	    <div>2. <?php _e('Select map alignment', 'umapper') ?></div>
	    <div id="alignment_preview"><img id="alignment_image" rel="none" src="<?php echo Umapper_Plugin::getPluginUri() ?>/content/img/alignment_center.png" alt=""/></div>
	    <div id="allignments">
	        <input type="radio" id="alignment_none" name="alignment" value="none" /> <label for="alignment_none"><?php _e('Default', 'umapper') ?></label><br />
	        <input type="radio" id="alignment_left" name="alignment" value="left" /> <label for="alignment_left"><?php _e('Left', 'umapper') ?></label><br />
	        <input type="radio" id="alignment_center" name="alignment" value="center" checked="checked"/> <label for="alignment_center"><?php _e('Center', 'umapper') ?></label><br />
	        <input type="radio" id="alignment_right" name="alignment" value="right" /> <label for="alignment_right"><?php _e('Right', 'umapper') ?></label><br />
	    </div>
	</div>
</form>
</div>