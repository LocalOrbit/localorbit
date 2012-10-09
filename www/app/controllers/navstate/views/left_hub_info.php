

<?if(trim($core->config['domain']['buyer_types_description']) != ''){?>
	<h1>Selling To</h1>
	<?=$core->config['domain']['buyer_types_description']?>
	<br />&nbsp;<br />
<?}?>


<? if($core->config['domain']['domain_id'] > 1){?>

<h2>Pickup/Delivery</h2>
<?
$delivs = core::model('delivery_days')->collection()->filter('domain_id',$core->config['domain']['domain_id']);
foreach($delivs as $deliv)
{
	echo($deliv['buyer_formatted_cycle'].'.<br />&nbsp;<br />');
}

?>
&nbsp;<br />

<?if(trim($core->config['domain']['secondary_contact_name']) != ''){?>
	<h2>Contact</h2>
	<a href="mailTo:<?=$core->config['domain']['secondary_contact_email']?>"><?=$core->config['domain']['secondary_contact_name']?></a><br />
	<?if(trim($core->config['domain']['secondary_contact_phone']) != ''){?>
		T: <?=$core->config['domain']['secondary_contact_phone']?>
	<?}?>
	<br />&nbsp;<br />
<?}?>
<?}?>
&nbsp;<br />
<? core::replace('left'); ?>