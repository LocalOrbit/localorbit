<?php 
$opts = core::model('template_options')->get_options(array('footer'));
?>
<?for ($i = 1; $i < 5; $i++){?>
	<?if($opts['footer-col'.$i.'-label'] != '' && $opts['footer-col'.$i.'-label'] != 'Know Local'){?>
		<div class="header_1"><?=$opts['footer-col'.$i.'-label']?></div>
		<ul class="subheader">
		<?for ($j = 1; $j < 9; $j++){?>
			<?
			if($opts['footer-col'.$i.'-link'.$j.'-href'] !='')
			{
				$target='';
				if(strpos('http',$opts['footer-col'.$i.'-link'.$j.'-href']) !== false)
					$target=' target="_blank"';
				else
					$target=' onclick="core.go(this.href);"';
				?>
			<li class="subheader_1">
				<a href="<?=$opts['footer-col'.$i.'-link'.$j.'-href']?>"<?=$target?>>
					<?=$opts['footer-col'.$i.'-link'.$j.'-label']?>
				</a>
			</li>
			<?}?>
		<?}?>
		</ul>
	<?}?>
<?}?>	
<?php core::replace('left'); ?>