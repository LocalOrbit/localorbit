$ ->
  $('#registration_terms_of_service').prop('checked', false)
  
  $('#new_registration').on 'submit', ->
    $(this).find('.registration-submit').attr('disabled', true)