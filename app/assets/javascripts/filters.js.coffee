$ ->
  $('.filter-toggle').click (e) ->
    e.preventDefault()
    $('.filter-toggle').not(this).removeClass('is-open')
    $('.filter-list').not($(this.hash)).removeClass('is-open')
    $(this).toggleClass('is-open')
    $(this.hash).toggleClass('is-open')
    if $('.filter-toggle.is-open').length
      $('.overlay').addClass('is-open')
    else
      $('.overlay').removeClass('is-open')


  $('.overlay').click (e) ->
    $('.overlay').removeClass('is-open')
    $('.filter-list, .filter-toggle').removeClass('is-open')
