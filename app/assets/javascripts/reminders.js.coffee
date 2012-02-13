# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(".mark_as_complete").live "click", ->
  element = $(this)
  form = $(this).parent("td").siblings("form")[0]
  $.ajax
    type: 'PUT'
    url: form.action
    data: {reminder : { 'delivered' : $(this).is(':checked') }}
    dataType: 'json'
    success: ->
      $('.status').show()
      $('.status').text('Saving changes')
      $('.status').fadeOut(2000)
      if element.closest("tr").hasClass("completed_row")
        element.closest("tr").removeClass "completed_row"
      else
        element.closest("tr").addClass "completed_row"

$ ->
  if ($('.ckedit').length)
    CKEDITOR.replace "reminder_body",
      toolbar : 'Basic'
