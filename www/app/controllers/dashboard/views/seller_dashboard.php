<?
core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();
?>

<div class="row-fluid">
  <div class="span6"><? $this->seller_orders(); ?></div>
  <div class="span6"><? $this->seller_deliveries(); ?></div>
</div>

