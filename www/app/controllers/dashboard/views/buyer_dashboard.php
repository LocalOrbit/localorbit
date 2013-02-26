<?
core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();

$org = core::model('organizations')->load($core->session['org_id']);
$address = core::model('addresses')->collection()->filter('org_id',$org['org_id'])->filter('default_billing',1)->load();
$address = $address->row()
?>

<h1>Hello <?=$core->session['first_name']?> <?=$core->session['last_name']?></h1>
<p>From your Dashboard you have the ability to view a snapshot of your recent account activity and  update your account information. Select a link below to view or edit information.</p>

<? $this->buyer_orders(); ?>