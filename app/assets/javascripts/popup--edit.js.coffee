$ ->
  return unless $('.popup--edit').length

  $('.popup--edit').on "submit", (e) ->
    params = {}
    update_status = false
    $(e.target).find('input').each (i, el) ->
      params[el.name] = el.value

    update = $.post(this.action, params, (data) ->
          prefix = "#" + $(e.target).attr('data-prefix')
          response_text = data
          update_input = (pair) ->
            $(prefix + "_" + pair[0]).attr('value', pair[1])
          $('.edit-toggle[href="#' + e.target.id + '"]').text(response_text.toggle)
          update_input pair for pair in response_text.params
          $('<div class="flash flash--notice"><p>' + data.message + '</p></div>').appendTo('#flash-messages')
          error_holder = $(e.target).find('.popup-error').empty()
          $(e.target).find('.close').trigger "click"

          window.setTimeout ->
              window.fade_flash()
            , 0
        , "json")
      .fail (data) ->
        data = $.parseJSON(data.responseText)
        error_holder = $(e.target).find('.popup-error').empty()
        $('<h3>Could not save</h3>').appendTo(error_holder)
        $('<ul class="errors"></ul>').appendTo(error_holder)
        errors = $(error_holder).find('.errors')
        add_li = (text) ->
          $('<li>' + text + '</li>').appendTo(errors)
        add_li error for error in data.errors

    false


