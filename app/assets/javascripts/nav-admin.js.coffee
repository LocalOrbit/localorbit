$ -> 
  $('.caretted').click (e) ->
    e.preventDefault()
    $('.dropdown').not($(e.target).next()).parent().removeClass('is-open')
    $(e.target).parent().toggleClass('is-open')
    if $('.is-open .dropdown').length
      $('.overlay').addClass('is-open')
    else
      $('.overlay').removeClass('is-open')


  $('.overlay').click (e) ->
    console.log(e)
    $('.overlay').removeClass('is-open')
    $('.is-open .dropdown').parent().removeClass('is-open')
