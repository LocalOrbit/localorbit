$ ->
  window.per_page_paginate = ->
    $("#per_page").change ->
      $(this).submit()

  window.per_page_paginate()
