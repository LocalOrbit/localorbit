$ ->
  $('.filter-toggle').click (e) ->
    e.preventDefault()
    $('.filter-toggle').not(this).removeClass('is-open')
    $('.filter-list').not($(this.hash).get(0)).removeClass('is-open')
    $(this).toggleClass('is-open')
    $(this.hash).toggleClass('is-open')
