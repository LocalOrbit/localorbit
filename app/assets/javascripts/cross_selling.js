$(document).ready(function(){
  // Top-level category selection of all sub-categories
  $(".top").click(function(){
    var subcategories = "#category_" + this.value + " .secondlevel"
    $(subcategories).prop( "checked", $(this).prop("checked"));
  });

  // 'Select all' check boxes...
  // ...for categories
  $("#all_categories").click(function(){
    $("#product-add-categories input:checkbox").prop("checked", $(this).prop("checked"));
  });
  // ...for suppliers
  $("#all_suppliers").click(function(){
    $("#product-add-suppliers input:checkbox").prop("checked", $(this).prop("checked"));
  });
  // ...and for products
  $("#all_products").click(function(){
    $("#product-add-products input:checkbox").prop("checked", $(this).prop("checked"));
  });
});
