# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  if ($('.ckedit').length)
    CKEDITOR.replace "reminder_body",
      toolbar : 'Basic'

  $('.large').click ->
    window.location = $(this).parent('.reminder').attr('data_link')

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

  $('.js_submit').live "click", ->
    unless validateCc()
      alert('Reminder could not be saved! Not all cc addresses are properly formed.')
      event.preventDefault()

  validateCc =   ->
    regex = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    value = $('#reminder_cc_string').val()
    emails = value.split(/[,;]\s*/)
    valid = true
    for i of emails
      value = emails[i]
      unless value.trim() == ''
        valid = valid and regex.test(value)
    return valid

