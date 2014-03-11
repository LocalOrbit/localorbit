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

    $('input[type="submit"]').attr("disabled", "disabled")
    tokenize(type, getFormData($form))
      .done (payment_object) ->
        $("##{type}-uri").val(payment_object.uri)
        realFormId = $form.data("target-form") || "#{type}-uri-form"
        $realForm = $("##{realFormId}")
        updateInputs(payment_object, $realForm)
        $realForm.submit()
      .fail (error) ->
        for key of error
          $form.find("[name^=#{key}]").addClass("error")
      .always ->
          $('input[type="submit"]').removeAttr("disabled")
