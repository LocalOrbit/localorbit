$ ->
  $("#product_category_id").chosen
    search_contains: true
    group_search: true
    enable_split_word_search: true
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '500px'

  $("#seller_info").change ->
    $(".seller_info_fields").toggleClass("hidden")
