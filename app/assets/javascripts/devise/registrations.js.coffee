$(document).ready ->
  $("#user_timezone").chosen()

  $("#add_alias").live "click", ->
    $(this).disabled

  $(".delete_link").live "click", (event) ->
    event.preventDefault()
    element = $(this).parent('li')
    if confirm( 'Are you sure?')
      $.ajax
        type: 'DELETE'
        url: $(this).attr('data-link')
        success: (data, textStatus) ->
          element.remove()
