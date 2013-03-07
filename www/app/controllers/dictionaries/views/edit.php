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



core::ensure_navstate(array('left'=>'left_dashboard'),'dictionaries-edit','market-admin');
core_ui::fullWidth();
core::head('Dictionary','This page is used to edit the site dictionary');
core_ui::tagset_init('fieldtags');
lo3::require_permission();

$tag_classes=array('customer','address');
?>

<? page_header('Editing Dictionary',null,null, null, null, 'cog'); ?>

<form class="form-horizontal" method="post" name="dictform" action="dictionaries/update" onsubmit="return core.submit('/dictionaries/update',this);">
	<ul class="nav nav-tabs">
		<? $a = 0;
		foreach($cats as $cat): $a++; ?>
			<li <? if ($a == 1): ?>class="active"<? endif; ?>><a href="#tagset_<?= $a ?>" data-toggle="tab"><?= $cat['name'] ?></a></li>
		<? endforeach; ?>

		<? foreach($tag_classes as $tag): ?>
			<li><a href="#tagset_<?= $name ?>_<?= $value ?>" data-toggle="tab"><?= $value ?></a></li>
		<? endforeach; ?>
	</ul>

	<div class="tab-content">
	<? $a=0; foreach($cats as $cat): $a++; ?>

		<div class="tab-pane <? if ($a == 1): ?>active<? endif; ?>" id="tagset_<?= $a ?>">
			<? if ($cat['pcat_id'] == 8): ?>
				<p>Note: you can test these e-mails using the <a href="#!emails-tests" onclick="core.go(this.href);"><?=$core->i18n['nav2:emails:tests']?></a> page.</p>
			<? endif; ?>

			<? foreach($phrases[$cat['name']] as $phrase):
				$phrase['tags'] = explode(',',$phrase['tags']);
			?>
			
				<div class="control-group">
					<label class="control-label" for="phrase_<?=$phrase['phrase_id']?>"><?=$phrase['label']?>:</label>
					<div class="controls">
						<?if($phrase['edit_type'] == 'text'){?>
							<input type="text" name="phrase_<?=$phrase['phrase_id']?>" value="<?=htmlentities($phrase['default_value'])?>" />
						<?}else if($phrase['edit_type'] == 'textarea'){?>
							<textarea name="phrase_<?=$phrase['phrase_id']?>" rows="5" cols="45"><?=htmlentities($phrase['default_value'])?></textarea>
						<?} if($phrase['edit_type'] == 'rte'){?>
							<textarea class="wysihtml5 input-xxlarge" id="phrase_<?=$phrase['phrase_id']?>" name="phrase_<?=$phrase['phrase_id']?>" rows="5" cols="45"><?=htmlentities($phrase['default_value'])?></textarea>						
						<?}?>
						<?if($phrase['info_note'] != ''){ echo(info($phrase['info_note']));	}?>
					</div>
				</div>

			<? endforeach; ?>
		</div>

	<? endforeach; ?>
	</div> <!-- /.tab-content-->
	
	<? core_ui::wysihtml5(500,300,'/css/emails.css'); ?>
	<div class="form-actions">
		<!--<button type="button" class="btn" onclick="history.go(-1);">Cancel</button>-->
		<button type="submit" class="btn btn-primary">Save changes</button>
	</div>
	
</form>

<?=core_ui::tabset('phrasecats') ?>
<? core_ui::fullWidth(); ?>