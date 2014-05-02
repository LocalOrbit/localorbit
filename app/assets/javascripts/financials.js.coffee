$ ->
  $('.vendor-payment .review-orders').click (e)->
    e.preventDefault()
    $(this).parents('table').siblings('table').toggleClass('is-hidden')
    $(this).parents('tr').find('.pay-all-now').toggleClass('is-invisible')

  $('.vendor-payment .pay-all-now').click (e)->
    e.preventDefault()
    $(this).parents('table').siblings('table').find('input[type=checkbox]').prop('checked', true)
    $(this).parents('form').submit()

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
