$ ->
  $('#registration_terms_of_service').prop('checked', false)
  $('#terms-of-service .cancel, .overlay').click ->
    $('#registration_terms_of_service').prop('checked', false)
    $(this).closest('.popup').addClass('is-hidden')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable mobile-dim')

  $('#terms-of-service .read-terms').click ->
    $(this).closest('.popup').addClass('is-hidden')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable mobile-dim')
