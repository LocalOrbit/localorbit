$ ->
  $('.vendor-payment .review-orders').click (e)->
    e.preventDefault()
    link = $(this)
    form = link.parents('form')
    form.find('.order-details').toggleClass('is-hidden')
    form.find('.pay-all-now').toggleClass('is-invisible')
    form.find('.pay-selected-now').removeClass('is-hidden')

    if form.find('.order-details.is-hidden').length == 0
      form.find('.pay-all-now').addClass('is-invisible')
      link.html('Hide Orders')
    else
      form.find('.pay-all-now').removeClass('is-invisible')
      link.html('Review')

    paymentFields = form.find('.payment-details').not('.is-hidden')
    if paymentFields.length != 0
      paymentFields.addClass('is-hidden')

  $('.vendor-payment .pay-all-now').click (e)->
    e.preventDefault()
    form = $(this).parents('form')
    form.find('.order-details input[type=checkbox]').prop('checked', true)
    form.find('.pay-all-now').addClass('is-invisible')
    form.find('.payment-details').removeClass('is-hidden')

  $('.vendor-payment .pay-selected-now').click (e)->
    e.preventDefault()
    element = $(this)
    element.addClass('is-hidden')
    element.parents('form').find('.payment-details').removeClass('is-hidden')

  $('.vendor-payment .cancel').click (e)->
    e.preventDefault()
    element = $(this)
    form = element.parents('form')
    form.find('.payment-details').addClass('is-hidden')
    if form.find('.order-details.is-hidden').length == 0
      form.find('.pay-selected-now').removeClass('is-hidden')
    else
      form.find('.pay-all-now').removeClass('is-invisible')

  $('.vendor-payment .seller-order-id').change (e)->
    form = $(this).parents('form')
    items = form.find('.seller-order-id')
    total = _.reduce(items, (total, elm) ->
      elm = $(elm)
      if (elm.prop('checked'))
        total + parseFloat(elm.data('owed'))
      else
        total
    , 0)
    form.find('.total-owed').html(accounting.formatMoney(total))

  $('.vendor-payment .payment-types input[type=radio]').change (e)->
    option = $(this)
    paymentDetails = option.parents('.payment-details')

    paymentDetails.find('input[type=text]').prop('disabled', true)
    paymentDetails.find('.cash').not('.is-hidden').addClass('is-hidden')
    paymentDetails.find('.check').not('.is-hidden').addClass('is-hidden')

    details = paymentDetails.find(".#{option.val()}")
    details.find('input[type=text]').prop('disabled', false)
    details.removeClass('is-hidden')

    paymentDetails.find('.record-payment').removeClass('is-hidden')

  $('.vendor-payment-cancel > .cancel').click ->
    e.preventDefault()
    form = $(this).parents('form')
    form.find('.order-details input[type=checkbox]').prop('checked', true)
    form.find('.pay-all-now').removeClass('is-invisible')
    form.find('.payment-details').addClass('is-hidden')

