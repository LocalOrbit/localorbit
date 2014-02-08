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

  $("#product_organization_id, #seller_info").change ->
    # Only trigger the locations load when the user is
    # dealing with customizing location data to avoid
    # unecessary requests.
    return if $("#seller_info").prop("checked")

    # Users with multiple managed organizations have a dropdown where as users
    # with a single managed organization have a single value hidden field.
    organization_id = $("#product_organization_id option:selected").val() ||
                      $("#product_organization_id").val()

    $.get("/organizations/#{organization_id}/locations.json").done (json) ->

      product_location = $("#product_location_id")
      product_location.empty()

      $.each json.locations, (_, location) ->
        $("<option/>").attr("value", location.id)
                      .text(location.name)
                      .appendTo(product_location)
