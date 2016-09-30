$(document).ready(function(){
  // Top-level category selection of all sub-categories
  $(".top").click(function(){
    var subcategories = "#category_" + this.value + " .secondlevel"
    $(subcategories).prop( "checked", $(this).prop("checked"));
  });

  // 'Select all' check boxes...
  $(".select_all").click(function(){
    $(this).closest(".popup-body").find("input:checkbox").prop("checked", $(this).prop("checked"));
  });

  // Close button should do just that - close the modal without submission
  $('#close-modal').click(function(e) {
    $('.is-open').removeClass('is-open is-dark is-dim is-modal is-editable mobile-dim');
    $('.popup').addClass('is-hidden');
  });

});
