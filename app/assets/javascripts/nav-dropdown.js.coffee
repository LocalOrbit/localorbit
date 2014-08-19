$ ->
  $('select.nav-dropdown').change (e) ->
    window.location.pathname = $(e.target).val()
    
