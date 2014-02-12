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

  unless $("#seller_info").prop("checked")
    $(".seller_info_fields").toggleClass("hidden")

  $("#product_organization_id, #seller_info").change ->
    # Only trigger the locations load when the user is
    # dealing with customizing location data to avoid
    # unecessary requests.
    return if $("#seller_info").prop("checked")

    # Users with multiple managed organizations have a dropdown where as users
    # with a single managed organization have a single value hidden field.
    organizationId = $("#product_organization_id option:selected").val() ||
                      $("#product_organization_id").val()

    $.get("/organizations/#{organizationId}/locations.json").done (json) ->

      productLocation = $("#product_location_id")
      productLocation.empty()

      $.each json.locations, (_, location) ->
        $("<option/>").attr("value", location.id)
                      .text(location.name)
                      .appendTo(productLocation)

  $('#product_use_simple_inventory').change ->
    $('#simple-inventory').toggle()
    $('#product-inventory-nav').toggle()
