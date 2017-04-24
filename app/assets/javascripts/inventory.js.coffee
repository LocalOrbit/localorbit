$ ->
  EditTable.build ".inventory_form"
  $(".create-inventory-note").click (e)->
      $('.overlay').addClass('is-dim');
      e.preventDefault()