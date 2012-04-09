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

  @hide_reminder_row: (reminder_row) ->
    reminder_row.addClass('hidden')
    reminder_row.prev('tr.reminder').removeClass('active')

(exports ? this).Reminder = Reminder

$(document).ready ->
  if ($('#reminder_body').length > 0)
    $('#reminder_body').tinymce
      theme: "advanced",
      theme_advanced_buttons1: "bold,italic,underline, strikethrough",
      theme_advanced_buttons2: "",
      theme_advanced_buttons3: "",
      theme_advanced_buttons4: "",
      theme_advanced_toolbar_location: "top",
      theme_advanced_toolbar_align: "left"

  $(".subject_link").live "click", (event) ->
    event.preventDefault()
    element = $(this)
    reminder = element.parents('tr.reminder')
    reminder_row = reminder.next("tr.reminder_row")

    $('tr.reminder').removeClass('active')
    reminder.addClass('active')

    if (reminder_row.hasClass('hidden'))
      $.getScript(element.attr('href') + ".js")
    else
      Reminder.hide_reminder_row(reminder_row)

  #Validate the form of the cc email addresses before submitting
  $('.js_submit').live "click", (event) ->
    element = $(this)
    errors_box = element.parents('.reminder_row').find('.errors')
    unless Reminder.validate_cc_emails($('#reminder_other_recipients').val())
      error = $('<li/>').text('Not all Cc addresses are well formatted')
      errors_box.html('').append(error)
      event.preventDefault()

  $('#js_cancel').live "click", (event) ->
    event.preventDefault()
    reminder_row = $(this).parents('tr.reminder_row')
    Reminder.hide_reminder_row(reminder_row)
