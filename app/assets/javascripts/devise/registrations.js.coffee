$(document).ready ->
  $(".delete_link").live "click", ->
    event.preventDefault()
    element = $(this).parent('li')
    if confirm( 'Are you sure?')
      $.ajax
        type: 'DELETE'
        url: $(this).attr('data-link')
        success: (data, textStatus, jqXHR) ->
          element.remove()
