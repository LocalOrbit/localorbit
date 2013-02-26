<?php
global $data, $core;
$fonts = core::model('fonts')->collection()->sort('font_name');

$backgrounds = core::model('backgrounds')->collection();
$backgrounds = $backgrounds->filter('is_available', 1);

$bg_color = core_format::get_hex_code($data['background_color']);
$font_color = core_format::get_hex_code($data['text_color'], 0x1F7169);

$data['background_id'] = !isset($data['background_id']) && !isset($data['background_color']) ? 1 : $data['background_id'];
$data['header_font'] = $data['header_font']?$data['header_font']:1;
?>

<div class="control-group">
	<label class="control-label" for="font_color">Choose a Font Color <i class="helpslug icon-question-sign" rel="popover" data-title="Font Color" data-content="<?=$core->i18n['hub:style_chooser:font_color']?>" data-original-title=""></i></label>
	<div class="controls row">
		<div class="span5">
			<div id="font_color_picker" class="input-append color colorpicker" data-color="<?=$font_color?>" data-color-format="hex">
			  <input id="font_color" name="font_color" type="text" class="span2" value="<?=$font_color?>" data-default="<?=$font_color?>">
			  <span class="add-on"><i style="background-color: <?=$font_color?>"></i></span>
			</div>
		</div>
	</div>
</div>

<div class="control-group">
	<label class="control-label" for="header_font">Choose a Font <i class="helpslug icon-question-sign" rel="popover" data-title="Font" data-content="<?=$core->i18n['hub:style_chooser:font']?>" data-original-title=""></i></label>
	<div class="controls row">
		<div class="span8">
			<ul id="header_font">
				<? foreach ($fonts as $font) { ?>
				<?
					list($font_label) = explode(',', $font['font_name']);
					$font_label = str_replace("'", "", $font_label);
				?>
				<li>
					<label class="radio">
							<input type="radio" name="header_font" id="header_font_<?=$font['font_id']?>" value="<?=$font['font_id']?>"<?=$data['header_font']==$font['font_id']?' data-default="true" checked':''?> >
							<h2 style="font-family: <?=$font['font_name']?>; letter-spacing: <?=(isset($font['kerning']))?($font['kerning'].'px'):'normal'?>">
								<?=$font_label?>
							</h2>
					</label>
				</li>
				<? } ?>
			</ul>
		</div>
	</div>
</div>

<div class="control-group">
	<label class="control-label" for="background_id">Choose a Background <i class="helpslug icon-question-sign" rel="popover" data-title="Background" data-content="<?=$core->i18n['hub:style_chooser:background']?>" data-original-title=""></i></label>
	<div class="controls row">
		<div class="span5">
			<label class="radio">
			  <input type="radio" name="background_type" id="background_type_color" value="color" <?=(is_null($data['background_id']) || $data['background_id'] === 0)?'checked':''?>>
			  Color
			</label>
		</div>
	</div>
	<div class="controls row">
		<div class="span5">
			<div id="background_color_picker" class="input-append color colorpicker" data-color="<?=$bg_color?>" data-color-format="hex" data-disabled="true">
			  <input id="background_color" name="background_color" type="text" class="span2" value="<?=$bg_color?>" data-default="<?=$bg_color?>">
			  <span class="add-on"><i style="background-color: <?=$bg_color?>"></i></span>
			</div>
		</div>
	</div>
	<div class="controls row">
		<div class="span5">
			<label class="radio">
			  <input type="radio" name="background_type" id="background_type_image" value="image" <?=(is_null($data['background_id']) || $data['background_id'] === 0)?'':'checked'?>>
			  Image
			</label>
		</div>
	</div>
	<div class="controls row">
		<div class="span8">
			<select id="background_id" name="background_id" class="image-picker" data-color="<?=$bg_color?>" data-default="<?=$data['background_id']?>">
					<option <?=(is_null($data['background_id']) || $data['background_id'] === 0)?'':'selected'?>></option>
				<? foreach ($backgrounds as $background) { ?>
					<option value="<?=$background['background_id']?>" data-img-src="/img/backgrounds/thumb.php/<?=$background['file_name']?>" <?=$data['background_id']==$background['background_id']?'selected':''?>><?=$background['file_name']?></option>
				<? } ?>
			</select>
		</div>
	</div>
</div>

<button id="restore-defaults" class="btn-danger btn offset1" onclick="market.revertStyle();" type="button">Revert</button>
<button id="preview-style" class="btn-info btn" onclick="market.saveStyle();" type="button">Preview</button>