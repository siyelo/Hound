# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Reminder
  @get_params_for_update_delivered: (is_checked) ->
    { reminder: { 'delivered': is_checked } }

  @validate_cc_emails: (value)   ->
    regex = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    emails = value.trim().split(/[,;]\s*/)
    valid = true
    for i of emails
      email = emails[i]
      unless email.trim() == ''
        valid = valid and regex.test(email)
    return valid

  @mark_as_complete: (form, element) ->
    element.attr("disabled", true)
    $.ajax
      type: 'PUT'
      url: form.attr('action')
      data: Reminder.get_params_for_update_delivered element.is(':checked')
      dataType: 'json'
      complete: ->
        Reminder.mark_as_complete_callback(element)

  @mark_as_complete_callback: (element) ->
      element.attr("disabled", false)
      $('.status').show()
      $('.status').text('Saving changes')
      $('.status').fadeOut(2000)
      if element.closest("tr").hasClass("completed_row")
        element.closest("tr").removeClass "completed_row"
      else if element.is(':checked')
        element.closest("tr").addClass "completed_row"

(exports ? this).Reminder = Reminder

$(document).ready ->
  $(".subject_link").live "click", (event) ->
    event.preventDefault()
    element = $(this)
    reminder = element.parents('tr.reminder')
    reminder_row = reminder.next("tr.reminder_row")

    $('tr.reminder').removeClass('active')
    reminder.addClass('active')

    if (reminder_row.is(":visible"))
      reminder_row.hide()
    else
      $.getScript(element.attr('href') + ".js")

  $(".mark_as_complete").live "click", ->
    element = $(this)
    form = element.parents("form:first")
    Reminder.mark_as_complete(form, element)

  #Validate the form of the cc email addresses before submitting
  $('.js_submit').live "click", ->
    $('.errors').html('')
    unless Reminder.validate_cc_emails($('#reminder_other_recipients').val())
      $('.errors').html('<h3>Reminder could not be saved!</h3><p>Not all cc addresses are properly formed.</p><hr/>')
      event.preventDefault()

  $('#js_cancel').live "click", ->
    $('.inline_reminder').hide()
    return false
