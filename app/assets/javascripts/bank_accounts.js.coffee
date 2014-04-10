getFormData = ($form) ->
  hash = {}
  hash[n['name']] = n['value'] for n in $form.serializeArray()
  hash

tokenize = (type, info) ->
  deferred = $.Deferred()
  balanced[type].create info, (response) =>
    if response.status == 201
      deferred.resolve(response.data)
    else
      deferred.reject(response.error)

  deferred.promise()

updateInputs = (object, $form) ->
  $form.find("[data-balanced-attribute]").each (index, el) ->
    $el = $(el)
    $el.val(object[$el.data("balanced-attribute")])

$ ->
  $("#balanced-payments-uri").submit (event) ->
    event.preventDefault()
    $form = $(event.target)
    balanced.init($form.data("balanced-marketplace-uri"))
    type = $form.data("balanced-object-type")

    $(".field_with_errors :input").unwrap()
    $('input[type="submit"]').attr("disabled", "disabled")
    tokenize(type, getFormData($form))
      .done (payment_object) ->
        $("##{type}-uri").val(payment_object.uri)
        realFormId = $form.data("target-form") || "#{type}-uri-form"
        $realForm = $("##{realFormId}")
        updateInputs(payment_object, $realForm)
        $realForm.submit()
      .fail (error) ->
        # (re-)set up error container
        if $("#balanced-js-errors").length
          $("#balanced-js-errors").html("")
        else
          $form.prepend('<ul id="balanced-js-errors" class="form-errors">')

        messages = if error.extras? then error.extras else error
        for key of messages
          field_name = key.replace(/_/g, " ")
          field_name = field_name.charAt(0).toUpperCase() + field_name.substr(1)
          $form.find("[name^=#{key}]").wrap('<div class="field_with_errors"/>')
          $("#balanced-js-errors").append("<li>#{field_name}: #{messages[key]}</li>")
      .always ->
          $('input[type="submit"]').removeAttr("disabled")
