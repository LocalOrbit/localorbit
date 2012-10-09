<?php
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

$cats = new core_collection('select * from phrase_categories order by sort_order');
$phrases = new core_collection('
	select p.*,pc.name as category
	from phrases p
	left join phrase_categories pc using (pcat_id)
	order by pc.sort_order,p.sort_order
');
$overrides = new core_collection('
	select po.*,d.name as domain,l.name as language
	from phrase_overrides po
	left join languages l using (lang_id)
	left join domains d using (domain_id)
	order by po.phrase_id,d.name,l.name
');
$phrases = $phrases->to_hash('category');
$overrides = $overrides->to_hash('phrase_id');



core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Dictionary','This page is used to edit the site dictionary');
core_ui::tagset_init('fieldtags');
lo3::require_permission();

$tag_classes=array('customer','address');
?>
<h1>Editing Dictionary</h1>
<form method="post" name="dictform" action="dictionaries/update" onsubmit="return core.submit('/dictionaries/update',this);">
	<div class="tagset">
	<?foreach($tag_classes as $tag){ echo(core_ui::tagset_link('fieldtags',$tag));	} ?>
	</div>
	<div class="tabset" id="phrasecats">
		<?php $a=0; foreach($cats as $cat){ $a++;?>
		<div class="tabswitch" id="phrasecats-s<?=$a?>">
			<?=$cat['name']?>
		</div>
		<?}?>
	</div>
	<?php $a=0; foreach($cats as $cat){ $a++;?>
		<div class="tabarea" id="phrasecats-a<?=$a?>">
			<?if($cat['pcat_id'] == 8){?>
			Note: you can test these e-mails using the <a href="#!emails-tests" onclick="core.go(this.href);"><?=$core->i18n['nav2:emails:tests']?></a> page.
			<?}?>
			<table class="form">
				<col width="240" />
				<col />
			<?
			foreach($phrases[$cat['name']] as $phrase)
			{
				
				$phrase['tags'] = explode(',',$phrase['tags']);
			?>
				<tr<?=core_ui::tagset_classes('fieldtags',$phrase['tags'])?>>
					<td class="label">
						<?=$phrase['label']?>:
					</td>
					<td class="value">
						<?if($phrase['edit_type'] == 'text'){?>
						<input type="text" style="width: 400px;" name="phrase_<?=$phrase['phrase_id']?>" value="<?=htmlentities($phrase['default_value'])?>" />
						<?}else if($phrase['edit_type'] == 'textarea'){?>
						<textarea name="phrase_<?=$phrase['phrase_id']?>" rows="5" cols="45"><?=htmlentities($phrase['default_value'])?></textarea>
						<?} if($phrase['edit_type'] == 'rte'){?>
						<textarea class="rte" id="phrase_<?=$phrase['phrase_id']?>" name="phrase_<?=$phrase['phrase_id']?>" rows="5" cols="45"><?=htmlentities($phrase['default_value'])?></textarea>						
						<?}?>
						<?if($phrase['info_note'] != ''){ echo(info($phrase['info_note']));	}?>
					</td>
				</tr>
			<?}?>
			</table>
		</div>
	<?}?>
	<? core_ui::rte(500,300,'/css/emails.css'); ?>
	<div class="buttonset">
		<input type="submit" class="button_primary" value="save" />
	</div>
</form>

<?=core_ui::tabset('phrasecats') ?>
