$ ->
  $("#product_category_id").chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '500px'
    search_contains: true

  chosenSearchInput = $("#product_category_id_chosen .chosen-search input")

  sendBackspaceToSearch = ()->
    press = jQuery.Event("keyup")
    press.ctrlKey = false
    press.which = 8
    press.keyCode = 8
    chosenSearchInput.trigger(press)

  # We redefine results_show on the chosen object
  # by calling the original results_show, then
  # check the results list to know if the chosen
  # search box gets cleared
  chosen_object = $("#product_category_id").data('chosen')
  if chosen_object?
    _old_results_show = chosen_object.results_show
    chosen_object.results_show = ()->
      _old_results_show.apply chosen_object, []
      if $(".active-result").size() == 0
        chosenSearchInput.val("")
        sendBackspaceToSearch()

  $('#product_category_id').on "chosen:showing_dropdown", ()->
    chosenSearchInput.val($("#product_name").val())

