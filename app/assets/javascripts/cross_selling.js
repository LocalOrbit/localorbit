$(document).ready(function(){
  // Top-level category selection of all sub-categories
  $(".top").click(function(){
    var subcategories = "#category_" + this.value + " .secondlevel"
    $(subcategories).prop( "checked", $(this).prop("checked"));
  });

  // 'Select all' check boxes...
  $(".select_all").click(function(){
    $(this).closest(".bound-list").find("input:checkbox").prop("checked", $(this).prop("checked"));
  });
});
